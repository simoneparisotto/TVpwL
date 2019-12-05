function [u,reg] = reconstruct_TV_2D (img, params, lambda)

s = size(img);

D = diffopn(s,1,'forward','neumann');

% reconstruct
cvx_begin quiet
    cvx_precision best
    cvx_solver Mosek

    % Set up variables
    variables u(s)
    variables g(prod(s),2) 
    
    % positivity constraint
    u >= 0
         
    % compute gradient
    Du = reshape( D * u(:) , prod(s), 2 );
    
    % fidelity
    fid = 0.5 * sum((u(:) - img(:)).^2);
    
    % regularization term
    Du(:) == g(:)
    reg = sum(norms(g , 2 , 2 ));
        
    minimize fid + lambda * reg

cvx_end

if ~strcmp(cvx_status, 'Solved')
    warning('\tProblem not solved.\tCVX Status: %s', cvx_status);
end

switch params.debiasing
    
    case 'on'
        % save intermediate result
        u_intermediate = u;

        % get subgradient
        p = (img(:)-u(:))/lambda;

        % debiasing
        eps = 1e-6;

        cvx_begin quiet
            cvx_solver Mosek
            cvx_precision best

            variables u(s)
            variables g(prod(s),2)
            
            % regulariser
            Du = reshape( D * u(:) , prod(s), 2 );
            Du == g
            regterm = sum(norms(g , 2 , 2 ));

            % model manifold
            regterm - p'*u(:) <= eps

            minimize norm(u(:)-img(:),2)

        cvx_end
        if ~strcmp(cvx_status, 'Solved')
            warning('\tProblem not solved.\tCVX Status: %s', cvx_status);
        end
    case 'off'
end