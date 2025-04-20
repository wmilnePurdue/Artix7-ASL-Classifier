%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inference all images in the folder%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; clc;

classNames = {'a','b','c','d','e','f','g','h','i','k','l','m',...
              'n','o','p','q','r','s','t','u','v','w','x','y'};

load('../3.Result/manually_quant_net.mat', 'manually_qt_net');

image_folder = '../2.Dataset/test_img2_resize/';
image_files = dir(fullfile(image_folder, '*.jpeg'));

for i = 1:numel(image_files)
    imgPath = fullfile(image_folder, image_files(i).name);
    img = imread(imgPath);

    %%%% PIXEL BINNING %%%%

    % Step 1: RGB channel 5bit truncation
    R = bitshift(img(:,:,1), -3);
    G = bitshift(img(:,:,2), -3);
    B = bitshift(img(:,:,3), -3);

    % Step 2: L/R 80 pxls trimming (center 480pxl)
    R_trim = R(:,81:560);
    G_trim = G(:,81:560);
    B_trim = B(:,81:560);

    % Step 3: hor 15pxls binning (480 → 32 pxl)
    R_bin_x = zeros(480,32,'uint16');
    G_bin_x = zeros(480,32,'uint16');
    B_bin_x = zeros(480,32,'uint16');
    for x=1:32
        idx_s=(x-1)*15+1;
        idx_e=idx_s+14;
        R_bin_x(:,x)=sum(R_trim(:,idx_s:idx_e),2);
        G_bin_x(:,x)=sum(G_trim(:,idx_s:idx_e),2);
        B_bin_x(:,x)=sum(B_trim(:,idx_s:idx_e),2);
    end

    % Step 4: ver 15pxls binning (480 → 32 pxl)
    R_bin = zeros(32,32,'uint16');
    G_bin = zeros(32,32,'uint16');
    B_bin = zeros(32,32,'uint16');
    for y=1:32
        idx_s=(y-1)*15+1;
        idx_e=idx_s+14;
        R_bin(y,:)=sum(R_bin_x(idx_s:idx_e,:),1);
        G_bin(y,:)=sum(G_bin_x(idx_s:idx_e,:),1);
        B_bin(y,:)=sum(B_bin_x(idx_s:idx_e,:),1);
    end

    % Step 5: normalization [0~1]
    % max 15*15*31 = 6975
    R_norm = double(R_bin) / (27*256);
    G_norm = double(G_bin) / (27*256);
    B_norm = double(B_bin) / (27*256);

    img_quantized = cat(3, R_norm, G_norm, B_norm);

    img_input = dlarray(img_quantized, 'SSCB');

    %inference

    scores = predict(manually_qt_net, img_input);
    [~, idx] = max(extractdata(scores));

    predictedLabel = classNames{idx};
    fprintf('Image: %s → Predicted Label: %s\n', image_files(i).name, upper(predictedLabel));
end