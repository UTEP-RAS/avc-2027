# Coordinate frames

- **ROS side is ENU** (x = East, y = North, z = Up), per REP 103.
- **The flight controller is NED** (x = North, y = East, z = Down).
- Convert **only** with `avc_common.frames`, and only at the flight-controller boundary.

## Frame tree
<!-- Fill in once the hardware is final. -->
```
map
└── odom
    └── base_link
        ├── camera_link
        └── imu_link
```

Every `TargetReport` carries its frame in `header.frame_id`. A message with an empty frame_id is a bug.
