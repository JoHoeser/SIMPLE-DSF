function [] = ser1connect( handles )
   
    global ser1;
    global port1;
    
    global WPRREAD;
    global WPRINIT;
    WPRINIT = 'FALSE';
    
    %- Button Text ändern
    set(handles.connect1,'String','Connecting...');
    
    %- In Dropdown usgewählten COM-Port auslesen
    portNr = get(handles.comPorts1, 'Value');
    %- Wenn COM-Port ausgewählt
    if portNr == 1
        %- Wenn keiner ausgewählt wurde
        errordlg('Select valid COM port');
    else
        %- Wenn vernünftiger Port ausgewählt
        %- Ausgewählte Dropdown Nr in COM-String umwandeln und verbinden
        ports = get(handles.comPorts1, 'String');
        port1 = ports(portNr);
        %- Einstellungen für COM-Port vornehmen
        ser1 = serial(port1, ...
            'BaudRate', 9600, ...
            'DataBits', 8, ...
            'StopBits', 1, ...
            'Terminator', 'CR' );
        
        try
            %- Verbindungsversuch
            fopen(ser1);
            
            %- Initialstatus setzen...
            ser1log(handles , '0000', 'Serial connection (1) opened.');
            
            %- LS55 initialisieren
            LS55init( handles );
            
            %- WPR initialisieren
            MX = get(handles.MX, 'String');
            MM = get(handles.MM, 'String');
            SX = get(handles.SX, 'String');
            SM = get(handles.SM, 'String');
            OS = get(handles.OS, 'Value');
            FW = get(handles.FW, 'Value');
            
            WPRinit( handles, MX, MM, SX, SM, OS, FW );
            WPRparam( handles );
    
            WPRINIT = 'TRUE';
            WPRREAD = 'FALSE';
            
            %- Button Text ändern
            set(handles.connect1,'String','Disconnect');
            
            %- LS55 GUI freischelten
            LS55state( handles, 'on');
            
        %- Falls fehler in Textbox ausgeben
        catch e
            errordlg(e.message);
        end
    end
    
end

