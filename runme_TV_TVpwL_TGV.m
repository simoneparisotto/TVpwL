% Authors: Yury Korolev, Simone Parisotto
% Date: September 2019

clear
close all
clc

addpath ./lib
addpath ./lib/cvx
addpath ./lib/stand_func/ % FOR TGV
addpath ./lib/export_fig

cvx_setup

%% DEFINE IMAGES, INITIALISATION, PARAMS,...
% decomment these lines for a single test case.. or use one of the next.

IMAGES         = {'butterfly','gull','cameraman','barbara','pine_tree','squirrel','flowers','brickwall','fish','house','butterfly','owl','synthetic1','synthetic3','synthetic4'};
INITIALISATION = {'GT','over_TV'};
SZ             = [128,256];
DELTA          = [0.10,0.20,0.05,0.15,0.25];
type           = 'Gaussian_Bound';

% OVERRIDE PARAMETERS for experiments
IMAGES         = {'butterfly'};
INITIALISATION = {'over_TV'};
SZ             = [256];
DELTA          = 0.1;

% parameters
for d = 1:numel(DELTA) % noise level
    
    for s = 1:numel(SZ) % image size
        
        sz              = SZ(s);
        params.delta    = DELTA(d); % standard deviation delta*255
        LAMBDA          = 1;   % fidelity
        params.fidelity = 'Bound';
        params.bound    = sz * 255 * params.delta;
        params.C        = 1;
        params.tol      = 1e-3; % for Primal-Dual
        params.niter    = 20000;
        
        
        %% START THE ALGORITHM
        for img = 1:numel(IMAGES)
            
            seed = 5849774;
            rng(seed)
            
            image = IMAGES{img};
            
            savepath = ['./results_',num2str(sz),'px_delta',num2str(DELTA(d)),'/',image,'/'];
            mkdir(savepath)
            
            orig = load_image(image,sz);
            
            % add gaussian noise
            noisy      = add_noise(orig , type , params.delta);
            noisy      = double(noisy);
            SSIM_noisy = ssim(noisy, orig, 'DynamicRange',255);
            PSNR_noisy = psnr(noisy, orig);
            
            % save images
            imwrite(im2double(orig)/255,        [savepath,'/u_orig','.png'])
            imwrite(im2double(noisy)/255,       [savepath,'/u_noise','.png'])
            
            %% RECONSTRUCT USING TVpwL
            for init = 1:numel(INITIALISATION)
                
                % computation of gamma
                cputime_gamma = cputime;
                [params.gamma,u_est,residual] = compute_gamma(noisy,orig,INITIALISATION{init});
                cputime_gamma = cputime-cputime_gamma;
                
                % write images
                imwrite(im2double(u_est)/255,       [savepath,'/u_estimated_',INITIALISATION{init},'.png'])
                imwrite(mat2gray(params.gamma),     [savepath,'/gamma_rescaled_',INITIALISATION{init},'.png'])
                imwrite(im2double(residual)/255,    [savepath,'/u_residual_',INITIALISATION{init},'.png'])
                
                % PDHG
                cputime_TVpwL_PDHG = cputime;
                [u_TVpwL_PDHG,res_TVpwL_PDHG,iter_TVpwL_PDHG,PD_gap_TVpwL_PDHG,bound_TVpwL] = minimization_TVpwL_PDHG(noisy,params);
                cputime_TVpwL_PDHG = cputime-cputime_TVpwL_PDHG;
                
                SSIM_TVpwL_PDHG = ssim(orig,u_TVpwL_PDHG,'DynamicRange',255);
                PSNR_TVpwL_PDHG = psnr(orig,u_TVpwL_PDHG);
                
                subplot(2,3,3)
                imshow(uint8(u_TVpwL_PDHG))
                xlabel({['TV_{pwL}'],['SSIM = ' num2str(round(SSIM_TVpwL_PDHG,3))],[num2str(cputime_TVpwL_PDHG),' s. (PDHG)']},'FontWeight','bold','FontSize',15)
                
                pause(0.001)
                
                % CVX
                params.regularizer = 'TV_pwL';
                
                cputime_TVpwL_CVX  = cputime;
                [u_TVpwL_CVX,res_TVpwL_CVX,iter_TVpwL_CVX] = minimization(noisy,params,LAMBDA);
                cputime_TVpwL_CVX  = cputime-cputime_TVpwL_CVX ;
                
                SSIM_TVpwL_CVX     = ssim(u_TVpwL_CVX,orig,'DynamicRange',255);
                PSNR_TVpwL_CVX     = psnr(u_TVpwL_CVX,orig);
                
                subplot(2,3,4)
                imshow(uint8(u_TVpwL_CVX))
                xlabel({['TV_{pwL}'],['SSIM = ' num2str(round(SSIM_TVpwL_CVX ,3))],[num2str(cputime_TVpwL_CVX),' s. (CVX)']},'FontWeight','bold','FontSize',15)
                pause(0.001)
                
                % write images
                imwrite(im2double(u_TVpwL_PDHG)/255,[savepath,'/u_TVpwL_PDHG_',INITIALISATION{init},'_SSIM',num2str(SSIM_TVpwL_PDHG),'_PSNR',num2str(PSNR_TVpwL_PDHG),'_cputime',num2str(cputime_TVpwL_PDHG),'.png'])
                imwrite(im2double(u_TVpwL_CVX)/255, [savepath,'/u_TVpwL_CVX_',INITIALISATION{init},'_SSIM',num2str(SSIM_TVpwL_CVX),'_PSNR',num2str(PSNR_TVpwL_CVX),'_cputime',num2str(cputime_TVpwL_CVX),'.png'])
                
                % write loglog plot
                loglog_TVpwL = figure;
                x_PD_gap_TVpwL = 1:numel(PD_gap_TVpwL_PDHG);
                loglog(x_PD_gap_TVpwL,x_PD_gap_TVpwL.^-1,'-k',...
                    x_PD_gap_TVpwL,x_PD_gap_TVpwL.^-2,':k',...
                    x_PD_gap_TVpwL,PD_gap_TVpwL_PDHG,'.-r',...
                    x_PD_gap_TVpwL,-bound_TVpwL,'--b','Linewidth',2)
                axis square
                legend('order 1','order 2','residual','$\delta-\|u-f\|_2$','Interpreter','Latex','Location','SouthWest','Fontsize',16)
                export_fig(loglog_TVpwL,[savepath,'/loglog_TVpwL_',INITIALISATION{init},'.png'],'-transparent','-r300')
                
                save([savepath,'/TVpwL_',INITIALISATION{init},'.mat'])
            end
                
            %% RECONSTRUCT USING TV
            % PDHG
            cputime_TV_PDHG = cputime;
            [u_TV_PDHG,res_TV_PDHG,iter_TV_PDHG,PD_gap_TV_PDHG,bound_TV] = minimization_TV_PDHG(noisy,params);
            cputime_TV_PDHG = cputime-cputime_TV_PDHG;
            
            SSIM_TV_PDHG = ssim(orig,u_TV_PDHG,'DynamicRange',255);
            PSNR_TV_PDHG = psnr(orig,u_TV_PDHG);
            
            subplot(2,3,1)
            imshow(uint8(u_TV_PDHG))
            xlabel({['TV'],['SSIM = ' num2str(round(SSIM_TV_PDHG,3))],[num2str(cputime_TV_PDHG),' s. (PDHG)']},'FontWeight','bold','FontSize',15)
            
            pause(0.001)
            
            % CVX
            params.regularizer = 'TV';
            
            cputime_TV_CVX = cputime;
            [u_TV_CVX,res_TV_CVX,iter_TV_CVX] = minimization(noisy,params,LAMBDA);
            cputime_TV_CVX = cputime-cputime_TV_CVX;
            
            SSIM_TV_CVX = ssim(orig,u_TV_CVX,'DynamicRange',255);
            PSNR_TV_CVX = psnr(orig,u_TV_CVX);
            
            subplot(2,3,2)
            imshow(uint8(u_TV_CVX))
            xlabel({['TV'],['SSIM = ' num2str(round(SSIM_TV_CVX,3))],[num2str(cputime_TV_CVX),' s. (CVX)']},'FontWeight','bold','FontSize',15)
            
            pause(0.001)
            
            % write images
            imwrite(im2double(u_TV_PDHG)/255,   [savepath,'/u_TV_PDHG','_SSIM',num2str(SSIM_TV_PDHG),'_PSNR',num2str(PSNR_TV_PDHG),'_cputime',num2str(cputime_TV_PDHG),'.png'])
            imwrite(im2double(u_TV_CVX)/255,    [savepath,'/u_TV_CVX','_SSIM',num2str(SSIM_TV_CVX),'_PSNR',num2str(PSNR_TV_CVX),'_cputime',num2str(cputime_TV_CVX),'.png'])
            
            % write loglog plot
            loglog_TV = figure;
            x_PD_gap_TV = 1:numel(PD_gap_TV_PDHG);
            loglog(x_PD_gap_TV,x_PD_gap_TV.^-1,'-k',...
                x_PD_gap_TV,x_PD_gap_TV.^-2,':k',...
                x_PD_gap_TV,PD_gap_TV_PDHG,'.-r',...
                x_PD_gap_TV,-bound_TV,'--b','Linewidth',2)
            axis square
            legend('order 1','order 2','residual','$\delta-\|u-f\|_2$','Interpreter','Latex','Location','SouthWest','Fontsize',16)
            set(gcf, 'Color', 'w');
            export_fig(loglog_TV,[savepath,'/loglog_TV.png'],'-transparent','-r300')
            
            %% RECONSTRUCT USING TGV2
            % PDHG
            params.regularizer = 'TGV2';
            params.beta = 1.25;
            
            cputime_TGV_PDHG = cputime;
            [u_TGV_PDHG,res_TGV_PDHG,iter_TGV_PDHG,PD_gap_TGV_PDHG,bound_TGV] = minimization_TGV_PDHG(noisy,params);
            cputime_TGV_PDHG = cputime-cputime_TGV_PDHG;
            
            SSIM_TGV_PDHG = ssim(u_TGV_PDHG,orig,'DynamicRange',255);
            PSNR_TGV_PDHG = psnr(u_TGV_PDHG,orig);
            
            subplot(2,3,5)
            imshow(uint8(u_TGV_PDHG))
            xlabel({['TGV^2'],['SSIM = ' num2str(round(SSIM_TGV_PDHG,3))],[num2str(cputime_TGV_PDHG),' s. (PDHG)']},'FontWeight','bold','FontSize',15)
            pause(0.001)
            
            % CVX
            params.regularizer = 'TGV2';
            params.beta = 1.25;
            
            cputime_TGV_CVX = cputime;
            [u_TGV_CVX,res_TGV_CVX,iter_TGV_CVX] = minimization(noisy,params,LAMBDA);
            cputime_TGV_CVX = cputime-cputime_TGV_CVX;
            
            SSIM_TGV_CVX = ssim(u_TGV_CVX,orig,'DynamicRange',255);
            PSNR_TGV_CVX = psnr(u_TGV_CVX,orig);
            
            subplot(2,3,6)
            imshow(uint8(u_TGV_CVX))
            xlabel({['TGV^2'],['SSIM = ' num2str(round(SSIM_TGV_CVX,3))],[num2str(cputime_TGV_CVX),' s. (CVX)']},'FontWeight','bold','FontSize',15)
            pause(0.001)
            
            % write images
            imwrite(im2double(u_TGV_PDHG)/255,  [savepath,'/u_TGV_PDHG','_SSIM',num2str(SSIM_TGV_PDHG),'_PSNR',num2str(PSNR_TGV_PDHG),'_cputime',num2str(cputime_TGV_PDHG),'.png'])
            imwrite(im2double(u_TGV_CVX)/255,   [savepath,'/u_TGV_CVX','_SSIM',num2str(SSIM_TGV_CVX),'_PSNR',num2str(PSNR_TGV_CVX),'_cputime',num2str(cputime_TGV_CVX),'.png'])
            
            % write loglog plots
            loglog_TGV = figure;
            x_PD_gap_TGV = 1:numel(PD_gap_TGV_PDHG);
            loglog(x_PD_gap_TGV,x_PD_gap_TGV.^-1,'-k',...
                x_PD_gap_TGV,x_PD_gap_TGV.^-2,':k',...
                x_PD_gap_TGV,PD_gap_TGV_PDHG,'.-r',...
                x_PD_gap_TGV,-bound_TGV,'--b','Linewidth',2)
            axis square
            legend('order 1','order 2','residual','$\delta-\|u-f\|_2$','Interpreter','Latex','Location','SouthWest','Fontsize',16)
            export_fig(loglog_TGV,[savepath,'/loglog_TGV.png'],'-transparent','-r300')
            
            save([savepath,'/',image,'.mat'])
            
            pause(1)
            close all
            
        end
    end
end

return