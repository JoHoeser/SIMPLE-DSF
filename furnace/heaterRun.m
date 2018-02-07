function [] = heaterRun( handles )

    global ser1;
    global ser2;
    
    global currentTemp;
    global setTemp;
    
    global HEATERSTATE;

    %- Wenn Heater gerade aus
    if strcmp( get( handles.heaterState, 'String' ), 'Gradient Read' )
        %- Lampe anschalten
        ser1log(handles, '0000', 'Switching lamp on.');
        fprintf(ser1, '$ES 0');
        OK(handles);
        set(handles.ES, 'String', 'Lamp ON');
        ser2log(handles, '0000', 'Calculating starting temperature.');
        %- Neue Start-Temperatur berechnen 
        pause(3);
        setTemp = ( round( currentTemp ) + 1 );
        %- Daten ausgeben
        pause(1);
        set(handles.currentTemp, 'String', num2str(currentTemp) );
        set(handles.setTemp, 'String', num2str(setTemp) );
        set(handles.heaterState, 'String', 'Measuring...');
        %- Heizung anschalten
        HEATERSTATE = 'ON';
        ser2log(handles, '0000', 'Heater ON');
        fprintf( ser2, num2str(setTemp) );
    else
        %- Heizung nicht mehr verfügbar
        HEATERSTATE = 'OFF';
        ser2log(handles, '0000', 'Heater OFF');
        %- Temperaturdaten löschen
        currentTemp = str2double('');
        set(handles.currentTemp, 'String', '');
        setTemp = str2double('');
        set(handles.setTemp, 'String', '');
        %- Zieltemperatur auf 1°C runterfahren...
        fprintf( ser2, '1' );
        %- Daten ausgeben
        set(handles.heaterState, 'String', 'Gradient Read');

    end

end

