function y = proxG_box(x,img,bound)
% mask = norms(x-img,2,3)<=(bound/numel(x));
% y = mask.*x + (1-mask).*( img+(bound/sum(mask(:))).*(x-img)./norms(x-img,2,3) );

c = 1-1e-5;

if norm(x(:)-img(:),2)<=c*bound
    y = x;
else
    y = img + c*bound.*(x-img)./norm(x(:)-img(:),2);
end