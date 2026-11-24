#!/usr/bin/env bash
# AVC 2027 simulation environment for Ubuntu 24.04 (arm64 VM or x86_64 desktop).
#
# Installs:  ROS 2 Jazzy (desktop + dev tools), ros_gz (Gazebo Harmonic),
#            PX4 SITL, px4_msgs, Micro XRCE-DDS Agent
# Builds:    ~/px4_ws (px4_msgs + agent) and ~/avc-2027 if it's cloned there
#
# Safe to re-run: each step skips work that's already done.
# Usage:     bash scripts/setup-sim-ubuntu.sh
# Override versions/paths with env vars, e.g.  PX4_DIR=~/src/px4 bash scripts/setup-sim-ubuntu.sh

set -euo pipefail

# Pinned versions. PX4, px4_msgs and the agent must move together.
PX4_VERSION="${PX4_VERSION:-v1.18.0}"
PX4_MSGS_BRANCH="${PX4_MSGS_BRANCH:-release/1.18}"
XRCE_AGENT_VERSION="${XRCE_AGENT_VERSION:-v2.4.3}"   # the version PX4 pairs with ROS 2 Jazzy

PX4_DIR="${PX4_DIR:-$HOME/PX4-Autopilot}"
PX4_WS="${PX4_WS:-$HOME/px4_ws}"
AVC_WS="${AVC_WS:-$HOME/avc-2027}"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[warn] %s\033[0m\n' "$*"; }
die()  { printf '\033[1;31m[error] %s\033[0m\n' "$*" >&2; exit 1; }

# --------------------------------------------------------------------------
# 0. Preflight
# --------------------------------------------------------------------------
[[ $EUID -ne 0 ]] || die "Run as your normal user, not root. The script calls sudo when it needs to."
# shellcheck disable=SC1091
. /etc/os-release
[[ "${VERSION_CODENAME:-}" == "noble" ]] || die "Needs Ubuntu 24.04 (noble); found ${PRETTY_NAME:-unknown}."
step "Preflight: $(uname -m), ${PRETTY_NAME}"

sudo apt-get update
sudo apt-get install -y curl git software-properties-common locales mesa-utils

if glxinfo -B 2>/dev/null | grep -qi llvmpipe; then
  warn "OpenGL is software-rendered (llvmpipe). Gazebo will crawl; fix 3D acceleration first."
fi

if [[ -f /etc/apt/sources.list.d/ubuntu.sources ]] \
   && ! grep -q 'noble-updates' /etc/apt/sources.list.d/ubuntu.sources; then
  warn "noble-updates isn't in your apt sources; ros-dev-tools may fail to install."
  warn "Fix: set 'Suites: noble noble-updates noble-backports' in /etc/apt/sources.list.d/ubuntu.sources"
fi

# --------------------------------------------------------------------------
# 1. Locale (ROS needs UTF-8)
# --------------------------------------------------------------------------
step "Locale"
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# --------------------------------------------------------------------------
# 2. ROS 2 apt repository
# --------------------------------------------------------------------------
step "ROS 2 apt repository"
sudo add-apt-repository -y universe
if ! dpkg -s ros2-apt-source >/dev/null 2>&1; then
  ROS_APT_SOURCE_VERSION=$(curl -fsSL https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest \
    | grep -F '"tag_name"' | awk -F'"' '{print $4}')
  [[ -n "$ROS_APT_SOURCE_VERSION" ]] || die "Couldn't look up the ros-apt-source version (GitHub API)."
  curl -fL -o /tmp/ros2-apt-source.deb \
    "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.${UBUNTU_CODENAME:-${VERSION_CODENAME}}_all.deb"
  sudo dpkg -i /tmp/ros2-apt-source.deb
else
  echo "ros2-apt-source already installed"
fi

# --------------------------------------------------------------------------
# 3. ROS 2 Jazzy + ros_gz
# --------------------------------------------------------------------------
step "ROS 2 Jazzy desktop, dev tools, ros_gz"
sudo apt-get update
sudo apt-get install -y ros-jazzy-desktop ros-dev-tools ros-jazzy-ros-gz python3-pip
[[ -f /etc/ros/rosdep/sources.list.d/20-default.list ]] || sudo rosdep init
rosdep update --rosdistro jazzy

# --------------------------------------------------------------------------
# 4. PX4 SITL (+ Gazebo Harmonic via PX4's own setup script)
# --------------------------------------------------------------------------
step "PX4 ${PX4_VERSION}"
if [[ ! -d "$PX4_DIR/.git" ]]; then
  git clone --recursive --branch "$PX4_VERSION" https://github.com/PX4/PX4-Autopilot.git "$PX4_DIR"
else
  warn "$PX4_DIR exists; leaving it at $(git -C "$PX4_DIR" describe --tags --always)"
fi

# --no-nuttx skips the flight-controller cross-compiler; we only need SITL here.
bash "$PX4_DIR/Tools/setup/ubuntu.sh" --no-nuttx

# Build SITL with ROS paths stripped, so PX4's CMake picks up the system Gazebo
# rather than anything from /opt/ros if this shell already sources ROS.
( cd "$PX4_DIR" && env -u AMENT_PREFIX_PATH -u CMAKE_PREFIX_PATH -u ROS_DISTRO make px4_sitl )

# --------------------------------------------------------------------------
# 5. px4_msgs + Micro XRCE-DDS Agent workspace
# --------------------------------------------------------------------------
step "px4_msgs (${PX4_MSGS_BRANCH}) + XRCE-DDS Agent (${XRCE_AGENT_VERSION}) -> $PX4_WS"
mkdir -p "$PX4_WS/src"
[[ -d "$PX4_WS/src/px4_msgs" ]] || \
  git clone --branch "$PX4_MSGS_BRANCH" https://github.com/PX4/px4_msgs.git "$PX4_WS/src/px4_msgs"
[[ -d "$PX4_WS/src/Micro-XRCE-DDS-Agent" ]] || \
  git clone --branch "$XRCE_AGENT_VERSION" https://github.com/eProsima/Micro-XRCE-DDS-Agent.git \
    "$PX4_WS/src/Micro-XRCE-DDS-Agent"
(
  set +u   # ROS setup scripts reference unset variables
  # shellcheck disable=SC1091
  source /opt/ros/jazzy/setup.bash
  cd "$PX4_WS"
  colcon build --symlink-install
)

# --------------------------------------------------------------------------
# 6. avc-2027 workspace (if cloned)
# --------------------------------------------------------------------------
if [[ -d "$AVC_WS/src" ]]; then
  step "Building $AVC_WS"
  (
    set +u
    # shellcheck disable=SC1091
    source /opt/ros/jazzy/setup.bash
    # shellcheck disable=SC1091
    source "$PX4_WS/install/setup.bash"
    cd "$AVC_WS"
    rosdep install --from-paths src --ignore-src -y --rosdistro jazzy
    colcon build --symlink-install
  )
else
  warn "No repo at $AVC_WS. Clone avc-2027 there (or set AVC_WS) and re-run to build it."
fi

# --------------------------------------------------------------------------
# 7. Shell setup
# --------------------------------------------------------------------------
step "Shell setup (~/.bashrc)"
MARK_BEGIN="# >>> avc-2027 sim env >>>"
if ! grep -qF "$MARK_BEGIN" ~/.bashrc; then
  cat >> ~/.bashrc <<EOF

$MARK_BEGIN
source /opt/ros/jazzy/setup.bash
[ -f "$PX4_WS/install/setup.bash" ] && source "$PX4_WS/install/setup.bash"
[ -f "$AVC_WS/install/setup.bash" ] && source "$AVC_WS/install/setup.bash"
export PX4_DIR="$PX4_DIR"
# <<< avc-2027 sim env <<<
EOF
  echo "Added ROS/PX4/AVC sourcing to ~/.bashrc"
else
  echo "Shell setup already in ~/.bashrc"
fi

step "Done. Open a NEW terminal, then check each piece:"
cat <<'EOF'
  1. Drone in Gazebo:      cd $PX4_DIR && make px4_sitl gz_x500
  2. XRCE agent (new tab): MicroXRCEAgent udp4 -p 8888
  3. PX4 topics in ROS:    ros2 topic list | grep /fmu/
  4. AVC handoff:          ros2 launch avc_mission_sim mission.launch.py
EOF
