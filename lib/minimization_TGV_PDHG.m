function [u ,res_final,iter,PD_gap,bound] = minimization_TGV_PDHG( img, params )
%DO_MINIMIZATION Summary of this function goes here
%   Detailed explanation goes here

[M,N] = size(img);

%% COMPUTE THE DERIVATIVE OPERATOR OF ORDER Q FOR EACH Q, WEIGHTED BY M
% Compute derivatives along (i,j,k)
D  = Kmat(img);

%% COMPUTE SADDLE-POINT OPERATORS AND PROX

K       = @(ext)  cat(3,fgrad_1(ext(:,:,1))-ext(:,:,2:3),sym_bgrad_2(ext(:,:,2:3)));
KS      = @(y,ext)cat(3,  -bdiv_1(y(:,:,1:2)),-y(:,:,1:2)-fdiv_2(y(:,:,3:5)) );


% Project y+=(p,q,r) to {(p,q,r):|p|<alph1,|q|<alph0}                        
ProxFS  = @(y,sigma)  cat(3,  y(:,:,1:2)./max(1,repmat(norms(y(:,:,1:2)      ,2,3)./1          ,1,1,2)),...
                              y(:,:,3:5)./max(1,repmat(norms(y(:,:,[3,4,5,5]),2,3)./params.beta,1,1,3)));
 
% G = box
ProxG     = @(x,tau) cat(3,proxG_box(x(:,:,1),img,params.bound),x(:,:,2:end));

%% PRIMAL DUAL via Chambolle-Pock
[u,res_final,iter,PD_gap,bound] = primal_dual_TGV(img, K, KS, ProxFS, ProxG, params);

end