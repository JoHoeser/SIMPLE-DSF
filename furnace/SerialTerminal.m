function varargout = SerialTerminal(varargin)

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @SerialTerminal_OpeningFcn, ...
                       'gui_OutputFcn',  @SerialTerminal_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT

%%

function SerialTerminal_OpeningFcn(hObject, eventdata, handles, varargin)

    % Choose default command line output for SerialTerminal
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    %- serielle Porst freigeben...
    delete(instrfindall);
    %- verfügbare serielle Schnittstellen suchen
    serialPorts = instrhwinfo('serial');

    %- Pulldown menus in GUI
    set(handles.comPorts1,'String', [{'Select COM-Port'} ; serialPorts.SerialPorts ]);
    set(handles.comPorts1, 'Value', 1);
    set(handles.connect1, 'String', 'Connect');
    set(handles.ser1log, 'String', 'Select serial port of LS55 & connect.');

    set(handles.comPorts2,'String', [{'Select COM-Port'} ; serialPorts.SerialPorts ]);
    set(handles.comPorts2, 'Value', 1);
    set(handles.connect2, 'String', 'Connect');
    set(handles.ser2log, 'String', 'Select serial port of Heater & connect.');

    set(handles.OS, 'String', [ 
        {'Normalized data'} ; ...
        {'Filtered data'} ] );
    set(handles.OS, 'Value', 2);
    
    set(handles.FW, 'String', [ 
        {'290 nm cut-off filter'} ; ...
        {'350 nm cut-off filter'} ; ...
        {'390 nm cut-off filter'} ; ...
        {'430 nm cut-off filter'}  ; ...
        {'530 nm cut-off filter'}  ; ...
        {'blank'} ; ...
        {'no filter (clear)'} ; ...
        {'1% attenuator'} ] );

    set(handles.FW, 'Value', 7);

    %- Textboxes in GUI
    set(handles.currentTemp, 'String', '');
    set(handles.setTemp, 'String', '');
        %- Arbeitsverzeichnis vorbereiten
        workDir = 'C:\FURNACE_DATA\';
        
        %- kontrollieren ob es den Arbeits-Ordner gibt...
        if exist(workDir, 'dir') ~= 7
            %- falls nicht, Ordner erstellen
            mkdir(workDir);
        end
        
        %- Textfeld einrichten
        set(handles.targetPath, 'Enable', 'inactive'); 
        set(handles.targetPath, 'String', fullfile(workDir, 'furnace_output.xlsx') ); 

    
    %- Buttons in GUI
    set(handles.ES, 'String', 'Initializing Lamp');   
    set(handles.SendSettings, 'String', 'Send Settings');
    set(handles.setPath, 'String', 'Save As');
    set(handles.readWPR, 'String', 'Single Read');
    set(handles.heaterState, 'String', 'Heater Offline');
        
    %- GUI abschalten
    LS55state( handles, 'off' );
    heaterState( handles, 'off' );
    
    %- Warnung ausschalten wenn neues Sheet in Excel Datei angelegt wird
    warning('off','MATLAB:xlswrite:AddSheet');
    
    global setTemp;
    setTemp = 0;
    
    
% --- Outputs from this function are returned to the command line.
function varargout = SerialTerminal_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function figure1_CloseRequestFcn(hObject, eventdata, handles)
    %- Serielle Verbindungen beenden
    pause(1);
    if ~strcmp( get(handles.connect1, 'String'), 'Connect')
        ser1disconnect( handles );
    end
    if ~strcmp( get(handles.connect2, 'String'), 'Connect')
        ser2disconnect( handles );
    end
    
    %- Serielle Verbindungen zurücksetzen
    instrreset;

    %- GUI löschen
    delete(handles.figure1);

%%

%% LS55 Port Panel

function comPorts1_Callback(hObject, eventdata, handles)

function comPorts1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
%%

function connect1_Callback(hObject, eventdata, handles)

    %- Wenn gerade nicht mit LS55 verbunden...
    if strcmp(get(handles.connect1,'String'),'Connect')
        
        %- Verbinden und LS55 initialisieren
        ser1connect( handles );
    else
        %- Verbindung schließen
        ser1disconnect( handles );
    end

%% 


%% Logger für serielle Verbindung mit LS55

function ser1log_Callback(hObject, eventdata, handles)

    % %- Serielle Daten an das LS55 schicken...
    global ser1;
    input = get(hObject,'String');
    fprintf(ser1, input);
    set(hObject, 'String', '');

function ser1log_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
  
%%
    
