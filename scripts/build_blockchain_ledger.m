clc; clear;

% Load the charger data received by server
load('ServerData.mat','ServerData');

Blockchain = [];

for k = 1:length(ServerData)
    Transaction = ServerData(k);
    Blockchain = addBlock(Blockchain, Transaction)
end

% Save the blockchain ledger
save('BlockchainLedger.mat','Blockchain');
save('Transactions.mat', "Transaction")

disp("✅ Blockchain ledger successfully created.");
disp(Blockchain(end))