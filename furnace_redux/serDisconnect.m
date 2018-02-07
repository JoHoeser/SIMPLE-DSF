function [] = serDisconnect( handles )

    global ser;

    global tempTimer
    
    global HEATERSTATE;
    HEATERSTATE = 'OFF';

    %- Heizung ausschalten
    fprintf(ser, '1');
    set(handles.heaterState, 'String', 'OFFLINE'); 
    set(handles.currentTemp, 'String', '');
    set(handles.setTemp, 'String', ''); 
    set(handles.tempTime, 'String', '00:00:00');
    
    %- Temptimer stoppen.
    stop(tempTimer);
    delete(tempTimer);
    
    %- Heater GUI abschalten
    heaterState( handles, 'off' );
    
    try

        %- Verbindung beenden
        fclose(ser);
        delete(ser),
        clear ser;
        serLog( handles, '0000', 'Serial connection closed.');    
        %- Button Text ändern
        set(handles.connect,'String','Connect');

    %- Falls Fehler in Textbox ausgeben
    catch e
        errordlg(e.message);
    end

end

