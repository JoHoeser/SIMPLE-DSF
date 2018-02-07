function [] = controlTemp( ~, ~, handles )

    global ser2;
    
    global setTemp;
    global currentTemp;
    
    global HEATERSTATE;
    global WPRREAD;
    
    %- obere Temperaturgrenze (HARDLIMIT)
    maxTemp = str2double('95');
    
    %- Temperatur-Einstellungen auslesen
    targetTemp = str2double( get( handles.targetTemp, 'String' ) );
    deltaTemp = str2double( get( handles.deltaTemp, 'String' ) ); 

    %- Frühzeitig abbrechen zu heizen?
    if targetTemp <= maxTemp
        maxTemp = targetTemp;
    end
       
    %- soll der Heater heizen?
    if strcmp(HEATERSTATE, 'ON')
        
        %- Läuft der Plattenleser gerade?
        if strcmp(WPRREAD, 'FALSE')
                        
            %- Sicherheitsmechanismus - HARDLIMIT
            if setTemp > maxTemp
                %- Auf Maximaltemperatur begrenzen
                setTemp = maxTemp;
                fprintf( ser2, num2str(setTemp) );
                set(handles.setTemp, 'String', num2str(setTemp));
                ser2log(handles, '0000', ['Temperature corrected to ' num2str(setTemp) '°C. Currently at ' num2str(currentTemp) '°C.']);

            %- Letzter Zyklus oder nicht?
            elseif setTemp == maxTemp
                %- Letzter Zyklus auf exakt Maximaltemperatur
                fprintf( ser2, num2str(setTemp) );
                set(handles.setTemp, 'String', num2str(setTemp));
                ser2log(handles, '0000', ['Temperature set to ' num2str(setTemp) '°C. Currently at ' num2str(currentTemp) '°C.']);
                
                if ( currentTemp >= setTemp )
                    %- Zieltemperatur erreicht
                    ser2log(handles, '0000', 'Target temperature reached.');
                    %- Inkubieren
                    incubate( handles );
                    %- fertig inkubiert
                    ser2log(handles, '0000', 'Done incubating. Measuring.');
                    %- Messung starten
                    WPRread( handles );
                    
                    %- Heizung ausschalten
                    ser2log(handles, '0000', 'Heating done.');
                    pause(1);
                    heaterRun ( handles );
                    ser2log(handles, '0000', 'Heater shut down.');
                    %- Zurück auf Anfang...
                    pause(1);
                    ser1log(handles, '0000', 'LS55 ready.');
                    ser2log(handles, '0000', 'Heater ready.');
                    
                    
                else
                    %- Weiterheizen
                    ser1log(handles, '0000', 'Waiting for Heater.');
                    ser2log(handles, '0000', ['Heating. Temperature set to ' num2str(setTemp) '°C.']);
                end
               
            else
                %- Mitten drin, weit genug von MaxTemp entfernt
                fprintf( ser2, num2str(setTemp) );
                set(handles.setTemp, 'String', num2str(setTemp));
                ser2log(handles, '0000', ['Temperature set to ' num2str(setTemp) '°C. Currently at ' num2str(currentTemp) '°C.']);
                
                if ( currentTemp >= setTemp)
                    
                    %- Zieltemperatur erreicht
                    ser2log(handles, '0000', 'Target temperature reached.');
                    %- Inkubieren
                    incubate( handles );
                    %- fertig inkubiert
                    ser2log(handles, '0000', 'Done incubating. Measuring.');
                    %- Messung starten
                    WPRread( handles );
                 
                    %- Zieltemperatur um einen Schritt hoch
                    setTemp = setTemp + deltaTemp;
       
                else
                    %- Weiterheizen
                    ser2log(handles, '0000', ['Heating. Temperature set to ' num2str(setTemp) '°C.'] );
                    ser1log(handles, '0000', 'Waiting for Heater.');
                end
                
            end
            
        end
        
    end

