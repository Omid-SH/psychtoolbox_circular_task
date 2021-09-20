%% P1
clear; clc

% Load Data
%Id = input('Subject id? ');
fprintf("Id has been set to default. ([1 1 1])\n \n")
Id = [1 1 1]; 

Session = input('Session? ');

% Load images from Fraktals dataset
location = './Fractals/';       %  folder in which your images exists
imgs = zeros(48,600,600,3);      % store all images

for i = 1:48
    ds = imageDatastore([location, num2str(i), '.jpeg']);
    img = read(ds);
    imgs(i,:,:,:) = img;
end

image_order = load(['./Subjects/S_', num2str(Id(1)), '_', num2str(Id(2)), '_', num2str(Id(3)), '/K.mat']);
image_order = image_order.K; % Images sequence
imgs = imgs(image_order,:,:,:);

sca;
rng('shuffle');
error = audioread('success.wav');

% Generate Sequence
Sequence = struct();

% Key Model
% Key : abc -> a: 1(TP) 2(TA) ,b: 1(Value) 2(Perceptual) ,c: 3, 5, 7, 9
Base = [113 115 117 119 213 215 217 219 123 125 127 129 223 225 227 229];
Key_Bucket = [Base Base];

Value_Good_Bucket = [1:12 1:12];
Value_Bad_Bucket = [13:24 13:24];
Perceptual_Good_Bucket = [25:36 25:36];
Perceptual_Bad_Bucket = [37:48 37:48];

for i = 1:144
    % fill it again :))
    if(isempty(Key_Bucket))
        Key_Bucket = [Base Base];
    end

    if(isempty(Value_Good_Bucket))
        Value_Good_Bucket = [1:12 1:12];
    end
    
    if(isempty(Value_Bad_Bucket))
        Value_Bad_Bucket = [13:24 13:24];
    end
    
    if(isempty(Perceptual_Good_Bucket))
        Perceptual_Good_Bucket = [25:36 25:36];
    end
    
    if(isempty(Perceptual_Bad_Bucket))
        Perceptual_Bad_Bucket = [37:48 37:48];
    end
    
    item = randi([1 length(Key_Bucket)],1,1);
    Sequence(i).Key = Key_Bucket(item);
    Key_Bucket(item) = [];
    
    Key = Sequence(i).Key;
    T = floor(Key/100);
    V = mod(floor(Key/10), 10);
    N = mod(Key, 10);
    S = zeros(1,3);
    
    if(T == 1) %TP
        if(V == 1) % Value
            item = randi([1 length(Value_Good_Bucket)],1,1);
            S(1) = Value_Good_Bucket(item);
            Value_Good_Bucket(item) = [];
            
            for j = 2:N
                if(isempty(Value_Bad_Bucket))
                    Value_Bad_Bucket = [13:24 13:24];
                end
                
                item = randi([1 length(Value_Bad_Bucket)],1,1);
                S(j) = Value_Bad_Bucket(item);
                Value_Bad_Bucket(item) = [];
            end
        else
            item = randi([1 length(Perceptual_Good_Bucket)],1,1);
            S(1) = Perceptual_Good_Bucket(item);
            Perceptual_Good_Bucket(item) = [];

            for j = 2:N
                if(isempty(Perceptual_Bad_Bucket))
                    Perceptual_Bad_Bucket = [37:48 37:48];
                end

                item = randi([1 length(Perceptual_Bad_Bucket)],1,1);
                S(j) = Perceptual_Bad_Bucket(item);
                Perceptual_Bad_Bucket(item) = [];
            end
        end
    else
        if(V == 1) % Value            
            for j = 1:N
                if(isempty(Value_Bad_Bucket))
                    Value_Bad_Bucket = [13:24 13:24];
                end
                
                item = randi([1 length(Value_Bad_Bucket)],1,1);
                S(j) = Value_Bad_Bucket(item);
                Value_Bad_Bucket(item) = [];
            end
        else
            for j = 1:N
                if(isempty(Perceptual_Bad_Bucket))
                    Perceptual_Bad_Bucket = [37:48 37:48];
                end

                item = randi([1 length(Perceptual_Bad_Bucket)],1,1);
                S(j) = Perceptual_Bad_Bucket(item);
                Perceptual_Bad_Bucket(item) = [];
            end
        end
    end
    
    Sequence(i).S = S;

end

% Show Sequence and Save
nTrials = 144;

%Percent = input('How far you want to show the fraktals? (0-100 percentage) ');
Percent = 75;
%ImageSize = input('Fraktal Size? (in pixels) ');
ImageSize = 180;
% Fixation Settings
fixation_size = 30;

% Get Subject distance from monitor
subject_distance_from_monitor = 2000;
fractal_size_in_degree = atan(ImageSize/2/subject_distance_from_monitor) * 180 / pi;
% Setup PTB with some default values
PsychDefaultSetup(2);

screenNumber = max(Screen('Screens'));
% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
Screen('Preference', 'SkipSyncTests', 1);
[window1, rect] = PsychImaging('Openwindow', screenNumber, black, [], 32, 2,...
    [], [],  kPsychNeed32BPCFloat);

% Get the size of the on screen window1
[screenXpixels, screenYpixels] = Screen('windowSize', window1);

infix = 0;
fixWinSize = 100;

fixationWindow = [-fixWinSize -fixWinSize fixWinSize fixWinSize];
fixationWindow = CenterRect(fixationWindow, rect);

% Get the centre coordinate of the window1
[xc, yc] = RectCenter(rect);
slack = Screen('GetFlipInterval', window1)/2;

Screen(window1,'FillRect',black);
Screen('Flip', window1);

