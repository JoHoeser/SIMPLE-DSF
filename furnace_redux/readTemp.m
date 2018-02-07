function readTemp( ~, ~, handles )

    global ser;
    global currentTemp;
    
    currentTemp = str2double( fscanf(ser, '%s') );

    set( handles.currentTemp, 'String', num2str(currentTemp) );
    
end

