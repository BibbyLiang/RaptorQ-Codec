function [ C ] = phase5(matrixA, D, d, c, L, i, MO) 
%Phase 5

[Lr, Lc] = size(D);
C = zeros(Lr, Lc);

% "For j from 1 to i, perform the following operations:" 

for j = 1 : i - 1

    beta = matrixA(j, j);
    
    if (beta ~= 1)
        % "then divide row j of A by A[j,j]."
        matrixA = MO.divideRowInPlace(matrixA, j, beta);
        
        % decoding process - D[d[j]] / beta
        D = MO.divideRowInPlace(D, d(j), beta);
    end
    
    % "For eL from 1 to j-1"
    for eL = 1 : j - 1
        
        beta = matrixA(j, eL);
        
        if(beta == 0)
            continue;
        else
            % decoding process - (beta * D[d[eL]]) + D[d[j]]
            D = MO.addRowsInPlace(D, beta, d(eL), d(j)); 
            
        end
    
    end
end

% reorder C
for index = 1 : L
    C(c(index), :) = D(d(index), :);
end

end

