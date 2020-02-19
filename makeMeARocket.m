%% make me a rocket with functions and structures

clear all; close all; clc;
addpath(genpath('NitrousModelling')) %adds NitrousModelling folders and subfolders to path, used in tank pressure simulation. From Eddie Brown.

%% Setup

%Universal Constants
g0      = 9.81;         %[m/s^2]
bar     = 100000;       %[Pa]
P_amb   = 1.0135*bar;   %[Pa] ambient pressure;

universalConstants.g0      = g0;
universalConstants.bar     = bar;
universalConstants.P_amb   = P_amb;

%% Desired Rocket Design Parameters ----------------- MAIN SCRIPT INPUTS -----------------------

rocketDesignParameters.I_total = 13500; % Desired Total Impulse
rocketDesignParameters.F_init = 500; % Desired Thrust
rocketDesignParameters.t_burn  = rocketDesignParameters.I_total/rocketDesignParameters.F_init; %[s] total burn time in seconds

%% Combustion Parameters
rocketDesignParameters.P_cc     = 30*bar; %Chosen based on limits of tank pressurisation, and recommendations of [Physics of nitrous oxide, Aspire Space] in the drive
rocketDesignParameters.lambda   = 0.85;      %nozzle thrust efficiency factor
rocketDesignParameters.rho_fuel = 993;    %density of fuel (kg/m^3), guess, should be determined more accurately
rocketDesignParameters.etac     = 1;   %combustion efficiency [SPAD]
rocketDesignParameters.GO_max   = 350;    %[kg/(m^2*s)] max oxidiser flow flux [SPAD says blow-off/flooding limit is usually at 350-700 kg/m^2 s, so we used 350 to be safe]

InitialConfigVars.OF       = 7;   %intial oxidiser to fuel ratio (guess used for config)
InitialConfigVars.T_req    = 25;   %[degrees C] Input for 'nitrous;' function: temperature of ox tank contents
InitialConfigVars.Isp_init = 185; %initial guess, should be iterated to maximise overall average Isp
InitialConfigVars.Isp_avg  = 0.98*InitialConfigVars.Isp_init;   %[SPAD 7.4.4] Says that the average Isp should be ~2.0% lower than initial

%regRate
%regRateParams.a = 2.34e-5;  %need correct values! Using Paraffin/GOX value from [ref 2, Table 1] - gives rdot in m/sec but uses SI units for
%regRateParams.n = 0.8;      %need correct values!
%regRateParams.m = -0.2;     %need correct values!

%using numbers from adam bakers excel file.
regRateParams.a = 0.0000236;
regRateParams.n = 0.605;
regRateParams.m = 0;

% regRateParams.a = 0.0001146;
% regRateParams.n = 0.5036;
% regRateParams.m = 0;

%% Injector Parameters

injectorDesignParams.n = [1,3]; % Set number of injector orifices for each desired DISCRETE throttle state
injectorDesignParams.throttle_states = [0.7,1.3]; % Set multiplier for desired DISCRETE throttle states
injectorDesignParams.orificeType = 'sharp'; % Set type of orifice for determining head loss coeff. Options are 'sharp' and 'radiused'

%% Simulator Initialisation
%time based simulator threshold and timestep

thresh=1e-6; % in percentage - so 1e-2 is 1% change threshold.
deltaT = 0.01; %s

%% Output Select
%outputConditions

qplot = 1; %if 1, there will be an output displayed
qdisp = 1; %if 1, there will be an output displayed

%% Combustion Chamber Configuration

rocketDesign = intialConfig(universalConstants, rocketDesignParameters, InitialConfigVars, regRateParams);

%% Injector Configuration

injectorDesign = injectorConfig(injectorDesignParams,rocketDesign);

%% Run Time Based Simulation

[rocketPerformance, rocketSim] = timeBasedSimulator(universalConstants,rocketDesign,regRateParams,deltaT,thresh);


%% Display Results

disp('Simulation Successful')

if qdisp == 1
    disp('All values are in SI units')
    rocketDesign.port
    rocketDesign
    rocketPerformance
    injectorDesign
end

if qplot == 1
    
    t_axis = 0:deltaT:rocketPerformance.t_burn_result;
    
    figure(1);
    
    subplot(3,4,1)
    plot(t_axis,rocketSim.F,[0],[0])
    title('F')
    grid on
    
    subplot(3,4,2)
    plot(t_axis,rocketSim.c_star,[0],[0])
    title('c star')
    grid on
    
    
    subplot(3,4,3)
    plot(t_axis,rocketSim.port.fuelweb(1:end-1),[0],[0])
    grid on
    title('Fuel web thickness [m]')
    
    subplot(3,4,4)
    plot(t_axis,rocketSim.G_ox,[0],[0])
    title('G ox')
    grid on
    
    subplot(3,4,5)
    plot(t_axis,rocketSim.G_fuel,[0],[0])
    title('G fuel')
    grid on
    
    subplot(3,4,6)
    plot(t_axis,rocketSim.G_prop,[0],[0])
    title('G prop')
    grid on
    
    subplot(3,4,7)
    plot(t_axis,rocketSim.mdot_fuel,[0],[0])
    title('mdot fuel')
    grid on
    
    subplot(3,4,8)
    plot(t_axis,rocketSim.Isp,[0],[0])
    title('Isp')
    grid on
    
    subplot(3,4,9)
    plot(t_axis,rocketSim.M_exit,[0],[0])
    title('M exit')
    grid on
    
    subplot(3,4,10)
    plot(t_axis,rocketSim.OF,[0],[0])
    title('OF')
    grid on
    
    subplot(3,4,11)
    plot(t_axis,rocketSim.P_cc,[0],[0])
    title('P cc')
    grid on
    
    subplot(3,4,12)
    plot(t_axis,rocketSim.P_exit,[0],[0])
    title('P exit')
    grid on
    
    %Plot cross sections, before and after
    figure (2);
    clf
    
    
    subplot(1, 2, 1);
    
    plotPortXSection(rocketSim.port,1)
    
    title('Intial cross section [m]')
    
    subplot(1, 2, 2);
    plotPortXSection(rocketSim.port,length(t_axis))
    title('Final cross section [m]')
end












