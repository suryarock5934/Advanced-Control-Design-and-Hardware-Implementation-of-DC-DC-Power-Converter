function Loop = LoopAnalysis(P,TF)


%% Peak Current Mode Control
%% Type-II Compensation



clc;

s = tf('s');

disp(' ');
disp('===================================================');
disp('             LOOP ANALYSIS');
disp('===================================================');


%% TYPE-II COMPENSATOR
%
%              Kv(1+s/wzc)
% Fv(s) = -------------------------
%          s(1+s/wpc)
%


Fv = P.Kv*(1+s/P.wzc)/(s*(1+s/P.wpc));


%% CURRENT LOOP

% Ti = Gid Ri Fm



Ti = TF.Gid*P.Ri*P.Fm;


%% VOLTAGE LOOP

% Tv = Gvd Fv Fm



Tv = TF.Gvd*Fv*P.Fm;


%% OVERALL LOOP

% T1 = Ti + Tv


T1 = Ti + Tv;


%% OUTER LOOP

% T2 = Tv/(1+Ti)



T2 = Tv/(1+Ti);


% STORE

Loop.Fv = Fv;
Loop.Ti = Ti;
Loop.Tv = Tv;
Loop.T1 = T1;
Loop.T2 = T2;


%% DISPLAY TRANSFER FUNCTIONS


disp(' ');
disp('--------------- Type-II Compensator ----------------');
Fv

disp(' ');
disp('--------------- Current Loop Ti --------------------');
Ti

disp(' ');
disp('--------------- Voltage Loop Tv --------------------');
Tv

disp(' ');
disp('--------------- Overall Loop T1 --------------------');
T1

disp(' ');
disp('--------------- Outer Loop T2 ----------------------');
T2


%% STABILITY ANALYSIS

AnalyzeLoop(Ti,'CURRENT LOOP');

AnalyzeLoop(Tv,'VOLTAGE LOOP');

AnalyzeLoop(T1,'OVERALL LOOP');

AnalyzeLoop(T2,'OUTER LOOP');

%% PLOTS

PlotLoop(Ti,'Current Loop Ti');

PlotLoop(Tv,'Voltage Loop Tv');

PlotLoop(T1,'Overall Loop T1');

PlotLoop(T2,'Outer Loop T2');

end


%% FUNCTION : Analyze Loop

function AnalyzeLoop(sys,name)

fprintf('\n');
disp('===================================================');
disp(name);
disp('===================================================');

[GM,PM,Wcg,Wcp] = margin(sys);

if isinf(GM)
    fprintf('Gain Margin      : Infinite\n');
else
    fprintf('Gain Margin      : %.2f dB\n',20*log10(GM));
end

fprintf('Phase Margin     : %.2f deg\n',PM);

fprintf('Gain Crossover   : %.2f rad/s\n',Wcg);

fprintf('Phase Crossover  : %.2f rad/s\n',Wcp);

fprintf('\nPoles\n');

pole(sys)

fprintf('\nZeros\n');

zero(sys)

end


%% FUNCTION : Plot Loop

function PlotLoop(sys,name)

figure('Name',[name ' - Bode']);
margin(sys);
grid on;
title([name ' Bode Plot']);

figure('Name',[name ' - Nyquist']);
nyquist(sys);
grid on;
title([name ' Nyquist Plot']);

figure('Name',[name ' - Pole Zero']);
pzmap(sys);
grid on;
title([name ' Pole-Zero Map']);

end