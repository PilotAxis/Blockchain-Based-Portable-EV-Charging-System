% assemble_transactions.m
clearvars -except t_log Vout_log Iout_log Energy_log SOC_log Cost_log
% Ensure Timeseries exist
if ~exist('t_log','var'), error('t_log not found. Ensure To Workspace blocks saved Timeseries'); end

t = t_log.Time;
V = Vout_log.Data;
I = Iout_log.Data;
E = Energy_log.Data;
SOC = SOC_log.Data;
Cost = Cost_log.Data;

% detect charging sessions (simple threshold)
thresholdA = 0.5; % A, adjust
isCharging = abs(I) > thresholdA;
d = diff([0; isCharging(:)]);
starts = find(d==1);
ends = find(d==-1)-1;
if isempty(ends) && isCharging(end)
    ends = length(isCharging);
end
% if session doesn't start, try simple full data as single session
if isempty(starts) && any(isCharging)
    starts = 1; ends = length(isCharging);
end

Transactions = struct([]);
ChargerID = "Charger_01";
UserID = "EV_User_001";
TariffRate = 6.5;

for k = 1:length(starts)
    s = starts(k);
    e = ends(k);
    if e < s, continue; end
    txn.Vout = mean(V(s:e));
    txn.Iout = mean(I(s:e));
    txn.Energy_kWh = max(0, E(e) - E(s)); % energy in session
    txn.Cost = txn.Energy_kWh * TariffRate;
    txn.SOC_start = SOC(s);
    txn.SOC_end = SOC(e);
    txn.StartTime = t(s);
    txn.EndTime = t(e);
    txn.Duration_s = t(e) - t(s);
    txn.ChargerID = ChargerID;
    txn.UserID = UserID;
    Transactions = [Transactions; txn];
end

% Save Transactions
save('Transactions.mat','Transactions');

% Also create LiveLedger.csv with Hash fields so Python/Streamlit can verify
% Compute SHA-256 (via Java) for each transaction data string
import java.security.MessageDigest
fid = fopen('LiveLedger.tmp.csv','w');
fprintf(fid, 'BlockIndex,Timestamp,Vout,Iout,SOC,Energy,Cost,PrevHash,Hash\n');
prevHash = 'GENESIS';
for k=1:length(Transactions)
    tx = Transactions(k);
    ts = datestr(tx.StartTime,'yyyy-mm-dd HH:MM:SS');
    % create canonical string
    s = sprintf('Timestamp=%s|Vout=%.6f|Iout=%.6f|SOCstart=%.4f|SOCend=%.4f|Energy=%.6f|Cost=%.6f', ...
        ts, tx.Vout, tx.Iout, tx.SOC_start, tx.SOC_end, tx.Energy_kWh, tx.Cost);
    md = MessageDigest.getInstance('SHA-256');
    md.update(uint8(char(s)));
    hashBytes = md.digest();
    hashStr = lower(dec2hex(typecast(hashBytes,'uint8'))');
    hashStr = reshape(hashStr,1,[]);
    fprintf(fid, '%d,"%s",%.6f,%.6f,%.4f,%.6f,%.6f,"%s","%s"\n', ...
        k, ts, tx.Vout, tx.Iout, tx.SOC_end, tx.Energy_kWh, tx.Cost, prevHash, hashStr);
    prevHash = hashStr;
end
fclose(fid);
if isfile('LiveLedger.csv'), delete('LiveLedger.csv'); end
movefile('LiveLedger.tmp.csv','LiveLedger.csv');

disp('Transactions.mat and LiveLedger.csv created.');