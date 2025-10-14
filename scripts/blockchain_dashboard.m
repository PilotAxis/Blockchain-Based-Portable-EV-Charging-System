clc; clear; close all;
load('BlockchainLedger.mat','Blockchain');

% Extract data
timestamps = datetime([Blockchain.Timestamp]);
V = arrayfun(@(b)b.Data.Vout, Blockchain);
I = arrayfun(@(b)b.Data.Iout, Blockchain);
SOC = arrayfun(@(b)b.Data.SOC, Blockchain);
E = arrayfun(@(b)b.Data.Energy, Blockchain);
Cost = arrayfun(@(b)b.Data.Cost, Blockchain);

% Figure layout
figure('Name','Blockchain-Based EV Charger Dashboard','NumberTitle','off');

subplot(2,2,1)
plot(timestamps, SOC, 'LineWidth',2)
xlabel('Time'); ylabel('SOC (%)');
title('Battery SOC Progress'); grid on;

subplot(2,2,2)
plot(timestamps, E, 'LineWidth',2)
xlabel('Time'); ylabel('Energy (kWh)');
title('Cumulative Energy Delivered'); grid on;

subplot(2,2,3)
bar(Cost)
xlabel('Block #'); ylabel('Cost (₹)');
title('Charging Cost per Block'); grid on;

subplot(2,2,4)
plot(V, I, 'o-', 'LineWidth',2)
xlabel('Voltage (V)'); ylabel('Current (A)');
title('Charging V–I Profile'); grid on;