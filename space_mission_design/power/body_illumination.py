import matplotlib.pyplot as plt
import numpy as np
from numpy.linalg import norm


def sundir_coef_velocity(sundir):
    return sundir_coef_any(sundir, np.array([0, 1, 0]))


def sundir_coef_radial(sundir):
    return sundir_coef_any(sundir, np.array([1, 0, 0]))


def sundir_coef_orb(sundir):
    return sundir_coef_any(sundir, np.array([0, 0, 1]))


def sundir_coef_any(sundir, vector):
    vector = np.true_divide(vector, norm(vector))

    coef = np.dot(sundir, vector)

    return coef


def sun_angle_radial(sun_dir):
    """Calculate the angle of the sun direction in the plane of 'rouli'"""

    alpha = np.arccos(sun_dir[:, 0])

    return alpha


def faces_sun_direction_coef(sundir, rouli):
    """compute the sun illumination factor of the four faces for any rouli angle.
    This can be used if the attitude in velocity pointing

    rouli :: radian """

    faceA_normal = np.array([np.cos(rouli), 0, np.sin(rouli)])
    faceB_normal = np.array([-np.sin(rouli), 0, np.cos(rouli)])
    faceC_normal = np.array([-np.cos(rouli), 0, -np.sin(rouli)])
    faceD_normal = np.array([np.sin(rouli), 0, -np.cos(rouli)])

    return (
        sundir_coef_any(sundir, faceA_normal),
        sundir_coef_any(sundir, faceB_normal),
        sundir_coef_any(sundir, faceC_normal),
        sundir_coef_any(sundir, faceD_normal),
    )


def faces_sun_direction_illumination(sundir, rouli):
    """compute the sun illumination factor of the four faces for any rouli angle
    is zero is the sun if on the wrong size
    This can be used if the attitude in velocity pointing


    rouli :: radian """

    faceA, faceB, faceC, faceD = faces_sun_direction_coef(sundir, rouli)
    faceA[faceA < 0] = 0
    faceB[faceB < 0] = 0
    faceC[faceC < 0] = 0
    faceD[faceD < 0] = 0

    return faceA, faceB, faceC, faceD


def sunview_factor(cj_date, eclipses):
    """Compute weither the we are is view of the sun or not (i.e. Eclipse) """

    sunview = np.ones_like(cj_date)

    for interval in eclipses:
        # print(interval)
        mask = (cj_date > interval[0]) & (cj_date < interval[1])
        sunview[mask] = 0

    sunview[0] = sunview[1]
    sunview[-1] = sunview[-2]

    return sunview


def eclipse_duration(eclipses):
    """compute the duration of the eclips in minutes"""
    dur = (eclipses[:, 1] - eclipses[:, 0]) * 1440
    return dur


def mean_power_face(face_illumination, pannel, eclipses=None):
    """compute the mean power """
    if eclipses is None:
        mean_power = np.mean(face_illumination * pannel.power())
    else:
        mean_power = np.mean(eclipses * face_illumination * pannel.power())

    return mean_power


def mean_power_sat(sundir, rouli, pannel, eclipses=None):
    """return the mean power of the satellite"""

    faces_illuminations = faces_sun_direction_illumination(sundir, rouli)

    return np.sum([mean_power_face(f, pannel, eclipses) for f in faces_illuminations])
