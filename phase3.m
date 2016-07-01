function [ C ] = phase3( matrixA, matrixX, D, d, c, L, i , octmath)
%PHASE3 

Arows = i - 1;
Acols = L;
Xrows = Arows;
Xcols = Arows;

matrixA = octmath.multiplyMatrix(matrixX(1:Xrows, 1:Xcols), matrixA(1:Arows,1:Acols));   

[ignore lenD] = size(D);
DM = zeros(Xrows, lenD);

%construct DM 
for row = 1 : Xrows
    DM(row,:) = D(d(row), :);
end
 
for t = 1 : Xrows 
    D(d(t), :) = octmath.multiplyRow(matrixX(t,1:Xrows), DM); 
end

C = phase4(matrixA, D, d, c, L, i, octmath);

end

