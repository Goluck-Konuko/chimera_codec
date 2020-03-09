%% TO USE THIS FILE: run the encoder_main, and then use the stored variables in workspace

%% Open and read a given image from a yuv video
file = 'flower_cif.yuv';
k = 1;
frame = readFrame(file,k);

% image display with the correct colorspace
figure;
image(uint8(ycbcr2rgb(frame)));
axis image; axis off;

%% Display decoded image
imshow(ycbcr2rgb(decoded_sequence.iframe_1));

%% Parameters to set:
colorspace = 'yuv';
sequenceName = 'flower'; 
resolution = 'cif';
fileName = [sequenceName '_' resolution '.' colorspace];
profile  =  1; %0-Only I frames,1- I and P frames,2- I,B,P,3- I,B,B,P 
nFrames = 5;
height = 288;
width = 352;
bitDepth = 8;
gopSize = 10;
gopType = 0; %closed GOP | set to 1 for open GOP
blockSize = 16; %prediction block size
tuSize = 8; %Transform block size
delta_iframe = 8;
delta_pframe = 16;
searchStrategy = 1; % 1 for hexagon search, 0 for full search
searchWindow = 16; % only used for full search
%% Call encoder for analysis (necessary for later on)
[~,~,decoded_sequence,~,~,~] = encoder_for_analysis(colorspace,sequenceName,resolution,profile,...
    nFrames,height,width,bitDepth,gopSize,gopType,blockSize,tuSize,delta_iframe,delta_pframe,searchStrategy,searchWindow);

x = uint8(readFrame(fileName,1));

%% RD and PSNR curves varying delta_iframe

dyn = 2^bitDepth;
nPoints = 10;
DELTA_IFRAME= fliplr(logspace(1,log10(256),nPoints));
R=  zeros(size(DELTA_IFRAME));
D = zeros(size(DELTA_IFRAME));
PSNR = zeros(size(DELTA_IFRAME));
for iDelta = 1:numel(DELTA_IFRAME)
    delta_iframe = DELTA_IFRAME(iDelta);
    R(iDelta) = bitDepth-log2(delta_iframe);
    [~,~,decoded_sequence,~,~,~] = encoder_for_analysis(colorspace,sequenceName,resolution,profile,...
            nFrames,height,width,bitDepth,gopSize,gopType,blockSize,tuSize,delta_iframe,delta_pframe,searchStrategy,searchWindow);
    XQ = decoded_sequence.iframe_1;
    D(iDelta)=  mean( (x(:)-XQ(:)).^2  ); % Is it also exactly holding for yuv frames?
    PSNR(iDelta) = 10*log10( dyn^2 / D(iDelta) );
end
%% Figures
figure; h=plot(R,D, 'x'); title('D(R) curve for first I frame');
xlabel('Rate [bpp]'); ylabel('D - MSE'); set(h,'LineWidth',2);
figure; h=plot(R,PSNR, 'o');  title('PSNR(R) curve for first I frame');
xlabel('Rate [bpp]'); ylabel('PSNR [dB]');

%% Curves varying 
