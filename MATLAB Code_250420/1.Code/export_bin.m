%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make params to .bin files%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('../3.Result/manually_quant_net.mat', 'manually_qt_net');

outputDir_fixed = fullfile('..', '3.Result', 'quantized_binary_params');
if ~exist(outputDir_fixed, 'dir')
    mkdir(outputDir_fixed);
end

layers = manually_qt_net.Layers;

for i = 1:numel(layers)
    layer = layers(i);

    if isprop(layer, 'Weights') && ~isempty(layer.Weights)
        layerName = layer.Name;
        
        fi_weights = fi(layer.Weights, 1, 8, 5);
        fi_bias = fi(layer.Bias, 1, 8, 5);
        
        weights_int8 = int8(fi_weights.int);
        bias_int8 = int8(fi_bias.int);
        
        % Weight binary
        weights_filename = fullfile(outputDir_fixed, sprintf('%s_Weights_fixed.bin', layerName));
        fid_w = fopen(weights_filename, 'wb');
        fwrite(fid_w, weights_int8, 'int8');
        fclose(fid_w);
        
        % Bias binary 
        bias_filename = fullfile(outputDir_fixed, sprintf('%s_Bias_fixed.bin', layerName));
        fid_b = fopen(bias_filename, 'wb');
        fwrite(fid_b, bias_int8, 'int8');
        fclose(fid_b);

        fprintf('Saved weights and bias for layer: %s\n', layerName);
    end
end

disp('Quantized parameters have been exported successfully in binary format.');