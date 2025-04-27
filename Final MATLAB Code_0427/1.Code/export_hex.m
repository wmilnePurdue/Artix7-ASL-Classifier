load('../3.Result/manually_quant_net.mat', 'manually_qt_net');

outputDir_fixed = fullfile('..', '3.Result', 'quantized_hex_params');
if ~exist(outputDir_fixed, 'dir')
    mkdir(outputDir_fixed);
end

layers = manually_qt_net.Layers;

word_len = 16;
frac_len = 10; 

for i = 1:numel(layers)
    layer = layers(i);

    if isprop(layer, 'Weights') && ~isempty(layer.Weights)
        layerName = layer.Name;
        
        % 16-bit quantization (Q16.10)
        fi_weights = fi(layer.Weights, 1, word_len, frac_len);
        fi_bias = fi(layer.Bias, 1, word_len, frac_len);
        
        weights_int16 = int16(fi_weights.int);
        bias_int16 = int16(fi_bias.int);
        
        % Weights HEX(ASCII) 
        weights_filename = fullfile(outputDir_fixed, sprintf('%s_Weights_fixed.hex', layerName));
        fid_w = fopen(weights_filename, 'w');
        for w = 1:numel(weights_int16)
            fprintf(fid_w, '%04X\n', typecast(weights_int16(w), 'uint16'));
        end
        fclose(fid_w);
        
        % Bias HEX(ASCII) 
        bias_filename = fullfile(outputDir_fixed, sprintf('%s_Bias_fixed.hex', layerName));
        fid_b = fopen(bias_filename, 'w');
        for b = 1:numel(bias_int16)
            fprintf(fid_b, '%04X\n', typecast(bias_int16(b), 'uint16'));
        end
        fclose(fid_b);

        fprintf('Saved HEX weights and bias for layer: %s\n', layerName);
    end
end

disp('Quantized parameters have been exported successfully in HEX (ASCII) format.');