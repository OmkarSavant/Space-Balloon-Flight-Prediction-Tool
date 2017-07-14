# Space-Balloon-Flight-Prediction-Tool

Update: The Penn Aerospace Club Balloon Team has updated this algorithm and used it in a Simulink Model that works much better. I re-wrote the code with Alexis Mitchnick and Dani Gelb. The code is available here: https://github.com/PennAerospaceClub/HAB11/tree/master/AltControl. 

This is a tool I wrote in MATLAB that takes inputs about balloon mass, payload mass, and volume to determine the vertical trajectory of the balloon as a function of time. This functionality is used by our High Altitude Balloon team when determining aerial photography and altitude changing maneuvers. 

This is a screenshot of the GUI: https://www.dropbox.com/s/o5twxiwmo0t4n7t/Screenshot%202016-10-16%2016.21.24.png?dl=0

The basis of the math behind the tool is as follows: 

The Office of Naval Research published a paper which attempted to model a balloon's path and came up with the equation: 

(Wp + Wf + Wg + CB*Pa*Vb)*(z'') = FL - (1/2g)(Cd*Pa*A*(z')^2), where FL = Pa*VB - Wg - Wp - Wf and
dV/dt = (R/(p*Mb))*(wG*dTemp/dt) + (Pa/p)*(Vb)*(z')

FL is free lift. Wg is the weight of the payload (lb), Wf is the weight of the balloon fabric, Wb is the weight of the balloon gas, Cb is the apparent additional mass coefficient of the balloon, Pa is the density of the air, Vb is the volume of the balloon. z'' is the upward acceleration, g is the force of gravity, Cd is the drag coefficient, Pa is the density of air, A is the cross-sectional surface area of the balloon, and z' is the upward velocity. R is the gas constant, Mb is the molecular weight of the balloon gas. dV/dt is the rate of change of the balloon volume. 

At the end of the day, we want to find z(t) since the only useful data for the team is altitude as a function of time. I have included the functions of air pressure, air density, and temperature as a function of altitude in the program as well but will leave them out of this write up for brevity. This also includes a calculation for the various burst diameters and drag coefficients based on balloon size.
 
The reason this is a tricky problem is because altitude, z, varies as a function of balloon volume and temperature, which both vary as a function of the rate of change of altitude and the altitude itself. So there is no way to solve this in one go, because the values of dV/dt and free lift are functions of altitude in a way themselves, but the problem is that we want to know what the altitude is as a function of time. To solve this, I first solved the second order non-linear differential equation on Wolfram Mathematica to get z as a function of time. A detailed description of how this was done is included in the comments of the altitude calculation function.

