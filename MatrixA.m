classdef MatrixA < handle
    %MATRIXA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        kprime;
        P;
        P1;
        U;
        W;
        S;
        H;
        J;
        
        octetmath;
        randomizer;
        tupleGene;
    end
    
    properties
        MatrixL = [];
    end
    
    methods
        function this = MatrixA(kprime, P, P1, U, W, S, H, J, randNumGene, tupleGene)
            this.octetmath = OctetMath();
            this.randomizer = randNumGene;
            this.tupleGene = tupleGene;
            
            this.kprime = kprime;
            this.P = P;
            this.P1 = P1;
            this.U = U;
            this.W = W;
            this.S = S;
            this.H = H;
            this.J = J;
            
            L = kprime + S + H;
            this.MatrixL = zeros(L, L); 
        end
        
        function matL = getLMatrix(this)   
             %fill G_LPDC2
            this.GLPDC2();
            
            this.GLPDC1();
            
            this.initIS();
            
            % bottom half of matrix
            this.initTh();
            
            mt = this.generateMT();
            gamma = this.generateGamma();
            
            GHDPC = this.octetmath.GaloisMultiply(mt, gamma);
            
            for row = this.S + 1 : this.S + this.H
                for col = 1 : this.W + this.U
                    this.MatrixL(row, col) = GHDPC(row - this.S, col);
                end
            end
            
            % G_ENC 
            this.initGENC();
            
            matL = this.MatrixL;
        end
        
    end
    
    methods (Access = private)
        function this = GLPDC2(this)
            
            for i = 1 : this.S
                this.MatrixL(i, mod(i, this.P) + this.W) = 1;
                this.MatrixL(i, mod((i + 1), this.P) + this.W) = 1; 
            end
            
        end
        
        function this = GLPDC1(this)
            
            circulant_matrix = 0;
            B = (this.W - this.S);
            
            for col = 1 : B 
                
                circulant_matrix_column = mod(col, this.S);
                
                if(circulant_matrix_column ~= 1)
                
                    %cyclic down-shift
                    this.MatrixL(1, col) = this.MatrixL(this.S, col - 1);
                    
                    for row = 2 : this.S;
                        this.MatrixL(row, col) = this.MatrixL(row - 1, col - 1);
                    end
                    
                else 
                    this.MatrixL(1, col) = 1;
                    
                    % (i + 1) mod S
                    this.MatrixL( mod(circulant_matrix + 2, this.S), col) = 1;
                    
                    % (2 * (i + 1)) mod S
                    this.MatrixL( mod(2 * (circulant_matrix + 1) + 1, this.S), col) = 1;
                    
                    circulant_matrix = circulant_matrix + 1;
                    
                end
                
            end 
        end
        
        function this = initIS(this)
            
            B = (this.W - this.S);
            
            for i = 1 : this.S
                this.MatrixL(i, i + B) = 1;
            end
            
        end
        
        function this = initTh(this)
            lower_limit_col = this.W + this.U;
            
            for n = 1 : this.H
                this.MatrixL(n + this.S, n + lower_limit_col) = 1;
            end
            
        end
         
        function MT = generateMT(this)
            
            MT = zeros(this.H, this.kprime + this.S);
            
            for row = 1 : this.H 
                for col = 1 : this.kprime + this.S - 1 
                    
                    bah = this.randomizer.getRandomNumber(col, 6, this.H) + 1;
                    test1 = (row == bah);
                    modans = this.randomizer.getRandomNumber(col, 7, this.H - 1) + 1;
                    test2 = (row == mod(bah + modans, this.H));
                    
                    if(row == this.H)
                    
                        if(bah == this.H || (bah + modans) == this.H)
                            MT(row, col) = 1;
                        end
                        
                    else
                        if(test1 || test2)
                            MT(row, col) = 1;
                        end 
                    end
                    
                end 
            end
            
            for row = 1 : this.H
               MT(row, this.kprime + this.S) =  this.octetmath.alphaToI(row - 1);
            end
            
        end
        
        function gamma = generateGamma(this)
            
            gamma = zeros(this.kprime + this.S, this.kprime + this.S);

            alphaVec = zeros(1, 256);
            
            for i = 1 : 256
                alphaVec(i) = this.octetmath.alphaToI(i - 1);
            end
               
            %fill the matrix with the vector
            for row = 1 : this.kprime + this.S 
                
                col2fill = this.kprime + this.S - row + 1;
                currCol = 1;
                offset = row - 1;
                while(col2fill >= currCol)
                    
                    %figure out end point
                    endCol = currCol + length(alphaVec) - 1;
                    
                    if(endCol > col2fill)
                        endCol = col2fill;
                        gamma(currCol + offset : endCol + offset, row) = alphaVec(1 : (endCol - currCol + 1));
                    else
                        gamma(currCol + offset : endCol + offset, row) = alphaVec;
                    end
                    
                    currCol = endCol + 1; 
                end 
            end 
            
        end
        
        function this = initGENC(this)
            
            L = this.kprime + this.S + this.H;
            
            for row = this.S + this.H + 1 : L
  
                genc = GENCompute(row - this.S - this.H - 1, this.tupleGene, this.P, this.P1, this.W);
                
                %setting indices value to matrix A
                for idx = 1 : length(genc)
                    this.MatrixL(row, genc(idx) + 1) = 1;
                end
            end
        end
        
    end
    
end

