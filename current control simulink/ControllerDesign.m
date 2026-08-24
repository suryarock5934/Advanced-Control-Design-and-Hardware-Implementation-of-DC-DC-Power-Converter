function P = ControllerDesign(P)

%% Peak Current Mode Controller Design
fprintf('\n');

disp('        PEAK CURRENT MODE CONTROLLER DESIGN');

fprintf('\n');

disp('        CURRENT LOOP DESIGN');

%% PWM Ramp Peak Voltage

Vmax = input('Enter PWM Ramp Peak Voltage Vmax (V) = ');

P.Ts = 1/P.fs;

s = tf('s');
%% STEP 1 : Select Current Loop Bandwidth


fprintf('\nRecommended Current Loop Bandwidth\n');
fprintf('0.15ws <= wci <= 0.30ws\n');

fprintf('ws = %.2f rad/s\n',P.ws);

alpha = input('Choose alpha (0.15~0.30) = ');

P.wci = alpha*P.ws;

fprintf('Current Loop Crossover = %.2f rad/s\n',P.wci);


%% STEP 2 : Current Loop Gain
% Ki = wid*wci^2/w0^2

P.Ki = (P.wid*P.wci^2)/(P.w0^2);

fprintf('Current Loop Gain Ki = %.6f\n',P.Ki);

%% STEP 3 : Current Sense Gain

Ri_limit = Vmax/P.ILpeak;

fprintf('\nMaximum Recommended Ri = %.5f V/A\n',Ri_limit);

P.Ri = 0.01*Ri_limit;

%% STEP 4 : PWM Modulator Gain

P.Fm = P.Ki/(P.Kid*P.Ri);

fprintf('PWM Modulator Gain Fm = %.6f\n',P.Fm);

%% STEP 5 : Inductor Current Slopes


switch lower(P.converter)

    case 'buck'

        Son = (P.Vi-P.Vo)/P.L;

        Soff = P.Vo/P.L;

    case 'boost'

        Son = P.Vi/P.L;

        Soff = abs(P.Vi-P.Vo)/P.L;

    case 'buckboost'

        Son = P.Vi/P.L;

        Soff = abs(P.Vo)/P.L;

end

%% Current Sense Slopes

P.Sn = Son*P.Ri;

P.Sf = Soff*P.Ri;

fprintf('\nCurrent Rising Slope  = %.4e V/s\n',P.Sn);

fprintf('Current Falling Slope = %.4e V/s\n',P.Sf);


%% STEP 6 : Minimum Slope Compensation


P.Se_min = (P.Sf-P.Sn)/2;

fprintf('\nMinimum Ramp Slope = %.4e V/s\n',P.Se_min);


%% STEP 7 : Actual Compensation Ramp


P.Se = 1/(P.Ts*P.Fm) + P.Se_min;

fprintf('Actual Ramp Slope = %.4e V/s\n',P.Se);


%% STEP 8 : Ramp Peak

P.Vm = P.Se*P.Ts;

fprintf('Ramp Peak Voltage = %.4f V\n',P.Vm);

Den = 1 + s/(P.Q*P.w0) + (s/P.w0)^2;

Ti = P.Ki*(1+(s/ P.wid))/Den ;


%% ===========================================================
%% AUTOMATIC VOLTAGE LOOP DESIGN
%% ===========================================================

fprintf('\n');

disp('      AUTOMATIC VOLTAGE LOOP DESIGN');

s = tf('s');

%% Desired Phase Margin

PM_desired = input('Desired Phase Margin (deg) = ');

%% STEP 1 : Compensation Pole

if strcmpi(P.converter,'buck')

    P.wpc = min(P.wesr,0.5*P.ws);

else

    P.wpc = min([P.wrhp P.wesr 0.5*P.ws]);

end

fprintf('\nCompensation Pole');
fprintf('\n------------------------------\n');
fprintf('wpc = %.3f rad/s\n',P.wpc);

%% STEP 2 : Search Limits

beta_min  = 0.60;
beta_max  = 0.80;
beta_step = 0.01;

if strcmpi(P.converter,'buck')

    gamma_min = 0.30;
    gamma_max = 1.00;

else

    gamma_min = 0.10;
    gamma_max = 0.30;

end

gamma_step = 0.001;

%% CURRENT LOOP

Ti = P.Gid*P.Ri*P.Fm;

%% INITIALIZATION

best_error = inf;

best_beta = NaN;
best_gamma = NaN;

best_PM = NaN;
best_GM = NaN;

best_wzc = NaN;
best_wcr = NaN;
best_Kv = NaN;

best_Fv = [];

best_Tv = [];
best_T2 = [];

disp('Initialization Complete.');
%% STEP 3 : ITERATIVE SEARCH

