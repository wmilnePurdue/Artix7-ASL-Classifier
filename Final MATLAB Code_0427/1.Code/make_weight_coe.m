%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make .coe files based memory architecture%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc;

inputDir = fullfile('..', '3.Result', 'quantized_hex_params');
outputDir = fullfile('..', '3.Result', 'Weights_COE_files');

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% HEX file read
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
allHexData = cell(1, length(weightFiles));
for k = 1:length(weightFiles)
    hexFilePath = fullfile(inputDir, weightFiles{k});
    allHexData{k} = readHexData(hexFilePath);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Conv1 / Conv2 / Conv3 (16bit)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ----- Conv1 -----
conv1_hex = allHexData{1};
bytesPerFilter_conv1 = 3*3*3;   % 27
numFilters_conv1     = 8;
reorderedData_conv1  = '';

for f = 1:numFilters_conv1
    hexLen = bytesPerFilter_conv1 * 4;
    rawFilterHex = conv1_hex(1:hexLen);
    conv1_hex(1:hexLen) = [];

    byteArray = zeros(bytesPerFilter_conv1, 1, 'uint16');
    for iByte = 1:bytesPerFilter_conv1
        twoHex = rawFilterHex((iByte-1)*4+1 : (iByte-1)*4+4);
        byteArray(iByte) = hex2dec(twoHex);
    end

    temp3d = reshape(byteArray, [3, 3, 3]);
    newFilter = [];
    for row = 1:3
        for ch = 1:3
            for col = 1:3
                val = temp3d(row,col,ch);
                newFilter(end+1) = val;
            end
        end
    end

    for i = 1:length(newFilter)
        reorderedData_conv1 = sprintf('%s%04X', reorderedData_conv1, newFilter(i));
    end
end
allHexData{1} = reorderedData_conv1;

% ----- Conv2 -----
conv2_hex = allHexData{2};
bytesPerFilter_conv2 = 3*3*8;   % 72
numFilters_conv2     = 16;
reorderedData_conv2  = '';

for f = 1:numFilters_conv2
    hexLen = bytesPerFilter_conv2 * 4;
    rawFilterHex = conv2_hex(1:hexLen);
    conv2_hex(1:hexLen) = [];

    byteArray = zeros(bytesPerFilter_conv2,1,'uint16');
    for iByte = 1:bytesPerFilter_conv2
        twoHex = rawFilterHex((iByte-1)*4+1 : (iByte-1)*4+4);
        byteArray(iByte) = hex2dec(twoHex);
    end

    temp3d = reshape(byteArray, [3, 3, 8]);
    newFilter = [];
    for row = 1:3
        for ch = 1:8
            for col = 1:3
                newFilter(end+1) = temp3d(row,col,ch);
            end
        end
    end

    for i = 1:length(newFilter)
        reorderedData_conv2 = sprintf('%s%04X', reorderedData_conv2, newFilter(i));
    end
end
allHexData{2} = reorderedData_conv2;

% ----- Conv3 -----
conv3_hex = allHexData{3};
bytesPerFilter_conv3 = 3*3*16; % 144
numFilters_conv3     = 24;
reorderedData_conv3  = '';

for f = 1:numFilters_conv3
    hexLen = bytesPerFilter_conv3 * 4;
    rawFilterHex = conv3_hex(1:hexLen);
    conv3_hex(1:hexLen) = [];

    byteArray = zeros(bytesPerFilter_conv3, 1, 'uint16');
    for iByte = 1:bytesPerFilter_conv3
        twoHex = rawFilterHex((iByte-1)*4+1 : (iByte-1)*4+4);
        byteArray(iByte) = hex2dec(twoHex);
    end

    temp3d = reshape(byteArray, [3,3,16]);
    newFilter = [];
    for row = 1:3
        for ch = 1:16
            for col = 1:3
                newFilter(end+1) = temp3d(row,col,ch); 
            end
        end
    end

    for i = 1:length(newFilter)
        reorderedData_conv3 = sprintf('%s%04X', reorderedData_conv3, newFilter(i));
    end
end
allHexData{3} = reorderedData_conv3;

