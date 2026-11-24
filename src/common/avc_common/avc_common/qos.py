"""Shared QoS profiles. Publisher and subscriber must use compatible QoS or they never connect."""

from rclpy.qos import DurabilityPolicy, HistoryPolicy, QoSProfile, ReliabilityPolicy

# Target handoff: reliable, and a UGV that joins late (reboot, Wi-Fi drop)
# still receives the last target the UAV published.
TARGET_REPORT_QOS = QoSProfile(
    history=HistoryPolicy.KEEP_LAST,
    depth=1,
    reliability=ReliabilityPolicy.RELIABLE,
    durability=DurabilityPolicy.TRANSIENT_LOCAL,
)

TARGET_REPORT_TOPIC = '/avc/target_report'
