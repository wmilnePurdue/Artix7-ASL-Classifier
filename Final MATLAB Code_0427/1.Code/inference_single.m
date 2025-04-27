%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inference single image%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load your quantized network
load('../3.Result/manually_quant_net.mat', 'manually_qt_net');

% Specify your test image path
%imgPath = '../Dataset/asl_dataset_augmented2/k/hand1_k_bot_seg_1_cropped_aug6.jpeg';
imgPath = '../2.Dataset/test_img/a2.jpeg';
%imgPath = '../Dataset/asl_dataset/e/hand1_e_bot_seg_3_cropped.jpeg';

% Read and preprocess the image
img = imread(imgPath);
img_resized = imresize(img, [32,32], 'nearest');
img_normalized = rescale(img_resized, 0, 1);
img_quantized = fi(img_normalized, 1, 8, 5).double;

% Convert the image to dlarray with format SSCB
img_input = dlarray(img_quantized, 'SSCB');

% Run prediction using quantized network
scores = predict(manually_qt_net, img_input);
[~, idx] = max(extractdata(scores));


% Retrieve class labels
pth = "../2.Dataset/";
dataFolder = fullfile(pth, 'train_img/');
SignImds = imageDatastore(dataFolder, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
%classNames = categories(SignImds.Labels);

predictedLabel = classNames{idx};

disp(['Predicted Label: ', predictedLabel]);