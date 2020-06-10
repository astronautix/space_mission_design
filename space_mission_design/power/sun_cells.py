import numpy as np


class Cell():
    """Caracteristic of a sun cell"""

    def __init__(self, area, efficiency):
        self.area = area  #: aera of one sun cell, in m²
        self.efficiency = efficiency  #: efficiency of the sun cell (light to electrical power generation)
        self.sunConstant = 1367   #: power per area generated for Spectrum of solar cell, in W/m²

    def power(self):
        """return the power (W) of one cell, without the sun direction taking into account"""

        return self.area * self.efficiency * self.sunConstant

class SolarPanel():
    """A solar panel is contitutied of several suncell"""

    def __init__(self, number_cell, area=30.18e-4, efficiency=27.8/100):
        self.cells = Cell(area, efficiency)
        self.number_cell = number_cell  #: the number of cell on the pannel. Usually 4 for 2U, 7 for 3U

    def power(self):
        """return the power (W) of the panel, without the sun direction taking into account"""
        return self.cells.power() * self.number_cell
