function [quantizedTransformBlock,reconstructedBlock, filter] = predictive_quantizer(transformBlock,frameName,tuSize, delta_iframe,delta_pframe)
% QPU_DZ Dead-zone predictive quantization
%[ind, filter, reconstr, predErrImg, qPredErrImg ] = qp_dz(x, delta)
% Input parameters:
%   x:  transformed residual block
%   delta: quantization interval
% Output parameters:
%   ind: quantized indexes, same size as x
%   filter: the filter used for spatial prediction
%   reconstr: the reconstructed quantized image
%   predErrImg: prediction error image
%   qPredErrImg: the quantized prediction error image
%(C) 2015-2016 M. Cagnazzo Telecom-ParisTech
%
%Initializations
[height, width] = size(transformBlock);
quantizedTransformBlock  = zeros(height,width);
reconstructedBlock =  zeros(height,width);
%% Prediction filter

%select here the predictor type
predictorType = 1;
%  1 = Two neighbors, [1/2 1/2]
%  2 = Two neighbors, optimal filter   ## NOT IMPLEMENTED YET
%  3 = Three neighbors, optimal filter ## NOT IMPLEMENTED YET
%  4 = Four neighbors, optimal filter  ## NOT IMPLEMENTED YET

switch predictorType
    case 1
        filter = [1/2 1/2 0 0]';
        %     case {2,3,4}
        %         filter = optimalPredictor(x,predictorType);
    otherwise
        filter = [1/2 1/2 0 0]'; % Default
end
type = strtok(frameName,'_');

if strcmp(type,'iframe')
    delta = delta_iframe;
else
    delta = delta_pframe;
end
b_index_x = 1;
b_index_y = 1;
%scan the Transform blocks and quantize each one independently
for i=1:tuSize:height
    for j=1:tuSize:width
        x = transformBlock(i:i+tuSize-1,j:j+tuSize-1);
        [ROWS, COLS] = size(x);
        xq = zeros(ROWS+1,COLS+2); % expand the transform unit to allow prediction
        predImg = zeros(ROWS,COLS);
        ind=zeros(ROWS,COLS); %Quantized transform block
        predErrImg =zeros(ROWS,COLS);
        qPredErrImg = zeros(ROWS,COLS);
        for row = 2:ROWS+1     % image expansion to manage out-of-border filtering
            for col = 2:COLS+1
                % row and col scan through the expanded image xq. The corresponding
                % indices on x are (row-1) and (col-1)
                % Samples for prediction are taken from the quantized decoded image
                % Note that xq has been initialzed as zero everywhere
                pastSamples = [ xq(row-1,col) xq(row,col-1) xq(row-1,col-1) xq(row-1,col+1) ]' ;
                
                if row==2, flt = [ 0 1 0 0]';  % First row: special case
                elseif col==2, flt = [1 0 0 0]'; % First col: special case
                elseif col==COLS+1, flt = [1/2 1/2 0 0]'; % Last col: special case
                else flt=filter; % General case
                end
                % Compute prediction
                pred = flt'*pastSamples;
                % Compute preidiction error
                predErr = x(row-1,col-1)-pred; % current sample is in (row-1,col-1)
                % Quantization encoding, DZ-QU
                ind(row-1,col-1) = fix(predErr/delta);
                % Quantization decoding
                qPredErr = delta*ind(row-1,col-1)  + (ind(row-1,col-1)~=0).*sign(ind(row-1,col-1) ).*delta/2 ;
                % Decoded quantized image
                xq(row,col) = qPredErr + pred;
                % Store the prediction
                predImg(row-1,col-1) = pred;
                % Store the quantization error
                predErrImg(row-1,col-1) = predErr;
                % Store the quantized prediction error
                qPredErrImg(row-1,col-1) = qPredErr;
            end
        end
        quantizedTransformBlock(i:i+tuSize-1,j:j+tuSize-1) = ind;
        reconstructedBlock(i:i+tuSize-1,j:j+tuSize-1) = xq(2:ROWS+1,2:COLS+1);
    end
end

% else
%     delta = delta_pframe;
%     for row = 2:ROWS+1     % image expansion to manage out-of-border filtering
%         for col = 2:COLS+1
%             pastSamples = [ xq(row-1,col) xq(row,col-1) xq(row-1,col-1) xq(row-1,col+1) ]' ;
%             if row==2, flt = [ 0 1 0 0]';  % First row: special case
%             elseif col==2, flt = [1 0 0 0]'; % First col: special case
%             elseif col==COLS+1, flt = [1/2 1/2 0 0]'; % Last col: special case
%             else flt=filter; % General case
%             end
%             % Compute prediction
%             pred = flt'*pastSamples;
%             % Compute preidction error
%             predErr = x(row-1,col-1)-pred; % current sample is in (row-1,col-1)
%             % Quantization encoding, DZ-QU
%             ind(row-1,col-1) = fix(predErr/delta);
%             % Quantization decoding
%             qPredErr = delta*ind(row-1,col-1)  + ...
%                 (ind(row-1,col-1)~=0).*sign(ind(row-1,col-1) ).*delta/2 ;
%             % Decoded quantized image
%             xq(row,col) = qPredErr + pred;
%             % Store the prediction
%             predImg(row-1,col-1) = pred;
%             % Store the quantization error
%             predErrImg(row-1,col-1) = predErr;
%             % Store the quantized prediction error
%             qPredErrImg(row-1,col-1) = qPredErr;
%         end
%     end
% end
% quantizedTransformBlock = ind;
% Remove expanded data
% reconstructedBlock = xq(2:ROWS+1,2:COLS+1);
end