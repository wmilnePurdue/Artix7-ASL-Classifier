

clear; clc;

% 디렉토리 설정
hexDir = fullfile('..', '3.Result', 'quantized_hex_params');
coeDir = fullfile('..', '3.Result', 'coe_files');

% 파일 목록 및 크기 정의
layerFiles = {
    'conv_1_Weights_fixed.hex', 
    'conv_2_Weights_fixed.hex', 
    'conv_3_Weights_fixed.hex', 
    'fc_1_Weights_fixed.hex', 
    'fc_2_Weights_fixed.hex'
};

layerSizes = [216, 1152, 3456, 24576, 1536]; % 바이트 단위

romDistribution = [
    27,  72, 144, 384*2, 64;  % ROM 1~8
     0,  72, 144, 384*2, 64;  % ROM 9~16
     0,   0, 144, 384*2, 64;  % ROM 17~24
     0,   0,   0, 384*2,  0]; % ROM 25~32

% 원본 데이터 미리 로드
allLayersHex = {};
for idx = 1:length(layerFiles)
    hexData = fileread(fullfile(hexDir, layerFiles{idx}));
    hexData = regexprep(hexData, '\s+', '');
    hexCells = regexp(hexData, '..', 'match');
    allLayersHex{idx} = hexCells;
end

% 각 ROM 데이터 로드
romData = cell(32,1);
for romIdx = 1:32
    coeFile = fullfile(coeDir, sprintf('ROM_%02d.coe', romIdx));
    coeText = fileread(coeFile);
    dataStart = strfind(coeText, 'memory_initialization_vector=') + length('memory_initialization_vector=');
    dataHex = regexp(coeText(dataStart:end), '[0-9A-Fa-f]{2}', 'match');
    romData{romIdx} = dataHex;
end

% 각 ROM 검증
layerOffset = [0, 0, 0, 0, 0];

for romIdx = 1:32
    expectedSize = 1075; % 모든 ROM 크기 동일
    actualSize = length(romData{romIdx});
    if actualSize ~= expectedSize
        fprintf('🚨 ROM %d 크기 불일치: 예상 %d bytes, 실제 %d bytes\n', romIdx, expectedSize, actualSize);
    else
        fprintf('✅ ROM %d 크기 확인 (%d bytes)\n', romIdx, actualSize);
    end

    % ROM별 각 레이어 데이터 검증
    hexPtr = 1;
    for layerIdx = 1:5
        byteCount = romDistribution(ceil(romIdx/8), layerIdx);
        if byteCount > 0
            layerHex = allLayersHex{layerIdx};
            expectedData = layerHex(layerOffset(layerIdx)+1 : layerOffset(layerIdx)+byteCount);
            actualData = romData{romIdx}(hexPtr : hexPtr+byteCount-1);

            if isequal(expectedData, actualData)
                fprintf('✅ ROM %d - %s 데이터 일치 확인\n', romIdx, layerFiles{layerIdx});
            else
                fprintf('🚨 ROM %d - %s 데이터 불일치!\n', romIdx, layerFiles{layerIdx});
            end

            layerOffset(layerIdx) = layerOffset(layerIdx) + byteCount;
            hexPtr = hexPtr + byteCount;
        else
            % reserved 영역은 모두 0인지 확인
            reservedSize = romDistribution(find(romDistribution(:,layerIdx)>0,1,'first'), layerIdx);
            actualData = romData{romIdx}(hexPtr : hexPtr+reservedSize-1);
            if all(strcmp(actualData, '00'))
                fprintf('✅ ROM %d - %s reserved 영역 확인 (모두 00)\n', romIdx, layerFiles{layerIdx});
            else
                fprintf('🚨 ROM %d - %s reserved 영역 오류!\n', romIdx, layerFiles{layerIdx});
            end
            hexPtr = hexPtr + reservedSize;
        end
    end
end

% FC1 special layout 확인 (Neuron1 & 33, 2 & 34, ...)
fc1_hex = allLayersHex{4};

for romIdx = 1:32
    neuron1_idx = (romIdx-1)*384 + 1;
    neuron2_idx = (romIdx+31)*384 + 1;

    expected_fc1 = [fc1_hex(neuron1_idx:neuron1_idx+383), fc1_hex(neuron2_idx:neuron2_idx+383)];

    fc1_start_idx = sum(romDistribution(1,1:3)) + 1;
    actual_fc1 = romData{romIdx}(fc1_start_idx:fc1_start_idx+767);

    if isequal(expected_fc1, actual_fc1)
        fprintf('✅ ROM %d FC1 배열 정확 (Neuron %d & %d)\n', romIdx, romIdx, romIdx+32);
    else
        fprintf('🚨 ROM %d FC1 배열 오류 (Neuron %d & %d)\n', romIdx, romIdx, romIdx+32);
    end
end