function ser2log(handles, status, ser2msg)

    %set(handles.ser2log, 'String', [status ' - ' ser2msg]);
    set(handles.ser2log, 'String', ser2msg);

end

