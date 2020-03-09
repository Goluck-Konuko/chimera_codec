function [vps,pps,decoded_sequence,residuals,prediction_modes,mvfs] = encoder_for_analysis(colorspace,sequenceName,resolution,profile,...
    nFrames,height,width,bitDepth,gopSize,gopType,blockSize,tuSize,delta_iframe,delta_pframe,searchStrategy,searchWindow)
% Useful for further performance analysis

% colorspace = 'yuv';
% sequenceName = 'flower'; 
% resolution = 'cif';
% profile  =  1; %0-Only I frames,1- I and P frames,2- I,B,P,3- I,B,B,P 
fileName = [sequenceName '_' resolution '.' colorspace];
% nFrames = 5;
% height = 288;
% width = 352;
% bitDepth = 8;
% gopSize = 10;
% gopType = 0; %closed GOP | set to 1 for open GOP
% blockSize = 16; %prediction block size
% tuSize = 8; %Transform block size
% delta_iframe = 8;
% delta_pframe = 16;
% searchStrategy = 1;
% searchWindow = 16;



tic
%create the video parameter set
vps.profile = profile;
vps.bitDepth = bitDepth;
vps.gopSize = gopSize;
vps.height = height;
vps.width = width;
vps.nFrames = nFrames;


%create the Sequence Parameter set
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
    %create the PPS
    pps.type = frameName;
    pps.number = frame;
    pps.ref = frame-1;
    
    
    [decodedFrame, newReferenceFrame,residualBlock,modes,mvf]  = encode(currentFrame, referenceFrame,frameName, colorspace,blockSize,tuSize,delta_iframe,delta_pframe,profile,searchStrategy,searchWindow);
    decoded_sequence.(frameName) = decodedFrame;
    residuals.(frameName) = residualBlock;
    if strcmp(strtok(frameName,'_'),'iframe')
        referenceFrame = newReferenceFrame;%update the reference frame
        prediction_modes.(frameName) = modes;
    else
        %annex this condition to add the mvf block for coding
       mvfs.(frameName) = mvf;
       if strcmp(colorspace, 'yuv')
           prediction_modes.(frameName) = modes; %for the chroma channels
       end
       if gopType==1
           referenceFrame = newReferenceFrame;%update the reference frame
       end
    end
    %Encode the quantized values into a bitstream
end
toc
