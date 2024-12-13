function expand_ROI
    % Function to expand ROIs in a binary TIFF file while maintaining their shape

    % Add necessary paths (update paths as needed)
    addpath(genpath(''));

    % Load the binary TIFF image
    [DMDinput_filename, DMDinput_path] = uigetfile('*.tif', 'Select binary TIFF file for ROI expansion.');
    if isequal(DMDinput_filename, 0)
        disp('File selection canceled.');
        return;
    end
    inputFile = fullfile(DMDinput_path, DMDinput_filename);
    DMDinput = imread(inputFile);

    % Ensure uppermost 1600 pixels are used if height exceeds 1600
    [height, width] = size(DMDinput);
    if height > 1600
        DMDinput = DMDinput(1:1600, :);
    end

    % Define parameters
    [~, name, ~] = fileparts(DMDinput_filename); % Extract file name without extension
    outputFile = fullfile(DMDinput_path, [name, '_expanded.tif']);
    expansionRadius = 15; % Expansion radius in pixels

    % Label connected components in the binary image
    labeledImg = bwlabel(DMDinput);
    properties = regionprops(labeledImg, 'PixelIdxList');

    % Create an expanded binary image
    expandedImg = false(size(DMDinput));

    % Expand each ROI using its outline
    for i = 1:length(properties)
        % Get the pixel indices of the ROI
        pixelList = properties(i).PixelIdxList;

        % Create a temporary binary image for the current ROI
        tempImg = false(size(DMDinput));
        tempImg(pixelList) = true;

        % Get the outline of the ROI
        outlineImg = bwperim(tempImg);

        % Expand the outline using morphological dilation
        se = strel('disk', expansionRadius); % Circular structuring element
        expandedOutline = imdilate(outlineImg, se);

        % Fill the expanded outline to create the new ROI
        filledROI = imfill(expandedOutline, 'holes');

        % Combine with the expanded image
        expandedImg = expandedImg | filledROI;
    end

    % Save the expanded image to a new TIFF file
    imwrite(expandedImg, outputFile);

    disp(['Expanded ROI image saved as: ', outputFile]);
end
