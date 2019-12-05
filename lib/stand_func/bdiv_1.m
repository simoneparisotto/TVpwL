%Function to calculate the divergence of a [n,m]-matrix using backward
%differences. The boundary extension mode is 0 for the 0' and n/m'th
%row/colomn
%
%!Remember! grad*=-div i.e. -div is dual operator of gradient
%
%div(v)_[i,j]=v_[i,j]-v_[i-1,j] + v_[i,j]-v_[i,j-1]

function [div_v] = bdiv_1(v)

n = size(v,1);
m = size(v,2);

div_v = zeros(n,m);

div_v(1,:) = v(1,:,1);
div_v(n,:) = -v(n-1,:,1);
div_v(2:n-1,:) = v(2:n-1,:,1) - v(1:n-2,:,1);


div_v(:,1) = div_v(:,1) + v(:,1,2);
div_v(:,m) = div_v(:,m) - v(:,m-1,2);
div_v(:,2:m-1) = div_v(:,2:m-1) + v(:,2:m-1,2) - v(:,1:m-2,2);