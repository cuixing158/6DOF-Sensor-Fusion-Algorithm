function androidlistener=makeandroidlistener()
% androidlistener=makeandroidlistener()
% function that generates a UDP phone listener object to listen to android
% phones. Use getandroiddata subsequently.
% input:
%   none.
% output:
% androidlistener : UDP object that listens to incoming signals on port
% 5000.

% get Local IP  address

% Use Java's InetAddress class to get the local host
host = java.net.InetAddress.getLocalHost();

% Get the IP address as a string
ipAddress = string(host.getHostAddress());


%% Creating UDP object and opening connection
localPort = 5000;
try
    androidlistener=udpport('datagram','LocalHost',ipAddress,'LocalPort',localPort);
    localPort = androidlistener.LocalPort;
catch
    androidlistener=udp(ipAddress,'LocalPort',localPort); % MATLAB version older than R2020b
    fopen(androidlistener);%Opening UDP communication
end


% Display the IP address
dispStr = "Local IP Address:"+ipAddress+",Port:"+string(localPort);
disp(dispStr);

