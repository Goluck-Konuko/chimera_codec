%Create a sequence of gops based on the desired profile
function [currentFrame,field] = sequence_parser(fileName,gopCount,gopSize,index,profile)
    if profile==0 %Only I frames will be encoded
            field = strcat('iframe_',int2str(index));
            currentFrame = readFrame(fileName, index);
    else
        if mod((index-1),gopSize)==0 %this is also an I frame within a gop
            field = strcat('iframe_',int2str(int8(index/gopSize)+1));
            currentFrame = readFrame(fileName, index);
        elseif gopCount==1
            field = strcat('pframe_',int2str(gopCount+1),'_',int2str(index-(gopSize*gopCount)));
            currentFrame = readFrame(fileName, index);
        else
            field = strcat('pframe_',int2str(gopCount+1),'_',int2str(index-(gopSize*gopCount)));
            currentFrame = readFrame(fileName, index);
        end
    end
end