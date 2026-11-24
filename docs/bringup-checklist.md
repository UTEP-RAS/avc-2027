# Hardware bring-up checklist

Run this top to bottom when a vehicle is first assembled and after any rewiring.

## Both vehicles
- [ ] Pi 5 boots, connects to the team network, `ros2 topic list` works from a laptop
- [ ] Pico 2 enumerates on the Pi over USB, and its link to the Pi reconnects after a replug
- [ ] Pi 5 holds temperature under load with the active cooler (no thermal throttling during a full run)
- [ ] Camera streams; intrinsics calibration loaded
- [ ] IMU publishes at the expected rate, orientation looks right when you tilt it
- [ ] Every sensor topic has a heartbeat, and killing it triggers the watchdog
- [ ] rosbag recording starts automatically

## UGV
- [ ] Each motor spins the right direction at low PWM
- [ ] Encoders count in the right direction; unplugging one is detected
- [ ] E-stop cuts the motors

## UAV
- [ ] Flight controller connected, frame conversion checked (push the drone north → +y in ROS)
- [ ] Failsafes configured and tested props-off
