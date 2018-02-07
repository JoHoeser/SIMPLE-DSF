function [] = LS55init( handles )

    global ser1;

    %- Versuchen dem LS55 ein Lebenszeichen zu entlocken...
    fprintf(ser1, ['$AB' char(17)]);
    status = fscanf(ser1, '%s');

    %- Falls beschäftigt, gemächlich regelmässig leicht nerven...
    while strcmp(status, '0110') || strcmp(status, '')
        %- Status Ausgeben
        ser1log(handles, status, 'LS55 busy.');
        %- Neuen Status beantragen
        fprintf(ser1, ['$AB' char(17)]);
        pause(5);
        status = fscanf(ser1, '%s');
    end

    pause(2);

    %- Falls nicht mehr beschäftigt: freilaufenden Modus starten...
    if strcmp(status, '0022') || strcmp(status, '0002') || strcmp(status, '0000')
        %- Status Ausgeben
        ser1log(handles, status, 'LS55 connected.');
        %- in freilaufenden modus schalten
        fprintf(ser1, '$RE 0');
        pause(1);
        OK( handles );
        %- Status Ausgeben
        ser1log(handles, '0000', 'LS55 in free running mode.');
        %- Status Ausgeben
        ser1log(handles, status, 'LS55 up & running.');
        %- Lampenstatus abfragen
        fprintf(ser1, '$ES');
        OK(handles);
        ES = fscanf(ser1, '%s');
        ES(1) = ''; %- Erstes Zeichen aus String entfernen
        OK(handles);
        %- Lampenstatus abfragen und Button anpassen
        if strcmp(ES,'0')
            set(handles.ES, 'String', 'Lamp ON' );
        elseif strcmp(ES,'1')
            set(handles.ES, 'String', 'Lamp OFF' );
        else
            set(handles.ES, 'String', 'Lamp ERROR' );
        end
    
    else
        %- Wenn irgendwas im argen ist: benachrichtigen
        ser1log(handles, status, 'ERROR! Disconnecting.');
        ser1disconnect( handles );
    end

end

