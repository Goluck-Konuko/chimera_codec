function [decodedFrame, newReferenceFrame,finalResidualBlock,modes,mvf] = encode(currentFrame, referenceFrame,frameName, colorspace,blockSize,tuSize,delta_iframe,delta_pframe,profile,searchStrategy,searchWindow)
    %perform predictions for the current frame
    type = strtok(frameName,'_');
    %Initializations
    [height, width] = size(currentFrame(:,:,1));
    mvf = zeros(height,width,2);
%     residualBlock = zeros(height,width,3);
    newReferenceFrame = zeros(height,width,3);
    finalResidualBlock = zeros(height,width,3);
    %predictionModesLuma = [];
    modes = [];
    residualBlocks = [];
    if strcmp(colorspace,'y')
        %encode .y sequence
        if strcmp(type,'iframe')
            %encode an Iframe
            [residualBlockLuma, predictionModesLuma] = intraPrediction(currentFrame,blockSize,'luma');
            %store data for possible out-of-loop entropy coding
            modes(:,:,1) = predictionModesLuma;
        else
            %encode a Pframe
            %just interprediction
            [residualBlockLuma, mvf] = interPrediction(currentFrame, referenceFrame,blockSize,searchStrategy,searchWindow);
        end
        %compute the transforms on each block
        transformBlockLuma = transformer(residualBlockLuma,tuSize);
         %Use different QP for the Iframes??
        [currentQuantizedTransformBlockLuma,reconstructedBlockLuma, ~] = predictive_quantizer(transformBlockLuma,frameName,tuSize, delta_iframe, delta_pframe);
        %quantizedTransformBlocksLuma.(frameName) = currentQuantizedTransformBlockLuma;
        finalResidualBlock(:,:,1) = currentQuantizedTransformBlockLuma;
%       inverseQP
        %reconstructedTransformBlockLuma = inverse_predictive_quantizer(currentQuantizedTransformBlockLuma,tuSize,delta_iframe,delta_pframe,frameName,filter); 
        %IDCT
        inverseTransformBlockLuma = inverse_transformer(reconstructedBlockLuma,tuSize);
        %---------------------------------------------------
        %DECODING LOOP
        %---------------------------------------------------
        if strcmp(type,'iframe')%decode intra-predicted frames
            decodedIntraFrameLuma = intra_frame_decoder(inverseTransformBlockLuma, predictionModesLuma,blockSize,'luma');
            decodedFrame = uint8(decodedIntraFrameLuma);
            if profile==1 %set the iframe to the decoder buffer as the current reference
                newReferenceFrame = decodedIntraFrameLuma;
            end
        else %decode inter-predicted frames
            decodedInterFrameLuma = inter_frame_decoder(inverseTransformBlockLuma,referenceFrame, mvf, blockSize);
            decodedFrame = uint8(decodedInterFrameLuma);
        end
    else
    %encode yuv sequence
        if strcmp(type,'iframe')
            %encode a yuv Iframe
            %intra prediction for luma samples
            [residualBlockLuma,predictionModesLuma]  = intraPrediction(currentFrame(:,:,1),blockSize,'luma');
            %perform intra prediction for chroma channels
            [residualBlockChroma1,predictionModesChroma1]  = intraPrediction(currentFrame(:,:,2),blockSize,'chroma');
            [residualBlockChroma2,predictionModesChroma2]  = intraPrediction(currentFrame(:,:,3),blockSize,'chroma');
            
            %Data aggregation
            modes(:,:,1) = predictionModesLuma;
            modes(:,:,2) = predictionModesChroma1;
            modes(:,:,3) = predictionModesChroma2;
            residualBlocks(:,:,1) = residualBlockLuma;
            residualBlocks(:,:,2) = residualBlockChroma1;
            residualBlocks(:,:,3) = residualBlockChroma2;
            
            %generate the decoded frame after transformation and
            %quantization
            [decodedFrame,finalResidualBlock,referenceFrame] = encoding_loop(residualBlocks,frameName,referenceFrame,tuSize,delta_iframe,delta_pframe,modes,mvf,blockSize,profile);
            newReferenceFrame = referenceFrame;
        else
            %encode a yuv Pframe
            %interprediction for the luma channel
            [residualBlockLuma, mvf] = interPrediction(currentFrame(:,:,1), referenceFrame,blockSize,searchStrategy,searchWindow);
            %intra_prediction for the chroma channels
            [residualBlockChroma1,predictionModesChroma1]  = intraPrediction(currentFrame(:,:,2),blockSize,'chroma');
            [residualBlockChroma2,predictionModesChroma2]  = intraPrediction(currentFrame(:,:,3),blockSize,'chroma');
            modes(:,:,2) = predictionModesChroma1;
            modes(:,:,3) = predictionModesChroma2;
            residualBlocks(:,:,1) = residualBlockLuma;
            residualBlocks(:,:,2) = residualBlockChroma1;
            residualBlocks(:,:,3) = residualBlockChroma2;
            %generate the decoded frame after transformation and
            %quantization
            [decodedFrame,finalResidualBlock,referenceFrame] = encoding_loop(residualBlocks,frameName,referenceFrame,tuSize,delta_iframe,delta_pframe,modes,mvf,blockSize,profile);
        end
    end 
end