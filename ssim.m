function fitness = ssim_sima(img,dn)
% function to compute structural similarity (SSIM) index
 
org_mean = mean2(img);
org_std = std2(img);
 
dn_mean = mean2(dn);
dn_std = std2(dn);
 
a = corr2(img,dn);
b = (2*org_mean*dn_mean)/((org_mean^2) + (dn_mean^2));
c = (2*dn_std*org_std)/((org_std^2) + (dn_std^2));
 
fitness = a*b*c;

