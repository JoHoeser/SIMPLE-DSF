function [] = ser2connect( handles )

    global ser2;
    global port2;
    
    global tempTimer;
    global currentTemp;
        
    global HEATERSTATE;
    
    %- Button Text ändern
    set(handles.connect2,'String','Connecting...');
    
    %- In Dropdown usgewählten COM-Port auslesen
    portNr = get(handles.comPorts2, 'Value');
    %- Wenn COM-Port ausgewählt
    if portNr == 1
        %- Wenn keiner ausgewählt wurde
        errordlg('Select valid COM port');
    else
        %- Wenn vernünftiger Port ausgewählt
        %- Ausgewählte Dropdown Nr in COM-String umwandeln und verbinden
        ports = get(handles.comPorts2, 'String');
        port2 = (ports(portNr));
        
        %- Einstellungen für COM-Port vornehmen
        ser2 = serial(port2, ...
            'BaudRate', 115200, ...
            'DataBits', 8, ...
            'StopBits', 1, ...
        	'BytesAvailableFcnMode', 'terminator', ...
        	'BytesAvailableFcn', { @readTemp, handles } );
        
        try
            %- Verbindungsversuch
            fopen(ser2);
            ser2log( handles, '0000', 'Serial connection (2) opened.');
            %- Button Text ändern
            set(handles.connect2,'String','Disconnect');
           
            %- TempTimer definieren
            tempTimer = timer( ... 
                'Name', 'tempTimer', ...
                'ExecutionMode', 'fixedRate', ...
                'Period', 0.3, ...
                'TimerFcn', { @controlTemp, handles } );
                
                %'StartFcn', { @(~,~)disp('tempTimer started.') }, ...
                %'StopFcn', { @(~,~)disp('tempTimer stopped.')} );
            %- ... und starten
            start(tempTimer);
            
            %- Heater GUI freischalten            
            heaterState( handles, 'on' );
            
            %- Neue Start-Temperatur berechnen 
            pause(3);
            set(handles.currentTemp, 'String', num2str(currentTemp) );
            
            %setTemp = ( round( currentTemp ) + 1 );
            %- Daten ausgeben
            %pause(1);
            %set(handles.setTemp, 'String', num2str(setTemp) );
            %- Heater initialisieren
            HEATERSTATE = 'OFF';
            set(handles.heaterState, 'String', 'Gradient Read');
            
            ser2log( handles, '0000', 'Heater ready.');
            
        %- Falls fehler in Textbox ausgeben
        catch e
            errordlg(e.message);
        end
    end
end

