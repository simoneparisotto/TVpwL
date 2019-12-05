function [ x, p, g ] = minimization( img, params, alpha )
%DO_MINIMIZATION Summary of this function goes here
%   Detailed explanation goes here

% Set default values
if nargin < 3
    if isfield(params, 'alpha')
        alpha = params.alpha;
    else
        alpha = 1;
    end
end

fidelity    = params.fidelity;
regularizer = params.regularizer;
s           = size(img);
n_ghosts    = 0; % Number of ghost cells at each boundary
sg          = s + (2*n_ghosts); % Size including ghost cells


cvx_begin quiet
    
    cvx_solver Mosek
%    cvx_precision best

    % Set up variables
    variables u(sg)             % including ghost cells
    variables g(prod(sg),2)
    
    u(:) >= 0;
    
    data = u(1+n_ghosts:end-n_ghosts,...
             1+n_ghosts:end-n_ghosts);  % excluding ghost cells
         
    % generate differential operators
    D = diffopn(sg,1,'forward','neumann');
    Du = reshape( D * u(:) , prod(sg), 2 );
    % Define fidelity term
    switch fidelity
        case 'L2 squared'
            fid = 0.5 * sum((data(:) - img(:)).^2);
        case 'Indicator'
            delta = params.delta;
            fid = 0;
            %fid = max(abs(data(:)-img(:)));
            img(:) - 0.5 * 255 * delta * ones( prod(sg),1 ) <= data(:) ...
                <= img(:) + 0.5 * 255 * delta * ones( prod(sg),1 );   
        case 'Bound'
            fid = 0;
            bound = params.C*params.bound;
            norm( data(:)-img(:), 2 ) <= bound;
            %sum(sum(norms( data-img, 2,3 ))) <= bound;
    end
    
    % Define regularization term
    if alpha == 0
        reg = 0;
    else
        switch regularizer

            case 'TV'           % ||Du||_1
                Du(:) == g(:)
                reg = sum(norms(g , 2 , 2 ));
                %reg = sum(abs(g(:)));
                              
            case 'TV_pwL'
                gamma = params.gamma;
                %gamma <= g <= gamma;
%                abs(g) <= abs(gamma);
                norms( g , 2 , 2 ) <= gamma(:);
                reg = sum( norms( Du-g , 2 , 2 ) );
                                     
            case 'TVLp'     % ||Du-w||_1 + b/a* ||w||_p
                p = params.p;
                b = params.beta;
                if isequal(p,'inf') == 0
                    if p == 2
                        reg = sum ( norms ( Du-g , 2 , 2 ) ) ...
                            + b/alpha * norms ( g(:) , 2 );
                    else
                        reg = sum ( norms ( Du-g , 2 , 2 ) ) ...
                            + b/alpha * norms ( norms(g,2,2) , p );
                    end
                else
                    reg = sum( norms( Du-g , 2 , 2 ) )...
                       + b/alpha * max( norms(g , 2 , 2 )) ;
                end
                
            case 'TGV2'
                b = params.beta;
                
                Dgy = reshape ( D * g(:,1) , prod(sg) , 2);
                Dgx = reshape ( D * g(:,2) , prod(sg) , 2);
                Eg = [Dgy(:,1) 0.5*(Dgy(:,2)+Dgx(:,1))...
                    0.5*(Dgy(:,2)+Dgx(:,1)) Dgx(:,2)];             
                reg = sum(norms( Du-g, 2 , 2 ))...
                      + b * sum(norms( Eg , 2 , 2));
        end
        
        minimize fid + alpha * reg
    end

cvx_end

if ~strcmp(cvx_status, 'Solved')
    warning('\tProblem not solved.\tCVX Status: %s', cvx_status);
end

if not(exist('g'))
    g = [];
end

if not(exist('p'))
    p = [];
end

x = full(data);

end