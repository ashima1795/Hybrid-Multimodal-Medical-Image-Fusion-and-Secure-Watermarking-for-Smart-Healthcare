alpha=[0.005;0.01;0.03;0.05;0.07;0.09;0.1;0.5];

for i=1:length(alpha)
    [p,s,nc,b,n]=DwTRdwtRsvd(alpha(i));
    PSNR(i)=p;
    SSIM(i)=s;
    NC(i)=nc;
    BER(i)=b;
    NPCR(i)=n;
end
