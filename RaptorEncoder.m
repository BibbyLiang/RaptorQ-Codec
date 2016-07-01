function [ SourceSymbols, RepairSymbols, numSouceSymbols, numPadding ] = RaptorEncoder( data, erasureRate, overhead )
% RAPTORENCODER  
% Input: data 
%        numOfRepairSymbols

%% RaptorQ maximum pay length per symbol
global PAY_LEN
%PAY_LEN = 1500 - 20 - 8;
%MAX_DEC_MEM = 8 * 1024 * 1024; 

[SourceSymbols, numPadding] = DataBreaker(data, PAY_LEN);
[numSouceSymbols, ignore] = size(SourceSymbols);

%compute the # symbols needed
numOfRepairSymbols = ceil(numSouceSymbols * erasureRate) + overhead;

RepairSymbols = zeros(numOfRepairSymbols, PAY_LEN);

%% load lookup table
load('data.mat');
[k_prime, J, S, H, W] = systemIndexor.search(numSouceSymbols);

%% padding zeros k_prime - numSouceSymbols
for i = 1 : k_prime - numSouceSymbols
    SourceSymbols = [SourceSymbols; zeros(1, PAY_LEN)];
end

%% S + H (low and high density parity check)
for i = 1 : (S + H)
    SourceSymbols = [zeros(1, PAY_LEN); SourceSymbols];
end

fprintf('Creating MatrixA ... \n');

% constants
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

%% Generate intermediate symbols
matGene = MatrixA(k_prime, P, P1, U, W, S, H, J, randGene, tupleGene);
matrixA = matGene.getLMatrix();

%TODO - implement matrixA inverse to hijack this step :)
fprintf('Generating Intermediate Symbols \n');
tic
IntermediateSymbols = GenerateIntermediateSymbol(matrixA, SourceSymbols, P, L, S, H, k_prime);
toc

%% Generate repair symbols
fprintf('Generating Repair Symbols \n');

for i = 1 : numOfRepairSymbols
    
    ix = GENCompute(k_prime + i - 1, tupleGene, P, P1, W );
    
    matA = zeros(1, L);
    
    for ii = 1 : length(ix)
        matA(ix(ii) + 1) = 1;
    end
    
    RepairSymbols(i, :) = MO.multiplyMatrix(matA, IntermediateSymbols);
end

%coalesce the source symbol
SourceSymbols = SourceSymbols(S + H + 1 : L - (k_prime - numSouceSymbols), :);

end

