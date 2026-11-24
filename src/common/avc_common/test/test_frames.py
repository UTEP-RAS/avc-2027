from avc_common.frames import enu_to_ned, ned_to_enu


def test_ned_to_enu_axes():
    # 1 m north, 2 m east, 3 m down -> 2 m east, 1 m north, 3 m below
    assert ned_to_enu(1.0, 2.0, 3.0) == (2.0, 1.0, -3.0)


def test_round_trip():
    p = (4.5, -1.25, 10.0)
    assert enu_to_ned(*ned_to_enu(*p)) == p
