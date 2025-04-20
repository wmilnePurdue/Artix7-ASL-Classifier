function augImg = customAugment(img)

    % (1) Random rotation 
    angle = -30 + 60*rand();
    img = imrotate(img, angle, 'bilinear', 'crop');

    % (2) Random translation 
    tx = -10 + 20*rand(); 
    ty = -10 + 20*rand();
    img = imtranslate(img,[tx, ty],'FillValues',0);

    % (3) Random scaling (80%~120%)
    scaleFactor = 0.8 + 0.4*rand();
    img = imresize(img, scaleFactor);

    targetSize = [size(img,1), size(img,2)];
    img = imresize(img, targetSize);

    % (4) bw
    if rand < 0.15
        grayImg = rgb2gray(img);
        invertedGray = imcomplement(grayImg);
        img = cat(3,invertedGray,invertedGray,invertedGray);
    end

    % (5) brightness
    brightnessFactor = 0.6 + 0.8*rand(); % (60% ~ 140%)
    img = im2double(img) * brightnessFactor;
    img = min(max(img,0),1);

    % (6) Hue, Saturation
    hsv_img = rgb2hsv(img);

    hueShift = -0.2 + 0.4*rand();
    hsv_img(:,:,1) = mod(hsv_img(:,:,1) + hueShift,1);

    saturationFactor = 0.6 + 0.8*rand();
    hsv_img(:,:,2) = hsv_img(:,:,2) * saturationFactor;
    hsv_img(:,:,2) = min(max(hsv_img(:,:,2),0),1);

    % HSV to RGB
    img = hsv2rgb(hsv_img);

    % (7) Gaussian Blur 
    if rand > 0.5 % 50%
        sigma = rand();
        img = imgaussfilt(img, sigma);
    end

    % uint8
    augImg = im2uint8(img);