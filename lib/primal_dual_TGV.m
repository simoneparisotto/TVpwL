function [x,res_final,iter,res,bound] = primal_dual_TGV(x, K, KS, ProxFS, ProxG, options)
% perform_primal_dual - primal-dual algorithm
%
%    [x,R] = perform_admm(x, K,  KS, ProxFS, ProxG, options);
%
%   Solves`
%       min_x F(K*x) + G(x)
%   where F and G are convex proper functions with an easy to compute proximal operator,
%   and where K is a linear operator
%
%   Uses the Preconditioned Alternating direction method of multiplier (ADMM) method described in
%       Antonin Chambolle, Thomas Pock,
%       A first-order primal-dual algorithm for convex problems with applications to imaging,
%       Preprint CMAP-685
%
%   INPUTS:
%   ProxFS(y,sigma) computes Prox_{sigma*F^*}(y)
%   ProxG(x,tau) computes Prox_{tau*G}(x)
%   K(y) is a linear operator.
%   KS(y) compute K^*(y) the dual linear operator.
%   options.sigma and options.tau are the parameters of the
%       method, they shoudl satisfy sigma*tau*norm(K)^2<1
%   options.theta=1 for the ADMM, but can be set in [0,1].
%   options.verb=0 suppress display of progression.
%   options.niter is the number of iterations.
%   options.report(x) is a function to fill in R.
%
%   OUTPUTS:
%   x is the final solution.
%   R(i) = options.report(x) at iteration i.
%
%   Copyright (c) 2010 Gabriel Peyre

options.null = 0;
niter        = getoptions(options, 'niter', 100);
theta        = getoptions(options, 'theta', 1);
tol          = getoptions(options, 'tol', 1e-6);
verbose      = getoptions(options, 'verbose', 0);
acceleration = getoptions(options, 'acceleration', 0);
eta          = getoptions(options, 'eta', 1);

% OPERATOR NORM
L = 64;

if acceleration
    %  ADMM
    tau   = 1/sqrt(L);
    sigma = 1./(tau*L);
    gamma = 0.35*eta;
    
else
%    sigma = 10;
%    tau   = 0.9/(sigma*L);
    sigma = 1/sqrt(L*1.01);
    tau   = 1/sqrt(L*1.01);
end

x0     = x;

%Storage variables
ext = cat(3,x0,zeros(size(x0,1),size(x0,2),2)); % extragradient

y        = zeros(size(x0,1),size(x0,2),5); % 5x1

exthat   = ext;    % 3x1
extstar  = KS(y,ext); % 3x1

res      = NaN(niter,1);
bound    = NaN(niter,1);

for iter = 1:niter
    
    ext_old     = ext;
    y_old       = y;
    Kx_old      = K(ext); 
    extstar_old = extstar;
    
    % DUAL PROBLEM
    Kx_hat = K(exthat);
    y      = ProxFS( y + sigma*Kx_hat, sigma );
    
    % PRIMAL PROBLEM
    extstar = KS(y,ext);
        
    %Set x+=x-tau*K'(y+)    
    ext = ProxG( ext - tau*extstar,tau );

    % EXTRAPOLATION
    exthat = ext + theta * (ext-ext_old);
    
    % ACCELERATION
    if acceleration
        theta = 1./sqrt(1+2*gamma*tau);
        tau   = theta*tau;
        sigma = sigma/theta;
    end
    
    % primal residual
    p_res = (ext_old-ext)/tau - (extstar_old-extstar) ; %- norms((y_old-y)/sigma,2,3).*options.gamma;
    p = sum(sum(abs(p_res)));
    % dual residual
    d_res = (y_old-y)/sigma - (Kx_old-Kx_hat);
    d = sum(sum(abs(d_res)));
    
    res(iter)   = (sum(p)+sum(d)) / numel(x(:,:,1));
    bound(iter) = norm(reshape(ext(:,:,1),[],1)-x0(:),2)-options.bound;
    if true
        fprintf('%d: res: %2.2e - bound %2.2e\n',iter,res(iter),bound(iter))
    end
    
    if res(iter)<tol
        break
    end
    
end

res_final = res(iter);
x = exthat(:,:,1);
res(isnan(res))     = [];
bound(isnan(bound)) = [];

end

% function [L,e] = compute_operator_norm(A,n)
% % compute_operator_norm - compute operator norm
% %
% %   [L,e] = compute_operator_norm(A,n);
% %
% %   Copyright (c) 2010 Gabriel Peyre
%
% if length(n)==1
%     u = randn(n,1); u = u/norm(u);
% else
%     u = n;
%     u = u/norm(u);
% end
% e = [];
% for i=1:30
%     v = A(u);
%     e(end+1) = sum(u(:).*v(:));
%     u = v/norm(v(:));
% end
% L = e(end);
% end
%
function v = getoptions(options, name, v, mendatory)
% getoptions - retrieve options parameter
%
%   v = getoptions(options, 'entry', v0);
% is equivalent to the code:
%   if isfield(options, 'entry')
%       v = options.entry;
%   else
%       v = v0;
%   end
%
%   Copyright (c) 2007 Gabriel Peyre

if nargin<4
    mendatory = 0;
end

if isfield(options, name)
    v = eval(['options.' name ';']);
elseif mendatory
    error(['You have to provide options.' name '.']);
end
end