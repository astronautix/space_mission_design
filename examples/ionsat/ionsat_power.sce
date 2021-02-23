// run with PYTHONHOME=/usr/bin LIBGL_ALWAYS_SOFTWARE=1 scilab -f crocus_power.sce


disp("stating the script")

celestlab_loarder_path = getenv("Celestlab_loader", "loader_celestlab.sce")

disp("celestlab loader file :")
disp(celestlab_loarder_path)

exec(celestlab_loarder_path, 2) // mode 2 without line prompts

doPlots = %F
// =====================================================
// Satellite ephemeris
// The orbit is approximately frozen and Sun-synchronous
// Initial mean local time of ascending node (MLTAN) = 10h30
// =====================================================

disp("loading the parameters")

file_input_parameters = mopen('parameters.txt',"r")

// Date/time of orbital elements (TREF)
date_parameters = mgetl(file_input_parameters, 5)
year = evstr(date_parameters(1))
month = evstr(date_parameters(2))
day = evstr(date_parameters(3))
hour = evstr(date_parameters(4))
minutes = evstr(date_parameters(5))

cjd0 = CL_dat_cal2cjd(year,month,day,hour,minutes,0);

// Keplerian mean orbital elements, frame = ECI
sma = 7200.e3; // semi major axis
ecc = 1.e-3;   // eccentricity
inc = 98 * %pi/180; // inclination
pom = %pi/2; // Argument of perigee
mlh = 10.5; // MLTAN (hours) (mean local time of ascending node))
anm = 0; // Mean anomaly

// Overwrite the values by the inputfile
orb_parameters = mgetl(file_input_parameters, 5)
sma = evstr(orb_parameters(1))
ecc = evstr(orb_parameters(2))
inc = evstr(orb_parameters(3))
mlh = evstr(orb_parameters(4))
anm = evstr(orb_parameters(5))

gom = CL_op_locTime(cjd0, "mlh", mlh, "ra"); // RAAN

kep0 = [sma; ecc; inc; pom; gom; anm];

// Simulation dates/times (duration = 1 day)
num_parameters = mgetl(file_input_parameters, 2)
disp(num_parameters)
number_days = evstr(num_parameters(1))
timestep = evstr(num_parameters(2))

disp(number_days)
cjd = cjd0 + (0 : 3/86400 : number_days);

//output file
save_parameters = mgetl(file_input_parameters, 1)
disp(save_parameters)
outputfile = save_parameters(1)

disp("starting propagation for ")
disp(number_days)
disp("days")

// Propagate with "lydlp" model (output = osculating elements)
kep = CL_ex_propagate("lydlp", "kep", cjd0, kep0, cjd, "o");

disp("processing and saving data")
// Position and velocity in ECI
[pos_eci, vel_eci] = CL_oe_kep2car(kep);

// Position in ECF
pos_ecf = CL_fr_convert("ECI", "ECF", cjd, pos_eci);


// =====================================================
// Other data
// =====================================================

// Ground stations geodetic coordinates:
// longitude (rad), latitude (rad), altitude (m)
sta1 = [1.499*%pi/180; 43.43*%pi/180; 154.0];
sta2 = [-52.64*%pi/180; 5.1*%pi/180; 94.0];

// Earth->Sun and Earth->Moon in ECI
Sun_eci = CL_eph_sun(cjd);
Moon_eci = CL_eph_moon(cjd);

// =====================================================
// Ground stations visibility
// =====================================================

// Min elevation for visibility
min_elev = 10 * %pi/180;

// Computation of visibility intervalsanti_aliasing
[tvisi1] = CL_ev_stationVisibility(cjd, pos_ecf, sta1, min_elev);
[tvisi2] = CL_ev_stationVisibility(cjd, pos_ecf, sta2, min_elev);



// =====================================================
// (geocentric) Longitude/latitude plot
// =====================================================

if doPlots then
   scf();

   // Plot Earth map
   CL_plot_earthMap(color_id=color("seagreen"));

   // Plot ground tracks
   CL_plot_ephem(pos_ecf, color_id=color("grey50"));

   xtitle("Ground Tracks", "Longitude", 'Latitude')
   // BetterPlot()
   xs2svg(gcf(),'groundtracks.svg');
else
   save(outputfile, "pos_ecf", "-append")
end
// =====================================================
// Sun and Moon  in Satellite frame
// Satellite frame supposed to be "qsw" (radius, velocity, orb)
// =====================================================

M_eci2sat = CL_fr_qswMat(pos_eci, vel_eci);

// Satellite->Sun and satellite->Moon directions
Sun_dir = M_eci2sat * CL_unitVector(Sun_eci - pos_eci);
Moon_dir = M_eci2sat * CL_unitVector(Moon_eci - pos_eci);


 if doPlots then

   // Plot angles
   f=scf();
   plot(cjd-cjd0, CL_vectAngle(Sun_dir, [0;0;1])*180/%pi, "r", "thickness", 2);
   plot(cjd-cjd0, CL_vectAngle(Sun_dir, [1;0;0])*180/%pi, "b", "thickness", 2);

   plot(cjd-cjd0, CL_vectAngle(Sun_dir, [0;1;0])*180/%pi, "g", "thickness", 2);
   xtitle("Angle with satellite frame axis (deg)", "Days");
   CL_g_legend(gca(), ["Sun <-> Z", "Sun <-> X", "Sun <-> Y"]);
   // CL_g_stdaxes();

   // BetterPlot()
else
   save(outputfile, "cjd", 'Sun_dir' , "-append")

end


// =====================================================
// Eclipse periods of Sun by Earth
// =====================================================

// Eclipse intervals (umbra)
interv = CL_ev_eclipse(cjd, pos_eci, Sun_eci, typ = "umb");

 if doPlots then
   // Plot
   scf();

   dur = (interv(2,:) - interv(1,:)) * 1440; // min
   x = [interv(1,:); interv; interv(2,:); %nan * interv(1,:)] - cjd0;
   y = [zeros(dur); dur; dur; zeros(dur); %nan * ones(dur)];
   plot(x(:)', y(:)', "thickness", 2);
   // title("Time in Earth Shadow", 'font_style',10)
   xtitle("Time in Earth shadow", "Days", "Length (min)" );

   // CL_g_stdaxes();

   // BetterPlot()
   df=gcf()
   // df.anti_aliasing="8x"
    axes_entity = df.children;
   // title_entity = axes_entity.children;
   // title_entity.font_style = 10;

   x_label = axes_entity.x_label;
   x_label.font_style=10;
   // x_label.font_size=10;
   y_label = axes_entity.y_label;
   y_label.font_style=10;
   // y_label.font_size=10;
   x_label.text=" Weight"
   xs2svg(gcf(),'eclips.svg');

else
   save(outputfile, "interv", 'Sun_dir' , "-append")

end

disp("Script finished")
disp("exiting scilab")
exit;
