"""Full mission: UAV + UGV together.

Next steps: start Gazebo with avc_worlds/worlds/field.sdf (ros_gz_sim) and PX4 SITL here,
so this one launch runs the whole competition run in sim.
"""

import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource


def _include(pkg, launch_file):
    path = os.path.join(get_package_share_directory(pkg), 'launch', launch_file)
    return IncludeLaunchDescription(PythonLaunchDescriptionSource(path))


def generate_launch_description():
    return LaunchDescription([
        _include('uav_bringup', 'uav.launch.py'),
        _include('ugv_bringup', 'ugv.launch.py'),
    ])
