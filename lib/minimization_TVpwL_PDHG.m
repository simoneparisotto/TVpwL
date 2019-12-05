function [u ,res_final,iter,res,bound] = minimization_TVpwL_PDHG( img, params )
%DO_MINIMIZATION Summary of this function goes here
%   Detailed explanation goes here

[M,N] = size(img);

%% COMPUTE THE DERIVATIVE OPERATOR OF ORDER Q FOR EACH Q, WEIGHTED BY M
% Compute derivatives along (i,j,k)
D  = Kmat(img);

%% COMPUTE SADDLE-POINT OPERATORS AND PROX

% F:= (lamdba/eta)*TDV  is the vectorial soft thresholding.
K         = @(u)       cat(3,reshape(D{1}*u(:),M,N),reshape(D{2}*u(:),M,N));
KS        = @(y)       reshape( D{1}.'*reshape(y(:,:,1),M*N,1) + D{2}.'*reshape(y(:,:,2),M*N,1), M,N);

mask1  = @(y,sigma) norms(y,2,3) <= (params.gamma.*sigma) ;
mask3  = @(y,sigma) norms(y,2,3) >= (1+params.gamma.*sigma);
mask2  = @(y,sigma) 1 - ( mask1(y,sigma) | mask3(y,sigma) );
alpha  = @(y,sigma) compute_alpha(y,sigma,params.gamma,mask1(y,sigma),mask2(y,sigma),mask3(y,sigma));
ProxFS = @(y,sigma) repmat(alpha(y,sigma),1,1,size(y,3)).*y;

% G = box
ProxG     = @(x,tau) proxG_box(x,img,params.bound);

%% PRIMAL DUAL via Chambolle-Pock
[u,res_final,iter,res,bound] = primal_dual(img, K, KS, ProxFS, ProxG, params);

end

function alpha = compute_alpha(y,sigma,gamma,mask1,mask2,mask3)

a1    = zeros(size(y,1),size(y,2));
a2    = (1-sigma*gamma./norms(y,2,3));
a3    = 1./norms(y,2,3);

alpha = zeros(size(y,1),size(y,2));
alpha(mask1>0) = a1(mask1>0);
alpha(mask2>0) = a2(mask2>0);
alpha(mask3>0) = a3(mask3>0);

end