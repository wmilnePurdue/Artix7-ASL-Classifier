%% Quantization through original training method for entire folder

image_folder = '../2.Dataset/test_img2_resize/';
output_folder = '../2.Dataset/hex_test_img2_resize_quant2/';

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

image_files = dir(fullfile(image_folder, '*.jpeg'));

for i = 1:numel(image_files)
    imgPath = fullfile(image_folder, image_files(i).name);
    original_img = imread(imgPath);
    resized_image = imresize(original_img, [32,32], 'nearest');
    normalized_image = rescale(resized_image,0,1);

    quantized_image = uint8(double(fi(normalized_image, 1, 8, 5)));

    quantized_image_uint8 = uint8(double(quantized_image) * 255);

    [~, file_name, ~] = fileparts(image_files(i).name);
    hexFileName = fullfile(output_folder, sprintf('%s.hex', file_name));
    
    fid = fopen(hexFileName, 'w');

    % R (32x32)
    for row = 1:32
        for col = 1:32
            fprintf(fid, '%02X ', quantized_image(row,col,1));
        end
        fprintf(fid, '\n');
    end

    % G (32x32)
    for row = 1:32
        for col = 1:32
            fprintf(fid, '%02X ', quantized_image(row,col,2));
        end
        fprintf(fid, '\n');
    end

    % B (32x32)
    for row = 1:32
        for col = 1:32
            fprintf(fid, '%02X ', quantized_image(row,col,3));
        end
        fprintf(fid, '\n');
    end

    fclose(fid);
end

disp('Complete');
