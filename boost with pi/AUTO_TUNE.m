
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
 
Ki =1;
Kp = 1;
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
fc = 1100;
wc = 2*pi*fc;

fz = fc/10;

wz = 2*pi*fz;

%% AUTO TUNE ATTEMPT

% Choose PI zero (one decade below crossover)
fz = fc/10;
wz = 2*pi*fz;

% PI controller without gain
Gc_noK = (1 + wz/s);

% Open-loop without gain
Loop0 = Gc_noK * Tp * beta * Tm;

% Calculate gain
[mag,~] = bode(Loop0,wc);
mag = squeeze(mag);

K = 1/mag;

% Final PI controller
Tc = K * Gc_noK;

% PI gains
Kp = K;
Ki = K*wz;

fprintf('Kp = %.6f\n',Kp);
fprintf('Ki = %.6f\n',Ki);

%Verify
margin(Tc*Tp*beta*Tm)
grid on