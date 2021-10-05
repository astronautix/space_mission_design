import space_mission_design
from space_mission_design.celestlab import celestlab_wrapper
from space_mission_design.visualisation import ploting_map

import numpy as np
import matplotlib.pyplot as plt
plt.style.use("presentation")

from astropy import units as u

from poliastro.bodies import Earth, Mars, Sun
from poliastro.twobody import Orbit
from tqdm.auto import tqdm
import os

from space_mission_design.power import body_illumination

wrapper = celestlab_wrapper.WrapperCelestlab(scilab_path="/home/tavant/Data/tavant/CSE-perso/tools/CNES/scilab-6.0.2/bin/",
                                             celestlab_loader="/home/tavant/Data/tavant/CSE-perso/IonSat/power/loader_celestlab.sce")

print("Small example : propagate and plot")
specitic_params = {"year":2024, "hour":12, "inc": 51*np.pi/180, "sma": (Earth.R_mean + 300 * u.km).to(u.m).value,
                   "outputFileName":"results_ionsat.h5" }

wrapper.write_paramerter_file(specitic_params)
wrapper.launch_celestlab("ionsat_power.sce")

sun_position, ecf_position, eclipses, cj_date = wrapper.read_celestlab_results("results_ionsat.h5")

ploting_map.plot_planisphere(ecf_position)

ploting_map.plot_poles(ecf_position)
plt.show()
# plt.savefig("map_51deg.png", dpi=300)
