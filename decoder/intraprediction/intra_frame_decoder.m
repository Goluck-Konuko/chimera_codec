function decodedIntraFrame = intra_frame_decoder(inverseTransformBlock, predictionModes,blockSize)
[height, width] = size(inverseTransformBlock);
%initialize
decodedIntraFrame = zeros(height,width);
m_index_x = 1;
m_index_y = 1;
for i=1:blockSize:height
    for j=1:blockSize:width
        if i==1 %TODO send boundary blocks to residual struct
            decodedIntraFrame(i:i+blockSize-1,j:j+blockSize-1) = inverseTransformBlock(i:i+blockSize-1,j:j+blockSize-1);
            if m_index_y == width/blockSize
                m_index_y = 1;
                m_index_x = m_index_x+1;
            else
                m_index_y = m_index_y+1;
            end
        elseif i>1 && j==1
            decodedIntraFrame(i:i+blockSize-1,j:j+blockSize-1) = inverseTransformBlock(i:i+blockSize-1,j:j+blockSize-1);
            m_index_y = m_index_y+1;
        else
            %initialize decoded PU
            prediction_unit = zeros(blockSize);
            %find the reference samples and do predictions
            left_ref = decodedIntraFrame(i:i+blockSize-1,j-1); %left reference samples
            top_ref = decodedIntraFrame(i-1,j-1:j+blockSize-1); %top reference samples
            predictionMode = predictionModes(m_index_x,m_index_y);
            predOut = mode_selection(left_ref, top_ref, prediction_unit,blockSize,predictionMode);
            %insert the decoded PU into the decoded Frame after adding the
            %residuals
            decodedIntraFrame(i:i+blockSize-1,j:j+blockSize-1) = predOut + inverseTransformBlock(i:i+blockSize-1,j:j+blockSize-1);
            if m_index_y == width/blockSize
                m_index_y=1;
                m_index_x=m_index_x+1;
            else
                m_index_y = m_index_y+1;
            end
        end
    end
end
end