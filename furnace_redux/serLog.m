function serLog(handles, status, serMsg)

    %set(handles.ser2log, 'String', [status ' - ' ser2msg]);
    set(handles.serLog, 'String', serMsg);

end

