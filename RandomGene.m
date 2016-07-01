classdef RandomGene
    %Radom Number Generator from Raptor Q
    
    properties
        
        V0 = [];
        V1 = [];
        V2 = [];
        V3 = [];
        
    end
    
    methods
        function this = RandomGene()
            load('randomTables.mat');
            this.V0 = V0Table;
            this.V1 = V1Table;
            this.V2 = V2Table;
            this.V3 = V3Table;
        end
        
        function randomNum = getRandomNumber(this, y, i, m)
            
            %compute indices
            x0 = mod(y + i, 2^8) + 1;
            
            x1 = floor(y / 2^8) + i;
            x1 = mod(x1, 2^8) + 1;
            
            x2 = floor(y / 2^16) + i;
            x2 = mod(x2, 2^8) + 1;
            
            x3 = floor(y / 2^24) + i;
            x3 = mod(x3, 2^8) + 1;
             
            %compute binary value 
            randomNum = bitxor(this.V0(x0), this.V1(x1));
            randomNum = bitxor(randomNum, this.V2(x2));
            randomNum = bitxor(randomNum, this.V3(x3));
            
            randomNum = mod(randomNum, m);
            
        end
         
    end
    
    
    
end

