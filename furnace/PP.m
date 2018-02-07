function [] = PP( handles, col, col_spacing, col_offset, row, row_spacing, row_offset )
    
    global ser1;

    %- Positionsbestimmung
    col_pos = ( col - 1 ) * col_spacing + col_offset;
    row_pos = ( row - 1 ) * row_spacing + row_offset;
    
    %- Position anfahren
    fprintf(ser1, ['$PP ' num2str(col_pos) ',' num2str(row_pos) ]);
    
    %- Status abwarten
    OK(handles);
      
end
