%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make .coe files based memory architecture%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc;

inputDir = fullfile('..', '3.Result', 'quantized_hex_params');
outputDir = fullfile('..', '3.Result', 'coe_files_c');

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

weightFiles = {
    'conv_1_Weights_fixed.hex', ...
    'conv_2_Weights_fixed.hex', ...
    'conv_3_Weights_fixed.hex', ...
    'fc_1_Weights_fixed.hex', ...
    'fc_2_Weights_fixed.hex'
};

romDistribution = [
    27,  72, 144, 768,  64;  % ROM 1~8
     0,  72, 144, 768,  64;  % ROM 9~16
     0,   0, 144, 768,  64;  % ROM 17~24
     0,   0,   0, 768,   0]; % ROM 25~32

readHexData = @(filename) regexprep(fileread(filename), '\s+', '');

% 데이터 미리 로드
for k = 1:length(weightFiles)
    hexFilePath = fullfile(inputDir, weightFiles{k});
    allHexData{k} = readHexData(hexFilePath);
end

% fc1_weights 데이터를 절반으로 나누고 interleave
fc1_hex = allHexData{4};
neuronSize = 384 * 2; % 768 chars (384 bytes * 2)
numNeurons = length(fc1_hex) / neuronSize;

% 두 그룹으로 나눔
firstHalf = cell(1, numNeurons/2);
secondHalf = cell(1, numNeurons/2);

for i = 1:(numNeurons/2)
    firstHalf{i} = fc1_hex((i-1)*neuronSize+1 : i*neuronSize);
    secondHalf{i} = fc1_hex((i-1+numNeurons/2)*neuronSize+1 : (i+numNeurons/2)*neuronSize);
end

% interleave 합치기
fc1_interleaved = [firstHalf; secondHalf];
fc1_interleaved = fc1_interleaved(:)';
allHexData{4} = strjoin(fc1_interleaved, '');

for romIdx = 1:32
    romData = '';
    groupIdx = ceil(romIdx / 8);

    for fileIdx = 1:length(weightFiles)
        numBytes = romDistribution(groupIdx, fileIdx);

        if numBytes > 0
            extractLen = numBytes * 2;

            if length(allHexData{fileIdx}) >= extractLen
                currentHex = allHexData{fileIdx}(1:extractLen);
                allHexData{fileIdx}(1:extractLen) = [];
            else
                currentHex = [allHexData{fileIdx}, repmat('00', 1, extractLen - length(allHexData{fileIdx}))];
                allHexData{fileIdx} = '';
            end

            romData = [romData currentHex];
        else
            prevGroupIdx = find(romDistribution(:, fileIdx) > 0, 1, 'first');
            reservedLen = romDistribution(prevGroupIdx, fileIdx)*2;
            reservedZeros = repmat('00', 1, reservedLen/2);
            romData = [romData reservedZeros];
        end
    end

    hexPairs = regexp(romData, '..', 'match');
    romDataWithCommas = strjoin(hexPairs, ', ');

    coeFileName = fullfile(outputDir, sprintf('ROM_%02d.coe', romIdx));
    fid = fopen(coeFileName, 'w');
    fprintf(fid, 'memory_initialization_radix=16;\n');
    fprintf(fid, 'memory_initialization_vector=\n%s;\n', romDataWithCommas);
    fclose(fid);

    fprintf('ROM %02d 저장 완료: %s\n', romIdx, coeFileName);
end

disp('✅ 모든 ROM 파일 생성이 완료되었습니다.');