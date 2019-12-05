function orig = load_image(image,sz)

switch image
        case 'pine_tree'
            pine_tree = imread('dataset/pine_tree.tiff');
            pine_tree = rgb2gray(pine_tree);
            pine_tree = imresize(pine_tree,[sz sz]);
            orig = double(pine_tree);
        case 'squirrel'
            squirrel = imread('dataset/squirrel.tiff');
            squirrel = rgb2gray(squirrel);
            squirrel = imresize(squirrel,[sz sz]);
            orig = double(squirrel);
        case 'flowers'
            flowers = imread('dataset/flowers1.tiff');
            flowers = rgb2gray(flowers);
            flowers = imresize(flowers,[sz sz]);
            orig = double(flowers);
        case 'barbara'
            barbara = imread('dataset/256x256/barbara_256.tif');
            barbara = imresize(barbara,[sz sz]);
            orig = double(barbara);
        case 'brickwall'
            brickwall = imread('dataset/256x256/brickwall_256.tif');
            brickwall = imresize(brickwall,[sz sz]);
            orig = double(brickwall(:,:,1));
        case 'cameraman'
            cameraman = imread('dataset/256x256/camera_256.tif');
            cameraman = imresize(cameraman,[sz sz]);
            orig = double(cameraman);
        case 'fish'
            fish = imread('dataset/256x256/fish_256.tif');
            fish = imresize(fish,[sz sz]);
            orig = double(fish(:,:,1));
        case 'gull'
            gull = imread('dataset/256x256/gull_256.tif');
            gull = imresize(gull,[sz sz]);
            orig = double(gull(:,:,1));
        case 'house'
            house = imread('dataset/256x256/house_256.tif');
            house = imresize(house,[sz sz]);
            orig = double(house(:,:,1));
        case 'butterfly'
            butterfly = imread('dataset/256x256/butterfly_256.tif');
            butterfly = imresize(butterfly,[sz sz]);
            orig = double(butterfly);
        case 'owl'
            owl = imread('dataset/256x256/owl_256.tif');
            owl = imresize(owl,[sz sz]);
            orig = double(owl);
        case 'synthetic1'
            synthetic1 = imread('dataset/256x256/synthetic1_256.tif');
            synthetic1 = imresize(synthetic1,[sz sz]);
            orig = double(synthetic1);
        case 'synthetic3'
            synthetic3 = imread('dataset/256x256/synthetic3_256.tif');
            synthetic3 = imresize(synthetic3,[sz sz]);
            orig = double(synthetic3(:,:,1));
        case 'synthetic4'
            synthetic4 = imread('dataset/256x256/synthetic4_256.tif');
            synthetic4 = imresize(synthetic4,[sz sz]);
            orig = double(synthetic4(:,:,1));    
    otherwise
        error('Invalid filename: image not found');
end