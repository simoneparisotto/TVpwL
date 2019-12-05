%Function to compare psnr-difference of two images x and y

function [psnr_v] = psnr(x,y)

x = double(x);
y = double(y);

[n,m] = size(x);

psnr_v = (sum(sum((x-y).^2)))/(n*m);

psnr_v = 10*log10(255^2/psnr_v);
end