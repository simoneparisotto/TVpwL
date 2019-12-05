function [fx,fy] = my_imgradient(img,omega)

[n,m] = size(img);

fx = zeros(n,m);
fy = zeros(n,m);

for i = 1:n
    for j = 1:omega
        fx(i,j) = (img(i,j+omega) - img(i,j))/omega;
    end
    for j = omega+1 : m-omega
        fx(i,j) = (img(i,j+omega) - img(i,j-omega))/(2*omega);
    end
    for j = m-omega+1 : m
        fx(i,j) = (img(i,j) - img(i,j-omega))/omega;
    end
end

for j = 1:m
    for i = 1:omega
        fy(i,j) = (img(i+omega,j) - img(i,j))/omega;
    end
    for i = omega+1 : n-omega
        fy(i,j) = (img(i+omega,j) - img(i-omega,j))/(2*omega);
    end
    for i = n-omega+1 : n
        fy(i,j) = (img(i,j) - img(i-omega,j))/omega;
    end
end