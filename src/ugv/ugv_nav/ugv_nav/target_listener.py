"""UGV target listener (stub).

Receives the UAV's target report. Later this hands the goal to Nav2.
"""

import rclpy
from rclpy.node import Node

from avc_common.qos import TARGET_REPORT_QOS, TARGET_REPORT_TOPIC
from avc_interfaces.msg import TargetReport


class TargetListener(Node):
    def __init__(self):
        super().__init__('target_listener')
        self.declare_parameter('min_confidence', 0.5)
        self._sub = self.create_subscription(
            TargetReport, TARGET_REPORT_TOPIC, self._on_target, TARGET_REPORT_QOS)

    def _on_target(self, msg: TargetReport):
        min_conf = self.get_parameter('min_confidence').value
        if msg.confidence < min_conf:
            self.get_logger().warn(f'Ignoring target {msg.target_id}: confidence {msg.confidence:.2f}')
            return
        p = msg.position
        self.get_logger().info(
            f'Target {msg.target_id} at ({p.x:.2f}, {p.y:.2f}, {p.z:.2f}) in '
            f'"{msg.header.frame_id}", conf {msg.confidence:.2f}')
        # TODO: send a NavigateToPose goal to Nav2


def main(args=None):
    rclpy.init(args=args)
    node = TargetListener()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.try_shutdown()


if __name__ == '__main__':
    main()
