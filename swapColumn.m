function [ matrix ] = swapColumn( matrix, colA, colB )
%SWAPCOLUMN 

tempA = matrix(:, colA);
matrix(:, colA) = matrix(:, colB);
matrix(:, colB) = tempA;

end

