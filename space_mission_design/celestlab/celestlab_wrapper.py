import numpy as np
from numpy.linalg import norm
import h5py as hp

import subprocess


def get_default_params():
    """return a dict ith the parameters that can be used in celestlab"""
    params = {
        "year": 2020,
        "month": 6,
        "day": 15,
        "hour": 12,
        "minutes": 30,
        "outputFileName": "results.h5",
        "sma": 7200.0e3,  # semi  major axis
        "ecc": 1.0e-3,  # eccentricity
        "inc": 98 * np.pi / 180,  # inclination
        "pom": np.pi / 2,  # Argument of perigee
        "mlh": 10.5,  # MLTAN(hours)(mean  local  time of ascending node))
        "anm": 0,  # Mean   anomaly
        "number_days": 1,  # the total number of days simulated
        "timestep": 3 / 86400,  # The time step of the simulations
    }

    return params


def write_paramerter_file(other_params):
    """Write the parameter_file that is used in CelestLab.
    Celestlab i/o is shit, so the order of the parameters given is very important"""

    params = get_default_params()

    for k, v in other_params.items():
        if k in params:
            params[k] = v
        else:
            raise RuntimeError(
                f"Parameter {k} is not understood. \n Available parameters are {params.keys()}"
            )

    filename = "./parameters.txt"

    parameter_key_list = [
        "year",
        "month",
        "day",
        "hour",
        "minutes",
        "sma",
        "ecc",
        "inc",
        "mlh",
        "anm",
        "number_days",
        "timestep",
    ]

    with open(filename, "w") as f:
        for k in parameter_key_list:
            f.write(f"{params[k]}\n")


def launch_celestlab():
    """launch the celestlab script with subprocess"""

    command = "/home/tavant/Documents/CSE-perso/tools/CNES/scilab-6.0.2/bin/scilab -nw -f crocus_power.sce "
    env = {
        "LIBGL_ALWAYS_SOFTWARE": "1"
    }  # Should be used to disable the hardware accelleration of libGL used by Scilab

    p = subprocess.Popen(command.split())
    p.wait()


def read_celestlab_results(filename="./results.h5"):
    """The celestlab script dumps the results in a HDF5 file. """

    with hp.File(filename, "r") as f:
        # print(f.keys())
        sun_dir = f["Sun_dir"][()]
        cjd = f["cjd"][()]
        pos_ecf = f["pos_ecf"][()]
        eclipses = f["interv"][()]

    cjd = cjd[:, 0]

    return sun_dir, cjd, pos_ecf, eclipses
