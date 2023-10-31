function varargout = PointTform

fxpoints = [];
mvpoints = [];
dlg_txt = {'X (Reference):', 'Y (Reference):', 'X (Moved):', 'Y (Moved):'};
dlg_default = {'1', '1', '1', '1'};
while true
    Inputpoint = inputdlg(dlg_txt, 'Input points', [1 35], dlg_default);
    if isempty(Inputpoint)
        break
    end
    
    Inputpoint = str2double(Inputpoint);
    fxpoints = [fxpoints; Inputpoint(1:2)'];
    mvpoints = [mvpoints; Inputpoint(3:4)'];
end

tform = fitgeotrans(mvpoints, fxpoints, 'similarity');
varargout{1} = tform;


end