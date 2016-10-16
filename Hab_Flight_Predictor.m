function varargout = Hab_Flight_Predictor(varargin)
% HAB_FLIGHT_PREDICTOR MATLAB code for Hab_Flight_Predictor.fig
%      HAB_FLIGHT_PREDICTOR, by itself, creates a new HAB_FLIGHT_PREDICTOR or raises the existing
%      singleton*.
%
%      H = HAB_FLIGHT_PREDICTOR returns the handle to a new HAB_FLIGHT_PREDICTOR or the handle to
%      the existing singleton*.
%
%      HAB_FLIGHT_PREDICTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HAB_FLIGHT_PREDICTOR.M with the given input arguments.
%
%      HAB_FLIGHT_PREDICTOR('Property','Value',...) creates a new HAB_FLIGHT_PREDICTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Hab_Flight_Predictor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Hab_Flight_Predictor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Hab_Flight_Predictor

% Last Modified by GUIDE v2.5 06-May-2016 10:46:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Hab_Flight_Predictor_OpeningFcn, ...
                   'gui_OutputFcn',  @Hab_Flight_Predictor_OutputFcn, ...
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

% Initial free lift is gross lift (minus weight of fabric) - weight of the
% payload. 

%Initial value of temperature of balloon gas is approximated to the
%temperature of air at ground level. 

% --- Executes just before Hab_Flight_Predictor is made visible.
function Hab_Flight_Predictor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Hab_Flight_Predictor (see VARARGIN)

% Choose default command line output for Hab_Flight_Predictor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Hab_Flight_Predictor wait for user response (see UIRESUME)
% uiwait(handles.tagBox1);


% --- Outputs from this function are returned to the command line.
function varargout = Hab_Flight_Predictor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_helium_Callback(hObject, eventdata, handles)
% hObject    handle to edit_helium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_helium as text
%        str2double(get(hObject,'String')) returns contents of edit_helium as a double


% --- Executes during object creation, after setting all properties.
function edit_helium_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_helium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function slider_payload_Callback(hObject, eventdata, handles)
% hObject    handle to slider_payload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.sliderText.String = num2str(handles.slider_payload.Value); %The text displays the value of the slider.

% --- Executes during object creation, after setting all properties.
function slider_payload_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_payload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in calcbutton.
function calcbutton_Callback(hObject, eventdata, handles)
global balloonmass;
% hObject    handle to calcbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

payloadmass = handles.slider_payload.Value; 
heliumUsed = handles.edit_helium.String;
large_array = calc_alt(balloonmass,payloadmass,str2num(heliumUsed));
altitude_array = large_array(:,1);

negVals = find(altitude_array == -1);

if altitude_array(1) == -1 %This indicates that the balloon never had any lift. If it does not, a warning is displayed to the user.
    handles.graph.Color = 'red';
    handles.popup.Visible = 'on';

else %If this is the case, all is normal. 
    handles.popup.Visible = 'off';
    altPlot.Color = [0 0 0];
    t = [1:1:negVals(1)-1]; %This finds the first value where there is no lift, so that the graph can be truncated at this point.

    resizedAltArray = altitude_array(1:(negVals(1))-1);

    altPlot = plot(handles.graph,t,resizedAltArray);
    altPlot.Visible = 'on';
    altPlot.LineWidth = 4;
    altPlot.Color = 'red';
    handles.graph.XColor = 'red';
    handles.graph.YColor = 'red';
    
end

% --- Executes on button press in resetbutton.
function resetbutton_Callback(hObject, eventdata, handles)
% hObject    handle to resetbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.graph.Color = 'white';
handles.popup.Visible = 'off';
handles.slider_payload.Value = 0;
altPlot.Visible = 'off';
handles.sliderText.String = '0';


% --- Executes on button press in resetbutton.

function radiobutton_200_Callback(hObject, eventdata, handles)
% hObject    handle to resetbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function radiobutton_400_Callback(hObject, eventdata, handles)
% hObject    handle to resetbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function radiobutton_600_Callback(hObject, eventdata, handles)
% hObject    handle to resetbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function radiobutton_800_Callback(hObject, eventdata, handles)
% hObject    handle to resetbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function radiobutton_1000_Callback(hObject, eventdata, handles)
% hObject    handle to resetbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in sizebuttongroup.
function sizebuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in sizebuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global balloonmass;
switch get(eventdata.NewValue,'Tag')
    case 'radiobutton_200',  balloonmass = 200;
    case 'radiobutton_400',  balloonmass = 400;
    case 'radiobutton_600',  balloonmass = 600;
    case 'radiobutton_800',  balloonmass = 800;
    case 'radiobutton_1000',  balloonmass = 1000;
    otherwise, balloonmass = 0;
end


% --- Executes during object creation, after setting all properties.
function graph_CreateFcn(hObject, eventdata, handles)
% hObject    handle to graph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
ha = axes('units','normalized', ...
            'position',[0 0 1 1]);
uistack(ha,'bottom');
I=imread('IMG_1064.jpg');
hi = imagesc(I)
colormap gray
set(ha,'handlevisibility','off', ...
            'visible','off')


% Hint: place code in OpeningFcn to populate graph


% --- Executes during object creation, after setting all properties.
function text2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
