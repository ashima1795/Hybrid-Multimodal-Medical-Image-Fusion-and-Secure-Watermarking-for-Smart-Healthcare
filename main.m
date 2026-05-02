close all
clear all
clc

addpath shearlet\
addpath nsst_toolbox\

%% Step 1: Visible watermarking

vwatermark = imread('logo.jpg');
if ndims(vwatermark) > 2
    vwatermark=rgb2gray(vwatermark);
end
%Resize the watermark according to the area
modified = imresize(vwatermark,[64,64],'bilinear');
% disp(size(modified));

original_image = imread('img.png');
original_image = imresize(original_image,[512, 512]);


temp = zeros(size(original_image(: , : , 1)),'uint8');
[rows, cols, depth] = size(modified);
%Co-ordinnates to place the watermark
X = 448;
Y = 448;
temp(X:X+rows-1,Y:Y+cols-1,:) = modified;
v_alpha = 0.5;
f_cover1 = v_alpha * original_image  + (1-v_alpha)*temp;

temp = zeros(size(original_image(: , : , 2)),'uint8');
[rows, cols, depth] = size(modified);
%Co-ordinnates to place the watermark
X = 448;
Y = 448;
temp(X:X+rows-1,Y:Y+cols-1,:) = modified;
v_alpha = 0.5;
f_cover2 = v_alpha * original_image  + (1-v_alpha)*temp;

temp = zeros(size(original_image(: , : , 3)),'uint8');
[rows, cols, depth] = size(modified);
%Co-ordinnates to place the watermark
X = 448;
Y = 448;
temp(X:X+rows-1,Y:Y+cols-1,:) = modified;
v_alpha = 0.5;
f_cover3 = v_alpha * original_image  + (1-v_alpha)*temp;

fcover = cat(3, fcover1, fcover2, fcover3);


%% Image fusion 
A=imread("1img1.jpg");
B=imread("1img2.jpg");

A=imresize(A,[256,256]);
B=imresize(B,[256,256]);

if size(A,3)>1
    A = rgb2gray(A);
end

if size(B,3)>1
    B= rgb2gray(B);
end

fused_img = fun_DTCWT_NSST_PAPCNN(A,B);




function F = fun_DTCWT_NSST_PAPCNN(A,B)
% DTCWT decomposition

[Yl1,Yh1] = dtwavexfm2(double(A),1,'near_sym_a','qshift_a');
[Yl2,Yh2] = dtwavexfm2(double(B),1,'near_sym_a','qshift_a');

% NSST decomposition

pfilt = 'maxflat';
shear_parameters.dcomp =[3,3,4,4];
shear_parameters.dsize =[8,8,16,16];
[y1,shear_f1]=nsst_dec2(Yl1,shear_parameters,pfilt);
[y2,shear_f2]=nsst_dec2(Yl2,shear_parameters,pfilt);

% fusion of coefficients of nsst
y=y1;
y{1} = lowpass_fuse(y1{1},y2{1});
for m=2:length(shear_parameters.dcomp)+1
    temp=size((y1{m}));temp=temp(3);
    for n=1:temp
        Ahigh=y1{m}(:,:,n);
        Bhigh=y2{m}(:,:,n);
        y{m}(:,:,n)=highpass_fuse(Ahigh,Bhigh);
    end
end

% fusion of high coefficients of dtcwt
Yh=Yh1;
temp=size((Yh1{1,1}));temp=temp(3);
for n=1:temp
    Ahigh1=Yh1{1,1}(:,:,n);
    Bhigh1=Yh2{1,1}(:,:,n);
    Yh{1,1}(:,:,n)=highpass_fuse(Ahigh1,Bhigh1);
end
%  NSST reconstruction
F_Yl=nsst_rec2(y,shear_f1,pfilt);

% DTCWT reconstruction
F = dtwaveifm2(F_Yl,Yh,'near_sym_a','qshift_a');
end



%% PCA based watermarking using NSST and SVD


cover=fcover;
wat_img = fused_img;
alpha=0.5;


% PCA

[r,c,s]=size(cover);

img1=cover(:,:,1);
img2=cover(:,:,2);
img3=cover(:,:,3);

