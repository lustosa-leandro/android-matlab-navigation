function connect(mobile_ip, local_port)
% CONNECT plots Android mobile sensors data by means of IMU+GPS-Stream app.
%   usage: CONNECT(mobile_ip, local_port)
%   for example: CONNECT('192.168.6.106',5555)
% for more information, see <a href="matlab: 
% web('http://lustosa-leandro.github.io')">the author's website</a>.

%% binds udp socket to mobile phone
u = udp(mobile_ip,5554,'LocalPort',local_port);
fopen(u);

%% prepare interface

% close figure opened by last run, if any
figTag = 'AndroidPhoneNavFigure';
close(findobj('tag',figTag));

% create new figure for showing sensors graphs
hFig = figure('numbertitle', 'off', ...
    'name', 'Android Phone Navigation Sensors', ...
    'menubar','none', ...
    'toolbar','none', ...
    'resize', 'on', ...
    'tag',figTag, ...
    'renderer','painters', ...
    'position',[200 200 1200 700]);

% create axes and titles for 9 sensors real-time plotting
hei_graph =  0.27;
hAxes.axis1 = createPanelAxisTitle(hFig,[0.01 0.05 0.30 hei_graph],'Accelerometer X'); % [X Y W H]
hAxes.axis2 = createPanelAxisTitle(hFig,[0.33 0.05 0.30 hei_graph],'Accelerometer Y'); % [X Y W H]
hAxes.axis3 = createPanelAxisTitle(hFig,[0.66 0.05 0.30 hei_graph],'Accelerometer Z'); % [X Y W H]
hAxes.axis4 = createPanelAxisTitle(hFig,[0.01 0.35 0.30 hei_graph],'Rate-Gyro X'); % [X Y W H]
hAxes.axis5 = createPanelAxisTitle(hFig,[0.33 0.35 0.30 hei_graph],'Rate-Gyro Y'); % [X Y W H]
hAxes.axis6 = createPanelAxisTitle(hFig,[0.66 0.35 0.30 hei_graph],'Rate-Gyro Z'); % [X Y W H]
hAxes.axis7 = createPanelAxisTitle(hFig,[0.01 0.65 0.30 hei_graph],'Magnetometer X'); % [X Y W H]
hAxes.axis8 = createPanelAxisTitle(hFig,[0.33 0.65 0.30 hei_graph],'Magnetometer Y'); % [X Y W H]
hAxes.axis9 = createPanelAxisTitle(hFig,[0.66 0.65 0.30 hei_graph],'Magnetometer Z'); % [X Y W H]
% creating animation handles
axes(hAxes.axis1); hLines.h1 = animatedline;
axes(hAxes.axis2); hLines.h2 = animatedline;
axes(hAxes.axis3); hLines.h3 = animatedline;
axes(hAxes.axis4); hLines.h4 = animatedline;
axes(hAxes.axis5); hLines.h5 = animatedline;
axes(hAxes.axis6); hLines.h6 = animatedline;
axes(hAxes.axis7); hLines.h7 = animatedline;
axes(hAxes.axis8); hLines.h8 = animatedline;
axes(hAxes.axis9); hLines.h9 = animatedline;

% exit button with text "exit"
uicontrol(hFig,'unit','pixel','style','pushbutton','string','Exit',...
    'position',[100 10 50 25],'callback', ...
    {@exitCallback,u});

%% main loop 
while true
    
    %% check if UDP is dead, and terminate program if that is the case
    if strcmp(u.status,'closed')
        break; % something went wrong, let's stop everything!
    end
    
    %% reads a package of raw data
    try 
        [udp_raw, charCount] = fread(u,8192);
    catch 
        continue;
    end
    udp_raw = udp_raw';
    % check if reading was succesful and deal with it if unsuccessful
    if charCount <= 0
        break; % something went wrong, let's stop everything!
    end
    % navData is an object for capturing and abstracting sensor data of class
    % navSensorsData
    try
        navData = udpSocket2NavData(udp_raw);
    catch
        continue;
    end
    
    %% draws acc data in figure, if any
    if navData.acc_hasData
        addpoints(hLines.h1,navData.time,navData.acc(1));
        addpoints(hLines.h2,navData.time,navData.acc(2));
        addpoints(hLines.h3,navData.time,navData.acc(3));
        windows_width = 5;
        set(hAxes.axis1,'XLim',[navData.time-windows_width navData.time]);
        set(hAxes.axis2,'XLim',[navData.time-windows_width navData.time]);
        set(hAxes.axis3,'XLim',[navData.time-windows_width navData.time]);
        drawnow;
    end

    %% draws rate-gyro data in figure, if any
    if navData.gyr_hasData
        addpoints(hLines.h4,navData.time,navData.gyr(1));
        addpoints(hLines.h5,navData.time,navData.gyr(2));
        addpoints(hLines.h6,navData.time,navData.gyr(3));
        windows_width = 5;
        set(hAxes.axis4,'XLim',[navData.time-windows_width navData.time]);
        set(hAxes.axis5,'XLim',[navData.time-windows_width navData.time]);
        set(hAxes.axis6,'XLim',[navData.time-windows_width navData.time]);
        drawnow;
    end
    
    %% draws magneto data in figure, if any
    if navData.mag_hasData
        addpoints(hLines.h7,navData.time,navData.mag(1));
        addpoints(hLines.h8,navData.time,navData.mag(2));
        addpoints(hLines.h9,navData.time,navData.mag(3));
        windows_width = 5;
        set(hAxes.axis7,'XLim',[navData.time-windows_width navData.time]);
        set(hAxes.axis8,'XLim',[navData.time-windows_width navData.time]);
        set(hAxes.axis9,'XLim',[navData.time-windows_width navData.time]);
        drawnow;
    end
    
end

%% closes UDP binding and figure
fclose(u);
close(hFig);

end

%% create axis and title
% axis is created on uipanel container object. this allows more control
% over the layout of the GUI.
function hAxis = createPanelAxisTitle(hFig, pos, axisTitle)

% create panel
hPanel = uipanel('parent',hFig,'Position',pos,'Units','Normalized');

% create axis
hAxis = axes('position',[0 0 1 1],'Parent',hPanel);
hAxis.XTick = [];
hAxis.YTick = [];
hAxis.XColor = [1 1 1];
hAxis.YColor = [1 1 1];
% set video title using uicontrol. uicontrol is used so that text
% can be positioned in the context of the figure, not the axis.
titlePos = [pos(1)+0.02 pos(2)+pos(4) 0.3 0.03];
uicontrol('style','text',...
    'String', axisTitle,...
    'Units','Normalized',...
    'Parent',hFig,'Position', titlePos,...
    'BackgroundColor',hFig.Color);
end

%% exit button callback
% this callback function releases system objects and closes figure window.
function exitCallback(~,~,udp_descrip)

% close udp bindings (this forces window to close in main loop as well)
fclose(udp_descrip);

end



