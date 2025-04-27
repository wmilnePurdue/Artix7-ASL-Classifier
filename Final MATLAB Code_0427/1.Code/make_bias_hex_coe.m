clear; clc;

inputDir = fullfile('..', '3.Result', 'quantized_hex_params');
outputHexDir = fullfile('..', '3.Result', 'Bias_HEX_files');
outputCoeDir = fullfile('..', '3.Result', 'Bias_COE_files');

if ~exist(outputHexDir, 'dir'), mkdir(outputHexDir); end
if ~exist(outputCoeDir, 'dir'), mkdir(outputCoeDir); end

biasFiles = {
    'conv_1_Bias_fixed.hex', ...
    'conv_2_Bias_fixed.hex', ...
    'conv_3_Bias_fixed.hex', ...
    'fc_1_Bias_fixed.hex', ...
    'fc_2_Bias_fixed.hex'
};

biasData = cell(1, numel(biasFiles));
for k = 1:numel(biasFiles)
    filePath = fullfile(inputDir, biasFiles{k});
    fid = fopen(filePath, 'r');
    biasData{k} = textscan(fid, '%s');
    fclose(fid);
    biasData{k} = biasData{k}{1};
end

for idx = 1:32
    hex_values = repmat({'0000'}, 6, 1); % 16-bit default '0000'

    if idx <= numel(biasData{1}), hex_values{1} = biasData{1}{idx}; end
    if idx <= numel(biasData{2}), hex_values{2} = biasData{2}{idx}; end
    if idx <= numel(biasData{3}), hex_values{3} = biasData{3}{idx}; end
    if idx <= 32 && idx <= numel(biasData{4}), hex_values{4} = biasData{4}{idx}; end
    if (idx+32) <= numel(biasData{4}), hex_values{5} = biasData{4}{idx+32}; end
    if idx <= numel(biasData{5}), hex_values{6} = biasData{5}{idx}; end

    hexFileName = fullfile(outputHexDir, sprintf('bias_%02d.hex', idx));
    fid = fopen(hexFileName, 'w');
    fprintf(fid, '%s\n', hex_values{:});
    fclose(fid);

    coeFileName = fullfile(outputCoeDir, sprintf('bias_%02d.coe', idx));
    fid = fopen(coeFileName, 'w');
    fprintf(fid, 'memory_initialization_radix=16;\n');
    fprintf(fid, 'memory_initialization_vector=\n');
    fprintf(fid, '%s,\n', hex_values{1:end-1});
    fprintf(fid, '%s;\n', hex_values{end});
    fclose(fid);
end

disp('Saved Bias HEX & COE files (16-bit) 32 each');