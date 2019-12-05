A1=ones(256,256);
a1 = 0:255;
for i=1:256
    A1(i,:)=a;
end

B1 = ones(128,128);
b1 = 255:-2:0;
for i=65:192
    for j=65:192
        A1(i,j)=b1(j-64);
    end
end

figure
imshow(uint8(A))

imwrite(uint8(A),'synthetic1_256.tif')


%%
% A2 = zeros(256,256);
% B2 = zeros(32,32);
b2 = 0:8:255;
for i = 1:32
    B2(i,:) = b2;
    C2(:,i) = b2';
end
A2 = [B2,C2,B2,C2,B2,C2,B2,C2;C2,B2,C2,B2,C2,B2,C2,B2];
A2 = [A2;A2;A2;A2];
 figure
 imshow(uint8(A2));
 
 imwrite(uint8(A2),'synthetic2_256.tif')


 
 %%
 
 A3=ones(256,256);
a3 = 255/(256^2-1);
b3 = 1:256;
b3 = a3.*(b3.*b3)-a3;
for i=1:256
    A3(i,:)=b3;
end



figure
imshow(uint8(A3))

%%
% A2 = zeros(256,256);
% a2 = sqrt(2*128.5^2);
% for i = 1:256
%     for j = 1:256
%         A(i,j) = sqrt((i-128.5)^2+(j-128.5)^2)/a2;
%     end
% end
% for i=1:256
%     for j=1:256
%         if sqrt((i-128.5)^2+(j-128.5)^2)<96
%             A2(i,j)=0;
%         end
%     end
% end
% 
% figure
% imshow(uint8(A2))
