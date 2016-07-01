classdef SystemIndices 
    %SYSTEMINDICES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties  
      
        kprime;
        J;
        S;
        H;
        W; 
        
        length;
    end
    
    methods
        function this = SystemIndices()
            this.length = 0;
            this.kprime = [];
            this.J = [];
            this.S = [];
            this.H = [];
            this.W = [];
        end
        
        function [kprime, J, S, H, W] = search(this, k)
            
            for index = 1 : this.length
                
                if(this.kprime(index) > k)
                    kprime = this.kprime(index);
                    J = this.J(index);
                    S = this.S(index);
                    H = this.H(index);
                    W = this.W(index);
                    break;
                end
            end
            
        end
        
        function [] = add(this, kprime, J, S, H, W)
            this.length = this.length + 1;
            this.kprime = [this.kprime; kprime];
            this.J = [this.J; J];
            this.S = [this.S; S];
            this.H = [this.H; H];
            this.W = [this.W; W];
        end
        
    end
    
end