%% WPR Settings Panel

function WPR_start_row_Callback(hObject, eventdata, handles)
    
    WPR_stop_row = convertRow( get(handles.WPR_stop_row, 'String') );

    %- String auf ein Char kürzen
    WPR_start_row = get(handles.WPR_start_row, 'String');
    set(handles.WPR_start_row, 'String', WPR_start_row(1) );
    WPR_start_row = convertRow( get(handles.WPR_start_row, 'String') );

    if ( WPR_start_row == 0 )
        set(handles.WPR_start_row, 'String', '');
    else
        if ( WPR_start_row < 1 ) || ( WPR_stop_row < WPR_start_row )
            errordlg(['Enter a value between A and ' convertRow( num2str( WPR_stop_row ) ) ' as first row.']);
            set(handles.WPR_start_row, 'String', '');
            return;
        end
    end

function WPR_start_row_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

%%

function WPR_start_col_Callback(hObject, eventdata, handles)
    WPR_stop_col = str2double( get(handles.WPR_stop_col, 'String') );
    WPR_start_col = str2double( get(handles.WPR_start_col, 'String') );
    
    if ( WPR_start_col < 1 ) || ( WPR_stop_col < WPR_start_col )  
        errordlg(['Enter a value between 1 and ' num2str(WPR_stop_col) ' as first column.']);
        set(handles.WPR_start_col, 'String', '');
    end

function WPR_start_col_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
%%

function WPR_stop_row_Callback(hObject, eventdata, handles)

    WPR_start_row = convertRow( get(handles.WPR_start_row, 'String') );

    %- String auf ein Char kürzen
    WPR_stop_row = get(handles.WPR_stop_row, 'String');
    set(handles.WPR_stop_row, 'String', WPR_stop_row(1) );
    WPR_stop_row = convertRow( get(handles.WPR_stop_row, 'String') );
    
    if ( WPR_stop_row == 0 )
        set(handles.WPR_stop_row, 'String', '');
    else
        if ( WPR_stop_row > 8 )  || ( WPR_stop_row < WPR_start_row )
            errordlg(['Enter a value between ' convertRow( num2str( WPR_start_row ) ) ' and H as last row.']);
            set(handles.WPR_stop_row, 'String', '');
            return;
        end
    end
    
function WPR_stop_row_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

%% 

function WPR_stop_col_Callback(hObject, eventdata, handles)
    WPR_stop_col = str2double( get(handles.WPR_stop_col, 'String') );
    WPR_start_col = str2double( get(handles.WPR_start_col, 'String') );
    if ( WPR_stop_col < WPR_start_col ) || ( WPR_stop_col > 12 )  
        errordlg(['Enter a value between ' num2str(WPR_start_col) ' and 12 as last column.']);
        set(handles.WPR_stop_col, 'String', '');
    end

function WPR_stop_col_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
%% 

function readTime_Callback(hObject, eventdata, handles)
    readTime = str2double(get(handles.readTime, 'String'));
    if ( readTime < 0.1 ) || ( readTime > 2 )  
        errordlg('Enter a value between 0.1 s and 2 s.');
        set(handles.readTime, 'String', '');
    end

function readTime_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
%% LS55 Settings - Panel

function MX_Callback(hObject, eventdata, handles)
    MX = str2double(get(handles.MX, 'String'));
    if ( MX < 200 ) || ( MX > 800 )  
        errordlg('Enter a value between 200 nm and 800 nm.');
        set(handles.MX, 'String', '');
    end

function MX_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

%%

function MM_Callback(hObject, eventdata, handles)
    MM = str2double(get(handles.MM, 'String'));
    if ( MM < 200 ) || ( MM > 900 )  
        errordlg('Enter a value between 200 nm and 900 nm.');
        set(handles.MM, 'String', '');
    end
    
function MM_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

%%

function SX_Callback(hObject, eventdata, handles)
    SX = str2double(get(handles.SX, 'String'));
    if ( SX < 2.5 ) || ( SX > 15 )  
        errordlg('Enter a value between 2.5 nm and 15 nm.');
        set(handles.SX, 'String', '');
    end


function SX_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

%%

function SM_Callback(hObject, eventdata, handles)
    SM = str2double(get(handles.SM, 'String'));
    if ( SM < 2.5 ) || ( SM > 20 )  
        errordlg('Enter a value between 2.5 nm and 20 nm.');
        set(handles.SM, 'String', '');
    end

function SM_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
%%
    
function OS_Callback(hObject, eventdata, handles)

function OS_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

