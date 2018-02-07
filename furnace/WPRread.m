function [] = WPRread( handles )

    global ser1;

    global setTemp;

    global WPRREAD;
    global WPRINIT;

    global WPR_data;
    
    %- Platte: Welldimensionen
    WPR_start_row = convertRow( get(handles.WPR_start_row, 'String') );
    WPR_stop_row = convertRow( get(handles.WPR_stop_row, 'String') );
    WPR_start_col = str2double( get(handles.WPR_start_col, 'String') );
    WPR_stop_col = str2double( get(handles.WPR_stop_col, 'String') ); 
        
    readtime = str2double( get(handles.readTime, 'String') );

    %- Ergebnisarray erstellen & mit Nullen füllen
    ROWS = WPR_stop_row - WPR_start_row + 1;   
    COLS = WPR_stop_col - WPR_start_col + 1; 
    WPR_data = zeros( ROWS, COLS );

    %- Initialdaten zur Koordinatenberechnung
    %- kA ob Gerätekonstanten... zumindest spezifisch für 96 Well Platten 
    row_offset = 10.2; %- OFFSET Y
    col_offset = 12.0; %- OFFSET X
    row_spacing = 8.84; %- SPACING Y
    col_spacing = 8.99; %- SPACING X

    %- Aktuelle Well Nummer
    row = WPR_start_row;
    col = WPR_start_col;
    
    %- kontrollieren ob initialisiert
    if strcmp(WPRINIT, 'FALSE');
        
        %- WPR (re-)initialisieren
        MX = get(handles.MX, 'String');
        MM = get(handles.MM, 'String');
        SX = get(handles.SX, 'String');
        SM = get(handles.SM, 'String');
        OS = get(handles.OS, 'Value');
        FW = get(handles.FW, 'Value');

        %- Platereader initialisieren
        WPRinit( handles, MX, MM, SX, SM, OS, FW );
        WPRparam( handles );
    
    %- Falls ja Messung starten
    else
    
        WPRREAD = 'TRUE';
        LS55state( handles, 'off' );

        %- Platte abrastern
        while row <= WPR_stop_row

            %- Well auslesen & Daten abspeichern
            WellRead( handles, col, col_spacing, col_offset, row, row_spacing, row_offset, readtime );
            
%             %- LESEKOPF NEU POSITIONIEREN (ZEILENWEISE):
%             %- Falls noch nicht hinten angekommen
%             if col < WPR_stop_col
%                 %- eins weiter
%             	col = col + 1;
%             %- falls doch
%             else
%                 %- nächste Zeile...
%                 row = row + 1;
%                 %- ... von vorne
%                 col = WPR_start_col;  
%             end
             
            %- LESEKOPF NEU POSITIONIEREN (SCHLANGENLINIEN):
            %- wenn Reihe ungerade:
            if mod(row, 2)
                   %- Falls letzte Spalte ...
                if col == WPR_stop_col
                    %- ... nächste Zeile, sonst ...
                    row = row + 1;
                else
                    %- ... nächste Spalte
                    col = col + 1;
                end
            %- wenn Reihe gerade:    
            else 
                %- Falls erste Spalte ...
                if col == WPR_start_col
                    %- ... nächste Zeile, sonst ...
                    row = row + 1;
                else
                    %- ... vorige Spalte
                    col = col - 1;
                end  
           end
            
            %- sehr kurz verzögern (wegen Timer)
            pause(0.1);
            
        end

        %- in Parkposition fahren
        fprintf(ser1, '$PP');
        %- Status abwarten
        pause(3);
        OK(handles);

        WPRREAD = 'FALSE';
        LS55state( handles, 'on' );
            
        %- Dateipfad für den Output
        targetPath = get(handles.targetPath, 'String');
        
        %- Sheetname für Output
        if isnumeric(setTemp)
            sheetname_part1 = num2str(setTemp);
        else
            sheetname_part1 = 'single' ;
        end
        
        sheetname_part2 = datestr(now, 'HHMMSS'); %- Hier nichst wie HH:MM:SS einfügen, da sonst nicht gespeichert wird!
        
        %- Datei- und Sheetname zusammenknibbeln
        sheetname = [ sheetname_part1 '°C - ' sheetname_part2 ];
        
        %- Ergebnisarray in Datei schreiben
        ser1log(handles, '0000', 'Starting writing result file.');
        
        try
            %xlsheets( sheetname, targetPath );
            xlswrite( targetPath , WPR_data, sheetname );
        %- Falls Fehler: in Textbox ausgeben
        catch e
            errordlg(e.message);
        end
        ser1log(handles, '0000', [ 'Dataset saved to: ' targetPath ]);
        pause(1);
        
    end
   
end

