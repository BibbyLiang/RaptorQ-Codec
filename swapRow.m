function [ mat ] = swapRow( mat, target, source )
%SWAPROW Summary of this function goes here
%   Detailed explanation goes here

temp = mat(source, :);
mat(source, :) = mat(target, :);
mat(target, :) = temp;

end

