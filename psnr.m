  function [PSNR1,mse]=psnr(X,Y)
% function [PSNR,mse]=psnr(X,Y)
% Peak signal to noise ratio of the difference between images and the 
% mean square error
%    If the second input Y is missing then the PSNR and MSE of X itself 
% becomes the output (as if Y=0).

if nargin<2, D=X;
else
   if any(size(X)~=size(Y)), 
       error('The input size is not equal to each other');
   end
   D=X-Y;
end

mse=sum(D(:).*D(:))/prod(size(X));
PSNR1=10*log10(255^2/mse);
