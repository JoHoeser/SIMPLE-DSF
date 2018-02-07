function [] = ser1disconnect( handles )

    global ser1;
    global currentTemp;
    global setTemp;
    
    global WPRINIT;
    WPRINIT = 'FALSE';
        
    global WPRreading;
    WPRreading = 'FALSE';
    
    global heaterState;
    heaterState = 'OFF';
    
    set(handles.heaterState, 'String', 'Heater OFF');
    currentTemp = str2double('');
    set(handles.currentTemp, 'String', '');
    setTemp = str2double('');
    set(handles.setTemp, 'String', '');
    
    %- LS55 GUI abschalten
    LS55state( handles, 'off' );
    
    try
        %- Verbindung beenden
        fclose(ser1);
        delete(ser1);
        clear ser1;
        ser1log(handles, '0000', 'Serial connection (1) closed.');  
        %- Button Text ändern
        set(handles.connect1,'String','Connect');
    %- Falls Fehler in Textbox ausgeben
    catch e
        errordlg(e.message);
    end

end

