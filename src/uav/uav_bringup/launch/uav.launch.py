import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description():
    params = os.path.join(get_package_share_directory('uav_bringup'), 'config', 'uav_params.yaml')

    return LaunchDescription([
        Node(
            package='uav_mission',
            executable='mission_node',
            namespace='uav',
            parameters=[params],
            output='screen',
        ),
    ])
