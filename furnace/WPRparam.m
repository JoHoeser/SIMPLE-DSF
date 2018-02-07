function [] = WPRparam( handles )

    global ser1;
    global WPRINIT;
    
    WPRINIT = 'FALSE';

    set(handles.ES, 'Enable', 'off');
    
    %- Textfelder leeren
    set(handles.MX, 'String', '');
    set(handles.MM, 'String', '');
    set(handles.SX, 'String', '');
    set(handles.SM, 'String', '');
    
    %- Gerätestatus abfragen
    ser1log(handles, '0000', 'Reading LS55 settings.');
    pause(1);
    fprintf(ser1, '$ST');
    OK( handles );
    %- Gerätestatus empfangen
    ST = fscanf(ser1, '%s');
    OK( handles );
    ST(1) = '';

    %- Gerätestatus in Einzelteile zerlegen
    STsplit = strsplit(ST, ',');
    
    %- Teilestatus in die Vorgesehenen Felder füllen
    %- Anregnungsmonochromator
    MX = str2double(STsplit(3));
    set(handles.MX, 'String', MX);
    %- Emissionsmonochromator
    MM = str2double(STsplit(4));
    set(handles.MM, 'String', MM);
    %- Anregungsspalt
    SX = str2double(STsplit(6));
    set(handles.SX, 'String', SX);
    %- Emissionsspalt
    SM = str2double(STsplit(7));
    set(handles.SM, 'String', SM);
    
    ser1log(handles, '0000', 'LS55 settings received.');
    pause(1);
    ser1log(handles, '0000', 'Ready.');
    
    WPRINIT = 'TRUE';
    
    set(handles.ES, 'Enable', 'on');
    
end
