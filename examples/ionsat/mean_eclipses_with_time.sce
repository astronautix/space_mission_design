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

gom0 = CL_op_locTime(cjd0, "mlh", mlh, "ra"); // RAAN

kep0 = [sma; ecc; inc; pom; gom0; anm];

// Simulation dates/times (duration = 1 day)
num_parameters = mgetl(file_input_parameters, 2)
disp(num_parameters)
number_days = evstr(num_parameters(1))
timestep = evstr(num_parameters(2))

disp(number_days)
cjd = cjd0 + (0 : timestep : number_days);

//output file
save_parameters = mgetl(file_input_parameters, 1)
disp(save_parameters)
outputfile = save_parameters(1)

disp("starting propagation for ")
disp(number_days)
disp("days")


//  run the study


[pomdot, gomdot, anmdot] = CL_op_driftJ2(sma, ecc, inc);  // compute drifts due to j2

pos_sun = CL_eph_sun(cjd);  //compute sun position starting at t0 (in ECI)
pos_sun_sph = CL_co_car2sph(pos_sun); // spherical coordinates

// beta angle for each initial local time 
gom = gom0 + gomdot * ( cjd - cjd0) *86400 ; // raan =f(t)
results_beta = CL_gm_raan2beta(inc, gom, pos_sun_sph(1,:), pos_sun_sph(2,:));
results_eclips = 2 * CL_gm_betaEclipse(sma, results_beta) / (pomdot + anmdot); // seconds



save(outputfile, "cjd", "-append")


save(outputfile, "results_beta", "-append")
save(outputfile, "results_eclips", "-append")


disp("Script finished")
disp("exiting scilab")
exit;