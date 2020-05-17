%%
%load configuration file
cfg

eStart = tic;
%initialize the frames
referenceFrame = zeros(height,width);
reconstructed_video = [];
Y = {};
U = {};
v = {};

bitstream_size = 0;

%ENCODING LOOP
gopCount = 0;
for frame=1:nFrames-1 %loop through the entire sequence
    fprintf("::Encoding frame: %d",frame);
    start_text = sprintf("::Encoding frame: %d... \n",frame);
    start = tic;
    bitstream = [];
    %Organize the video sequence into a sequence of GOPs
    if profile==0
        [currentFrame,frameName] = sequence_parser(fileName,gopCount,gopSize,frame,profile);
    else
        [currentFrame,frameName] = sequence_parser(fileName,gopCount,gopSize,frame,profile);
        %dynamically change how gops are incremented
        if mod(frame,gopSize) == 0
            gopCount = gopCount + 1;
        end
    end
        
    [decodedFrame, newReferenceFrame,residualBlock,modes,mvf]  = encode(currentFrame, referenceFrame,frameName, colorspace,blockSize,tuSize,delta_iframe,delta_pframe,profile,searchStrategy,searchWindow,intraMode);
    [nalu] = entropy_coder_residuals(residualBlock,tuSize,colorspace); 
    bitstream  = [bitstream nalu];
    if strcmp(strtok(frameName,'_'),'iframe')
        referenceFrame = newReferenceFrame;%update the reference frame
    else
       %annex this condition to add the mvf block for coding
       [nalu_mvfs] = entropy_coder_mvfs(mvf,blockSize);
       bitstream  = [bitstream nalu_mvfs]; %add coded mvfs to bitstream
       if gopType==1
           referenceFrame = newReferenceFrame;%update the reference frame
       end
    end
    %nalus.(frameName) = bitstream;
    bitstream_size = bitstream_size + length(bitstream);
    %implement reconstruction for y- sequence
    if strcmp(colorspace, 'y')
        Y{frame} = decodedFrame(:,:,1);
    else
        Y{frame} = decodedFrame(:,:,1);
        U{frame} = imresize(decodedFrame(:,:,2), 0.5);
        V{frame} = imresize(decodedFrame(:,:,3), 0.5);
    end
    stop = toc(start);
    PSNR = psnr(double(decodedFrame(:,:,1)), currentFrame(:,:,1), 255);
    bitstream_len = length(bitstream)/8000;
    fprintf("..Frame: %d PSNR: %.3f Apr NALU Size: %.0f KB .Elapsed time: %.4f seconds \n",frame,PSNR,bitstream_len, stop)
    stop_text = sprintf("Frame: %d PSNR: %.3f Apr NALU Size: %.0f KB Elapsed time: %.3f seconds \n",frame,PSNR,bitstream_len, stop);
    fid = fopen(strcat("data/logs/",sequenceName,"_",int2str(delta_iframe),"_",int2str(delta_pframe),".txt"), "a");
    fwrite(fid,stop_text);
    fclose(fid);
end
%save reconstructed frame
if strcmp(colorspace,'yuv')
    yuv_export(Y,U,V, strcat("data/reconstructed/",sequenceName,"_",int2str(delta_iframe),"_",int2str(delta_pframe),".yuv"),nFrames-1,"w");
end
%compute bitrate
comp_bitrate = bitstream_size/(1000*fps);
%compute file compression ratio
if strcmp(colorspace,'y')
    raw_media_size = height*width*8*nFrames;
else
    raw_media_size = height*width*3*8*nFrames;
end
raw_bitrate = raw_media_size/(1000*fps);
comp_ratio = 100 - ((bitstream_size/raw_media_size)*100);
eStop = toc(eStart);
fprintf(":::METRICS SUMMARY::: \n Sequence: %s \n Raw_Bitrate: %.3f Kbps \n Compressed_Bitrate: %.3f Kbps \n Compression_ratio: %.2f percent \n Total Elapsed Time: %.3f seconds \n",sequenceName,raw_bitrate,comp_bitrate,comp_ratio, eStop);
summary = sprintf(":::METRICS SUMMARY::: \n Sequence: %s \n Raw_Bitrate: %.3f Kbps \n Compressed_Bitrate: %.3f Kbps \n Compression_ratio: %.2f percent \n",sequenceName,raw_bitrate,comp_bitrate,comp_ratio);
fid = fopen(strcat( "data/logs/",sequenceName,"_",int2str(delta_iframe),"_",int2str(delta_pframe),".txt"), "a");
fwrite(fid,summary);
fclose(fid);

