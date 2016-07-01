function [ C ] = phase1(  matrixA, D, P, L, S, H, krpime )
%PHASE1  

[r, M] = size(matrixA);

i = 1;
u = P;

%copy matrix A to matrix X
matrixX = matrixA;

d = 1:length(matrixA);
d = d';
c = d;

keyss = {};
values = {};


%% find nonzeros columns 
for row = 1 : r
    
    ro = RowObject();
    ro.index = row;
    ro.nonzeros = nonZerosInRow(matrixA, row, 1, L - u);
    
    if(row >= S + 1 && row < S + H + 1)
        ro.isHDPC = 1;
    else
        ro.isHDPC = 0;
    end
    
    nonZerosArr = nonZeroRowIterator(matrixA, row, 1, L - u);
    
    if(ro.nonzeros == 2 && ro.isHDPC == 0)
        
        for n = 1 : length(nonZerosArr)
            cellarr = nonZerosArr(n, :);
            ro.degree = bitxor(ro.degree, cell2mat(cellarr(2)));
            ro.nodes = [ro.nodes; cell2mat(cellarr(1))];
        end
        
    else
        
        od = 0;
        
        for n = 1 : length(nonZerosArr)
            od = od + nonZerosArr{n, 2};
        end
        
        ro.degree = od;
    end
    
    keyss = [keyss; {row}];
    values = [values; {ro}];
    
end 
columnMap = containers.Map(keyss, values);

nonHDPCRows = S + krpime;
chosenRowsCounter = 0;
MO = OctetMath();

%at most L step
while((i + u) <= L)
    
    mindegree = 256 * L;
    
    r = L + 1;
    
    ro = RowObject();
    
    two1s = 0;
    
    keyss = keys(columnMap);
    
    allzeros = 1;
    
    %find r
    for ct = 1 : length(keyss)
        
        row = columnMap(cell2mat(keyss(ct)));
        
        %this might be an error
        if(row.nonzeros ~= 0)
            allzeros = 0;
        end
        
        if(row.isHDPC == 1 && chosenRowsCounter < nonHDPCRows)
            continue;
        end
        
        if(~isempty(row.nodes))
            two1s = 1;
        end
        
        if (row.nonzeros < r && row.nonzeros > 0)
            ro = row;
            r = ro.nonzeros;
            mindegree = ro.degree;
        elseif(row.nonzeros == r && row.degree < mindegree)
            ro = row;
            mindegree = ro.degree;
        end
        
    end
    
    if (allzeros == 1)
        error(['Phase 1: Row info consist of all zeros at ', ct]);
    end
    
    %choose the row for 2 degrees
    if(r == 2 && two1s == 1)
        
        ro = 0;
        
        noderows = [];
        nodes = [];
        
        %loop the map again
        for ct = 1 : length(keyss)
            row = columnMap(cell2mat(keyss(ct)));
            if(~isempty(row.nodes))
                noderows = [noderows; row; row];
                nodes = [nodes; row.nodes];
            end
        end
        
        %find the greatest component
        target = mode(nodes);
        
        for ct = 1 : length(nodes)
            
            if(target == nodes(ct))
                ro = noderows(ct);
                break;
            end
            
        end
        
        
    end
    
    chosenRowsCounter = chosenRowsCounter + 1;
    
    %row has been chosen
    if(ro.index ~= i)
        
        matrixA = swapRow(matrixA, i, ro.index);
        matrixX = swapRow(matrixX, i, ro.index);
        
        d = swapVector(d, i, ro.index);
        
        %update row position
        other = columnMap(i);
        other.index = ro.index;
        columnMap(ro.index) = other;
        remove(columnMap, i);
        ro.index = i;
        
    end
    
    nonZeroPos = nonZeroRowIterator(matrixA, i, i, L - u);
    firstNZpos = cell2mat(nonZeroPos(1, 1));
    
    if(firstNZpos ~= i)
        matrixA = swapColumn(matrixA, i, firstNZpos);
        matrixX = swapColumn(matrixX, i, firstNZpos);
        c = swapVector(c, i, firstNZpos);
    end
    
    %  swap the remaining non-zeros' columns so that they're the last columns in V
    currCol = L - u;
    [nzp, ignore] = size(nonZeroPos);
    
    while(nzp > 1)
        
        currNZpos = cell2mat(nonZeroPos(nzp, 1));
        
        if(currCol ~= currNZpos)
            matrixA = swapColumn(matrixA, currCol, currNZpos);
            matrixX = swapColumn(matrixX, currCol, currNZpos);
            c = swapVector(c, currCol, currNZpos);
        end
        
        nzp = nzp - 1;
        currCol = currCol - 1;
        
    end
    
    %the chosen row has entry alpha in the first column of V
    alpha = matrixA(i, i);
    
    % let's look at all rows below the chosen one
    % Page35@RFC6330 1st Par.
    for row = (i + 1) : M
        
        beta = matrixA(row, i);
        
        if(beta == 0)
            continue;
        else
            bOA = MO.divide(beta, alpha);
            
            matrixA = MO.addRowsInPlace(matrixA, bOA, i, row);
            
            %decoding process of D
            D = MO.addRowsInPlace(D, bOA, d(i), d(row));
            
        end
    end
    
    i = i + 1;
    u = u + r - 1;
    
    keyss = keys(columnMap);
    
    %update nonZeros from rows
    for ct = 1 : length(keyss)
        
        row = columnMap(cell2mat(keyss(ct)));
        
        row.nonzeros = nonZerosInRow(matrixA, row.index, i, L - u);
        row.nodes = [];
        
        if(row.nonzeros ~= 2 ||  row.isHDPC == 1)
            continue;
        else
            
            it = nonZeroRowIterator(matrixA, row.index, i, L - u);
            
            for bb = 1 : length(it)
                cellarr = it(bb);
                row.nodes = [row.nodes; cell2mat(cellarr(1))];
            end
            
        end
        
    end
    
end


%% Apply phase 2
[ matrixA, d, D ] = phase2(matrixA, D, d, i, M, L - u + 1, L, MO);

%% Apply phase 3
C = phase3(matrixA, matrixX, D, d, c, L, i, MO);


end

