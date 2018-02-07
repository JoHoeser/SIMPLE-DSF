function [] = heaterState( handles, state )

    %% Textboxes in GUI
    %- LS55 Panel
    set(handles.targetTemp, 'Enable', state);
    set(handles.deltaTemp, 'Enable', state);
    
    if strcmp(state, 'on')
        set(handles.currentTemp, 'Enable', 'inactive');
        set(handles.setTemp, 'Enable', 'inactive');
    else
        set(handles.currentTemp, 'Enable', state);
        set(handles.setTemp, 'Enable', state);     
    end
    
    %% Dropdowns in GUI
   
    
    %%  Buttons in GUI
    set(handles.heaterState, 'Enable', state);

end

