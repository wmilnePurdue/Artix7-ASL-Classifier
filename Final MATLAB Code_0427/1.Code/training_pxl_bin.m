%% Training 및 Inference 시 FPGA 픽셀 비닝 방식으로 Quantization 일치
%% Code currently not running due to image size of the testset

currentFolder = "../2.Dataset";
dataFolder = fullfile(currentFolder, 'train_img_augmented');

SignImds = imageDatastore(dataFolder, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

classNames = categories(SignImds.Labels);
disp('Classes : ');
disp(classNames);

[SignImds_Train, SignImds_Validation, SignImds_Test] = splitEachLabel(SignImds, 0.6, 0.2, 'randomized');

function [labelled_image, info] = FPGA_PixelBinning(image, info)
    %% FPGA 방식 픽셀 비닝
    % Step 1: RGB channel 5bit truncation
    R = bitshift(image(:,:,1), -3);
    G = bitshift(image(:,:,2), -3);
    B = bitshift(image(:,:,3), -3);

    % Step 2: L/R 80 pixels trimming (center 480px)
    %R_trim = R(:,81:560);
    %G_trim = G(:,81:560);
    %B_trim = B(:,81:560);

    % Step 3: Horizontal 15px binning (480 → 32 px)
    R_bin_x = zeros(480,32,'uint16');
    G_bin_x = zeros(480,32,'uint16');
    B_bin_x = zeros(480,32,'uint16');
    for x = 1:32
        idx_s = (x-1)*15 + 1;
        idx_e = idx_s + 14;
        R_bin_x(:,x) = sum(R_trim(:,idx_s:idx_e),2);
        G_bin_x(:,x) = sum(G_trim(:,idx_s:idx_e),2);
        B_bin_x(:,x) = sum(B_trim(:,idx_s:idx_e),2);
    end

    % Step 4: Vertical 15px binning (480 → 32 px)
    R_bin = zeros(32,32,'uint16');
    G_bin = zeros(32,32,'uint16');
    B_bin = zeros(32,32,'uint16');
    for y = 1:32
        idx_s = (y-1)*15 + 1;
        idx_e = idx_s + 14;
        R_bin(y,:) = sum(R_bin_x(idx_s:idx_e,:),1);
        G_bin(y,:) = sum(G_bin_x(idx_s:idx_e,:),1);
        B_bin(y,:) = sum(B_bin_x(idx_s:idx_e,:),1);
    end

    % Step 5: FPGA 방식 Quantization
    scaling_factor = 218;
    img_quantized = cat(3, R_bin, G_bin, B_bin);
    img_quantized = floor(double(img_quantized) / scaling_factor);

    % 0~1로 재정규화
    labelled_image = {rescale(img_quantized, 0, 1), info.Label};
end

SignImdsTransformed_Train = transform(SignImds_Train, @FPGA_PixelBinning, 'IncludeInfo', true);
SignImdsTransformed_Validation = transform(SignImds_Validation, @FPGA_PixelBinning, 'IncludeInfo', true);
SignImdsTransformed_Test = transform(SignImds_Test, @FPGA_PixelBinning, 'IncludeInfo', true);

%% 네트워크 정의
layers = [
    imageInputLayer([32 32 3])
    convolution2dLayer(3,8,'Padding','same')
    reluLayer
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(3,16,'Padding','same')
    reluLayer
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(3,24,'Padding','same')
    reluLayer
    maxPooling2dLayer(2,'Stride',2)
    flattenLayer('Name','flatten1')
    fullyConnectedLayer(64)
    dropoutLayer(0.5)
    fullyConnectedLayer(numel(classNames))
    softmaxLayer];

options = trainingOptions("adam", ...
    InitialLearnRate=0.001, ...
    MaxEpochs=8, ...
    Shuffle="every-epoch", ...
    ValidationData=SignImdsTransformed_Validation, ...
    ValidationFrequency=30, ...
    Plots="training-progress", ...
    Metrics="accuracy", ...
    MiniBatchSize=32, ...
    L2Regularization=0.01, ...
    Verbose=false);

net = trainnet(SignImdsTransformed_Train, layers, "crossentropy", options);

outputDir = "../3.Result/";
outputFile = fullfile(outputDir, "trained_net_fpga_binning.mat");
save(outputFile, "net");

scores_test = minibatchpredict(net, SignImdsTransformed_Test);
YValidation_test = scores2label(scores_test, classNames);
TValidation_test = SignImds_Test.Labels;
accuracy_test = mean(YValidation_test == TValidation_test);

fprintf('FPGA Binning Test Accuracy: %.2f%%\n', accuracy_test * 100);
