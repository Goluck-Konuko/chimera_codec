function [residualBlock,predictionModes]= intraPrediction(currentFrame,frameName,blockSize)
%the block name indicates its index in the current slice
%The border blocks in intraprediction are copied directly into the
%residuals struct
%Prediction residuals are added after cost optimization
    type = strtok(frameName,'_'); %infer the frame type from its name
    %check type of frame
    if strcmp(type,'iframe')      
        %TODO pad the current frame to fit the block dimensions
        paddedFrame = padding(currentFrame,blockSize); 
        [height_p, width_p] = size(paddedFrame);
        residualBlock = zeros(height_p,width_p);
        predictionModes = zeros(height_p/blockSize,width_p/blockSize);
        m_index_x = 1;
        m_index_y = 1;
        %scan the current frame
        for i=1:blockSize:height_p
            for j=1:blockSize:width_p
                if i==1 %TODO send boundary blocks to residual struct
                   residualBlock(i:i+blockSize-1,j:j+blockSize-1) = currentFrame(i:i+blockSize-1,j:j+blockSize-1);
                   predictionModes(m_index_x,m_index_y) = 5;
                   if m_index_y == width_p/blockSize
                       m_index_y = 1;
                       m_index_x = m_index_x+1;
                   else
                      m_index_y = m_index_y+1; 
                   end
                elseif i>1 && j==1
                    residualBlock(i:i+blockSize-1,j:j+blockSize-1) = currentFrame(i:i+blockSize-1,j:j+blockSize-1);                   
                    predictionModes(m_index_x,m_index_y) = 5;
                    m_index_y = m_index_y+1;
                else
                    %create reference samples and do predictions with cost
                    prediction_unit = currentFrame(i:i+blockSize-1,j:j+blockSize-1);
                    left_ref = currentFrame(i:i+blockSize-1,j-1); %left reference samples
                    top_ref = currentFrame(i-1,j-1:j+blockSize-1); %top reference sample
                    [predOut, selectedMode] = mode_selection(left_ref, top_ref, prediction_unit,blockSize);
                    %[predOut, selectedMode] = py.hevc_intrapredictor.intra_predictor(left_ref, top_ref, prediction_unit,blockSize);
                    predictionModes(m_index_x,m_index_y) = selectedMode;
                    if m_index_y == width_p/blockSize
                        m_index_y=1;
                        m_index_x=m_index_x+1;
                    else
                        m_index_y = m_index_y+1;
                    end
                    puResiduals = int16((prediction_unit) - double(predOut));%compute residuals
                    residualBlock(i:i+blockSize-1,j:j+blockSize-1) = puResiduals; %add to the residual block
                end
            end
        end
    end
end