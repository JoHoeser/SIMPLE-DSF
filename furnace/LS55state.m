function [] = LS55state( handles , state )

    %% Textboxes in GUI
    %- WPR Panel
    set(handles.WPR_start_row, 'Enable', state);
    set(handles.WPR_stop_row, 'Enable', state);
    set(handles.WPR_start_col, 'Enable', state);
    set(handles.WPR_stop_col, 'Enable', state);
    set(handles.readTime, 'Enable', state);
    %- LS55 Panel
    set(handles.MX, 'Enable', state);
    set(handles.MM, 'Enable', state);
    set(handles.SX, 'Enable', state);
    set(handles.SM, 'Enable', state); 
    
    %% Dropdowns in GUI
    set(handles.OS, 'Enable', state);
    set(handles.FW, 'Enable', state);    
    
    %%  Buttons in GUI
    set(handles.ES, 'Enable', state);
    set(handles.resetLS55, 'Enable', state);
    set(handles.SendSettings, 'Enable', state);
    set(handles.readWPR, 'Enable', state);
    set(handles.targetPath, 'Enable', state);
    
end

