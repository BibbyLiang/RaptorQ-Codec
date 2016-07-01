function [ C ] = phase4(matrixA, D, d, c, L, i, MO)
%PHASE4

%"For each of the first i rows of U_upper, do the following: if the row has
% a nonzero entry at position j, and if the value of that nonzero entry is 
% b, then add to this row b times row j of I_u."
 
%for each of the first i rows of U_upper
for row = 1 : i - 1
    
    for col = i : L
    
        b = matrixA(row, col);
        
        if(b == 0)
            continue;
        else 
            D = MO.addRowsInPlace(D, b, d(col), d(row)); 
        end
        
    end
end

C = phase5(matrixA, D, d, c, L, i, MO);

end

