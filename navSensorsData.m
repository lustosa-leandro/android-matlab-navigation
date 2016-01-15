% NAVSENSORSDATA class that organizes data from Android sensors
%   This class attempts to abstract the data that comes from several
%   sensors at different time instants. It is useful to abstract remote
%   measurements such as done in our mobile phone navigator!
% for more information, see <a href="matlab: 
% web('http://lustosa-leandro.github.io')">the author's website</a>.

classdef navSensorsData

%% navSensorData internal variables
    properties (GetAccess='public', SetAccess='public')
        %% Accelerometer State variables
        acc = zeros(3,1); % m/s^2
        acc_hasData = false;
        %% Rate-gyro State variables
        gyr = zeros(3,1); % rad/s
        gyr_hasData = false;
        %% Magnetometer State variables
        mag = zeros(3,1); % not sure what unit here! should be normalized
        mag_hasData = false;
        %% GNSS State variables
        gnss_lla = zeros(3,1); % rad, rad, meters
        gnss_vel = zeros(3,1); % m/s in WGS-84 NED
        gnss_hasPosData = false;
        gnss_hasVelData = false;
        %% Timestamp
        time = 0; % seconds
    end
    
end

