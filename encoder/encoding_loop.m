function [decodedFrame,residualBlock, referenceFrame] = encoding_loop(residualBlocks,frameName,referenceFrame,tuSize,delta_iframe,delta_pframe,prediction_modes,mvf,blockSize,profile)
        type = strtok(frameName,'_');
        %compute the transforms on each block
        transformBlockLuma = transformer(residualBlocks(:,:,1),tuSize);
        transformBlockChroma1 = transformer(residualBlocks(:,:,2),tuSize); 
        transformBlockChroma2 = transformer(residualBlocks(:,:,3),tuSize);
        %Quantize the transdform coefficients
         %Use different QP for the Iframes??
        [currentQuantizedTransformBlockLuma,reconstructedBlockLuma, filter] = predictive_quantizer(transformBlockLuma,frameName,tuSize, delta_iframe, delta_pframe);
        [currentQuantizedTransformBlockChroma1,reconstructedBlockChroma1, ~] = predictive_quantizer(transformBlockChroma1,frameName,tuSize, delta_iframe, delta_pframe);
        [currentQuantizedTransformBlockChroma2,reconstructedBlockChroma2, ~] = predictive_quantizer(transformBlockChroma2,frameName,tuSize, delta_iframe, delta_pframe);
        
        
        residualBlock(:,:,1) = currentQuantizedTransformBlockLuma;
        residualBlock(:,:,2) = currentQuantizedTransformBlockChroma1;
        residualBlock(:,:,3) = currentQuantizedTransformBlockChroma2;
        %Encode the quantized transform blocks
        %TODO- refine the entropy coding process
%         currentNALU = entropy_coder(currentQuantizedTransformBlock);
%         data.(frameName) = currentNALU;
%         %Decoding loop
%         %inverseQP
         reconstructedTransformBlockLuma = inverse_predictive_quantizer(currentQuantizedTransformBlockLuma,tuSize,delta_iframe,delta_pframe,frameName,filter);
         reconstructedTransformBlockChroma1 = inverse_predictive_quantizer(currentQuantizedTransformBlockChroma1,tuSize,delta_iframe,delta_pframe,frameName,filter);
         reconstructedTransformBlockChroma2 = inverse_predictive_quantizer(currentQuantizedTransformBlockChroma2,tuSize,delta_iframe,delta_pframe,frameName,filter);
        %IDCT
        inverseTransformBlockLuma = inverse_transformer(reconstructedTransformBlockLuma,tuSize);
        inverseTransformBlockChroma1 = inverse_transformer(reconstructedTransformBlockChroma1,tuSize);
        inverseTransformBlockChroma2 = inverse_transformer(reconstructedTransformBlockChroma2,tuSize);
        %---------------------------------------------------
        %DECODING LOOP
        %---------------------------------------------------
        if strcmp(type,'iframe')%decode intra-predicted frames
            decodedIntraFrameLuma = intra_frame_decoder(inverseTransformBlockLuma, prediction_modes(:,:,1),blockSize,'luma');
            decodedFrame(:,:,1) = uint8(decodedIntraFrameLuma);
            decodedIntraFrameChroma1 = intra_frame_decoder(inverseTransformBlockChroma1, prediction_modes(:,:,2),blockSize,'chroma');
            decodedFrame(:,:,2) = uint8(decodedIntraFrameChroma1);
            decodedIntraFrameChroma2 = intra_frame_decoder(inverseTransformBlockChroma2, prediction_modes(:,:,3),blockSize,'chroma');
            decodedFrame(:,:,3) = uint8(decodedIntraFrameChroma2);
            if profile==1 %set the iframe to the decoder buffer as the current reference
                referenceFrame = decodedIntraFrameLuma;
            end
        else %decode inter-predicted frames
            decodedInterFrameLuma = inter_frame_decoder(inverseTransformBlockLuma,referenceFrame, mvf, blockSize);
            decodedFrame(:,:,1) = uint8(decodedInterFrameLuma);
            decodedInterFrameChroma1 = intra_frame_decoder(inverseTransformBlockChroma1, prediction_modes(:,:,2),blockSize,'chroma');
            decodedFrame(:,:,2) = uint8(decodedInterFrameChroma1);
            decodedInterFrameChroma2 = intra_frame_decoder(inverseTransformBlockChroma2, prediction_modes(:,:,3),blockSize,'chroma');
            decodedFrame(:,:,3) = uint8(decodedInterFrameChroma2);
        end
end