%% 

function FW_Callback(hObject, eventdata, handles)

function FW_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

%%

function ES_Callback(hObject, eventdata, handles)

    global ser1;

    if strcmp(get(hObject,'String'),'Lamp ON')
        %- Lampe anschalten
        fprintf(ser1, '$ES 1');
        OK(handles);
        %- Button Text ändern
        set(handles.ES, 'String', 'Lamp OFF');
    else 
        %- Lampe anschalten
        fprintf(ser1, '$ES 0');
        OK(handles);
        %- Button Text ändern
        set(handles.ES, 'String', 'Lamp ON');
    end
    
function resetLS55_Callback(hObject, eventdata, handles)
    
    global ser1;
    
    %- Softreset auslösen
    ser1log(handles, 'RESET', 'LS55 software reset triggered.');
    fprintf(ser1, '$WS');
    
    %- Status abwarten
    pause(5);
    
    OK(handles);
    
%%

function SendSettings_Callback(hObject, eventdata, handles)

    %- Anregungsmonochromator
    MX = get(handles.MX, 'String');
    %- Emissionsmonochromator
    MM = get(handles.MM, 'String');
    %- Anregnungsspalt
    SX = get(handles.SX, 'String');
    %- Emissionsspalt
    SM = get(handles.SM, 'String');

    %- Output modus
    OS = get(handles.OS, 'Value');
    %- Filterposition
    FW = get(handles.FW, 'Value');

    %- Platereader initialisieren
    WPRinit( handles, MX, MM, SX, SM, OS, FW );
    WPRparam( handles );

%%
    
function readWPR_Callback(hObject, eventdata, handles)
    
    %- Platte auslesen und in Datei speichern
    ser2log(handles, '0000', 'Manual plate measurement started.');
    WPRread( handles );

%% 

%% Heater Port Panel

function comPorts2_Callback(hObject, eventdata, handles)

function comPorts2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
%%

function connect2_Callback(hObject, eventdata, handles)

    %- Wenn gerade nicht mit Heater verbunden...
    if strcmp(get(hObject,'String'),'Connect')
        %- Mit Heater verbinden
        ser2connect( handles );
    else
        %- Verbindung zum Heater trennen
        ser2disconnect( handles );
    end

%%


%% Logger für serielle Verbindung mit Heater
    
function ser2log_Callback(hObject, eventdata, handles)

    %- Daten an den Heater schicken
    % global ser2;
    % input = get(hObject,'String');
    % input = str2double(input);
    % fprintf( ser2, num2str(input) );
    % disp(['<2< ' num2str(input)]);
    % set( hObject, 'String', '' );


function ser2log_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
%%

%% Heater Settings Panel

function targetTemp_Callback(hObject, eventdata, handles)
    targetTemp = str2double(get(handles.targetTemp, 'String'));
    if ( targetTemp < 20 ) || ( targetTemp > 95 )  
        errordlg('Enter a value between 20 and 95°C.');
        set(handles.targetTemp, 'String', '');
    end
function targetTemp_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

%%

function deltaTemp_Callback(hObject, eventdata, handles)
    deltaTemp = str2double(get(handles.deltaTemp, 'String'));
    if ( deltaTemp < 2 ) || ( deltaTemp > 20 )  
        errordlg('Enter a value between 2 and 20°C.');
        set(handles.deltaTemp, 'String', '');
    end

function deltaTemp_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


%%

function heaterState_Callback(hObject, eventdata, handles)

if strcmp( get(handles.connect1, 'String'), 'Connect' )  
    errordlg('Connect the LS55 first.');
else
	heaterRun( handles );
end
    
%%

function currentTemp_Callback(hObject, eventdata, handles)

function currentTemp_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

%%
    
function setTemp_Callback(hObject, eventdata, handles)

function setTemp_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


%%

function targetPath_Callback(hObject, eventdata, handles)

function targetPath_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
%%

function setPath_Callback(hObject, eventdata, handles)
    
    %- Dialogfeld um Pfad und Dateinamen zu holen
    [outFile, outPath] = uiputfile( ...
        { '*.xls, *.xlsx', 'Microsoft Excel Files (*.xls, *.xlsx)' ; ...
         '*.*',  'All Files (*.*)' }, ...
         'Save as', ...
         get(handles.targetPath, 'String') );
    
    %- kontrollieren ob Dateiname gesetzt
    if ~isequal(outPath,0) || ~isequal(outFile,0)
        set( handles.targetPath, 'String', [ fullfile(outPath,outFile) ] );
    end
