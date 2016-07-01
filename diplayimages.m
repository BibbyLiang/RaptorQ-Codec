[img1, map1] = imread('littleKitty.jpg');
[img2, map2] = imread('recoveredKitty.jpg');

subplot(1,2,1)
title('Original'); 
subimage(img1);
subplot(1,2,2)
title('Recovered');
subimage(img2);


figure('name', 'kitty cat');
imshow(img1, 'Border', 'tight');