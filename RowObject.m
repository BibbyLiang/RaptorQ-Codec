classdef RowObject < handle
    %ROWOBJECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        nonzeros = 0;
        isHDPC = 0;
        index = 0;
        degree = 0;
        nodes = [];
        
    end
    
    methods
        function this = RowObject() 
        end
    end
    
end

