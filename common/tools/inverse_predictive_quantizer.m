function reconstructedTransformBlock = inverse_predictive_quantizer(quantizedTransformBlock,tuSize,delta_iframe,delta_pframe,frameName,filter)
% Recontruction of predictive quantization
[height, width] = size(quantizedTransformBlock);
% initialization
reconstructedTransformBlock = zeros(height,width);
type = strtok(frameName,'_');
%Scan the TU blocks
for i=1:tuSize:height
    for j=1:tuSize:width
        ind = quantizedTransformBlock(i:i+tuSize-1,j:j+tuSize-1);
        [ ROWS , COLS] = size(ind);
        if strcmp(type,'iframe')
            delta = delta_iframe;
            qPredErrImg = delta*ind  + (ind~=0).*sign(ind).*delta/2;
        else
            delta = delta_pframe;
            qPredErrImg = delta*ind  + (ind~=0).*sign(ind).*delta/2;
        end
        xhat=zeros(ROWS+1,COLS+2);
        % The first sample in each block is quantized without prediction
        xhat(2,2) = qPredErrImg(1,1);   
        for row = 2:ROWS+1
            for col = 2:COLS+1
                pastSamples = [ xhat(row-1,col) xhat(row,col-1) xhat(row-1,col-1) xhat(row-1,col+1) ]' ;
                if row==2
                    if col==2
                        continue;
                    else
                        flt = [ 0 1 0 0]';
                    end
                elseif col==2
                    flt = [1 0 0 0]';
                elseif col==COLS+1
                    flt = [1/2 1/2 0 0]';
                else
                    flt=filter;
                end
                pred = flt'*pastSamples;
                xhat(row,col) = qPredErrImg(row-1,col-1)+pred;
            end
        end
        reconstructedTransformBlock(i:i+tuSize-1,j:j+tuSize-1)  = xhat(2:ROWS+1,2:COLS+1);
    end
end
end

