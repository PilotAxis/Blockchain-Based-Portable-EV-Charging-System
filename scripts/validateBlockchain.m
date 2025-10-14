function isValid = validateBlockchain(Blockchain);
% Verify that hashes in the blockchain are consistent

isValid = true;
for i = 2:numel(Blockchain)
    prevHash = Blockchain(i-1).Hash;
    if Blockchain(i).PrevHash ~= prevHash
        fprintf('❌ Chain broken at block %d\n', i);
        isValid = false;
        return;
    end
end
if isValid
    disp('✅ Blockchain integrity verified.');
end
end