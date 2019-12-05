% adds gaussian or uniform noise to an image, takes the original image and
% variance, gives the noisy image

function [noisy] = add_noise (orig, type, delta)

seed = 5849774;
rng(seed)
switch type
    case {'Gaussian' , 'Gaussian_Bound'}
        noise = 255 * delta * randn(size(orig));
    case 'Uniform'
        noise = 255 * delta * (rand(size(orig))-0.5);
end

noisy = orig + noise;


% function [noisy] = add_noise (orig, mean, var)
% 
% orig = double(orig) / 255
% 
% noisy = imnoise(orig,'gaussian', mean, var)
% noisy = noisy * 255