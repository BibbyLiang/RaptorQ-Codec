classdef TupleGenerator 
    %TUPLEGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        J;
        W;
        P1; %prime number
        
        randomNumGenerator;
        degreeGenerator;
        
    end
    
    methods
        function this = TupleGenerator(J, W, P1, randNumGene, degreeGene)
            this.J = J;
            this.W = W;
            this.P1 = P1;
            this.randomNumGenerator = randNumGene;
            this.degreeGenerator = degreeGene;
        end
        
        %Provide X - ISI index
        function [d, a, b, d1, a1, b1] = getTuple(this, X)
            
            A = 53591 + this.J * 997;
            
            if(mod(A, 2) == 0)
                A = A + 1;
            end
            
            B = 10267 * (this.J + 1);
            
            y = (B + X * A);
            y = mod(y, 2^32);
            
            v = this.randomNumGenerator.getRandomNumber(y, 0, 2^20);
            d = this.degreeGenerator.getDegree(v);
            
            a = 1 + this.randomNumGenerator.getRandomNumber(y, 1, this.W - 1);
            b = this.randomNumGenerator.getRandomNumber(y, 2, this.W);
            
            %bound the degree to 2?
            if(d < 4)
                d1 = 2 + this.randomNumGenerator.getRandomNumber(X, 3, 2);
            else
                d1 = 2;
            end
            
            a1 = 1 + this.randomNumGenerator.getRandomNumber(X, 4, this.P1 - 1);
            b1 = this.randomNumGenerator.getRandomNumber(X, 5, this.P1);
        end
        
    end
    
end

