function [ output ] = convertRow ( input ) %- Input muss String sein, ggf beim Aufrufen der Funktion num2str benutzen!

    %- Input in ASCII umwandeln (double precision)
    ascii = double(input);
    
    ascii = uint8(ascii);
    
    %- Ziffern 1-8
    if (ascii(1) >= 49) && (ascii(1) <= 56)
        %- in Großbuchstaben A-H umwandeln
        output = ascii + 16;
        output = char(output);

    %- Großbuchstaben A-H
    elseif (ascii >= 65) && (ascii <= 72)
        %- in Ziffern 1-8 umwandeln
        output = ascii - 64;

    %- Kleinbuchstaben a-h
    elseif (ascii >= 97) && (ascii <= 104)
        %- in Ziffern 1-8 umwandeln
        output = ascii - 96;

    %- Andere Eingaben
    else
        %- Fehlermeldung ausgeben
        output = 0;
        errordlg('Input invalid.');
        return;

    end