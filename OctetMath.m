classdef OctetMath
    %OCTETMATH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        
        logArray = [];
        expArray = [];
        
    end
    
    methods
        function this = OctetMath()
            %load loop up table
            load('octets_math.mat');
            this.logArray = oct_log;
            this.expArray = oct_exp;
        end
        
        function a = log(this, number)
            a = this.logArray(number);
        end
        
        function a = exp(this, number) 
            a = this.expArray(number + 1);
        end
        
        function a = multiply(this, octet1, octet2)
            if(octet1 == 0 || octet2 == 0)
                a = 0;
            else
                a = this.exp(this.log(octet1) + this.log(octet2));
            end
        end
        
        function a = divide(this, octet1, octet2)
            
            if(octet1 == 0)
                a = 0;
            else
                a = this.exp(this.log(octet1) - this.log(octet2) + 255);
            end
        end
        
        function matrix = addRowsInPlace(this, matrix, bOA, sourceRow, destRow)
            
            [r, c] = size(matrix);
            
            for i = 1 : c
                matrix(destRow, i) = bitxor(matrix(destRow, i), this.multiply(bOA, matrix(sourceRow, i)));
            end
            
        end
        
        function matrix = divideRowInPlace(this, matrix, row, dividend)
            
            [r, c] = size(matrix);
            
            for i = 1 : c
                matrix(row, i) = this.divide(matrix(row, i), dividend);
            end
            
        end
        
        function matrix = divideRowsInPlace(this, matrix, r, beta)
            
            [ignore, c] = size(matrix);
            
            for i = 1 : c
            
                matrix(r, i) = this.divide(matrix(r, i), beta);
                
            end 
        end
        
        function matrix = multiplyMatrix(this, matrixA, matrixB)
            
            [mr, mc] = size(matrixA);
            [mrb, mcb] = size(matrixB);
            
            if(mc ~= mrb)
                error('dimension is different ');
            end
            
            matrix = zeros(mr, mcb);
            
            %row of A
            for row = 1 : mr
                
                %col of B
                for col = 1 : mcb
                    for x = 1 : mc
                        temp = this.multiply(matrixA(row, x), matrixB(x, col));
                        matrix(row, col) = bitxor(matrix(row, col), temp);
                    end
                    
                end
            end 
        end
        
        function matrix = multiplyRow(this, matRow, multiplicant)
            
            [numRows, numCols] = size(multiplicant); 
            matlen = length(matRow);
            if(numRows ~= matlen)
                error('Size of row and the size of column is different!');
            end
            
            matrix = zeros(1, numCols);
            
            for rs = 1 : numCols
                for c = 1 : matlen
                    temp = uint8(this.multiply(matRow(c), multiplicant(c, rs)));
                    matrix(rs) = bitxor(uint8(matrix(rs)), temp);
                end
            end
            
        end
        
        function vec = vectorVectorAddition(this, vec, target)
            
            for i = 1 : length(vec)
                vec(i) = bitxor(vec(i), target(i));
            end
            
        end
        
        function a = alphaToI(this, i)
            a = this.exp(i);
        end
        
        %% multiply 2 Galois matrices
        function matAns = GaloisMultiply(this, matA, matB)
            
            [matArow, matAcol] = size(matA); % m by n
            [matBrow, matBcol] = size(matB); % p by q
            
            % n should equal to p or break
            if (matAcol ~= matBrow)
                throw(MEexception('Matrices have incompatible size. Try again \n'));
            end
            
            %result is n by q matrix
            matAns = zeros(matArow, matBcol);
            
            %loop col of the multiplicant
            for row = 1 : matArow
                
                %loop col of the multipler
                for col = 1 : matBcol
                    matAns(row, col) = this.time(matA(row,:), matB(:,col));
                end 
            end
        end
        
        function m = time(this, vec1, vec2)
            m = 0;
            
            for i = 1 : length(vec1)
                m = bitxor(m, this.multiply(vec1(i), vec2(i)));
            end
        end
        
    end
end





