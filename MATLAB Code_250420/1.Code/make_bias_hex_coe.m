clear; clc;

inputDir = fullfile('..', '3.Result', 'quantized_hex_params');
outputHexDir = fullfile('..', '3.Result', 'Bias_HEX_files');
outputCoeDir = fullfile('..', '3.Result', 'Bias_COE_files');

% 디렉토리 생성
if ~exist(outputHexDir, 'dir'), mkdir(outputHexDir); end
if ~exist(outputCoeDir, 'dir'), mkdir(outputCoeDir); end

% 파일 목록
biasFiles = {
    'conv_1_Bias_fixed.hex', ...
    'conv_2_Bias_fixed.hex', ...
    'conv_3_Bias_fixed.hex', ...
    'fc_1_Bias_fixed.hex', ...
    'fc_2_Bias_fixed.hex'
};

% HEX 데이터 읽기
biasData = cell(1, numel(biasFiles));
for k = 1:numel(biasFiles)
    filePath = fullfile(inputDir, biasFiles{k});
    fid = fopen(filePath, 'r');
    biasData{k} = textscan(fid, '%s');
    fclose(fid);
    biasData{k} = biasData{k}{1};
end

% HEX 및 COE 파일 생성
for idx = 1:32
    hex_values = repmat({'00'}, 6, 1);

    if idx <= numel(biasData{1}), hex_values{1} = biasData{1}{idx}; end
    if idx <= numel(biasData{2}), hex_values{2} = biasData{2}{idx}; end
    if idx <= numel(biasData{3}), hex_values{3} = biasData{3}{idx}; end
    if idx <= 32 && idx <= numel(biasData{4}), hex_values{4} = biasData{4}{idx}; end
    if (idx+32) <= numel(biasData{4}), hex_values{5} = biasData{4}{idx+32}; end
    if idx <= numel(biasData{5}), hex_values{6} = biasData{5}{idx}; end

    % HEX 파일 저장
    hexFileName = fullfile(outputHexDir, sprintf('bias_%02d.hex', idx));
    fid = fopen(hexFileName, 'w');
    fprintf(fid, '%s\n', hex_values{:});
    fclose(fid);

    % COE 파일 저장
    coeFileName = fullfile(outputCoeDir, sprintf('bias_%02d.coe', idx));
    fid = fopen(coeFileName, 'w');
    fprintf(fid, 'memory_initialization_radix=16;\n');
    fprintf(fid, 'memory_initialization_vector=\n');
    fprintf(fid, '%s,\n', hex_values{1:end-1});
    fprintf(fid, '%s;\n', hex_values{end});
    fclose(fid);
end

disp('✅ Bias HEX 및 COE 파일 32개씩 생성 완료');
