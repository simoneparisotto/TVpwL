function [u,res_final,iter,PD_gap,bound] = minimization_TV_PDHG( img, params )
%DO_MINIMIZATION Summary of this function goes here
%   Detailed explanation goes here

[M,N] = size(img);

%% COMPUTE THE DERIVATIVE OPERATOR OF ORDER Q FOR EACH Q, WEIGHTED BY M
% Compute derivatives along (i,j,k)
D  = Kmat(img);

%% COMPUTE SADDLE-POINT OPERATORS AND PROX

% F:= TV  is the vectorial soft thresholding.
K         = @(u)       cat(3,reshape(D{1}*u(:),M,N),reshape(D{2}*u(:),M,N));
KS        = @(y)       reshape( D{1}.'*reshape(y(:,:,1),M*N,1) + D{2}.'*reshape(y(:,:,2),M*N,1), M,N);
ProxFS    = @(y,sigma) y./repmat(max(1,norms(y,2,3)),1,1,size(y,3));

% G = box
%ProxG     = @(x,tau) (double(norms(x-img,2,3))<=params.bound).*x + (double(norms(x-img,2,3))>params.bound)*(img+params.bound.*(x-img)./norms(x-img,2,3));
ProxG     = @(x,tau) proxG_box(x,img,params.bound);

%% PRIMAL DUAL via Chambolle-Pock
[u,res_final,iter,PD_gap,bound] = primal_dual(img, K, KS, ProxFS, ProxG, params);

end