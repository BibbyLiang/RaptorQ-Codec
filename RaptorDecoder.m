function [ SourceSymbols ] = RaptorDecoder( SourceSymbols, numSymbols, missIdx, RepairSymbols, repairIdx, padding )
% RAPTORDECODER
% Input - SourceSymbols: Received source symbols (may contain missing)
%         RepairSymbols: Received repair symbols
%         numSymbols: Number of expected source symbols

load('data.mat');
[k_prime, J, S, H, W] = systemIndexor.search(numSymbols);

% constants
global PAY_LEN
%PAY_LEN = 1500 - 20 - 8;
L = k_prime + S + H;
P = L - W;
P1 = nextprime(P);
U = P - H;
%B = W - S;

% objects to be pass around and use
degGene = DegreeGenerator(W);
randGene = RandomGene();
tupleGene = TupleGenerator(J, W, P1, randGene, degGene);
MO = OctetMath();

if(length(missIdx) > length(repairIdx))
    error('Not enough symbols to recover source symbols');
end

%% padding zeros k_prime - numSouceSymbols
for i = 1 : k_prime - numSymbols
    SourceSymbols = [SourceSymbols; zeros(1, PAY_LEN)];
end

%% S + H
for i = 1 : (S + H)
    SourceSymbols = [zeros(1, PAY_LEN); SourceSymbols];
end

matGene = MatrixA(k_prime, P, P1, U, W, S, H, J, randGene, tupleGene);
matrixA = matGene.getLMatrix();

%% Filling missing symbol
fprintf('missing symbol index %d \n', missIdx);
counter = 0;
for i = 1 : length(missIdx)
    idx = S + H + missIdx(i);
    matrixA(idx, :) = zeros(1, L); 
    %fill with repair symbol of matrix A
    ix = GENCompute(k_prime + repairIdx(i) - 1, tupleGene, P, P1, W );
    
    %fill matrix A with repair symbol
    for ii = 1 : length(ix)
        matrixA(idx, ix(ii) + 1) = 1;
    end
    
    counter = i;
    
    %replace source symbol with repair symbols
    SourceSymbols(idx, :) = RepairSymbols(i, :);
end


%% append the remaining raptor repair symbols
fprintf('Appending remaining repair symbols ... \n');
if(counter + 1 < length(repairIdx))
    
    numOfAppendedSymbols = 0;
    
    for i = counter + 1 : length(repairIdx)
        
        ix = GENCompute(k_prime + repairIdx(i) - 1, tupleGene, P, P1, W );
        
        % back fill matrix A
        matA = zeros(1, L);
        
        for ii = 1 : length(ix)
            matA(ix(ii) + 1) = 1;
        end
        
        matrixA = [matrixA; matA];
        SourceSymbols = [SourceSymbols; RepairSymbols(i, :)];
        numOfAppendedSymbols = numOfAppendedSymbols + 1;
        
    end
    
    %[newL, ignore] = size(SourceSymbols);
    [mx, my] = size(matrixA);
    matrixA = [matrixA, zeros(mx, mx - my)];
end

% add padding to 
fprintf('Generating Recovery Intermediate Symbols ... \n');
tic
RecoveredIS = GenerateIntermediateSymbol(matrixA, SourceSymbols, P, L, S, H, k_prime);
toc

% recover the data
fprintf('Recovering data ... \n');
%{
for i = 1 : length(missIdx)
    [d, a, b, d1, a1, b1] = tupleGene.getTuple(missIdx(i) - 1);
    
    %replace receive source data with repair symbol
    SourceSymbols(S + H + missIdx(i), :) = Encode(RecoveredIS,  d, a, b, d1, a1, b1, W, P, P1, MO);  
    
end
%}
SourceSymbols = [];
for i = 1 : k_prime - 1
    [d, a, b, d1, a1, b1] = tupleGene.getTuple(i - 1);
    SourceSymbols = [SourceSymbols; Encode(RecoveredIS,  d, a, b, d1, a1, b1, W, P, P1, MO)];  
end
 
fprintf('Decoded!!! \n\n\n');

end

