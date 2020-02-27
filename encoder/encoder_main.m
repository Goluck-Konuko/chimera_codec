%%
colorspace = 'y';
sequenceName = 'flower'; 
resolution = 'cif';
profile  =  1; %0-Only I frames,1- I and P frames,2- I,B,P,3- I,B,B,P 
fileName = [sequenceName '_' resolution '.' colorspace];
nFrames = 10;
height = 288;
width = 352;
bitDepth = 8;
gopSize = 10;
blockSize = 16; %prediction block size
tuSize = 8; %Transform block size
delta_iframe = 16;
delta_pframe = 16;

% %insert python script to python path
% scriptPath = fileparts(which('hevc_intrapredictor.py','hevc_augmenter.py'));
% if count(py.sys.path,scriptPath)==0
%     insert(py.sys.path,int32(0),scriptPath);
% end

%ENCODING LOOP
gopCount = 0;
%initialize the frames
referenceFrame = zeros(height,width);
for frame=1:nFrames-1 %loop through the entire sequence
    %Organize the video sequence into a sequence of GOPs
    if profile==0
        [currentFrame,frameName] = sequence_parser(fileName,gopCount,gopSize,frame,profile);
    else
        [currentFrame,frameName] = sequence_parser(fileName,gopCount,gopSize,frame,profile);
        if mod(frame,gopSize) == 0
            gopCount = gopCount + 1;
        end
    end
    %perform predictions for the current frame
    type = strtok(frameName,'_');
    if strcmp(type,'pframe') %set the reference
        [residualBlock, mvf] = interPrediction(currentFrame, referenceFrame,blockSize);
        %store data for possible out-of-loop entropy coding
        residuals.(frameName) = residualBlock;
        mvfs.(frameName) = mvf;
    else
        [residualBlock, predictionModes] = intraPrediction(currentFrame,frameName,blockSize);
        %store data for possible out-of-loop entropy coding
        residuals.(frameName) = residualBlock;
        prediction_modes.(frameName) = predictionModes;
    end
    %compute the transforms on each block
    transformBlock = transformer(residualBlock,tuSize);
    %Quantize the transdform coefficients
    %Use different QP for the Iframes??
    [quantizedTransformBlock,reconstructedBlock, filter] = predictive_quantizer(transformBlock,frameName,tuSize, delta_iframe, delta_pframe);
    %Decoding loop
    %inverseQP
    reconstructedTransformBlock = inverse_predictive_quantizer(quantizedTransformBlock,tuSize,delta_iframe,delta_pframe,frameName,filter);
    %IDCT
    inverseTransformBlock = inverse_transformer(reconstructedBlock,tuSize);
    if strcmp(type,'iframe')%decode intra-predicted frames
        decodedIntraFrame = intra_frame_decoder(inverseTransformBlock, predictionModes,blockSize);
       %Adjust pixel values to fit [0 255]
        decoded_sequence.(frameName) = decodedIntraFrame;
        if profile==1 %set the iframe to the decoder buffer as the current reference
           referenceFrame = decodedIntraFrame; 
        end
    else %decode inter-predicted frames
        decodedInterFrame = inter_frame_decoder(inverseTransformBlock,referenceFrame, mvf, blockSize);
        decoded_sequence.(frameName) = decodedInterFrame;
    end
    %Encode the quantized values into a bitstream
end
% %compute the residuals and motion vectors(pframes) for all the frames
% [residuals,mvfs] = predictor(gopSequence, blockSize);
% %compute the dct transforms of the residuals
% transformBlocks = batch_transformer(residuals, tuSize);
% %Quantize the transformed residuals
% quantizedTransformBlocks = batch_quantizer(transformBlocks,delta_iframe, delta_pframe);
% %-for each GOP create a SPS
% %--create PPS
% %--Compose NALU for frame i.e header and payload


