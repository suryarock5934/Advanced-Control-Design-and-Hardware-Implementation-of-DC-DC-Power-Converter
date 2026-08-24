clc;

clear;
close all;

fprintf('\n');

fprintf(' DC-DC CONVERTER ANALYSIS TOOLBOX\n');

%% Fixed Parameters

converter = 'Boost';      % 'Buck', 'Boost', or 'BuckBoost'

Vi = 48;                  % Input Voltage (V)
Vo = 120;                 % Output Voltage (V)
R  = 12;                  % Load Resistance (Ohm)
L  = 100e-6;              % Inductance (H)
C  = 33e-6;               % Capacitance (F)
Rc = 0.05;               % Capacitor ESR (Ohm)
Rl = 0.05;                

fs = 200e3;               % Switching Frequency (Hz)

%% Converter Parameters

P = ConverterModel(...
    converter,...
    Vi,...
    Vo,...
    R,...
    L,...
    C,...
    Rc, ...
    Rl,...
    fs);



%% Controller Design

P = ControllerDesign(P);

%% Build Transfer Functions

TF = BuildTransferFunctions(P);
%% Display Parameters

DisplayParameters(P);



%% Loop Analysis

%Loop = LoopAnalysis(P,TF);

disp(' ');
disp('Analysis Completed Successfully.');