% Skip sync tests for demo purposes only
Screen('Preference', 'SkipSyncTests', 2);

% Get the size of the on screen window1
screen_size = get(0, 'ScreenSize');
Delta_X = floor(Percent * screen_size(4) / 200);
peripheral_circle_degree = atan(Delta_X/subject_distance_from_monitor) * 180 / pi;

% % Left and right hand destination rectangles
[xCent, yCent] = RectCenter(rect);

Fast_Response_txt = sprintf('Sorry, too fast!');    

KbName('UnifyKeyNames'); %used for cross-platform compatibility of keynaming
Space = KbName('space');
X = KbName('x');
E = KbName('Escape');
Screen('BlendFunction', window1, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Start screen
Screen('TextSize', window1, 20);
DrawFormattedText(window1, 'Press a key to begin', 'center', 'center', white);
Screen('Flip',window1);

% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo
KbStrokeWait;
Screen('Flip',window1);

RTs = zeros(256, nTrials); % save reaction time
RKs = zeros(1, nTrials); % save key reaction 
MPs = zeros(2, nTrials); % save mouse position

key_index = -1;
CR = 0; % Correct Rejection
Reward = 0;
% clear KbCheck;

for t = 1:nTrials
    Key = Sequence(t).Key;
    T = floor(Key/100);
    V = mod(floor(Key/10), 10);
    N = mod(Key, 10);
    S = Sequence(t).S;
    
    Tetha = randi(360);
    Tethas = Tetha + linspace(0,360,N+1);
    Tethas = mod(Tethas(1:N), 360); % Fractals Positions in Degree
    position = zeros(3,4);
    
    % Fractals positions
    for k = 1:N
        tet = pi*Tethas(k)/180;
        position(k,:) = [xCent + Delta_X * cos(tet)-ImageSize/2, yCent+Delta_X*sin(tet)-ImageSize/2, xCent+Delta_X*cos(tet)+ImageSize/2, yCent+Delta_X*sin(tet)+ImageSize/2];    
    end
    
    Screen('DrawDots' ,  window1 , [xCent; yCent], fixation_size, [0 0 255], [], 2);
    DrawFormattedText(window1, sprintf(['Trial: ', num2str(t)]), 10, 50);
    DrawFormattedText(window1, sprintf(['Reward: ', num2str(Reward)]), 10, 100);
    DrawFormattedText(window1, sprintf(['CR: ', num2str(CR)]), 10, 150);
    DrawFormattedText(window1, sprintf(['Key pressed: ', num2str(key_index)]), 10, 200);

    Screen('Flip',window1);
    WaitSecs(0.2*rand(1)+0.3);
        
    for k = 1:N
        Image = Screen('MakeTexture', window1, uint8(squeeze(imgs(S(k),:,:,:))));    
        Screen('DrawTextures', window1, Image, [], position(k,:));
        if(k==1 && T==1)
            Screen('FrameRect', window1, [0 255 0] ,position(k,:), 5);
        else
            Screen('FrameRect', window1, [255 0 0] ,position(k,:), 5);
        end
    end
    
    DrawFormattedText(window1, sprintf(['Trial: ', num2str(t)]), 10, 50);
    DrawFormattedText(window1, sprintf(['Reward: ', num2str(Reward)]), 10, 100);
    DrawFormattedText(window1, sprintf(['CR: ', num2str(CR)]), 10, 150);
    DrawFormattedText(window1, sprintf(['Key pressed: ', num2str(key_index)]), 10, 200);

    Screen('Flip',window1);
    
    Reward = 0;
    startTime= WaitSecs(0);
    [secs, keyCode] = KbWait([],[],startTime + 3);
    [x,y] = GetMouse(window1);
    MPs(:,t) = [x,y];
    Screen('Flip',window1);
        
    key_index = -1;

    if sum(keyCode) %if key was pressed do the following            
            key_index = find(keyCode~=0, 1);             
            if key_index == Space || key_index == X
                
                if T==1
                    if key_index == X
                        CR = 0;
                        WaitSecs(1.5);
                    else
                        selected = 0;
                        for k = 1:N
                            if(x>position(k,1) && x<position(k,3) && y>position(k,2) && y<position(k,4))
                                selected = k;
                            end
                        end
                        if selected==0
                            soundsc(error, 44100);
                            WaitSecs(1.5);
                        elseif selected==1
                            Reward = 3;
                            WaitSecs(1.5);
                        else
                            Reward = 1;
                            WaitSecs(1.5);
                        end
                    end
                else
                    if key_index == X
                        if CR==3
                            CR = 0;
                            Reward = 3;
                            WaitSecs(1.5);
                        else
                            CR = CR + 1;
                            WaitSecs(0.2);   
                        end
                    else
                        CR = 0;
                        selected = 0;
                        for k = 1:N
                            if(x>position(k,1) && x<position(k,3) && y>position(k,2) && y<position(k,4))
                                selected = k;
                            end
                        end
                        if selected==0
                            soundsc(error, 44100);
                            WaitSecs(1.5);
                        else
                            Reward = 1;
                            WaitSecs(1.5);
                        end                      
                    end
                end
            elseif key_index == E
                sca;
                return
            else
                WaitSecs(1.5);
            end
    else
        soundsc(error, 44100);
        WaitSecs(1.5);
    end   
    
    RTs(:,t) = secs;
    RKs(:,t) = key_index;
end

% Save data (all needed data is availble on workspace)
save(['./Subjects/S_', num2str(Id(1)), '_', num2str(Id(2)), '_', num2str(Id(3)), '/Out_', num2str(Session)]);
