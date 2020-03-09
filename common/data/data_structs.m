%%Video Parameter set
vps  = struct('colorspace', 'y','sequenceName', 'flower', 'resolution', 'cif', 'profile', 1,...
    'fileName', 'flower_cif.y','nFrames',3,...
    'height',288,'width',352,'bitDepth',8,'gopSize', 10,'gopType',0,'blockSize',16,...
    'tuSize', 8,'delta_iframe' ,8,'delta_pframe', 16,'searchStrategy',0,'searchWindow',16);

%%
access_unit = struct('number',0);
%%
%Seqeuence of GOPs in the video sequence with the desired profile
%can be individual frames(I frames) when profile is 0
gop_sequence = struct(); 
decoded_sequence = struct();
%%
%the block name indicates its index in the current slice
%The border blocks in intraprediction are copied directly into the
%residuals struct
%Prediction residuals are added after cost optimization
residuals_luma = struct();
residuals_chroma_1 = struct();
residuals_chroma_2 = struct();
mvfs =struct();
prediction_modes = struct();
prediction_modes_luma = struct();
prediction_modes_chroma_1 = struct();
prediction_modes_chroma_2 = struct();
%transform blocks
transformBlocks = struct();
%Quantized transforms
quantizedTransformBlocksLuma = struct();
quantizedTransformBlocksChroma_1 = struct();
quantizedTransformBlocksChroma_2 = struct();
%%
%Each access unit consists of a header and payload
header = struct('type','vps|sps|pps|mvf|data','encoding','ex-gollomb|Cabac|vlc','length',0);
%Payloads
vps = struct('profile','0|1|2|3','bit_depth',8,'gop_size',10,'dimensions',[1920 1080]);
sps = struct('number',0);
pps = struct('type','I|P|B','number',0,'dts',0,'cts',0,'ref',[],'qp',4,'eof',0);
data =struct();





