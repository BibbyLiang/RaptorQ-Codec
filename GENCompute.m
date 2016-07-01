function [ indices ] = GENCompute( index, tupletGene, P, P1, W )
% compute encoding for matrix GENC

[d, a, b, d1, a1, b1] = tupletGene.getTuple(index);

indices = [];
indices = [indices; b];

%simulate encoding
for j = 1 : d
    b = mod(b + a, W);
    indices = [indices; b];
end

indices = sort(indices);

while(b1 >= P)
    b1 = mod(b1 + a1, P1);
end

indices = [indices; W + b1];

for j = 1 : d1 - 1
    
    while(true)
        b1 = mod(b1 + a1, P1);
        
        if(b1 < P)
            break;
        end
    end
    
    indices = [indices; W + b1];
    
end

end

