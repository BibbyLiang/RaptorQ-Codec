classdef DegreeGenerator 
    %DEGREEGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fd = [];
        W; %number generated during percoding
    end
    
    methods
        
        function this = DegreeGenerator(W)
            this.W = W;
            
            this.fd = [0;
                5243;
                529531;
                704294;
                791675;
                844104;
                879057;
                904023;
                922747;
                937311;
                948962;
                958494;
                966438;
                973160;
                978921;
                983914;
                988283;
                992138;
                995565;
                998631;
                1001391;
                1003887;
                1006157;
                1008229;
                1010129;
                1011876;
                1013490;
                1014983;
                1016370;
                1017662;
                1048576]; 
        end
        
        function deg = getDegree(this, v)
            
            for i = 1 : length(this.fd)
                if(this.fd(i) > v)
                    deg = i - 1;
                    break;
                end
            end
            
            deg = min(deg, this.W - 2);
            
        end
        
    end
    
end

