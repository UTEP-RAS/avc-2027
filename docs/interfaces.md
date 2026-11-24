# Interfaces

The contract between vehicles. If you change anything here, update both sides in the **same PR**.

| Topic | Type | Publisher | Subscriber | QoS |
|---|---|---|---|---|
| `/avc/target_report` | `avc_interfaces/TargetReport` | `/uav/uav_mission` | `/ugv/target_listener` | reliable, transient_local, depth 1 |

## Namespaces
- Everything on the drone lives under `/uav`, everything on the rover under `/ugv`.
- Cross-vehicle topics live under `/avc`.

## QoS
Shared profiles are in `avc_common/qos.py`. Import them instead of hand-rolling QoS. Mismatched QoS means the topics silently never connect.