for beta = beta_min:beta_step:beta_max

    %% Compensation Zero

    wzc = beta*P.w0;

    for gamma = gamma_min:gamma_step:gamma_max

        %% Voltage Loop Crossover

        if strcmpi(P.converter,'buck')

            wcr = gamma*P.wesr;

        else

            wcr = gamma*P.wrhp;

        end

        %% Integrator Gain (Eq. 10.56)

        Kv = (P.Kid*wcr*P.Ri*wzc) ...
            /(P.wid*P.Kvd);

        %% Voltage Compensator

        Fv = Kv*(1+s/wzc) ...
              /(s*(1+s/P.wpc));
        [P.Fvnum, P.Fvden] = tfdata(Fv, 'v');

        s = tf('s');



        %% Open Voltage Loop

        Tv = P.Gvd*Fv*P.Fm;

        %% Overall Voltage Loop

        T2 = Tv/(1+Ti);

        %% Stability Margins

        [GM,PM,Wcg,Wcp] = margin(T2);

        %% Ignore Unstable Solutions

        if isnan(PM) || isinf(PM)
            continue;
        end

        %% Phase Margin Error

        PM_error = abs(PM_desired-PM);

        %% Store Best Design

        if PM_error < best_error

            best_error = PM_error;

            best_beta = beta;
            best_gamma = gamma;

            best_PM = PM;
            best_GM = GM;

            best_wzc = wzc;
            best_wcr = wcr;

            best_Kv = Kv;

            best_Fv = Fv;
            best_Tv = Tv;
            best_T2 = T2;

        end

        %% Desired Accuracy Reached

        if PM_error < 0.5
            break;
        end

    end

    if best_error < 0.5
        break;
    end

end
%% STEP 4 : SAVE BEST DESIGN

P.beta  = best_beta;
P.gamma = best_gamma;

P.wzc = best_wzc;
P.wcr = best_wcr;
P.Kv  = best_Kv;

P.Fv = best_Fv;

P.Ti = Ti;
P.Tv = best_Tv;
P.T2 = best_T2;

%% STEP 5 : BODE PLOT

fprintf('\n');
disp('          FINAL VOLTAGE LOOP');

figure;
margin(P.T2);
grid on;
title('Voltage Loop Gain T_2(s)');

%% Stability Margins

[GM,PM,Wcg,Wcp] = margin(P.T2);

%% DISPLAY RESULTS

fprintf('\nVoltage Controller Parameters\n');
fprintf('---------------------------------------\n');

fprintf('Beta                = %.2f\n',P.beta);
fprintf('Gamma               = %.2f\n',P.gamma);

fprintf('\n');

fprintf('Compensation Zero   = %.3f rad/s\n',P.wzc);
fprintf('Compensation Pole   = %.3f rad/s\n',P.wpc);

fprintf('Voltage Crossover   = %.3f rad/s\n',P.wcr);

fprintf('\n');

fprintf('Integrator Gain Kv  = %.6f\n',P.Kv);

fprintf('\n');

fprintf('Gain Margin         = %.2f dB\n',20*log10(GM));
fprintf('Phase Margin        = %.2f deg\n',PM);

fprintf('Gain Cross Freq     = %.3f rad/s\n',Wcg);
fprintf('Phase Cross Freq    = %.3f rad/s\n',Wcp);

fprintf('\n');

fprintf('Desired PM          = %.2f deg\n',PM_desired);
fprintf('PM Error            = %.2f deg\n',best_error);

disp('===============================================');


%% STEP 6 : ANALOG TYPE-II COMPENSATOR COMPONENTS


disp('      TYPE-II COMPENSATOR COMPONENTS');


% I HAVE USED FIXED RESISTOR FOR R2

R2 = 5000;

C2 = 1/(R2*P.wzc);

C3 = C2/(R2*P.wpc*C2-1) ;

R1 = 1/(P.Kv*(C2+C3));


%% Display

fprintf('R1 = %.3f Ohm\n',R1);
fprintf('R2 = %.3f Ohm\n',R2);

fprintf('\n');

fprintf('C2 = %.3e F\n',C2);
fprintf('C3 = %.3e F\n',C3);

disp('===============================================');

%% VOLTAGE COMPENSATOR

s = tf('s');

P.Fv = P.Kv*(1+s/P.wzc)...
      /(s*(1+s/P.wpc));

%% CURRENT LOOP

P.Ti = P.Gid*P.Ri*P.Fm;

%% OPEN VOLTAGE LOOP

P.Tv = P.Gvd*P.Fv*P.Fm;

%% ACTUAL VOLTAGE LOOP

P.T2 = P.Tv/(1+P.Ti);

%% FINAL RESULTS

disp('FINAL CONTROLLER');

disp('Current Loop Ti(s)');
P.Ti

disp('Voltage Compensator Fv(s)');
P.Fv

disp('Voltage Loop Tv(s)');
P.Tv

disp('Overall Voltage Loop T2(s)');
P.T2

%% FINAL STABILITY

figure;
margin(P.T2);
grid on;
title('Final Voltage Loop T_2(s)');

[GM,PM,Wcg,Wcp] = margin(P.T2);

fprintf('\n');
fprintf('Final Gain Margin  = %.2f dB\n',20*log10(GM));
fprintf('Final Phase Margin = %.2f deg\n',PM);
fprintf('Gain Crossover     = %.2f rad/s\n',Wcg);
fprintf('Phase Crossover    = %.2f rad/s\n',Wcp);

disp('===============================================');

end