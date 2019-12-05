function [gamma,u,residual] = compute_gamma(noisy,orig,init)

switch init
            
    case 'over_TV'
        %% over-relaxed TV
        lambda = 500;
        params.debiasing = 'off';
        u = reconstruct_TV_2D(noisy, params, lambda);
        %u =  minimization_TV_PDHG(noisy,params);
        residual = noisy - u;
        
        sigma = 2; %2
        filtered = imgaussfilt(residual,sigma);
        
        omega = 1; %3
        [fx,fy] = my_imgradient(filtered,omega);
        
    case 'GT'
        %% find exact gamma
        u = orig;
        residual = noisy - u;
        
        [fx,fy] = my_imgradient(u,1);
        
%    case 'Potts'
%         %% call Potts segmentation
%         gamma_Potts = 0.2 * (sz/128);
%         u = 255*minL2Potts2DADMM(noisy/255, gamma_Potts, 'verbose', true);
%         residual = noisy-u;
%         
%         % filter residual and choose gamma
%         sigma = 1 * (sz/128);
%         filtered = imgaussfilt(residual,sigma);
%         
%         omega = 2 * (sz/128);
%         [fx,fy] = my_imgradient(filtered,omega);
        
        
    otherwise
        error('Initialisation not valid or supported yet.')
        
end

gamma    = norms(cat(3,fx,fy),2,3);