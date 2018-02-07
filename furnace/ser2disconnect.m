function [] = ser2disconnect( handles )

    global ser2;
    
    global tempTimer;
    global currentTemp;
    global setTemp;

    global HEATERSTATE;
    HEATERSTATE = 'OFF';

    %- Heizung ausschalten
    fprintf( ser2, '1' );
    set(handles.heaterState, 'String', 'Heater Offline');
    currentTemp = str2double('');   
    set(handles.currentTemp, 'String', '');
    setTemp = str2double('');
    set(handles.setTemp, 'String', ''); 
    %- Temptimer stoppen.
    stop(tempTimer);
    delete(tempTimer);

    %- Heater GUI abschalten
    heaterState( handles, 'off' );
    
    try

        %- Verbindung beenden
        fclose(ser2);
        delete(ser2),
        clear ser2;
        ser2log( handles, '0000', 'Serial connection (2) closed.');    
        %- Button Text ändern
        set(handles.connect2,'String','Connect');

    %- Falls fehler in Textbox ausgeben
    catch e
        errordlg(e.message);
    end

end

