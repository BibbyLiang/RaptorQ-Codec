function [ matdata, numOfzeros ] = DataBreaker( rawdata, paylen )

% pad zeros

    matdata = [];
    len = length(rawdata);
    numOfPackets = floor(len / paylen);
    reminding = mod(len, paylen);
    
    numOfzeros = 0;
    
    for i = 1 : numOfPackets
        
        if(i == 1)
            startpt = 1;
            endpt = paylen;
        else
            startpt = (i - 1) * paylen + 1;
            endpt = i * paylen;
        end
        
        matdata = [matdata; rawdata(startpt : endpt)];
        
    end
    
    if(reminding > 0)
        
        numOfzeros = paylen - reminding;
         
        paddeddata = rawdata(len - reminding + 1 : len);
        
        for n = 1 : numOfzeros
            paddeddata = [paddeddata, 0];
        end
        
        matdata = [matdata; paddeddata];
        
    end
    

end

