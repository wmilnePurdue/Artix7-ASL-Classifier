%----------------------------------------------------
%% Make pxl binned .hex files based on Verilog code
%----------------------------------------------------

image_folder = '../2.Dataset/test_img2_resize/';
image_files = dir(fullfile(image_folder, '*.jpeg'));

output_folder = '../3.Result/pixel_binned_D218_img';

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

prefix = 'pxl_binned_D218_';

for i = 1:numel(image_files)
    imgPath = fullfile(image_folder, image_files(i).name);
    img = imread(imgPath);

    %% PIXEL BINNING

    % Step 1: RGB channel 5bit truncation
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

    %%
    scaling_factor = 218; 
    R_quant = floor(double(R_bin) / scaling_factor);
    G_quant = floor(double(G_bin) / scaling_factor);
    B_quant = floor(double(B_bin) / scaling_factor);

    img_quantized = cat(3, R_quant, G_quant, B_quant);

    [~, original_name, ~] = fileparts(image_files(i).name);

    %% HEX file save
    hexFileName = fullfile(output_folder, sprintf('%s%s.hex', prefix, original_name));
    fid = fopen(hexFileName, 'w');

    % R channel (32x32)
    for row = 1:32
        for col = 1:32
            fprintf(fid, '%02X\n', img_quantized(row, col, 1));
        end
    end

    % G channel (32x32)
    for row = 1:32
        for col = 1:32
            fprintf(fid, '%02X\n', img_quantized(row, col, 2));
        end
    end

    % B channel (32x32)
    for row = 1:32
        for col = 1:32
            fprintf(fid, '%02X\n', img_quantized(row, col, 3));
        end
    end

    fclose(fid);
    %%
end