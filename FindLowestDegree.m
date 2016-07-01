function [ rowIdx, colIdx ] = FindLowestDegree( matrix, rowpos )
% This function search for the highest degree row and col

[r, c] = size(matrix);
  
order = c + 1;

for row = rowpos : r
    tempOrder = length(find(matrix(row, :) ~= 0));
    
    if(tempOrder < order)
        order = tempOrder;
        [ignore, colIdx] = max(matrix(row, :));
        rowIdx = row;
    else
        continue;
    end 
    
end

end
