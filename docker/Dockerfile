# Shared dev image. Official ros images are multi-arch (amd64 + arm64),
# so this builds the same on WSL2, Apple Silicon, and the Raspberry Pi 5s.
# Build from the repo root:  docker build -f docker/Dockerfile -t avc-dev .
FROM ros:jazzy-ros-base

RUN apt-get update && apt-get install -y --no-install-recommends \
        git python3-pip python3-pytest vim \
    && rm -rf /var/lib/apt/lists/*

# Install every package's rosdep dependencies at image build time.
COPY src/ /tmp/src/
RUN apt-get update \
    && rosdep update --rosdistro jazzy \
    && rosdep install --from-paths /tmp/src --ignore-src -y --rosdistro jazzy \
    && rm -rf /var/lib/apt/lists/* /tmp/src

RUN echo 'source /opt/ros/jazzy/setup.bash' >> /etc/bash.bashrc \
    && echo '[ -f /ws/install/setup.bash ] && source /ws/install/setup.bash' >> /etc/bash.bashrc

WORKDIR /ws
CMD ["bash"]
