%% PARAMETERS
Vi = 48;
Vo = 120;
Rl = 12;
L  = 100e-6;
C  = 33e-6;
Rc = 0.001;
r = 0.002;
Ra = 30e3;
Rb = 10e3;
beta = Rb/(Ra+Rb);
H11 = (Ra*Rb)/(Ra+Rb);

D_dash = Vi/Vo; % D~ =(1-D)


s = tf('s');

%% PLANT

Tpx = ((-Vo*Rc)/(D_dash*(Rl+Rc)));
Wzn = (1/(C*Rc));
Wzp = (Rl*((D_dash^2)-r))/L;
W0 = (r+Rl*D_dash^2)/(L*C*(Rl+Rc))
W1 = (C*(r*(Rl+Rc)+Rl*Rc*D_dash^2)+L)/(L*C*(Rl+Rc));


Tp = Tpx*(s+Wzn)*(s-Wzp)/(s^2 + s*W1+W0);
[tp_num ,tp_den]= tfdata(Tp, 'v');

%% audio suscepatiblity

Mv = (D_dash*Rl*Rc/(L*(Rl+Rc)))*(s+Wzn)/(s^2 + s*W1+W0);
[mv_num ,Mv_den]= tfdata(Mv, 'v');

%% output impedance 

Z0 =(Rl*Rc/(Rl+Rc))*(s+Wzn)*(s-(r/L))/(s^2 + s*W1+W0);
[Z0_num ,Z0_den]= tfdata(Z0, 'v');
%% UNCOMPENSATED LOOP

Tm = 1;
G_uncomp = Tm *beta* Tp;

disp('--- Uncompensated System ---')
figure;
margin(G_uncomp);
grid on;

%% DESIRED CROSSOVER FREQUENCY
wc = 2*pi*1100 % 1100 Hz

%% MAGNITUDE & PHASE AT wc
[mag, phase] = bode(G_uncomp, wc);
mag = mag(:);
phase = phase(:);

PHASE_uncomp = phase;
fprintf('\nUncompensated Phase(wc) = %.2f deg\n', PHASE_uncomp);

%% DESIRED PHASE MARGIN
PM_desired = 60;

% Add safety margin
Phase_boost = PM_desired - PHASE_uncomp - 90;

fprintf('Required Phase Boost = %.2f deg\n', Phase_boost);

%% BOOST FACTOR
if Phase_boost <= 0 
    % TYPE I COMPENSATOR
    if abs(Phase_boost)>90
        typr_comp =2;
        phi = Phase_boost;
        k = (tan(deg2rad(45 + phi/2)));
        % ZERO & POLE
        wz = wc / (k);
        wp = wc * (k);
    
        fprintf('\nZero = %.2f rad/s\n', wz);
        fprintf('Pole = %.2f rad/s\n', wp);
    
        % TYPE-II COMPENSATOR
       Tc_tem = (1 + wz/s) / ( (1 + s/wp) );

    else
        typr_comp =1;
        k=1;
        Tc_tem = 1/s;
    end

elseif Phase_boost >0 && Phase_boost<=90
    
    typr_comp =2;
    
    phi = Phase_boost;
    k = (tan(deg2rad(45 + phi/2)));
    % ZERO & POLE
    wz = wc / (k);
    wp = wc * (k);
    
    fprintf('\nZero = %.2f rad/s\n', wz);
    fprintf('Pole = %.2f rad/s\n', wp);
    
    % TYPE-II COMPENSATOR
    Tc_tem = (1 +s/wz) / ( (1 + s/wp) );

elseif Phase_boost >90 && Phase_boost<180
    typr_comp =3;
    phi = Phase_boost;
    k = (tan(deg2rad(45 + phi/4)))^2;
    % ZERO & POLE
    wz = wc / (k^0.5);
    wp = wc * (k^0.5);
    
    fprintf('\nZero = %.2f rad/s\n', wz);
    fprintf('Pole = %.2f rad/s\n', wp);
    
    % TYPE-III COMPENSATOR
    Tc_tem =wz* (1 + s/wz)*(1 + s/wz) / ( (1 + s/wp)*(1 + s/wp) );

end
%% LOOP WITH COMPENSATOR (NO GAIN)
T_temp = Tc_tem *beta*Tm * Tp;

%% FIND GAIN
[mag2, ~] = bode(T_temp, wc);
mag2 = mag2(:);

K = 1/mag2;

fprintf('\n Gain K = %.4f\n', K);

%% FINAL COMPENSATOR
Tc = K * Tc_tem;

%% FINAL LOOP
G_final = Tc * Tm * beta * Tp;

disp('---  Compensated System ---')
figure;
margin(G_final);
grid on;

%% CHECK PHASE MARGIN
[GM, PM, Wcg, Wcp] = margin(G_final);
fprintf('\nFinal Phase Margin  = %.2f deg\n', PM);

[num, den] = tfdata(Tc, 'v');

%% design of components 


%% BOOST FACTOR
if Phase_boost <= 0 
    % TYPE I COMPENSATOR
    if abs(Phase_boost)>90
        typr_comp =2;
        phi = Phase_boost;
        k = (tan(deg2rad(45 + phi/2)));
        % ZERO & POLE
        wz = wc / (k);
        wp = wc * (k);
    
        fprintf('\nZero = %.2f rad/s\n', wz);
        fprintf('Pole = %.2f rad/s\n', wp);
    
        % TYPE-II COMPENSATOR
       Gc_noK = (1 + wz/s) / ( (1 + s/wp) );

    else
        typr_comp =1;
        k=1;
        Gc_noK = 1/s^2;
    end

