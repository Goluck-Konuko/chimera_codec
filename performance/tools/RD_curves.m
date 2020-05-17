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
delta_pframe = 8;
searchStrategy = 1; % 1 for hexagon search, 0 for full search
searchWindow = 16; % only used for full search

%% RD and PSNR curves varying delta_iframe
x = uint8(readFrame(fileName,1));

dyn = 2^bitDepth;
nPoints = 20;
DELTA_IFRAME= fliplr(logspace(-1,log10(256),nPoints));
R=  zeros(size(DELTA_IFRAME));
D = zeros(size(DELTA_IFRAME));
PSNR = zeros(size(DELTA_IFRAME));
for iDelta = 1:numel(DELTA_IFRAME)
    delta_iframe = DELTA_IFRAME(iDelta);
    [~,~,decoded_sequence,~,~,~,nalus] = encoder_for_analysis(colorspace,sequenceName,resolution,profile,...
            nFrames,height,width,bitDepth,gopSize,gopType,blockSize,tuSize,delta_iframe,delta_pframe,searchStrategy,searchWindow);
    R(iDelta) = length(nalus.iframe_1); % interested here in first I-frame
    XQ = decoded_sequence.iframe_1;
    D(iDelta)=  mean( (x(:)-XQ(:)).^2  ); % Is it also exactly holding for yuv frames?
    PSNR(iDelta) = 10*log10( dyn^2 / D(iDelta) );
end

% Compute the compression ratios
size_x = height*width*8*3;  %yuv frame
compression_ratios = zeros(size(DELTA_IFRAME));

for iDelta = 1:numel(DELTA_IFRAME)
    size_xq = R(iDelta);
    compression_ratios(iDelta) = size_xq/size_x;
end
%% Figures
figure; h=plot(R,D, '-x'); title('D(R) curve for first I frame in flower-cif.yuv, varying delta-iframe');
xlabel('Rate [bits]'); ylabel('D - MSE'); set(h,'LineWidth',2);
savefig('flower_cif.yuv_i1_RD__delta_iframe.fig');

figure; h=plot(R,PSNR, '-x');  title('PSNR(R) curve for first I frame in flower-cif.yuv, varying delta-iframe');
xlabel('Rate [bits]'); ylabel('PSNR [dB]'); set(h,'LineWidth',2);
savefig('flower_cif.yuv_i1_RPSNR__delta_iframe.fig');

%% Save variables
save('flower_cif.yuv_i1__delta_iframe.mat');

%%

%% RD and PSNR varying delta_pframe
x = uint8(readFrame(fileName,2));

dyn = 2^bitDepth;
nPoints = 20;
DELTA_PFRAME= fliplr(logspace(-1,log10(256),nPoints));
R=  zeros(size(DELTA_PFRAME));
D = zeros(size(DELTA_PFRAME));
PSNR = zeros(size(DELTA_PFRAME));
for iDelta = 1:numel(DELTA_PFRAME)
    delta_pframe = DELTA_PFRAME(iDelta);
    [~,~,decoded_sequence,~,~,~,nalus] = encoder_for_analysis(colorspace,sequenceName,resolution,profile,...
            nFrames,height,width,bitDepth,gopSize,gopType,blockSize,tuSize,delta_iframe,delta_pframe,searchStrategy,searchWindow);
    R(iDelta) = length(nalus.iframe_2); % interested here in first P-frame
    XQ = decoded_sequence.iframe_2;
    D(iDelta)=  mean( (x(:)-XQ(:)).^2  ); % Suppose also holding for yuv frames
    PSNR(iDelta) = 10*log10( dyn^2 / D(iDelta) );
end

% Compute the compression ratios
size_x = height*width*8*3;  %yuv frame
compression_ratios = zeros(size(DELTA_PFRAME));

for iDelta = 1:numel(DELTA_PFRAME)
    size_xq = R(iDelta);
    compression_ratios(iDelta) = size_xq/size_x;
end
%% Figures
figure; h=plot(R,D, '-x'); title('R(D) curve for first P frame in flower-cif.yuv, varying delta-pframe');
xlabel('Rate [bits]'); ylabel('D - MSE'); set(h,'LineWidth',2);
savefig('flower_cif.yuv_p2_2_RD__delta_pframe.fig');

figure; h=plot(R,PSNR, '-x');  title('PSNR(R) curve for first P frame in flower-cif.yuv, varying delta-pframe');
xlabel('Rate [bits]'); ylabel('PSNR [dB]'); set(h,'LineWidth',2);
savefig('flower_cif.yuv_p2_2_RPSNR__delta_pframe.fig');

%% Save variables
save('flower_cif.yuv_p2_2__delta_pframe.mat');
    
%%

%% RD and PSNR curves when changing profile type (only I (0) or IPP (1))
% Run a first time
x = uint8(readFrame(fileName,2)); 

dyn = 2^bitDepth;
nPoints = 20;
DELTA_PFRAME= fliplr(logspace(0,log10(128),nPoints));
R_p0=  zeros(size(DELTA_PFRAME)); % Rate for profile==0
R_p1 = zeros(size(DELTA_PFRAME)); % Rate for profile==1
D_p0 = zeros(size(DELTA_PFRAME));
D_p1 = zeros(size(DELTA_PFRAME));
PSNR_p0 = zeros(size(DELTA_PFRAME));
PSNR_p1 = zeros(size(DELTA_PFRAME));

