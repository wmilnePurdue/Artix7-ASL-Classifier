currentFolder = "../2.Dataset";
dataFolder = fullfile(currentFolder, 'train_img_augmented');

SignImds = imageDatastore(dataFolder, ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');

classNames = categories(SignImds.Labels);
disp('Classes : ');
disp(classNames);

numObs = length(SignImds.Labels);
numObsPerClass = countEachLabel(SignImds);

[SignImds_Train, SignImds_Validation, SignImds_Test] = splitEachLabel(SignImds,0.6,0.2,'randomized');

function [labelled_image,info] = PreprocessData(image,info)
    resized_image = imresize(image, [32,32], 'nearest');
    normalized_image = rescale(resized_image,0,1);
    labelled_image = {normalized_image,info.Label};
end

SignImdsTransformed_Train = transform(SignImds_Train,@PreprocessData,'IncludeInfo',true);
SignImdsTransformed_Validation = transform(SignImds_Validation,@PreprocessData,'IncludeInfo',true);
SignImdsTransformed_Test = transform(SignImds_Test,@PreprocessData,'IncludeInfo',true);

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

net = trainnet(SignImdsTransformed_Train,layers,"crossentropy",options);

outputDir = "../3.Result/";
outputFile = fullfile(outputDir, "trained_net2.mat");
save(outputFile, "net");

scores = minibatchpredict(net,SignImdsTransformed_Validation);
YValidation = scores2label(scores,classNames);
TValidation = SignImds_Validation.Labels;
accuracy = mean(YValidation == TValidation);

scores_test = minibatchpredict(net,SignImdsTransformed_Test);
YValidation_test = scores2label(scores_test,classNames);
TValidation_test = SignImds_Test.Labels;
accuracy_test = mean(YValidation_test == TValidation_test);

fprintf('Validation Accuracy: %.2f%%\n', accuracy*100);
fprintf('Test Accuracy: %.2f%%\n', accuracy_test*100);