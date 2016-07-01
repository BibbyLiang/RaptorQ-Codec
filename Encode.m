function [ result ] = Encode( IS, d, a, b, d1, a1, b1, W, P, P1, MO)

result = IS(b + 1, :);

for j = 1 : d
    b = mod(b + a, W);
    result = MO.vectorVectorAddition(result, IS(b + 1, :));
end


while(b1 >= P)
    b1 = mod(b1 + a1, P1);
end
 
result = MO.vectorVectorAddition(result, IS(W + b1 + 1, :));


for j = 1 : d1 - 1
    b1 = mod(b1 + a1, P1);
    
    while(b1 >= P)
        b1 = mod(b1 + a1, P1); 
    end
     
    result = MO.vectorVectorAddition(result, IS(W + b1 + 1, :));
end

end

