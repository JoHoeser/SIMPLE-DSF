function [] = WellRead( handles, col, col_spacing, col_offset, row, row_spacing, row_offset, readtime )

    global WPR_data

    PP( handles, col, col_spacing, col_offset, row, row_spacing, row_offset );
    ser1log( handles, '0000', ['Measuring well ' convertRow( num2str(row) ) num2str(col) '.'] );
    WPR_data( row, col ) = RD( handles, readtime );
    
    %- Komplette Ergebnistabelle updaten wenn ausgelesen
    set(handles.WPR_data, 'Data', WPR_data);

end