elseif Phase_boost >0 && Phase_boost<=90
    
    typr_comp =2;
    
    phi = Phase_boost;
    k = (tan(deg2rad(45 + phi/2)));
    % ZERO & POLE
    wz = wc / (k);
    wp = wc * (k);
    
    fprintf('\nZero = %.2f rad/s\n', wz);
    fprintf('Pole = %.2f rad/s\n', wp);
    
    % TYPE-II COMPENSATOR
    Gc_noK = (1 + wz/s) / ( (1 + s/wp) );

elseif Phase_boost >90 && Phase_boost<180
    typr_comp =3;
    phi = Phase_boost;
    k = (tan(deg2rad(45 + phi/4)))^2;
    % ZERO & POLE
    wz = wc / (k^0.5);
    wp = wc * (k^0.5);
    
    fprintf('\nZero = %.2f rad/s\n', wz);
    fprintf('Pole = %.2f rad/s\n', wp);
    
    % TYPE-III COMPENSATOR
    Gc_noK = (1 + wz/s)*(1 + s/wz) / ( (1 + s/wp)*(1 + s/wp) );

end
%% LOOP WITH COMPENSATOR (NO GAIN)
T_temp = Gc_noK * Tp * beta * Tm;

%% FIND GAIN
[mag2, ~] = bode(T_temp, wc);
mag2 = mag2(:);

K = 1/mag2;

fprintf('\nType-III Gain K = %.4f\n', K);

%% FINAL COMPENSATOR
Tc = K * Gc_noK 

%% FINAL LOOP
G_final = Tc * beta * Tm* Tp;

disp('---  Compensated System ---')
figure;
margin(G_final);
grid on;

%% CHECK PHASE MARGIN
[GM, PM, Wcg, Wcp] = margin(G_final);
fprintf('\nFinal Phase Margin  = %.2f deg\n', PM);

[num, den] = tfdata(Tc, 'v');

%% design of components 
R1_min = 1e3;
R1_max = 50e3;

C_min = 1e-12;
C_max = 100e-9;

max_iter = 1000;   % safety limit

for k = 1:max_iter

    if typr_comp == 1
        R1 = R1_min+1000;
        R1_min = R1;
        C1 = 1/(K * R1);

        if (C1 >= C_min) && (C1 <= C_max)
            fprintf('Type I Compensator:\n');
            fprintf('R1 = %.2f Ohm\n', R1);
            fprintf('C1 = %.3e F\n\n', C1);
            break;
        end

    elseif typr_comp == 2
        Ri = R1_min+1000;
        R1_min = Ri; 
        Rf = K * Ri;

        Cf  = 1/(Rf * wz);
        Chf = 1/(Rf * wp);

        if (Cf >= C_min && Cf <= C_max) && ...
           (Chf >= C_min && Chf <= C_max)

            fprintf('Type II Compensator:\n');
            fprintf('Ri = %.2f Ohm\n', Ri);
            fprintf('Rf = %.2f Ohm\n', Rf);
            fprintf('Cf = %.3e F\n', Cf);
            fprintf('Chf = %.3e F\n\n', Chf);
            break;
        end

    elseif typr_comp == 3
        Rif = R1_min+1000;
        R1_min = Rif; 
        Rf = K * Rif * sqrt(wz/wp);

        Cf  = 1/(Rf * wz);
        Cif = 1/(Rif * wp);
        Chf = 1/(Rf * wp);

        Ri = abs((1/(Cif * wz)) - Rif);

        if (Cf >= C_min && Cf <= C_max) && ...
           (Cif >= C_min && Cif <= C_max) && ...
           (Chf >= C_min && Chf <= C_max) 
            fprintf('Type III Compensator:\n');
            fprintf('Rif = %.2f Ohm\n', Rif);
            fprintf('Rf = %.2f Ohm\n', Rf);
            fprintf('Cf = %.3e F\n', Cf);
            fprintf('Cif = %.3e F\n', Cif);
            fprintf('Chf = %.3e F\n', Chf);
            fprintf('Ri = %.2f Ohm\n\n', Ri);
            break;
        end
    end
end

if k == max_iter
    fprintf('No valid design found within constraints.\n');
end


%%%
%% POLES AND ZEROS OF CLOSED LOOP SYSTEM
%% ==========================================================
% FINAL CLOSED-LOOP POLES AND ZEROS
%% ==========================================================

% Closed-loop transfer function
Tcl = feedback(G_final,1);

% Poles and Zeros
CL_Poles = pole(Tcl);
CL_Zeros = zero(Tcl);

disp('=========================================')
disp(' FINAL CLOSED-LOOP POLES')
disp('=========================================')
disp(CL_Poles)

disp('=========================================')
disp(' FINAL CLOSED-LOOP ZEROS')
disp('=========================================')
disp(CL_Zeros)
%%OPEN LOOP POLES
OL_Poles = pole(G_final);
OL_Zeros = zero(G_final);

disp(OL_Poles)
disp(OL_Zeros)