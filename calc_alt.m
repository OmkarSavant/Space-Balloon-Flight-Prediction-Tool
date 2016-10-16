%Omkar Savant
%Altitude Calculation Function

%This function uses an interative step function
%to determine the altitude as a function of time of a balloon with a
%payload on its way up. I am basing the first two equations in this program
%off of a research paper published by the Office of Naval Research and adapting them accordingly to
%preclude the need for intense double integration that is both
%computationally taxing and difficult to mathematically derive. 

%These are the equations from the Office of Naval Research: 
% (Wp + Wf + Wg + CB*Pa*Vb)*(z'') = FL - (1/2g)(Cd*Pa*A*(z')^2), where
% FL = Pa*VB - Wg - Wp - Wf and
% dV/dt = (R/(p*Mb))*(wG*dTemp/dt) + (Pa/p)*(Vb)*(z'), where
%Wg is the weight of the payload (lb), Wf is the weight of the balloon
%fabric, Wb is the weight of the balloon gas, Cb is the apparent additional
%mass coefficient of the balloon, Pa is the density of the air, Vb is the
%volume of the balloon. z'' is the upward acceleration, g is the force of
%gravity, Cd is the drag coefficient, Pa is the density of air, A is the
%cross-sectional surface area of the balloon, and z' is the upward velocity. R is the gas
%constant, Mb is the molecular weight of the balloon gas. 
% This is a tricky problem because altitude, z, varies as a function of
% balloon volume and temperature, which both vary as a function of the rate of change of
% altitude

%dV= (R/(p*Mb))*(wG*dTemp/dt)*dt + (Pa/p)*(Vb)*dz

% This creates a second order nonlinear differential equation which I was
% able to solve with Wolfram Mathematica
% let A = (Wp + Wf + Wg + Cb*Pa*Vb)
% let B = (1/2g * Cd * Pa * Sa) 
% let C = (Pa*Vb - Wg - Wp - Wf)
% Az'' = C - B(z')^2

%Solved to: z(t) = sqrt(C/B) * (-t + Alog(1 +
%e^((C/A)*(sqrt(C*B))*(t-A*c1))

function [alt_array] = calc_alt(BMass,PMass,GVol)

bd = [3.0,4.5,5.9,6.9,7.7]; %this is an array of burst diameters (in meters) based on the averages from various balloon manufacturer websites
cd = [0.25,0.25,0.3,0.3,0.3]; %this is an array of various drag coefficients based on averages from various balloon manufacturers. Each entry is the value of the corresponding balloon mass.  

switch BMass
    case 200,  realBD = bd(1);
    case 400,  realBD = bd(2);
    case 600,  realBD = bd(3);
    case 800,  realBD = bd(4);
    case 1000, realBD = bd(5);
    otherwise, realBD = bd(1);
end

switch BMass
    case 200,  realCD = cd(1);
    case 400,  realCD = cd(2);
    case 600,  realCD = cd(3);
    case 800,  realCD = cd(4);
    case 1000, realCD = cd(5);
    otherwise, realCD = cd(1);
end

%intital condition constant is calculated based on the volume of the balloon and
%weights of the objects. Initially, z = 0. 

%The following equations are from NASA's Earth Atmosphere Model (English
%Units): 
%The equation for air density is RhoA = p/(1718*(T+459.7))

%air pressure varies as a function of altitude:
    %For a alt below 36152 feet (troposphere): 
    %p = 2116*[(T+459.7)/(518.6)]^5.256
    %For 36152<alt<82345: p = 473.1*e^(1.73- 0.000048h)
    %For alt > 82345: p = 51.97 * [(T+459.7)/389.98]^-11.388
    
%Temperature (F) also varies as a function of altitude
    %For alt below 36152 feet (troposphere):T = 59 - 0.00356h 
    %For 36152<alt<82345: T = -70
    %For alt>82345: T = 205.05 + 0.00164h

% These are components of the nonlinear differential equation described
% above.
%A = (Wp + Wf + Wg + Cb*Pa*Vb) 
%B = (1/2g * Cd * Pa * Ca) 
%C = (Pa*Vb - Wb - Wg - Wf)

%Wg is based on PV = nRT so this will have to vary as a function altitude
%as well. As a result, A and C will vary as a function of this and B will
%vary as a function of volume and altitude because it depends on surface
%area and the air pressure. 

%since temperature is the only variable that is solely dependent on height,
%it will be the first to be calcuated. Other values will be calculated
%based on this.

alt = 1; %initial altitude in feet
dalt = 0; %initial change in altitude is 0 feet
vol = GVol; %the initial balloon volume is equal to the amount of air pumped in. (ft^3)
dvol = 0; %the change of the volume is initally 0
r = 1545; %This is the gas constant. Units are ftlb/lbmol0R. 
Mb = 4.0026; %This is the molecular weight of the balloon gas (Helium)
p = 2118.145;%This is the inital atmospheric pressure (lb/ft^2)
temp = 59; %This is the initial temperature
tempR = temp + 460; % This is the temperature in degrees Rankine
RhoA = p/(1718*(temp+459.7)); %This is the density of air (lb/ft^3)
Wg = Mb*p*vol/(r*tempR);
Wf = BMass*0.00220462; % This is the weight of the balloon in pounds
Wp = PMass*0.00220462; % This is the weight of the payload in pounds
cb = 0.55; % This is the apparent additional mass coefficient for balloons based on a study from UMich in 1995
g = 32.2; % acceleration caused by gravity (ft/sec^2)
dt = 1;
radius = ((3/(4*pi))*vol)^(1/3);

alt_array = zeros(10800);

for t = 1:1:10800 %Max ascent time most likely will not exceed 3 hours
    oldTemp = temp;
    oldTempR = tempR; 
    if (alt <= 36152)
        temp = 59 - 0.00356*alt; 
        tempR = temp + 460;
        p = 2116*((temp+459.7)/(518.6))^5.256;
        
    elseif (alt > 36152 && alt < 82345)
        temp = -70;
        tempR = temp + 460;
        p = 473.1*exp(1.73-0.000048*alt);
        
    else 
        temp = 205.05 + 0.00164*alt; 
        tempR = temp + 460;
        p = 51.97 * ((temp+459.7)/389.98)^-11.388;
    end

    dTemp = abs(temp - oldTemp);
    dTempR = abs(tempR - oldTempR); 
    
    RhoA = (p/(1718*(temp+459.7)))*32.174; %This is the density of air which needs to be updated. 32.174 is the conversion factor between slugs and lbs.

    Wg = Mb*p*vol/(r*tempR); %The weight of the gas has to be updated for the new temperature
    
    radius = ((3/(4*pi))*vol)^(1/3);
    Ca = pi*radius^2;   
    
    A = (Wp + Wf + Wg + cb*p*vol); 
    B = (1/2*g * realCD * RhoA * Ca); 
    C = (RhoA*vol - Wg - Wp - Wf);
    
    if t == 1
        constant = -1*(sqrt(C/B) * (t + (A*log(1 + exp((C/A)*(sqrt(C*B))*(t))))/sqrt(C*B))); %This  has to be added to the equation to ensure that we start with an altitude of 0
    end
    
    oldAlt = alt;
    
    if C >= 0 %The gross lift must be positive or the  balloon will not rise
        alt = constant + sqrt(C/B) * (t + (A*log(1 + exp((C/A)*(sqrt(C*B))*(t))))/sqrt(C*B)); %This is the simplified solution provided by Wolfram mathematica
        alt_array(t) = alt; 
    else alt_array(t) = -1; 
    end
    
    dalt = alt - oldAlt; %this is the change in altitude from the last second
    
    dVol= (r/(p*Mb))*(Wg*dTempR/dt)*dt + (RhoA/p)*(vol)*dalt;
    
    vol = vol + dVol; 
end
end
        
        
        

