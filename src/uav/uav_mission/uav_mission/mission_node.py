"""UAV mission node (stub).

For now it publishes a fake target so the UAV -> UGV handoff can be tested end to end.
Replace `_detect_target` with the real perception pipeline later.
"""

import rclpy
from rclpy.node import Node

from avc_common.qos import TARGET_REPORT_QOS, TARGET_REPORT_TOPIC
from avc_interfaces.msg import TargetReport


class MissionNode(Node):
    def __init__(self):
        super().__init__('uav_mission')
        self.declare_parameter('publish_rate_hz', 1.0)
        self.declare_parameter('fake_target_xyz', [3.0, 2.0, 0.0])

        rate = self.get_parameter('publish_rate_hz').value
        self._pub = self.create_publisher(TargetReport, TARGET_REPORT_TOPIC, TARGET_REPORT_QOS)
        self._timer = self.create_timer(1.0 / rate, self._tick)
        self.get_logger().info(f'Publishing fake targets on {TARGET_REPORT_TOPIC} at {rate} Hz')

    def _detect_target(self):
        x, y, z = self.get_parameter('fake_target_xyz').value
        return x, y, z, 0.9

    def _tick(self):
        x, y, z, conf = self._detect_target()
        msg = TargetReport()
        msg.header.stamp = self.get_clock().now().to_msg()
        msg.header.frame_id = 'map'
        msg.target_id = 0
        msg.position.x, msg.position.y, msg.position.z = float(x), float(y), float(z)
        msg.confidence = float(conf)
        msg.source = TargetReport.SOURCE_ARUCO
        self._pub.publish(msg)


def main(args=None):
    rclpy.init(args=args)
    node = MissionNode()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.try_shutdown()


if __name__ == '__main__':
    main()
