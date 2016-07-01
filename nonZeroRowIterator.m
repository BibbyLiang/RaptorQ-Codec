function [ nonZeros ] = nonZeroRowIterator( matrix, row, startCol, endCol )
%NONZEROROWITERATOR Summary of this function goes here
%   Detailed explanation goes here

nonZeros = {};

for col = startCol : endCol
    
    if(matrix(row, col) ~= 0)
        
        nonZeros = [nonZeros; {col, matrix(row, col)}];
        
    end
    
end

end

