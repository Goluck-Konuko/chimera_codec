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
residuals = struct();
mvfs =struct();
prediction_modes = struct();
%transform blocks
transformBlocks = struct();
%Quantized transforms
quantizedTransformBlocks = struct();
%%
%Each access unit consists of a header and payload
header = struct('type','vps|sps|pps|mvf|data','encoding','ex-gollomb|Cabac|vlc','length',0);
%Payloads
vps = struct('profile','0|1|2|3','bit_depth',8,'gop_size',10,'dimensions',[1920 1080]);
sps = struct('number',0);
pps = struct('type','I|P|B','number',0,'dts',0,'cts',0,'ref',[],'qp',4,'eof',0);
data =struct('number',0,'arr',[]);





