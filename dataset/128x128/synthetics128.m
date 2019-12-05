A=ones(128,128);
a = 0:2:255;
for i=1:128
    A(i,:)=a;
end

B = ones(64,64);
a = 255:-4:0;
for i=33:96
    for j=33:96
        A(i,j)=a(j-32);
    end
end

figure
imshow(uint8(A))

imwrite(uint8(A),'synthetic1_128.tif')

%%
clear all
b2 = 0:16:255;
for i = 1:16
    B2(i,:) = b2;
    C2(:,i) = b2';
end
A2 = [B2,C2,B2,C2,B2,C2,B2,C2;C2,B2,C2,B2,C2,B2,C2,B2];
A2 = [A2;A2;A2;A2];
 figure
 imshow(uint8(A2));
 
imwrite(uint8(A2),'synthetic2_128.tif')