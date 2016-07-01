function [ vector ] = swapVector( vector, target, source )
%SWAPVECTOR Summary of this function goes here
%   Detailed explanation goes here

temp = vector(source);

vector(source) = vector(target);

vector(target) = temp;


end

