function [] = incubate( handles )

    %global ser2;
    %global currentTemp;
    
    %- Variablen holen
    WPR_start_row = convertRow( get(handles.WPR_start_row, 'String') );
    WPR_stop_row = convertRow( get(handles.WPR_stop_row, 'String') );
    WPR_start_col = str2double( get(handles.WPR_start_col, 'String') );
    WPR_stop_col = str2double( get(handles.WPR_stop_col, 'String') );
    readtime = str2double( get(handles.readTime, 'String') );
    deltaTemp = str2double( get(handles.deltaTemp, 'String') );
    
    %- n�tige Variablen berechnen...
    interval = 300;                 %- 5 Minuten Messintervall                          (willk�rlich)
    readSpeed = 1.2 + readtime ;    %- 1.5 Sekunden Messzeit bei 0.3 Sekunden readtime  (gesch�tzt)
                                    %- 1.2 s/Well f�r Schlangenlinien, 1.4 s/Well f�r Zeilenweise
    heaterSpeed = 10;               %- 20 Sekunden f�r +2�C                             (gesch�tzt)

    %- Inkubationszeit berechnen
    incubation = interval - (deltaTemp * heaterSpeed) - (( WPR_stop_col - WPR_start_col + 1 ) * ( WPR_stop_row - WPR_start_row + 1 ) * readSpeed);

    %- Timer Reset
    t = 0;
    
    %- Stoppuhr starten...
    tic

    while t < incubation
        %- Zeit seit Stoppuhr l�uft holen
        t = toc; 
        %- Wie lange noch inkubieren?
        incubate = round(incubation - t);
        ser2log( handles, '0000', ['Incubating for ' num2str(incubate) ' more seconds.']);
        pause(0.5);
        
        %- Aktuelle Temperatur holen und ausgeben...
        %currentTemp = str2double( fscanf(ser2, '%s') );
        %set( handles.currentTemp, 'String', num2str(currentTemp) );
        
    end    
    


end

