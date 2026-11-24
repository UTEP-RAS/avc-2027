# UAV -> UGV target handoff. Published on /avc/target_report.
# Changing this file changes the contract for BOTH vehicles: update both sides in the same PR.

# Where the target came from
uint8 SOURCE_ARUCO=0
uint8 SOURCE_YOLO=1

# header.stamp    = time the target was observed (not publish time)
# header.frame_id = frame `position` is expressed in (ENU, e.g. "map"). Never NED.
std_msgs/Header header

uint32 target_id
geometry_msgs/Point position
float32 confidence      # 0.0 - 1.0
uint8 source
