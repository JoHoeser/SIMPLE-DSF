function [] = serConnect( handles )

    global ser;
    global port;
        
    global currentTemp;
    global tempTimer;
    
    global startTime;
    startTime = clock;
    
    global tempHistory;    
    %- Matrix f�r Temperaturdarstellung l�schen
    tempHistory = [ ; ];
    
    global HEATERSTATE;
    
    %- Button Text �ndern
    set(handles.connect,'String','Connecting...');
    
    %- In Dropdown usgew�hlten COM-Port auslesen
    portNr = get(handles.comPorts, 'Value');
    %- Wenn COM-Port ausgew�hlt
    if portNr == 1
        %- Wenn keiner ausgew�hlt wurde
        errordlg('Select valid COM port');
    else
        %- Wenn vern�nftiger Port ausgew�hlt
        %- Ausgew�hlte Dropdown Nr in COM-String umwandeln und verbinden
        ports = get(handles.comPorts, 'String');
        port = (ports(portNr));
        
        %- Einstellungen f�r COM-Port vornehmen
        ser = serial(port, ...
            'BaudRate', 115200, ...
            'DataBits', 8, ...
            'StopBits', 1, ...
        	'BytesAvailableFcnMode', 'terminator', ...
        	'BytesAvailableFcn', { @readTemp, handles } );
        
        try
            %- Verbindungsversuch
            fopen(ser);
            serLog( handles, '0000', 'Serial connection opened.');
            %- Button Text �ndern
            set(handles.connect, 'String', 'Disconnect');
            
            %- TempTimer definieren
            tempTimer = timer( ... 
                'Name', 'tempTimer', ...
                'ExecutionMode', 'fixedRate', ...
                'Period', 1, ...
                'TimerFcn', { @controlTemp, handles } );
            
            %- ... und starten
            start(tempTimer);
            
            %- Heater GUI freischalten            
            heaterState( handles, 'on' );
            
            %- Neue Start-Temperatur berechnen 
            pause(3);
            setTemp = round(currentTemp) + 1;
            set(handles.currentTemp, 'String', num2str(setTemp) );
            
            %- Heater initialisieren
            HEATERSTATE = 'OFF';
            set(handles.heaterState, 'String', 'Heater OFF');
            
            %- Status ausgeben
            serLog( handles, '0000', 'Heater ready.');
            
        %- Falls fehler in Textbox ausgeben
        catch e
            errordlg(e.message);
        end
    end
end

