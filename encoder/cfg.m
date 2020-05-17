%Configuration file
colorspace = 'yuv';
sequenceName = 'foreman'; 
resolution = 'cif';
profile  =  1; %0-Only I frames,1- I and P frames,2- I,B,P,3- I,B,B,P 
fileName = [sequenceName '_' resolution '.' colorspace];

%sequence params
nFrames = 250;
fps = 30;
height = 288;
width = 352;
bitDepth = 8;

%conding parameters
gopSize = 10;
gopType = 0; %closed GOP | set to 1 for open GOP
blockSize = 8; %prediction block size
tuSize = 8; %Transform block size
intraMode = 0; % Set to 1 to evaluate intraprediction within pframes
delta_iframe = 4;
delta_pframe = 12;
searchStrategy = 1; % 0: full search | 1: hexagon search
searchWindow = 16;