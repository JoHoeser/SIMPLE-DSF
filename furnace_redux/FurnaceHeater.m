function varargout = FurnaceHeater(varargin)
% FURNACEHEATER MATLAB code for FurnaceHeater.fig
%      FURNACEHEATER, by itself, creates a new FURNACEHEATER or raises the existing
%      singleton*.
%
%      H = FURNACEHEATER returns the handle to a new FURNACEHEATER or the handle to
%      the existing singleton*.
%
%      FURNACEHEATER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FURNACEHEATER.M with the given input arguments.
%
%      FURNACEHEATER('Property','Value',...) creates a new FURNACEHEATER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FurnaceHeater_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FurnaceHeater_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FurnaceHeater

% Last Modified by GUIDE v2.5 16-Dec-2014 13:51:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FurnaceHeater_OpeningFcn, ...
                   'gui_OutputFcn',  @FurnaceHeater_OutputFcn, ...
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

function FurnaceHeater_OpeningFcn(hObject, eventdata, handles, varargin)
    % Choose default command line output for FurnaceHeater
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    %- serielle Porst freigeben...
    delete(instrfindall);
    %- verfügbare serielle Schnittstellen suchen
    serialPorts = instrhwinfo('serial');

    %- Pulldown menus in GUI
    set(handles.comPorts,'String', [{'Select COM-Port'} ; serialPorts.SerialPorts ]);
    set(handles.comPorts, 'Value', 1);
    set(handles.connect, 'String', 'Connect');
    set(handles.serLog, 'String', 'Select serial port of Heater & connect.');

    %- Textboxes in GUI
    set(handles.currentTemp, 'String', '');
    set(handles.setTemp, 'String', '');
    set(handles.deltaTemp, 'String', '2');
    set(handles.targetTemp, 'String', '95');
    set(handles.tempTime, 'String', '00:00:00');
    set(handles.serLog, 'Enable', 'inactive');

    %- Buttons in GUI
    set(handles.heaterState, 'String', 'OFFLINE');
    set(handles.nextTemp, 'String', 'Temp UP');
    
    %- GUI abschalten
    heaterState( handles, 'off' );

    global setTemp;
    setTemp = 0;


%%
    
function varargout = FurnaceHeater_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;

%%

function figure1_CloseRequestFcn(hObject, eventdata, handles)
    %- Serielle Verbindungen beenden
    pause(1);
    if ~strcmp( get(handles.connect, 'String'), 'Connect')
        serDisconnect( handles );
    end
    
    %- GUI löschen
    delete(handles.figure1);

%%

function comPorts_Callback(hObject, eventdata, handles)

function comPorts_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

%%

function connect_Callback(hObject, eventdata, handles)
    %- Wenn gerade nicht mit Heater verbunden...
    if strcmp(get(hObject,'String'),'Connect')
        %- Mit Heater verbinden
        serConnect( handles );
    else
        %- Verbindung zum Heater trennen
        serDisconnect( handles );
    end


%%

function serLog_Callback(hObject, eventdata, handles)

function serLog_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
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
    
function deltaTemp_Callback(hObject, eventdata, handles)
    deltaTemp = str2double(get(handles.deltaTemp, 'String'));
    if ( deltaTemp < 1 ) || ( deltaTemp > 20 )  
        errordlg('Enter a value between 1 and 20°C.');
        set(handles.deltaTemp, 'String', '');
    end

function deltaTemp_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

%%
    
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

function heaterState_Callback(hObject, eventdata, handles)
    
    global ser;
    
    global HEATERSTATE;

    global startTime;
    startTime = clock;
    
    global tempHistory;    
    %- Matrix für Temperaturdarstellung löschen
    tempHistory = [ ; ];

    if strcmp( get(handles.heaterState, 'String'), 'Heater ON' )

        %- Heizung wieder auf 1°C stellen...
        fprintf(ser, '1');
        set(handles.tempTime, 'String', '');
 
        %- GUI Output
        set( handles.heaterState, 'String', 'Heater OFF');
        serLog( handles, '0000', 'Heater is now OFF.');
        
        HEATERSTATE = 'OFF';  
        
    elseif strcmp( get(handles.heaterState, 'String'), 'Heater OFF' )
        
        %- GUI Output    
        serLog( handles, '0000', 'Heater is now ON.');
        pause(1);
        setTemp = str2double( get(handles.setTemp, 'String') );
        set(handles.heaterState, 'String', 'Heater ON');
        serLog( handles, '0000', ['Initial temperature is ' num2str(setTemp) '°C.']);
        
        HEATERSTATE = 'ON'; 
        
    end



%%

function nextTemp_Callback(hObject, eventdata, handles)

    global startTime;
    startTime = clock;
    
    global tempHistory;
    %- Matrix für Temperaturdarstellung löschen
    tempHistory = [ ; ];
    
    %- GUI Output
    serLog(handles, '0000', 'Calculating next target temperature.');

    %- Nächste Temperaturstufe berechnen & weitergeben
    setTemp = str2double( get(handles.setTemp, 'String') );
    deltaTemp = str2double( get(handles.deltaTemp, 'String') );
    nextTemp = setTemp + deltaTemp;
    targetTemp = str2double( get(handles.targetTemp, 'String') );

    if nextTemp == targetTemp + deltaTemp
        serLog(handles, '0000', ['Maximum temperature already reached: ' num2str(targetTemp) '°C.']);  
        
    elseif nextTemp > targetTemp
        nextTemp = targetTemp;
        serLog(handles, '0000', ['New target temperature limited to ' num2str(nextTemp) '°C.']);
        set(handles.setTemp, 'String', nextTemp);
        
    else
        serLog(handles, '0000', ['New target temperature set to ' num2str(nextTemp) '°C.']);
        set(handles.setTemp, 'String', nextTemp);
        
    end
    

    
