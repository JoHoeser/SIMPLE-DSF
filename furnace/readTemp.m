function readTemp( ~, ~, handles )

    global ser2;
    
    global currentTemp;

    %- Temperatur holen,
    currentTemp = str2double( fscanf(ser2, '%s') );

    %- ... ausgeben und ...
    set( handles.currentTemp, 'String', num2str(currentTemp) );
    
end

