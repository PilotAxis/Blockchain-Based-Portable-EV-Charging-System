clc; clear;
disp("🛰️ Server listening for charger data...");

ServerData = []; % this will store all received packets
save('ServerData.mat','ServerData'); % create empty file

while true
    pause(1); % check every second
    if evalin('base','exist("LatestData","var")')
        data = evalin('base','LatestData');
        if ~isempty(data)
            ServerData = [ServerData; data]; %#ok<AGROW>
            save('ServerData.mat','ServerData');
            fprintf('Time: %s | V=%.1f V | I=%.1f A | SOC=%.1f %% | Energy=%.3f kWh | Cost=₹%.2f\n', ...
                string(data.Timestamp), data.Vout, data.Iout, ...
                data.SOC, data.Energy, data.Cost);
        end
    end
end