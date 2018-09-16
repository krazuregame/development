"""
This driver does not do any action.
"""
from rose.common import obstacles, actions  # NOQA

driver_name = "CosmosWillBeGooD"


def drive(world):
    return actions.NONE
