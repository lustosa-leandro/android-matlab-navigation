function navData = udpSocket2NavData( udp_raw )
% UDPSOCKET2NAVDATA Convert UDP UTF-8 phone package to MATLAB class
%   This functions take as input a UDP socket package and
%   delivers a object of class navSensorsData which yields sensors data in a
%   MATLAB friendly interface. Only works with the Android software called
%   IMU+GPS-Streamsensor, freely available at Android Store. 
% for more information, see <a href="matlab: 
% web('http://lustosa-leandro.github.io')">the author's website</a>.

%% UDP package pre-processing
% converts raw data to a string
iStr = num2str(udp_raw,'%s');
% converts string to array of double data
iRawData = textscan(iStr,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','Delimiter',',');

%% here we really handle data stream semantics

% instantiate object for capturing and abstracting sensor data
navSen = navSensorsData();

% first data is always timestamp (already in secs)
navSen.time = iRawData{1};

% from here on, depends on its frame identifier
byteCount = 2; % position in the frame
while ~isempty(iRawData{byteCount}) % are we in the end of the frame?
    % if not, get identifier and execute associated action
    switch iRawData{byteCount}
        case 1 % GNSS Position
            navSen.gnss_hasPosData = true;
            navSen.gnss_lla(1) = iRawData{byteCount+1}*pi/180;
            navSen.gnss_lla(2) = iRawData{byteCount+2}*pi/180;
            navSen.gnss_lla(3) = iRawData{byteCount+3};
            byteCount = byteCount + 4;
        case 3 % accelerometer
            navSen.acc_hasData = true;
            navSen.acc(1) = iRawData{byteCount+1};
            navSen.acc(2) = iRawData{byteCount+2};
            navSen.acc(3) = iRawData{byteCount+3};
            byteCount = byteCount + 4;
        case 4 % rate-gyro
            navSen.gyr_hasData = true;
            navSen.gyr(1) = iRawData{byteCount+1};
            navSen.gyr(2) = iRawData{byteCount+2};
            navSen.gyr(3) = iRawData{byteCount+3};
            byteCount = byteCount + 4;
        case 5 % magnetometer
            navSen.mag_hasData = true;
            navSen.mag(1) = iRawData{byteCount+1};
            navSen.mag(2) = iRawData{byteCount+2};
            navSen.mag(3) = iRawData{byteCount+3};
            byteCount = byteCount + 4;
        case 6 % GNSS extra info (disregard for now)
            byteCount = byteCount + 4;
        case 7 % GNSS extra info (disregard for now)
            byteCount = byteCount + 4;
        case 8 % GNSS extra info (disregard for now)
            byteCount = byteCount + 2;
        otherwise
            disp('Something stinky happened while reading sensors UDP frame')
    end
end

navData = navSen;

end

