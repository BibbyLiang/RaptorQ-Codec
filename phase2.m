function [ matrixA, d, D ] = phase2( matrixA, D, d, fromRow, toRow, fromCol, toCol, MO )
%PHASE2 - Reduce To Row Echelon Form

lead = fromCol;

%loop thru each row
for row = fromRow : toRow
    
    if(lead > toCol)
        return;
    end
    
    cr = row;
    %find next non zeros
    while(matrixA(cr, lead) == 0)
        
        cr = cr + 1;
        if(cr == toRow)
            cr = row;
            lead = lead + 1;
            
            if(lead >= toCol)
                error('Phase 2: No enough nonzero to decode this matrix... \n');
                return
            end
        end
    end
    
    %swap the zero with nonzero
    if(cr ~= row)
        matrixA = swapRow(matrixA, cr, row);
        d = swapVector(d, cr, row);
        beta = matrixA(row, lead);
    else
        beta = matrixA(cr, lead);
    end
     
    if(beta ~= 0)
        matrixA = MO.divideRowsInPlace(matrixA, row, beta);
        D = MO.divideRowsInPlace(D, d(row), beta);
    end
    
    %perform reduce
    for r = fromRow : toRow
        
        if(row ~= r)
            
            beta = matrixA(r, lead);
            matrixA = MO.addRowsInPlace(matrixA, beta, row, r);
            D = MO.addRowsInPlace(D, beta, d(row), d(r));
            
        end
    end
    
    lead = lead + 1;
    
end

%% check for zero row
[ignore, tcol] = size(matrixA);

for row = fromRow : toRow
    
    rowzeros = length(find(matrixA(row, :) == 0));
    
    if(rowzeros == tcol)
        error(['Phase 2: Row info consist of all zeros at ', row]);
    end
    
end

end

