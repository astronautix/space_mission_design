====================
Space mission design
====================


.. image:: https://img.shields.io/pypi/v/space_mission_design.svg
        :target: https://pypi.python.org/pypi/space_mission_design

.. image:: https://img.shields.io/travis/antoinetavant/space_mission_design.svg
        :target: https://travis-ci.com/antoinetavant/space_mission_design

.. image:: https://readthedocs.org/projects/space-mission-design/badge/?version=latest
        :target: https://space-mission-design.readthedocs.io/en/latest/?badge=latest
        :alt: Documentation Status


.. image:: https://pyup.io/repos/github/antoinetavant/space_mission_design/shield.svg
     :target: https://pyup.io/repos/github/antoinetavant/space_mission_design/
     :alt: Updates



A Python package to design space mission.


* Free software: MIT license
* Documentation: https://space-mission-design.readthedocs.io.

Description
--------

The package launch scilab to use the Celestlab tool developed by CNES.
Hence, you need to provide it with the path for celestlab and scilab.

A scilab script is launch to propagate the orbit and compute useful data.
All is stored in a HDF5 file to be then loaded on python.

Then, all the processes are done in python.

How to use
---------

Load the package

```
from space_mission_design.celestlab import celestlab_wrapper
from space_mission_design.visualisation import ploting_map
```

Initialize the wrapper with the needed infos

```
wrapper = celestlab_wrapper.WrapperCelestlab(scilab_path=<path to scilab bin>,
                                             celestlab_loader=<path to the scilab celestlab loader script>)
```

The celestlab script should be modified to set the absolute path of the `start` script. The default `loader.sce` script is not meant to be loaded from another working directory.
More precisely, I propose to modify the `loader.sce` script with :

```
[...]
try
      exec(<celestlab installation directory>+"etc/"+"celestlab.start");
[...]
```

Then, you can launch the analyse :

```
import matplotlib.pyplot as plt

wrapper.write_paramerter_file()
wrapper.launch_celestlab("ionsat_power.sce")

sun_position, cj_date, ecf_position, eclipses = wrapper.read_celestlab_results()

ploting_map.plot_planisphere(ecf_position)

ploting_map.plot_poles(ecf_position)
plt.show()
```

Here, the script "ionsat_power.sce" is the one present in the folder `example/ionsat/`.


Features
--------

* TODO

Credits
-------

This package was created with Cookiecutter_ and the `audreyr/cookiecutter-pypackage`_ project template.

.. _Cookiecutter: https://github.com/audreyr/cookiecutter
.. _`audreyr/cookiecutter-pypackage`: https://github.com/audreyr/cookiecutter-pypackage
