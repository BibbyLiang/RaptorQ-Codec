function [ nonZero ] = nonZerosInRow( matrix, row, startCol, endCol )
%NONZEROSINROW  

nonZero = 0;

for col = startCol : endCol
    
    if(matrix(row, col) ~= 0)
        nonZero = nonZero + 1;
    end
    
end

end

