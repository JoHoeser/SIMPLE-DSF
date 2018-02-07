function [ ] = controlTemp( ~, ~, handles )

    global ser;
    global HEATERSTATE;
        
    setTemp = str2double( get(handles.setTemp, 'String') );
    targetTemp = str2double( get(handles.targetTemp, 'String') );
    currentTemp = str2double( get(handles.currentTemp, 'String') );
    
    if strcmp(HEATERSTATE, 'ON');
        fprintf( ser, num2str(setTemp) );
    end
    
    if strcmp(HEATERSTATE, 'OFF');
        
        if currentTemp < targetTemp
            initTemp = round( currentTemp ) + 1;
        else
            initTemp = round( currentTemp );
        end
        
        %- GUI Output       
        set(handles.setTemp, 'String', initTemp );
    end
    
    %- Laufzeit der Temperaturstufe anzeigen
    global startTime;
    stopTime = clock;
    tempTime = etime( stopTime, startTime ); 
    set(handles.tempTime, 'String', datestr(tempTime / 86400, 'HH:MM:SS')); %.FFF'));
    
    %- Temperaturdaten speichern und anzeigen lassen
    global tempHistory;
    if ~isnan( currentTemp )
        %- aktuellen Temperaturwert in die Temp-Matrix einfügen
        temp = [ tempTime; currentTemp ];
        tempHistory = [ tempHistory temp ];
        
        %- Temperaturdaten plotten
        x = tempHistory(1, :);
        y = tempHistory(2, :);
        scatter(handles.tempGraph, x, y, 3);
         
        
        
    end

    
end

