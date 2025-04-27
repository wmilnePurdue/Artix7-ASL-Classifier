%%%%%%%%%%%%%%%%%%%%%%%%%
%% Perform augmentation%%
%%%%%%%%%%%%%%%%%%%%%%%%%


originalDatasetFolder = fullfile(pwd, '../Dataset/asl_dataset');
augmentedDatasetFolder = fullfile(pwd, '../Dataset/asl_dataset_augmented4');

imds = imageDatastore(originalDatasetFolder, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

labels = unique(imds.Labels);
for i = 1:numel(labels)
    folderName = fullfile(augmentedDatasetFolder, char(labels(i)));
    if ~exist(folderName, 'dir')
        mkdir(folderName);
    end
end

%%%%%%%%%%%%
augmentationsPerImage = 20;

reset(imds);

while hasdata(imds)
    [img, info] = read(imds);

    % original image
    [~, baseFileName, ext] = fileparts(info.Filename);
    outputFile = fullfile(augmentedDatasetFolder, char(info.Label), [baseFileName '_orig' ext]);
    imwrite(img, outputFile);

    % augmentation 
    for augIdx = 1:augmentationsPerImage
        augImg = customAugment(img); % customAugmentImage
        outputFile = fullfile(augmentedDatasetFolder, char(info.Label), [baseFileName '_aug' num2str(augIdx) ext]);
        imwrite(augImg, outputFile);
    end
end