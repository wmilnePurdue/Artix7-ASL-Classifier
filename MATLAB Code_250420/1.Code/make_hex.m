%----------------------
%% Make .jpeg to .hex
%----------------------

image_folder = '../2.Dataset/test_img2_resize/';
image_files = dir(fullfile(image_folder, '*.jpeg'));

% HEX 파일 저장할 폴더 설정
output_folder = '../2.Dataset/hex_img';

% 폴더 없으면 생성
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

prefix = 'test_img2_resize_';

for i = 1:numel(image_files)
    imgPath = fullfile(image_folder, image_files(i).name);
    img = imread(imgPath);
    
    % 원본 파일명 추출 (확장자 제외)
    [~, original_name, ~] = fileparts(image_files(i).name);

    % HEX 파일 생성
    hexFileName = fullfile(output_folder, sprintf('%s%s.hex', prefix, original_name));
    fid = fopen(hexFileName, 'w');

    % RGB 순서대로 픽셀 저장
    for channel = 1:3 % R, G, B
        for row = 1:size(img,1)
            for col = 1:size(img,2)
                fprintf(fid, '%02X\n', img(row, col, channel));
            end
        end
    end

    fclose(fid);
end