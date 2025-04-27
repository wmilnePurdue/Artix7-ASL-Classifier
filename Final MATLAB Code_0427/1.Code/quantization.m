load ../3.Result/trained_net.mat
manually_qt_net = net
word_len = 16
frac_len = 10

tempLayer1 = getLayer(manually_qt_net,'imageinput');
tempLayer2 = getLayer(manually_qt_net,'conv_1');
tempLayer3 = getLayer(manually_qt_net,'relu_1');
tempLayer4 = getLayer(manually_qt_net,'maxpool_1');
tempLayer5 = getLayer(manually_qt_net,'conv_2');
tempLayer6 = getLayer(manually_qt_net,'relu_2');
tempLayer7 = getLayer(manually_qt_net,'maxpool_2');
tempLayer8 = getLayer(manually_qt_net,'conv_3');
tempLayer9 = getLayer(manually_qt_net,'relu_3');
tempLayer10 = getLayer(manually_qt_net,'maxpool_3');
tempLayer11 = getLayer(manually_qt_net,'flatten1');
tempLayer12 = getLayer(manually_qt_net,'fc_1');
tempLayer13 = getLayer(manually_qt_net,'fc_2');
tempLayer14 = getLayer(manually_qt_net,'softmax');

manually_qt_net= layerGraph(manually_qt_net); %convert to lgraph

manually_qt_net = replaceLayer(manually_qt_net,"imageinput",tempLayer1);
manually_qt_net = replaceLayer(manually_qt_net,"relu_1",tempLayer3);
manually_qt_net = replaceLayer(manually_qt_net,"maxpool_1",tempLayer4);
manually_qt_net = replaceLayer(manually_qt_net,"relu_2",tempLayer6);
manually_qt_net = replaceLayer(manually_qt_net,"maxpool_2",tempLayer7);
manually_qt_net = replaceLayer(manually_qt_net,"relu_3",tempLayer9);
manually_qt_net = replaceLayer(manually_qt_net,"maxpool_3",tempLayer10);
manually_qt_net = replaceLayer(manually_qt_net,"flatten1",tempLayer11);

fi_weights = fi(tempLayer2.Weights, 1,word_len,frac_len);
tempLayer2.Weights = fi_weights.double;
fi_bias = fi(tempLayer2.Bias, 1,word_len,frac_len);
tempLayer2.Bias = fi_bias.double;
manually_qt_net = replaceLayer(manually_qt_net,"conv_1",tempLayer2);

fi_weights = fi(tempLayer5.Weights, 1,word_len,frac_len);
tempLayer5.Weights = fi_weights.double;
fi_bias = fi(tempLayer5.Bias, 1,word_len,frac_len);
tempLayer5.Bias = fi_bias.double;
manually_qt_net = replaceLayer(manually_qt_net,"conv_2",tempLayer5);

fi_weights = fi(tempLayer8.Weights, 1,word_len,frac_len);
tempLayer8.Weights = fi_weights.double;
fi_bias = fi(tempLayer8.Bias, 1,word_len,frac_len);
tempLayer8.Bias = fi_bias.double;
manually_qt_net = replaceLayer(manually_qt_net,"conv_3",tempLayer8);

fi_weights = fi(tempLayer12.Weights, 1,word_len,frac_len);
tempLayer12.Weights = fi_weights.double;
fi_bias = fi(tempLayer12.Bias, 1,word_len,frac_len);
tempLayer12.Bias = fi_bias.double;
manually_qt_net = replaceLayer(manually_qt_net,"fc_1",tempLayer12);

fi_weights = fi(tempLayer13.Weights, 1,word_len,frac_len);
tempLayer13.Weights = fi_weights.double;
fi_bias = fi(tempLayer13.Bias, 1,word_len,frac_len);
tempLayer13.Bias = fi_bias.double;
manually_qt_net = replaceLayer(manually_qt_net,"fc_2",tempLayer13);

manually_qt_net = replaceLayer(manually_qt_net,"softmax",tempLayer14);

manually_qt_net = dlnetwork(manually_qt_net);

outputFile = "../3.Result/manually_quant_net.mat";
save(outputFile, "manually_qt_net");

pth = "../2.Dataset/";
dataFolder = fullfile(pth, 'train_img_augmented');

SignImds = imageDatastore(dataFolder, ...
'IncludeSubfolders',true, ...
'LabelSource','foldernames');

numObs = length(SignImds.Labels)
numObsPerClass = countEachLabel(SignImds)

numObsToShow = 8;
idx = randperm(numObs,numObsToShow);
imshow(imtile(SignImds.Files(idx),'GridSize',[2 4],'ThumbnailSize',[100 100]))

[SignImds_Train,SignImds_Validation,SignImds_Test] = splitEachLabel(SignImds,0.6,0.2,'randomized');

function [labelled_image,info] = PreprocessData(image,info)
    resized_image = imresize(image, [32,32], 'nearest');
    normalized_image = rescale(resized_image,0,1);
    quantized_image = fi(normalized_image,1,16,10).double;
    labelled_image = {quantized_image,info.Label};
end

SignImdsTransformed_Train = transform(SignImds_Train,@PreprocessData,'IncludeInfo',true);
SignImdsTransformed_Validation = transform(SignImds_Validation,@PreprocessData,'IncludeInfo',true);
SignImdsTransformed_Test = transform(SignImds_Test,@PreprocessData,'IncludeInfo',true);


classNames = categories(SignImds.Labels);
scores = minibatchpredict(manually_qt_net,SignImdsTransformed_Validation);
YValidation = scores2label(scores,classNames);
TValidation = SignImds_Validation.Labels;
accuracy_val = mean(YValidation == TValidation)

scores_test = minibatchpredict(manually_qt_net,SignImdsTransformed_Test);
YValidation_test = scores2label(scores_test,classNames);
TValidation_test = SignImds_Test.Labels;
accuracy_test = mean(YValidation_test == TValidation_test)

disp('Quantized model saved successfully.');