for iDelta = 1:numel(DELTA_PFRAME)
    delta_pframe = DELTA_PFRAME(iDelta);
    [~,~,decoded_sequence_p0,~,~,~,nalus_p0] = encoder_for_analysis(colorspace,sequenceName,resolution,0,...
            nFrames,height,width,bitDepth,gopSize,gopType,blockSize,tuSize,delta_pframe,delta_pframe,searchStrategy,searchWindow); 
    [~,~,decoded_sequence_p1,~,~,~,nalus_p1] = encoder_for_analysis(colorspace,sequenceName,resolution,1,...
            nFrames,height,width,bitDepth,gopSize,gopType,blockSize,tuSize,delta_pframe,delta_pframe,searchStrategy,searchWindow); 
    R_p0(iDelta) = length(nalus_p0.iframe_2);
    R_p1(iDelta) = length(nalus_p1.pframe_1_2);
    XQ_p0 = decoded_sequence_p0.iframe_2;
    XQ_p1 = decoded_sequence_p1.pframe_1_2;
    D_p0(iDelta)=  mean( (x(:)-XQ_p0(:)).^2  ); 
    D_p1(iDelta)=  mean( (x(:)-XQ_p1(:)).^2  ); 
    PSNR_p0(iDelta) = 10*log10( dyn^2 / D_p0(iDelta) );
    PSNR_p1(iDelta) = 10*log10( dyn^2 / D_p1(iDelta) );
end

    
% Compute the compression ratios
size_x = height*width*8*3;  %yuv frame
compression_ratios_p0 = zeros(size(DELTA_PFRAME));
compression_ratios_p1 = zeros(size(DELTA_PFRAME));

for iDelta = 1:numel(DELTA_PFRAME)
    size_xq_p0 = R_p0(iDelta);
    size_xq_p1 = R_p1(iDelta);
    compression_ratios_p0(iDelta) = size_xq_p0/size_x;
    compression_ratios_p1(iDelta) = size_xq_p1/size_x;
end
%% Figures
figure; h=plot(R_p0,D_p0,'bx-',R_p1,D_p1,'rx-'); title('D(R) curves for second frame in flower-cif.yuv, varying GOP profile');
xlabel('Rate [bits]'); ylabel('D - MSE'); set(h,'LineWidth',2);
legend('0: only I-frames','1: IPPP..');
savefig('flower_cif.yuv_2_RD__profile.fig');

figure; h=plot(R_p0,PSNR_p0,'bx-',R_p1,PSNR_p1,'rx-');  title('PSNR(R) curves for second frame in flower-cif.yuv, varying GOP profile');
xlabel('Rate [bits]'); ylabel('PSNR [dB]'); set(h,'LineWidth',2);
legend('0: only I-frames','1: IPPP..');
savefig('flower_cif.yuv_2_RPSNR__profile.fig');

%% Save variables
save('flower_cif.yuv_2__profile.mat');

%%

%% Studying GOP structure
dyn = 2^bitDepth;
nFrames = 11;
R=  zeros(1,nFrames-1);
D = zeros(1,nFrames-1);
PSNR = zeros(1,nFrames-1);
profile = 1;
[~,~,decoded_sequence,~,~,~,nalus] = encoder_for_analysis(colorspace,sequenceName,resolution,profile,...
        nFrames,height,width,bitDepth,gopSize,gopType,blockSize,tuSize,delta_iframe,delta_pframe,searchStrategy,searchWindow);

for n=1:nFrames-1
    x = uint8(readFrame(fileName,n));
    if (n==1)
        R(n) = length(nalus.iframe_1); % interested here in first P-frame
        XQ = decoded_sequence.iframe_1;
    else
        R(n) = length(nalus.(strcat('pframe_1_',int2str(n)))); % interested here in first P-frame
        XQ = decoded_sequence.(strcat('pframe_1_',int2str(n)));
    end
    D(n)=  mean( (x(:)-XQ(:)).^2  ); % Suppose also holding for yuv frames
    PSNR(n) = 10*log10( dyn^2 / D(n) ); 
end

% Compute the compression ratios
size_x = height*width*8*3;  %yuv frame
compression_ratios = zeros(1,nFrames-1);

for n=1:nFrames-1
    size_xq = R(n);
    compression_ratios(n) = size_xq/size_x;
end

%% Figures
inp = 1:nFrames-1;
figure; h=plot(inp,D,'x-'); title('Distortion curve in flower-cif.yuv for different frames within the same GOP');
xlabel('Frame number'); ylabel('D - MSE'); set(h,'LineWidth',2);
savefig('flower_cif.yuv_mse_study.fig');

figure; h=plot(inp,PSNR,'x-');  title('PSNR curve in flower-cif.yuv for different frames within the same GOP');
xlabel('Frame number'); ylabel('PSNR [dB]'); set(h,'LineWidth',2);
savefig('flower_cif.yuv_PSNR_study.fig');

%% Save variables
save('flower_cif.yuv_study.mat');