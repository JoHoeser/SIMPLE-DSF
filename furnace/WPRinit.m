function [] = WPRinit( handles, MX, MM, SX, SM, OS, FW )

    global ser1;
    global WPRINIT;
    
    WPRINIT = 'FALSE';
    
    set(handles.ES, 'Enable', 'off');
    
%     %- Lampe anschalten
%     ser1log(handles, '0000', 'Switching lamp on.');
%     fprintf(ser1, '$ES 0');
%     %- Status abwarten
%     OK(handles);

    %- In Parkposition fahren
    ser1log(handles, '0000', 'Moving WPR to parking position.');
    fprintf(ser1, '$PP');
    %- Status abwarten
    pause(3);
    OK(handles);

    %- Output einstellen
    ser1log(handles, '0000', 'Setting data output.');
    fprintf(ser1, ['$OS 1' num2str(OS) ]);
    %- Status abwarten
    pause(2);
    OK(handles);

    %- Monochromatoren einstellen
    ser1log(handles, '0000', 'Setting monochromators.');
    fprintf(ser1, ['$GM ' num2str(MX) ',' num2str(MM) ]);
    %- Status abwarten
    pause(2);
    OK(handles);

    %- Anregungsspalt einstellen
    ser1log(handles, '0000', 'Adjusting excitation slit.');
    fprintf(ser1, ['$SX ' num2str(SX) ]);
    %- Status abwarten
    pause(2);
    OK(handles);
    %- Emissionsspalt einstellen
    ser1log(handles, '0000', 'Adjusting emission slit.');
    fprintf(ser1, ['$SM ' num2str(SM) ]);
    %- Status abwarten
    pause(2);
    OK(handles);

    %- Emissionsfilter auswählen
    ser1log(handles, '0000', 'Setting emission filter.');
    fprintf(ser1, ['$FW ' num2str(FW) ]);
    %- Status abwarten
    pause(2);
    OK(handles);
    
    WPRINIT = 'TRUE';
    
    set(handles.ES, 'Enable', 'on');

end

