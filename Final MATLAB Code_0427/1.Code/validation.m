%%%%%%%%%%%% 1) Input example 3x3x3  %%%%%%%%%%%%%
input_image = zeros(3,3,3);
input_image(:,:,1) = [0 0 0; 0 0.1562 0.125; 0 0.1562 0.125];
input_image(:,:,2) = [0 0 0; 0 0.1562 0.125; 0 0.1562 0.125];
input_image(:,:,3) = [0 0 0; 0 0.1562 0.125; 0 0.1562 0.125];

%%%%%%%%%%%% 2) Load model & get conv_1 parameters %%%%%%%%%%%%
load('../3.Result/manually_quant_net.mat', 'manually_qt_net');
layer_graph = layerGraph(manually_qt_net);
temp_net = dlnetwork(layer_graph);

conv1 = getLayer(manually_qt_net, 'conv_1'); 
weights = conv1.Weights;  % (3,3,3,8)
bias    = conv1.Bias;     % (1,8)
filter_idx = 1;           % first filter

%%%%%%%%%%%% 3) Get actual MATLAB output %%%%%%%%%%%%
dl_input = dlarray(input_image, 'SSCB');  % 4D
model_out = predict(temp_net, dl_input, 'Outputs','conv_1');
model_out = extractdata(model_out);   % size=[3,3,8,1]
model_val_center = model_out(2,2,filter_idx);

%%%%%%%%%%%% 4) Manual computation %%%%%%%%%%%%
w = weights(:,:,:, filter_idx); % shape=[3,3,3]
b = bias(filter_idx);

sumVal = 0.0;
for ch = 1:3
    sumVal = sumVal + sum(sum( input_image(:,:,ch).* w(:,:,ch) ));
end
hand_calc_val = sumVal + b;

%%%%%%%%%%%% 5) Compare results  %%%%%%%%%%%%
fprintf("Manual conv = %.6f\n", hand_calc_val);
fprintf("MATLAB conv = %.6f\n", model_val_center);

%%%%% Result by Devendra
result = minibatchpredict(manually_qt_net, input_image, Outputs="conv_1");
fprintf("\nDev conv = %.6f\n", result(2,2,1));
