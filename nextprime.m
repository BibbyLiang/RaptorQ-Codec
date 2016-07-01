function [ primenum ] = nextprime( num )

while(true)

    isprime = true;
    num = num + 1;
    sqtnum = round(sqrt(num));
    
    %check if it is divisible 
    for i = 2 : sqtnum
        if(mod(num, i) == 0)
            isprime = false;
            break;
        end
    end
    
    if(isprime)
        primenum = num;
        return;
    end
    
end


end

