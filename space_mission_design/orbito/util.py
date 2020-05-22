from astropy import units as u
from poliastro.bodies import Earth
from poliastro.twobody import Orbit
from astropy import time
from datetime import date
from poliastro.ephem import Ephem

def obrit_from_vectors(r, v, epoch=None):
    """ Return an Orbit from the Vector (Position and Velocity)"""
    if epoch is None:
        today = date.today()
        epoch = time.Time(today.strftime("%Y-%m-%d")+" 12:00")  # UTC by default
    return Orbit.from_vectors(Earth, r, v)


def get_earth_ephem(epoch=None):

    if epoch is None:
        today = date.today()
        epoch = time.Time(today.strftime("%Y-%m-%d") + " 12:00")  # UTC by default

    earth_eph = Ephem.from_body(Earth, epoch.tdb)

    return earth_eph
