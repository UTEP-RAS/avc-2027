# Firmware (Raspberry Pi Pico 2 / RP2350)

Real-time layer: motor PWM, encoder counting, IMU polling, e-stop. The Pi 5 handles
everything else and talks to the Pico over USB serial.

```
firmware/
├── ugv_pico/   rover motor control board
└── uav_pico/   drone payload / aux board (if used)
```

Built with the Pico SDK (CMake), not colcon. `COLCON_IGNORE` in this folder keeps
`colcon build` from trying to build it.

Because it lives in the same repo, a change to the Pi <-> Pico protocol updates both
sides in the same PR, the same rule as `avc_interfaces`.
