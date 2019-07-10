function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 08-Dec-2018 16:39:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% UIWAIT makes simpledemo2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
clear all;
reset;


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function reset
global hAxes1;
global hAxes2;

if (isempty(hAxes1))
    hAxes1 = findobj(gcf,'Tag', 'axes1');
end
if (isempty(hAxes2))
    hAxes2 = findobj(gcf,'Tag', 'axes2');
end

set(gcf, 'CurrentAxes', hAxes1);
imshow(1);
set(gcf, 'CurrentAxes', hAxes2);
imshow(1);
return;



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

reset;

global X; % original image
global last_edit;
global hAxes1;
global hAxes2;
global width;
global length;

% open an image
[FileName,PathName] = uigetfile('*.bmp;*.tif;*.jpg;*.hdf','Select the image file');
if ispc
    FullPathName = [PathName,'\',FileName];
elseif ismac
    FullPathName = [PathName,'/',FileName];
elseif isunix
    FullPathName = [PathName,'/',FileName];
else
    FullPathName = [PathName,'\',FileName];
end
X = imread(FullPathName);

R = X(:, :, 1);
width = size(R, 1);
length = size(R, 2);

%display the original image
set(gcf, 'CurrentAxes', hAxes1);
imshow(X);

set(gcf, 'CurrentAxes', hAxes2);
imshow(X);

last_edit = 0;


% --- Executes on slider movement.
function slider_vignette_Callback(hObject, eventdata, handles)
% hObject    handle to slider_vignette (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
process_vignette;


% --- Executes during object creation, after setting all properties.
function slider_vignette_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_vignette (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function process_vignette

global X;
global Y;
global last_edit;
global width;
global length;
global hAxes2;

wid_c = width/2;
len_c = length/2;
max_dist = sqrt((wid_c-1)^2+(len_c-1)^2);

if wid_c < len_c
    radius = wid_c;
else
    radius = len_c;
end

% get vignette strength based on slide bar value
slider_vign = findobj(gcf, 'Tag', 'slider_vignette');
vign_strength = get(slider_vign,'Value');

% curve fitting between radius and max_dist
x = [radius, max_dist];
y = [1 1-vign_strength];
p = polyfit(x, y, 2);

if last_edit == 1 || last_edit == 0
    [H, S, V] = rgb2hsv(X);
else
    [H, S, V] = rgb2hsv(Y);
    X = Y;
end

last_edit = 1;

nV = V;
for i = 1:1:width
    for j = 1:1:length
        dist = calcdist(i, j, wid_c, len_c);
        if (dist > radius)
            nV(i, j) = (p(1)*dist^2+p(2)*dist+p(3))*V(i, j);
        end
    end
end

newHSV = zeros(width, length, 3);
newHSV(:, :, 1) = H;
newHSV(:, :, 2) = S;
newHSV(:, :, 3) = nV;
Y = uint8(hsv2rgb(newHSV)*255);

set(gcf, 'CurrentAxes', hAxes2);
imshow(Y);


% --- Executes on slider movement.
function slider_vintage_Callback(hObject, eventdata, handles)
% hObject    handle to slider_vintage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
process_vintage;

% --- Executes during object creation, after setting all properties.
function slider_vintage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_vintage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function process_vintage

global X;
global Y;
global last_edit;
global width;
global length;
global hAxes2;

slider_vintage = findobj(gcf, 'Tag', 'slider_vintage');
vintage_strength = get(slider_vintage,'Value');

% adjust saturation
% adjust RGB
    
if last_edit == 2 || last_edit == 0
    R = X(:, :, 1);
    G = X(:, :, 2);
    B = X(:, :, 3);
else
    R = Y(:, :, 1);
    G = Y(:, :, 2);
    B = Y(:, :, 3);
    X = Y;
end

last_edit = 2;
    
nR = zeros(width, length);
nB = zeros(width, length);
nS = zeros(width, length);

weightR = zeros(256, 1);
weightB = zeros(256, 1);
k = 1:1:256;
weightR(1:128, 1) = 0.5*(2*(k(1:128)-1)/255).^(1+0.7*vintage_strength);
weightR(129:end, 1) = 0.5+0.5*(2*((k(129:end)-1)/255-0.5)).^(1-0.7*vintage_strength);
weightB(1:128, 1) = 0.5*(2*(k(1:128)-1)/255).^(1-0.7*vintage_strength);
weightB(129:end, 1) =  0.5+0.5*(2*((k(129:end)-1)/255-0.5)).^(1+0.7*vintage_strength);

for i = 1:1:width
    for j = 1:1:length
        nR(i, j) = uint8(weightR(R(i, j)+1)*255); 
        nB(i, j) = uint8(weightB(B(i, j)+1)*255);  
    end
end
inter = uint8(zeros(width, length, 3));
inter(:, :, 1) = nR;
inter(:, :, 2) = G;
inter(:, :, 3) = nB;

[H, S, V] = rgb2hsv(inter);
for i = 1:1:width
    for j = 1:1:length
        nS(i, j) = S(i, j)^(1+0.5*vintage_strength);
    end
end
newHSV = zeros(width, length, 3);
newHSV(:, :, 1) = H;
newHSV(:, :, 2) = nS;
newHSV(:, :, 3) = V;

Y = uint8(hsv2rgb(newHSV)*255);

set(gcf, 'CurrentAxes', hAxes2);
imshow(Y);

% --- Executes on slider movement.
function slider_oil_Callback(hObject, eventdata, handles)
% hObject    handle to slider_oil (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
process_oil;


% --- Executes during object creation, after setting all properties.
function slider_oil_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_oil (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function process_oil

global X;
global Y;
global last_edit;
global width;
global length;
global hAxes2;

slider_vintage = findobj(gcf, 'Tag', 'slider_oil');
oil_strength = get(slider_vintage,'Value');
levels = round((1-oil_strength)*50)+15;
m = 5;

% adjust saturation
% adjust RGB
    
if last_edit == 3 || last_edit == 0
    R = X(:, :, 1);
    G = X(:, :, 2);
    B = X(:, :, 3);
else
    R = Y(:, :, 1);
    G = Y(:, :, 2);
    B = Y(:, :, 3);
    X = Y;
end

last_edit = 3;

nR = zeros(width, length);
nG = zeros(width, length);
nB = zeros(width, length);

for i = 1:1:width
    for j = 1:1:length
        count = zeros(levels, 1);
        averageR = zeros(levels, 1);
        averageG = zeros(levels, 1);
        averageB = zeros(levels, 1);
        for k = -m:1:m
            for g = -m:1:m
                if i+k > 0 && j+k > 0 && i+g > 0 && j+g > 0 && i+k < width && j+k < length && i+g < width && j+g < length
                    rr = double(R(i+k,j+g));
                    gg = double(G(i+k,j+g));
                    bb = double(B(i+k,j+g));
                    curIntensity = round((rr+gg+bb)/3*levels/256)+1;
                    if curIntensity > levels
                        curIntensity = levels;
                    end
                    count(curIntensity, 1) = count(curIntensity, 1) + 1;
                    averageR(curIntensity, 1) = averageR(curIntensity, 1) + rr;
                    averageG(curIntensity, 1) = averageG(curIntensity, 1) + gg;
                    averageB(curIntensity, 1) = averageB(curIntensity, 1) + bb;
                    
                end
            end
        end
        curMax = 0;
        maxIndex = 1;
        
        for l = 1:1:levels
            if count(l, 1) > curMax
                curMax = count(l, 1);
                maxIndex = l;
            end
        end
        nR(i, j) = uint8(round(averageR(maxIndex, 1) / curMax));
        nG(i, j) = uint8(round(averageG(maxIndex, 1) / curMax));
        nB(i, j) = uint8(round(averageB(maxIndex, 1) / curMax));
    end
end

inter = uint8(zeros(width, length, 3));
inter(:, :, 1) = nR;
inter(:, :, 2) = nG;
inter(:, :, 3) = nB;

Y = inter;
set(gcf, 'CurrentAxes', hAxes2);
imshow(Y);

% --- Executes on slider movement.
function slider_brightness_Callback(hObject, eventdata, handles)
% hObject    handle to slider_brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
process_brightness;


% --- Executes during object creation, after setting all properties.
function slider_brightness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function process_brightness

global X;
global Y;
global last_edit;
global width;
global length;
global hAxes2;

slider_bri = findobj(gcf, 'Tag', 'slider_brightness');
bri_strength = get(slider_bri,'Value');

if last_edit == 4 || last_edit == 0
    [H, S, V] = rgb2hsv(X);
else
    [H, S, V] = rgb2hsv(Y);
    X = Y;
end

last_edit = 4;

nV = V;
for i = 1:1:width
    for j = 1:1:length
        nV(i, j) = V(i, j)*(1+0.5*bri_strength);
        if nV(i, j) >= 1
            nV(i, j) = 1;
        end
    end
end

newHSV = zeros(width, length, 3);
newHSV(:, :, 1) = H;
newHSV(:, :, 2) = S;
newHSV(:, :, 3) = nV;
Y = uint8(hsv2rgb(newHSV)*255);

set(gcf, 'CurrentAxes', hAxes2);
imshow(Y);

       

% --- Executes on slider movement.
function slider_contrast_Callback(hObject, eventdata, handles)
% hObject    handle to slider_contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
process_contrast;


% --- Executes during object creation, after setting all properties.
function slider_contrast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function process_contrast
global X;
global Y;
global last_edit;
global width;
global length;
global hAxes2;

slider_cont = findobj(gcf, 'Tag', 'slider_contrast');
cont_strength = get(slider_cont,'Value');

if last_edit == 5 || last_edit == 0
    [H, S, V] = rgb2hsv(X);
else
    [H, S, V] = rgb2hsv(Y);
    X = Y;
end

last_edit = 5;

start = 0.15;
slope = 1-cont_strength;

P1 = polyfit([0 start], [0 start*slope], 1);
P2 = polyfit([start 1-start], [start*slope 1-slope*start], 1);
P3 = polyfit([1-start 1], [1-slope*start 1], 1);

nV = V;
for i = 1:1:width
    for j = 1:1:length
        if V(i, j) <= start
            nV(i, j) = P1(1)*V(i,j)+P1(2);
        elseif V(i, j) > 1-start
            nV(i, j) = P3(1)*V(i,j)+P3(2);
        else
            nV(i, j) = P2(1)*V(i,j)+P2(2);
        end
    end
end

newHSV = zeros(width, length, 3);
newHSV(:, :, 1) = H;
newHSV(:, :, 2) = S;
newHSV(:, :, 3) = nV;
Y = uint8(hsv2rgb(newHSV)*255);

set(gcf, 'CurrentAxes', hAxes2);
imshow(Y);

        
        
function dist = calcdist(w, l, w_c, l_c)
dist = sqrt((w-w_c)^2+(l-l_c)^2);