%to get elements along rows
temp1=reshape(img1',r*c,1);
temp2=reshape(img2',r*c,1);
temp3=reshape(img3',r*c,1);

I=[temp1 temp2 temp3];

%to get mean
m1=mean(I,2);

%subtract mean

for i=1:3
    I1(:,i)=(double(I(:,i))-m1);
end

%Find the covariance matrix and eigen vectors
a1=double(I1);
a=a1';
covv =1/(r-1)*(a*a');

[eigenvec, eigenvalue]=eig(covv);
eigenvalue1 = diag(eigenvalue);
[egn,index]=sort(-1*eigenvalue1);
eigenvalue1=eigenvalue1(index);
eigenvec1=eigenvec(:,index);

pcaoutput=a1*eigenvec1;
ima=reshape(pcaoutput(:,3)',r,c);  % taking the 3rd component
ima=ima';
Host_image=ima; %host image = 3rd component after pca

[Hrow,Hcol]=size(Host_image);

% PCA END

% Using Subsampling method FOR COVER IMAGE

cover_img=Host_image;
F1=zeros(256);F2=zeros(256);F3=zeros(256);F4=zeros(256);
for i=1:256
    for j=1:256
        F1(i,j)=cover_img(2*i-1,2*j-1);
        F2(i,j)=cover_img(2*i-1,2*j);
        F3(i,j)=cover_img(2*i,2*j-1);
        F4(i,j)=cover_img(2*i,2*j);
    end
end

% Transforms NSST_SVD

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

% Embedding Procedure

watcC = cS + wS*alpha; %Watermark Embedding

% inverse MSVD
wtrmkd_nsst=cU*watcC*cV';

% inverse NSST
c_high(:,:,1)= wtrmkd_nsst;
c_y1{1,3}=c_high;
watermarked_F1 = nsst_rec2(c_y1,c_shear_f1,pfilt);

% Using Inverse Subsampling
for i=1:256
    for j=1:256
        Watermarked(2*i-1,2*j-1)=watermarked_F1(i,j);
        Watermarked(2*i-1,2*j)=F2(i,j);
        Watermarked(2*i,2*j-1)=F3(i,j);
        Watermarked(2*i,2*j)=F4(i,j);
    end
end

% Inverse PCA

t1=reshape(Watermarked',Hrow*Hcol,1);
t2=pcaoutput;
t2(:,3)=real(t1);  %do the changes here
V_inv=inv(eigenvec1);
original=t2*V_inv;
for i=1:3
    I2(:,i)=(double(original(:,i))+m1);
end
I2=round(I2);
img6=reshape(I2(:,1)',r,c);
img6=img6';
img7=reshape(I2(:,2)',r,c);
img7=img7';
img8=reshape(I2(:,3)',r,c);
img8=img8';
watermarked_cover = cat(3, img6, img7, img8);

pr = psnr(uint8(cover), uint8(watermarked_cover));
ssim=multissim(uint8(cover), uint8(watermarked_cover));
ssim1=ssim(:,:,1);
ssim2=ssim(:,:,2);
ssim3=ssim(:,:,3);


% Extraction

% received_img=imread("watermarked_cover.jpg");
received_img=Watermarked;

% Using Subsampling method FOR COVER IMAGE

rF1=zeros(256);rF2=zeros(256);rF3=zeros(256);rF4=zeros(256);
for i=1:256
    for j=1:256
        rF1(i,j)=received_img(2*i-1,2*j-1);
        rF2(i,j)=received_img(2*i-1,2*j);
        rF3(i,j)=received_img(2*i,2*j-1);
        rF4(i,j)=received_img(2*i,2*j);
    end
end

% Transforms NSST_SVD

% Cover decomposition
[r_y1,r_shear_f1]=nsst_dec2(rF1,shear_parameters,pfilt);

r_high=r_y1{1,3};
r_NSST=r_high(:,:,1);

% apply SVD in lower coefficient of NSST
[rU,rS,rV] = svd(r_NSST);

% Extraction

ext_wS=(rS-cS)*(1/alpha);
ext_wat=wU*ext_wS*wV';
nc= corr2(uint8(ext_wat),wat_img);
