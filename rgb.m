clear all;
close all;
clc;

addpath("nsst_toolbox");
alpha=0.9;

%% Watermark image
tic
wat_img = imread('chest.jpg');
wat_img=imresize(wat_img,[256 256]);
if ndims(wat_img) >= 2
    wat_img = rgb2gray(wat_img);
end

%% Read cover image and apply Dimentionality Reduction

cover=imread('lena_color_512.tif');
cover=imresize(cover,[512 512]);


r = cover(:,:,1);
g = cover(:,:,2);
b= cover(:,:,3);


%% Using Subsampling method FOR COVER IMAGE 

cover_img=r;
F1=zeros(256);F2=zeros(256);F3=zeros(256);F4=zeros(256);
for i=1:256
    for j=1:256 
       F1(i,j)=cover_img(2*i-1,2*j-1);
       F2(i,j)=cover_img(2*i-1,2*j);
       F3(i,j)=cover_img(2*i,2*j-1);
       F4(i,j)=cover_img(2*i,2*j);
    end  
end

%% Transforms NSST_SVD

% Cover decomposition
pfilt = 'maxflat';
shear_parameters.dcomp =[3,3,4,4];
shear_parameters.dsize =[8,8,16,16];
% pfilt = 'maxflat';
% shear_parameters.dcomp =[0 1 2 3];
% shear_parameters.dsize =[32 32 16 16];

[c_y1,c_shear_f1]=nsst_dec2(F1,shear_parameters,pfilt);

c_high=c_y1{1,3};
c_NSST=c_high(:,:,1);

% apply SVD in lower coefficient of NSST
[cU,cS,cV] = svd(c_NSST);
[wU,wS,wV] = svd(double(wat_img));

%% Embedding Procedure

watcC = cS + wS*alpha; %Watermark Embedding

% inverse MSVD
wtrmkd_nsst=cU*watcC*cV';

% inverse NSST

c_high(:,:,1)= wtrmkd_nsst;
c_y1{1,3}=c_high;

watermarked_F1 = nsst_rec2(c_y1,c_shear_f1,pfilt);

%% Using Inverse Subsampling 
for i=1:256
    for j=1:256
        Watermarked(2*i-1,2*j-1)=watermarked_F1(i,j);
        Watermarked(2*i-1,2*j)=F2(i,j);
        Watermarked(2*i,2*j-1)=F3(i,j);
        Watermarked(2*i,2*j)=F4(i,j);
    end
end

%% Inverse HSI
watermarked_cover = cat(3,Watermarked,g,b);

pnsr = psnr(uint8(cover), uint8(watermarked_cover))
dE = imcolordiff(uint8(cover), uint8(watermarked_cover),"Standard","CIEDE2000");
mean(mean(dE))
ssim=multissim(uint8(cover), uint8(watermarked_cover))

% imshow(watermarked_cover/255)

% imwrite(uint8(watermarked_cover),'watermarked_cover.jpg');

%% attack

%% Salt & Pepper Noise
%    Watermarked=imnoise(uint8(Watermarked),'salt & Pepper', 0.001);

%% Gaussian Noise
  % Watermarked=imnoise(uint8(Watermarked),'Gaussian',0,0.0001);

 
%% JPEG compression.
% imwrite (uint8(Watermarked), 'noise.jpg','jpg','quality',95);
% Watermarked = (imread ('noise.jpg'));

%% Cropping Attacks
% Watermarked = imcrop(uint8(Watermarked),[20 20 400 480]);  %%gives error due to SIZE
% Watermarked=imresize(Watermarked,[512 512]);

%% Rotate the image.
% Watermarked = imrotate(uint8(Watermarked),1);
% Watermarked = imresize (Watermarked,[512 512]);

%% Gaussian low-pass filter.
%  GLPF = fspecial ('gaussian', 1,.6);
%  Watermarked = filter2 (GLPF, Watermarked);

%% Sharpening Mask attack
% SM = fspecial('unsharp',0.5);       % value 0f alpha range from 0 to 1
% Watermarked = imfilter(Watermarked,SM,'replicate');

%% Median Filter Attack
% Watermarked = medfilt2((Watermarked),[2 2]);

%% Histogram equilization
% Watermarked=histeq(uint8(Watermarked));

%% Speckle Noise
% Watermarked=imnoise(uint8(Watermarked),'Speckle',0.05);

%% Scaling the image 
% Watermarked=imresize(Watermarked*2,size(Watermarked));

%% Translation attack
% Watermarked = imtranslate(Watermarked,[7, 7],'FillValues',255);

%% Extraction 

% received_img=imread("watermarked_cover.jpg");
received_img=Watermarked;

%% Using Subsampling method FOR COVER IMAGE 

rF1=zeros(256);rF2=zeros(256);rF3=zeros(256);rF4=zeros(256);
for i=1:256
    for j=1:256 
       rF1(i,j)=received_img(2*i-1,2*j-1);
       rF2(i,j)=received_img(2*i-1,2*j);
       rF3(i,j)=received_img(2*i,2*j-1);
       rF4(i,j)=received_img(2*i,2*j);
    end  
end

%% Transforms NSST_GSVD

% Cover decomposition
[r_y1,r_shear_f1]=nsst_dec2(rF1,shear_parameters,pfilt);

r_high=r_y1{1,3};
r_NSST=r_high(:,:,1);

% apply SVD in lower coefficient of NSST
[rU,rS,rV] = svd(r_NSST);

%% Extraction

ext_wS=(rS-cS)*(1/alpha);

ext_wat=wU*ext_wS*wV';
nc= corr2(uint8(ext_wat),wat_img)

% y=[0.9933, 0.9927,0.9914,0.9939,0.9931,0.9899,0.9939,0.9872,0.9924,0.9837];
% y1=[0.9144,0.7826,0.9111,0.9847,0.7941,0.988,0.9599,0.6797,0.5216,0.5883];
% figure, plot(y)
% hold on
% plot(y1)
% set(gca,'xtick',1:12,...
% 'xticklabel',{'Salt & Pepper','Rotation', 'JPEG Compr.','Speckle Noise','Cropping','Median Filter','Sharpening Mask', 'Hist. equalization', 'Scaling', 'Translation'})
% 
% figure
% 
% subplot(1,3,1); plot(imhist(cover(:,:,1)))
% hold on
% subplot(1,3,1);plot(imhist(uint8(watermarked_cover(:,:,1))));
% 
% subplot(1,3,2); plot(imhist(cover(:,:,2)))
% hold on
% subplot(1,3,2);plot(imhist(uint8(watermarked_cover(:,:,2))));
% 
% subplot(1,3,3); plot(imhist(cover(:,:,3)))
% hold on
% subplot(1,3,3);plot(imhist(uint8(watermarked_cover(:,:,3))));
% 
% figure(1);
% hold on;
% subplot(1,2,1);
% imhist(PlainImg)
% subplot(1,2,2);
% imhist(uint8(EncImg));






