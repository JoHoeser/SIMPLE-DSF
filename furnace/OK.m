function [] = OK( handles )

    global ser1;
    
    global WPRREAD;
    
    %- status abwarten
    try
        %- kurz inne halten und seriellen Port abfragen...
        status = fscanf(ser1, '%s');
        %- angekommen? läuft WPReader gerade nicht?
            if strcmp(status,'0000') && strcmp(WPRREAD, 'FALSE')
                %ser1log( handles, status, 'No error.');
            elseif strcmp(status,'')
                ser1log( handles, status, 'LS55 not responding! Waiting...');
                pause(5);
            elseif strcmp(status,'0110')
                ser1log( handles, status, 'Instrument busy.');
                pause(5);
            elseif strcmp(status,'0112')
                errordlg('Motor stepping error or FFA missing synchronous pulse.');
                WPRREAD = 'FALSE';
                pause(2);
                ser1disconnect( handles );
%             else
%                 ser1log( handles, status, 'ERROR! Disconnecting.');
%                 errordlg(['ERROR ' status ' OCCURED! Please refer to users manual! Disconnecting.']);
%                 pause(2);
%                 %ser1disconnect( handles );
%                 disp('Ser1: Verbindung kappen überbrückt! Noch aktiv!');
            end
        
    catch e
        errordlg(e.message);    
    end

end

