function varargout = weighted(varargin)
% WEIGHTED MATLAB code for weighted.fig
%      WEIGHTED, by itself, creates a new WEIGHTED or raises the existing
%      singleton*.
%
%      H = WEIGHTED returns the handle to a new WEIGHTED or the handle to
%      the existing singleton*.
%
%      WEIGHTED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WEIGHTED.M with the given input arguments.
%
%      WEIGHTED('Property','Value',...) creates a new WEIGHTED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before weighted_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to weighted_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help weighted

% Last Modified by GUIDE v2.5 14-Jan-2013 12:39:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @weighted_OpeningFcn, ...
                   'gui_OutputFcn',  @weighted_OutputFcn, ...
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


% --- Executes just before weighted is made visible.
function weighted_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to weighted (see VARARGIN)
 
% Choose default command line output for weighted
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes weighted wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = weighted_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% ******************************************************************
% ******************************************************************

% --- Executes during object creation, after setting all properties.
function popup_stdm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_stdm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

lsvar=evalin('base','whos');
[aa,bb]=size(lsvar);
j=2;
lsv(1)={'select a variable'};
for i=1:aa,
    csize=length(lsvar(i).class);
    if csize==6,
        if lsvar(i).class=='double',
            lsb=[lsvar(i).name];
            lsv(j)={lsb};
            j=j+1;
        end;
    end;
end;

set(hObject,'string',lsv)

% --- Executes on selection change in popup_stdm.
function popup_stdm_Callback(hObject, eventdata, handles)
% hObject    handle to popup_stdm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_stdm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_stdm

popmenu3=get(handles.popup_stdm,'String');
pm3=get(handles.popup_stdm,'Value');

if pm3==1
    set(handles.push_eval,'enable','off')
else
    selec3=char([popmenu3(pm3)]);
    y_matrix=evalin('base',selec3);
    assignin('base','y_matrix',y_matrix);
    evalin('base','mcr_als.alsOptions.weighted.y_matrix=y_matrix;');
    evalin('base','clear y_matrix');
    assignin('base','y_matrix_name',selec3);
    evalin('base','mcr_als.alsOptions.weighted.y_matrix_name=y_matrix_name;');
    evalin('base','clear y_matrix_name');
    set(handles.push_eval,'enable','on') 
end


% --- Executes during object creation, after setting all properties.
function edit_dim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

nsign=evalin('base','mcr_als.CompNumb.nc;');
set(hObject,'string',num2str(nsign));


function edit_dim_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dim as text
%        str2double(get(hObject,'String')) returns contents of edit_dim as a double

% nothing

% --- Executes during object creation, after setting all properties.
function edit_iterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

Witerations=evalin('base','mcr_als.alsOptions.weighted.max_iterations;');
set(hObject,'string',num2str(Witerations));

function edit_iterations_Callback(hObject, eventdata, handles)
% hObject    handle to edit_iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_iterations as text
%        str2double(get(hObject,'String')) returns contents of edit_iterations as a double

Witerations=str2num(get(hObject,'String'));
assignin('base','Witerations',Witerations);
evalin('base','mcr_als.alsOptions.weighted.max_iterations=Witerations;');
evalin('base','clear Witerations');


% --- Executes during object creation, after setting all properties.
function edit_conv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_conv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

Wconv=evalin('base','mcr_als.alsOptions.weighted.conv_limit;');
set(hObject,'string',num2str(Wconv));


function edit_conv_Callback(hObject, eventdata, handles)
% hObject    handle to edit_conv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_conv as text
%        str2double(get(hObject,'String')) returns contents of edit_conv as a double

Wconv=str2num(get(hObject,'String'));
assignin('base','Wconv',Wconv);
evalin('base','mcr_als.alsOptions.weighted.conv_limit=Wconv;');
evalin('base','clear Wconv');


% --- Executes on button press in push_eval.
function push_eval_Callback(hObject, eventdata, handles)
% hObject    handle to push_eval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% nsign
nsign=evalin('base','mcr_als.CompNumb.nc;');

% original data matrix
matdad=evalin('base','mcr_als.data;');

% maxim nr of iterations
max_iterations=evalin('base','mcr_als.alsOptions.weighted.max_iterations;');

% conv_limit
conv_limit=evalin('base','mcr_als.alsOptions.weighted.conv_limit;');

% error matrix
y_matrix=evalin('base','mcr_als.alsOptions.weighted.y_matrix;');

[m1,n1]=size(matdad);
[m2,n2]=size(y_matrix);

if (m1==m2) & (n1==n2)
    
    % execute
    set(handles.edit_term,'string',' Working','BackgroundColor',[1 .6 .2]);
    pause(1);
    [Ux,Sx,Vx,SOBJx,ErrFlagx] = mlpca(matdad,y_matrix,nsign,conv_limit,max_iterations);
    Xmat_weighted=Ux*Sx*Vx';
    assignin('base','Xmat_weighted',Xmat_weighted);
    evalin('base','mcr_als.alsOptions.weighted.Xmat_weighted=Xmat_weighted;');
    evalin('base','clear Xmat_weighted');
    
    assignin('base','ErrFlagx',ErrFlagx);
    evalin('base','mcr_als.alsOptions.weighted.ErrFlagx=ErrFlagx;');
    evalin('base','clear ErrFlagx');
    
    % buttons active
    set(handles.push_plot,'enable','on')
    set(handles.check_use,'enable','on')
    
    % alarm
    t=0:1/44000:3;sound(sin(440*2*pi*t),44000)
    
    if ErrFlagx == 0
        set(handles.edit_term,'string','Normal termination (convergence)','BackgroundColor','green');
    else
        set(handles.edit_term,'string','Maximum number of iterations exceeded','BackgroundColor','yellow');
        set(handles.push_done,'visible','on');
    end
    
else
    warndlg('dimensions error');
end
    
% --- Executes during object creation, after setting all properties.
function edit_term_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_term (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% nothing

function edit_term_Callback(hObject, eventdata, handles)
% hObject    handle to edit_term (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_term as text
%        str2double(get(hObject,'String')) returns contents of edit_term as a double

% nothing



% --- Executes on button press in push_plot.
function push_plot_Callback(hObject, eventdata, handles)
% hObject    handle to push_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Xmat_weighted=evalin('base','mcr_als.alsOptions.weighted.Xmat_weighted;');
figure;
plot(Xmat_weighted');



% --- Executes on button press in check_use.
function check_use_Callback(hObject, eventdata, handles)
% hObject    handle to check_use (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_use

valorW=get(hObject,'Value');
assignin('base','valorW',valorW);
evalin('base','mcr_als.alsOptions.weighted.constrained=valorW;');
evalin('base','clear valorW');


% --- Executes on button press in push_done.
function push_done_Callback(hObject, eventdata, handles)
% hObject    handle to push_done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

evalin('base','mcr_als.alsOptions.weighted.appWeight=1;');
check=evalin('base','mcr_als.alsOptions.weighted.constrained;');
if check==0
    warndlg('Weighted data will not be used');
else
    evalin('base','mcr_als.aux.estat=2;');
close;    
end


% --- Executes on button press in push_cancel.
function push_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

evalin('base','mcr_als.alsOptions=rmfield(mcr_als.alsOptions,''weighted'');');
evalin('base','mcr_als.alsOptions.weighted.appWeight=0;');
evalin('base','mcr_als.aux.estat=3;');
close;
