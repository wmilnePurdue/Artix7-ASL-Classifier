%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Image resize into square shape%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
inputDir = '../2.Dataset/test_img2/';
outputDir = '../2.Dataset/test_img2_resize/';
resizeDim = [640, 480]; % 최종 이미지 크기

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

imageFiles = dir(fullfile(inputDir, '*.jpeg'));

scaleFactor = 0.9; % 원본 크기의 90%로 크롭 (10% 확대 효과)

for k = 1:length(imageFiles)
    img = imread(fullfile(inputDir, imageFiles(k).name));

    % 이미지 크기 얻기
    [h, w, ~] = size(img);

    % 목표 크기 설정
    targetAspectRatio = 640 / 480;

    % 원본 이미지의 비율 계산
    originalAspectRatio = w / h;

    % 중심 기준 크롭 (10% 확대)
    if originalAspectRatio > targetAspectRatio
        % 가로가 길면 양옆 크롭
        newWidth = round(h * targetAspectRatio * scaleFactor);
        newHeight = round(h * scaleFactor);
    else
        % 세로가 길면 위아래 크롭
        newWidth = round(w * scaleFactor);
        newHeight = round((w / targetAspectRatio) * scaleFactor);
    end

    startX = round((w - newWidth) / 2);
    startY = round((h - newHeight) / 2);

    croppedImg = imcrop(img, [startX, startY, newWidth - 1, newHeight - 1]);

    % 최종 이미지 리사이징
    resizedImg = imresize(croppedImg, [480, 640]);

    % 결과 저장
    imwrite(resizedImg, fullfile(outputDir, imageFiles(k).name));
end