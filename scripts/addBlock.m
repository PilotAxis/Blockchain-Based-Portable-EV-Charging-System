function Blockchain = addBlock(Blockchain, Transaction)
% Add a new transaction block to the blockchain ledger

%--- 1. Encode transaction data
dataStr = jsonencode(Transaction);

%--- 2. Generate hash (simple SHA-256)
import java.security.*;
import java.math.*;
md = MessageDigest.getInstance('SHA-256');
hashBytes = md.digest(uint8(dataStr));
hashStr = sprintf('%.2x', typecast(hashBytes, 'uint8'));

%--- 3. Determine previous hash and block index
if isempty(Blockchain)
    prevHash = "GENESIS";
    index = 1;
else
    prevHash = Blockchain(end).Hash;
    index = numel(Blockchain) + 1;
end

%--- 4. Build new block
Block.Index     = index;
Block.Timestamp = datetime('now');
Block.Data      = Transaction;
Block.PrevHash  = prevHash;
Block.Hash      = hashStr;

%--- 5. Append block
Blockchain = [Blockchain; Block];
end