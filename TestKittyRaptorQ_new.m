clear;
close all;
clc;

%% Config
erasureRate = 0.8;
overhead = 2;
sourcefile = 'lena1.jpg';
recoveredfile = 'recoveredlena1.jpg';

fprintf('Erasure rate = %f and overhead of %d \n', erasureRate, overhead);

global PAY_LEN
PAY_LEN = 368;

%% Emulate sender side
% open kitty image file
fid = fopen(sourcefile, 'r');
kitty = fread(fid, inf, '*uint8')';
fclose(fid);

fprintf('Emulating Sender -- Encoding ... \n');
[ SourceSymbols, RepairSymbols, numSouceSymbols, padding ] = RaptorEncoder_new( kitty, erasureRate, overhead);

ReceivedSymbols = SourceSymbols;
%% Emulate receiver side
fprintf('\n\n\n'); 
fprintf('Emulating channel erasure... \n'); 

loss = ceil(erasureRate * numSouceSymbols);
lossnum = 0;
while(lossnum < loss)
    if(0 == lossnum)
        lossidx = randi([1, numSouceSymbols], loss, 1);
        lossidx = unique(lossidx);
        lossnum = size(lossidx);
    else
        temploss = randi([1, numSouceSymbols], 1, 1);
        lossidx = [lossidx; temploss];
        lossidx = unique(lossidx);
        lossnum = size(lossidx);
    end
end
lossidxK = lossidx;

%throw away data
for i = 1 : length(lossidx)
    ReceivedSymbols(lossidx(i), :) = 0;
    fprintf('Removing symbol ... %d \n', lossidx(i));
end


[numRepair, lenRepair] = size(RepairSymbols);
loss = floor(erasureRate * numRepair) - 1;
lossnum = 0;
while(lossnum < loss)
    if(0 == lossnum)
        lossidx = randi([1, numRepair], loss, 1);
        lossidx = unique(lossidx);
        lossnum = size(lossidx);
    else
        temploss = randi([1, numRepair], 1, 1);
        lossidx = [lossidx; temploss];
        lossidx = unique(lossidx);
        lossnum = size(lossidx);
    end
end

for i = 1 : length(lossidx)
    RepairSymbols(lossidx(i), :) = 0;
    fprintf('Removing Repair symbol ... %d \n', lossidx(i));
end

%% assuming no missing repair symbols -- is it a right assumption?(liangjw, 20160630)
repairIdx0 = 1 : 1 : numRepair;
repairIdx = zeros(1, (numRepair - lossnum(1)));
count = 1;
for i = 1 : 1 : numRepair
    if(0 ~= sum(RepairSymbols(i, :)))
        repairIdx(count) = repairIdx0(i);
        count = count + 1;
    end
end
RepairSymbolsReal = zeros((numRepair - lossnum(1)), size(RepairSymbols, 2));
for i = 1 : 1 : (numRepair - lossnum(1))
    RepairSymbolsReal(i, :) = RepairSymbols(repairIdx(i), :);
end

fprintf('\n\n\n'); 
fprintf('Emulating Receiver -- Decoding ... \n');
RecoveredSymbols = RaptorDecoder(ReceivedSymbols, numSouceSymbols, lossidxK, RepairSymbolsReal, repairIdx, padding);

fprintf('confirming received and source ... \n');
[wid, len] = size(SourceSymbols);

for row = 1 : wid
    for col = 1 : len
        
        if(RecoveredSymbols(row, col) ~= SourceSymbols(row, col))
            fprintf('mismatch found ... (%i, %i) \n', row, col);
            return;
        end
        
    end
end

fprintf('All symbols match! Job done! \n');

[w, l] = size(RecoveredSymbols);
numOfSymbols = w * l - padding;

delete(recoveredfile);
fid = fopen(recoveredfile, 'w');

counter = 0;
for n = 1 : w
    for nn = 1 : l
        
        fwrite(fid, RecoveredSymbols(n, nn), 'uint8');
        
        if(counter == numOfSymbols)
            return;
        end
    end
end

fclose(fid);


%% display the results
figure('name', sourcefile);
[original, map1] = imread(sourcefile);
imshow(original, 'Border', 'tight');

figure('name', [recoveredfile, ' w/ erasure rate of ', num2str(erasureRate)]);
[recovered, map2] = imread(recoveredfile);
imshow(recovered, 'Border', 'tight');


