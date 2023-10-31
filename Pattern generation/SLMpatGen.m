function varargout = SLMpatGen(slm, uigetpath)

global L
global SLMpattern_mask
global SLMpattern

% Identify each ROIs as ID number.
[~, L] = bwboundaries(slm);

% Save the grating direction for each ROI as number.
SLMpattern_mask = zeros(size(L));

% ROI image with grating. 
SLMpattern = zeros(size(L));

f = figure;
imshow(slm, 'Border', 'tight');

% Set the reaction(callback) for clicking the figure window.
set(f, 'WindowButtonDownFcn', @SpecifyDirectionFcn);

% Set the reaction(callback) for closing the figure window.
set(f, 'CloseRequestFcn', @MkPatternFcn);



% Update the output continuously until figure window exist.
while isgraphics(f)
    varargout{1} = SLMpattern;
    drawnow
end


    function SpecifyDirectionFcn(src,evt) 
        % Save the stimulation Region for each ROI as number.
        
        % Define the reaction(callback) function for clicking the figure window.
        % When click the roi, user can specify the grating direction.
        
        % Get the clicked point as coordinates on figure;
        cp = get(gca, 'CurrentPoint');
        cp = fix(cp(1,1:2));
        
        % Find the clicked ROI as ID number.
        roi_num = L(cp(2), cp(1));
        if roi_num ~= 0
            % IF click background, nothing happens.
            
            % Input the grating direction
            dlg_txt = sprintf(['Enter the direction.\n', 'e.g. up:8, rightdown:3,save selection:0']);
            direc = inputdlg(dlg_txt, 'Direction', [1 35], {'0'})
            direc = direc{1};

            % Indicate the direction on figure window.
            text(cp(1), cp(2), direc, 'Color', 'black', 'FontSize', 14, 'FontWeight', 'bold');

            % Following the input, assign the direction value for selected ROI into SLMpattern_mask.
            switch direc
                case '2'
                    SLMpattern_mask(L==roi_num) = 1;
                case '3'
                    SLMpattern_mask(L==roi_num) = 2;
                case '6'
                    SLMpattern_mask(L==roi_num) = 3;
                case '9'
                    SLMpattern_mask(L==roi_num) = 4;
                case '8'
                    SLMpattern_mask(L==roi_num) = 5;
                case '7'
                    SLMpattern_mask(L==roi_num) = 6;
                case '4'
                    SLMpattern_mask(L==roi_num) = 7;
                case '1'
                    SLMpattern_mask(L==roi_num) = 8;
                case '0'
                    fpath= uigetpath
                SLM_selection = fullfile(fpath,'slm_selection.png');
                saveas(gcf, SLM_selection);
                close (gcf);

            end


        end
    end





    function MkPatternFcn(src, evt)
        % Define the reaction(callback) for closing the figure window.
        % When closing, assign the grating direction for direction-unspecified ROIs.
        
        Non_selected = slm&(~(SLMpattern_mask>0));
        
        SLMgrating = {[185 185 185; 128 128 128; 61 61 61],...      % down
            [128 61 185; 61 185 128; 185 128 61],...      % right down
            [185 128 61; 185 128 61; 185 128 61],...      % right
            [185 128 61; 61 185 128; 128 61 185],...      % right up
            [61 61 61; 128 128 128; 185 185 185],...      % up
            [61 128 185; 128 185 61; 185 61 128],...      % left up
            [61 128 185; 61 128 185; 61 128 185],...      % left
            [185 61 128; 128 185 61; 61 128 185]};        % left down
        
        if any(Non_selected(:))
            % IF all ROIs were direction-specified, nothing happens.
            
            % Find unspecified directions as direction number.
            Non_selected_direc = setdiff(1:8, unique(SLMpattern_mask));
            
            % Identify the non-selected ROI as ID number.
            [~, NL] = bwboundaries(Non_selected);
            
            % The number of non-selected ROIs.
            num_non_selected_rois = max(NL(:))

            if isempty(Non_selected_direc)
                % IF All directions are specified, assign random direction.
                order = randperm(8);
                for i = 1 : num_non_selected_rois
                    SLMpattern_mask(NL==i) = order(rem(i,8)+1);
                end

            elseif length(Non_selected_direc) < num_non_selected_rois
                % IF non-selected ROIs are remain after assigning
                % unspecified directions, assign random direction.
                for i = 1 : length(Non_selected_direc)
                    SLMpattern_mask(NL==i) = Non_selected_direc(i);
                end
                
                % Assign random direction
                order = randperm(8);
                for i = (length(Non_selected_direc)+1):num_non_selected_rois
                    SLMpattern_mask(NL==i) = order(rem(i,8)+1);
                end
                
            elseif length(Non_selected_direc) > num_non_selected_rois
                % When the number of unspecified directions are larger than
                % the number of non-selected ROIs.
                for i = 1 : num_non_selected_rois
                    SLMpattern_mask(NL==i) = Non_selected_direc(i);
                end
            end
        end
        

%         SLMpattern_mask = watershed_Img(SLMpattern_mask);
    
        % Find specified directions.
        i_order = unique(SLMpattern_mask);
        i_order(i_order==0) = [];
        i_order = i_order';
        try
            % Generate grating pattern on ROIs.
            for i = i_order
                grating_image = repmat(SLMgrating{i}, size(slm)/3);
                SLMpattern_temp = double(SLMpattern_mask==i).* grating_image;
                SLMpattern = SLMpattern + SLMpattern_temp;
            end
        catch
            fprintf('error');
        end
        delete(f);
        varargout{1} = uint8(SLMpattern);
        drawnow
    end
end
