clear
a = arduino('COM3','MEGA2560');
s = servo(a,'D3');
%% Calibration
% Some initialization for sample values
t=[]; vH=[]; restH=[]; ii=0;

%Parameters that control the sampling (could have been parameters in the
%  function call - up to the next programmer
numSec=12;  % length in seconds of the sampling
samptime=0.02;  %intersample interval in seconds

% now we begin the sampling -- length of time, determined by numSec
%                           -
%                           -- resolution is 10 bits, 0 to 1023.
ii=0;
t0=tic;                         % tic is the absolute computer time
while (toc(t0)<=numSec)  
    % toc(t0) returns elapsed time from t0 in secs
    t1 = tic;
    ii = ii+1;                    % sample timing controlled by Arduino sketch
    tt = toc(t0);   % this generates time in milliseconds
    
    vvH = readVoltage(a,'A0');  % this is the voltage input
    
    t=[t tt];                   % appending the new time to the vector
    vH=[vH vvH];                % appending the new voltage to the vector   
                                % voltage came from  pin A0 --  defined 
                                % in the Arduino sketch, not here 
                                % we must know what type of variable Arduino 
                                % is sending ( % d, %f, %s, etc.)
    
    clc                            
    if(tt < round(numSec/3))
        disp('look straight');
        restH = [restH vvH];
    elseif (tt < round(2*numSec/3))
        disp('look left for 2 seconds then straight');
    elseif (tt < numSec)
        disp('look right for 2 seconds then straight');
    end
        
    
    while (toc(t1)<=samptime);
        b=2;                    % just stalling until ready for next sample
    end
end
% very important -- close the port

cla
figure(1)                         % open up a new figure
plot(t,vH,'*r')
hold
plot(t,vH,'g')
title('Horizontal EOG Measurement');
xlabel('time (ms)');
ylabel('voltage (V)');

zeroH = mean(restH);
sensitivity = 0.5;

horizontalInt = (round(length(vH)/3)):(round(length(vH)));

hMinima = islocalmin(vH(horizontalInt));
hMaxima = islocalmax(vH(horizontalInt));
leftPeaks = sort(vH(hMaxima));
rightPeaks = sort(vH(hMinima));

lowerH = rightPeaks(2);
lowerHThresh = sensitivity*(lowerH-zeroH)+zeroH;
upperH = leftPeaks(end-1);
upperHThresh = sensitivity*(upperH-zeroH)+zeroH;

disp([zeroH lowerH upperH]);
disp([zeroH lowerHThresh upperHThresh]);

%% Eye Tracking
%Creates Grid Graphic
x = 0;
y = 0;
figure(2)
color([3,1],[x,y]);
xrest = true;

% Some initialization for sample values
t=[]; vH=[]; ii=0;

%Parameters that control the sampling (could have been parameters in the
%  function call - up to the next programmer
numSec=20;  % length in seconds of the sampling
samptime=0.01;  %intersample interval in seconds

% now we begin the sampling -- length of time, determined by numSec
%                           -
%                           -- resolution is 10 bits, 0 to 1023.
ii=0;
t0=tic;                         % tic is the absolute computer time
while (toc(t0)<=numSec)  
    % toc(t0) returns elapsed time from t0 in secs
    t1 = tic;
    ii = ii+1;                    % sample timing controlled by Arduino sketch
    tt = toc(t0);   % this generates time in milliseconds
    
    vvH = readVoltage(a,'A0');  % this is the voltage input
    
    %Horizontal Movement
    if vvH > upperHThresh       %Look Left
        if x == 0 & xrest        %Eye centered
            x = -1;
        elseif x == 1           %Correcting to center
            x = 0;
        end
        xrest = false;
    elseif vvH < lowerHThresh   %Look Right
        if x == 0 & xrest        %Eye centered
            x = 1;
        elseif x == -1          %Correcting to center
            x = 0;
        end
        xrest = false;
    else
        if x == 0
            xrest = true;
        end
    end
    
    color([3,1],[x,0]);
    angle = (x+1)/2;
    writePosition(s,angle);
    pause(0.01)
    
    t=[t tt];                   % appending the new time to the vector
    vH=[vH vvH];                % appending the new voltage to the vector   
                                % voltage came from  pin A0 --  defined 
                                % in the Arduino sketch, not here 
                                % we must know what type of variable Arduino 
                                % is sending ( % d, %f, %s, etc.)
    while (toc(t1)<=samptime);
        b=2;                    % just stalling until ready for next sample
    end
end

figure(3)                         % open up a new figure
plot(t,vH,'*r')
hold
plot(t,vH,'g')
title('Horizontal EOG Measurement');
xlabel('time (ms)');
ylabel('voltage (V)');
