function [ intensity ] = RD( handles, readtime )

    global ser1;

    %- Well auslesen
    fprintf(ser1, ['$RD ' num2str(readtime)]);

    %- Auf Status warten
    OK(handles);

    %- Datensatz auslesen
    RD = fscanf(ser1, '%s');

    %- abwarten
    OK(handles);

    %- Datensatz zerlegen und Intensität rauspuhlen
    RDsplit = strsplit(RD, ',');
    intensity = str2double( RDsplit(4)) / 1000 ;

end

