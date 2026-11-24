"""Frame conversions.

ROS uses ENU (x=East, y=North, z=Up). PX4/ArduPilot use NED (x=North, y=East, z=Down).
Every value crossing the flight-controller boundary goes through these functions,
so the conversion lives in exactly one place.
"""


def ned_to_enu(x: float, y: float, z: float) -> tuple[float, float, float]:
    return (y, x, -z)


def enu_to_ned(x: float, y: float, z: float) -> tuple[float, float, float]:
    # The swap is its own inverse.
    return (y, x, -z)
