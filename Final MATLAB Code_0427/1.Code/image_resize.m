%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Image resize into square shape%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
inputDir = '../2.Dataset/test_img2/';
outputDir = '../2.Dataset/test_img2_resize/';
resizeDim = [640, 480]; % final image size

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

imageFiles = dir(fullfile(inputDir, '*.jpeg'));

scaleFactor = 0.9; % 90% crop

for k = 1:length(imageFiles)
    img = imread(fullfile(inputDir, imageFiles(k).name));

    [h, w, ~] = size(img);
    targetAspectRatio = 640 / 480;
    originalAspectRatio = w / h;


    if originalAspectRatio > targetAspectRatio
        newWidth = round(h * targetAspectRatio * scaleFactor);
        newHeight = round(h * scaleFactor);
    else
        newWidth = round(w * scaleFactor);
        newHeight = round((w / targetAspectRatio) * scaleFactor);
    end

    startX = round((w - newWidth) / 2);
    startY = round((h - newHeight) / 2);

    croppedImg = imcrop(img, [startX, startY, newWidth - 1, newHeight - 1]);

    resizedImg = imresize(croppedImg, [480, 640]);

    imwrite(resizedImg, fullfile(outputDir, imageFiles(k).name));
end