% ===================== FC1 =====================
fc1_hex = allHexData{4};
numBytes_fc1 = length(fc1_hex)/4;
fc1_int16 = zeros(1, numBytes_fc1, 'int16');
for iByte = 1:numBytes_fc1
    txt = fc1_hex((iByte-1)*4+1 : (iByte-1)*4+4);
    fc1_int16(iByte) = typecast(uint16(hex2dec(txt)), 'int16');
end

OutDim_fc1 = 64;  
InDim_fc1  = 384; 
if numBytes_fc1 ~= OutDim_fc1*InDim_fc1
    error('FC1 size mismatch: expected 64*384=%d, got %d',...
         OutDim_fc1*InDim_fc1, numBytes_fc1);
end

temp2D_fc1 = reshape(fc1_int16, [OutDim_fc1, InDim_fc1]);  


fc1_reordered_arr = [];
for i = 1:32
    neuronA = temp2D_fc1(i, :);
    neuronB = temp2D_fc1(i+32, :);
    fc1_reordered_arr = [fc1_reordered_arr, neuronA, neuronB]; 
end

% int8 -> hex
fc1_reordered_hex = '';
for i = 1:length(fc1_reordered_arr)
    val = fc1_reordered_arr(i);
    fc1_reordered_hex = sprintf('%s%04X', fc1_reordered_hex, typecast(val,'uint16'));
end
allHexData{4} = fc1_reordered_hex;


% ===================== FC2 =====================
fc2_hex = allHexData{5};
numBytes_fc2 = length(fc2_hex)/4;
fc2_int16 = zeros(1, numBytes_fc2, 'int16');
for iByte = 1:numBytes_fc2
    txt = fc2_hex((iByte-1)*4+1 : (iByte-1)*4+4);
    fc2_int16(iByte) = typecast(uint16(hex2dec(txt)), 'int16');
end

OutDim_fc2 = 24;  
InDim_fc2  = 64;
if numBytes_fc2 ~= OutDim_fc2*InDim_fc2
    error('FC2 size mismatch: expected 24*64=%d, got %d',...
          OutDim_fc2*InDim_fc2, numBytes_fc2);
end

temp2D_fc2 = reshape(fc2_int16, [OutDim_fc2, InDim_fc2]);


% fc2_reordered_arr = temp2D_fc2(:);  
fc2_reordered_arr = reshape(temp2D_fc2',1,[])
fc2_reordered_hex = '';
for i = 1:length(fc2_reordered_arr)
    val = fc2_reordered_arr(i);
    fc2_reordered_hex = sprintf('%s%04X', fc2_reordered_hex, typecast(val,'uint16'));
end
allHexData{5} = fc2_reordered_hex;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ROM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for romIdx = 1:32
    romData = '';
    groupIdx = ceil(romIdx / 8);

    for fileIdx = 1:length(weightFiles)
        numBytes = romDistribution(groupIdx, fileIdx);

        if numBytes > 0
            extractLen = numBytes * 4;

            if length(allHexData{fileIdx}) >= extractLen
                currentHex = allHexData{fileIdx}(1:extractLen);
                allHexData{fileIdx}(1:extractLen) = [];
            else
                currentHex = [allHexData{fileIdx}, ...
                              repmat('00',1, extractLen - length(allHexData{fileIdx}))];
                allHexData{fileIdx} = '';
            end

            romData = [romData currentHex];
        else
            prevGroupIdx = find(romDistribution(:, fileIdx) > 0, 1, 'first');
            reservedLen = romDistribution(prevGroupIdx, fileIdx)*4;
            reservedZeros = repmat('00', 1, reservedLen/2);
            romData = [romData reservedZeros];
        end
    end

    hexPairs = regexp(romData, '....', 'match');
    romDataWithCommas = strjoin(hexPairs, ', ');

    coeFileName = fullfile(outputDir, sprintf('ROM_%02d.coe', romIdx));
    fid = fopen(coeFileName, 'w');
    fprintf(fid, 'memory_initialization_radix=16;\n');
    fprintf(fid, 'memory_initialization_vector=\n%s;\n', romDataWithCommas);
    fclose(fid);

    fprintf('ROM %02d save COMPLETE: %s\n', romIdx, coeFileName);
end

disp('Saved ROM files.');
