# avc-2027

IEEE RAS UTEP Miners: UAV + UGV software for the Raytheon Autonomous Vehicle Competition.
ROS 2 Jazzy, one colcon workspace for both vehicles.

## Layout
```
src/
├── common/   avc_interfaces (msgs, the contract) · avc_common (frames, QoS)
├── uav/      uav_mission · uav_bringup
├── ugv/      ugv_nav · ugv_bringup
└── sim/      avc_worlds · avc_mission_sim (end-to-end launch)
firmware/     Pico 2 firmware (pico-sdk, not built by colcon)
docs/         interfaces, frames, bring-up checklist
docker/       shared dev image (amd64 + arm64)
```

## Quickstart (dev container)
```bash
docker build -f docker/Dockerfile -t avc-dev .
docker run -it --rm --network=host -v "$PWD":/ws avc-dev
# inside the container:
colcon build --symlink-install
source install/setup.bash
ros2 launch avc_mission_sim mission.launch.py
```
You should see the UGV log the fake target the UAV publishes.

## Building one vehicle only
```bash
colcon build --packages-up-to uav_bringup   # on the drone
colcon build --packages-up-to ugv_bringup   # on the rover
```

## Rules
1. Changes to `avc_interfaces` update both vehicles in the same PR.
2. No direct pushes to `main`: PR + green CI + one review.
3. Code freeze before competition. No exceptions, no rewrites the night before.
