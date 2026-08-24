function DisplayParameters(P)

%5 Displays all converter and controller parameters


fprintf('\n');
disp('=========================================================');
disp('        DC-DC CONVERTER PARAMETERS');
disp('=========================================================');

fprintf('\n');
fprintf('Converter Type              : %s\n',P.converter);

fprintf('\n');
disp('--------------- INPUT PARAMETERS ----------------');

fprintf('Input Voltage (Vi)          : %.4f V\n',P.Vi);
fprintf('Output Voltage (Vo)         : %.4f V\n',P.Vo);
fprintf('Load Resistance (R)         : %.4f Ohm\n',P.R);
fprintf('Inductance (L)             : %.6e H\n',P.L);
fprintf('Capacitance (C)            : %.6e F\n',P.C);
fprintf('Capacitor ESR (Rc)         : %.6f Ohm\n',P.Rc);

fprintf('Switching Frequency (fs)   : %.2f Hz\n',P.fs);
fprintf('Angular Frequency (ws)     : %.2f rad/s\n',P.ws);

fprintf('\n');
disp('--------------- CONVERTER PARAMETERS ---------------');

fprintf('Duty Ratio (D)             : %.6f\n',P.D);

fprintf('Kvs                        : %.6f\n',P.Kvs);
fprintf('Kvd                        : %.6f\n',P.Kvd);
fprintf('Kis                        : %.6f\n',P.Kis);
fprintf('Kid                        : %.6f\n',P.Kid);

fprintf('Kp                         : %.6f\n',P.Kp);
fprintf('Kq                         : %.6f\n',P.Kq);

fprintf('\n');

fprintf('Natural Frequency (w0)     : %.2f rad/s\n',P.w0);
fprintf('Quality Factor (Q)         : %.4f\n',P.Q);

fprintf('ESR Zero (wesr)            : %.2f rad/s\n',P.wesr);

if isinf(P.wrhp)

    fprintf('RHP Zero (wrhp)            : Infinity\n');

else

    fprintf('RHP Zero (wrhp)            : %.2f rad/s\n',P.wrhp);

end

fprintf('Current Pole (wid)         : %.2f rad/s\n',P.wid);
fprintf('Current Zero (wis)         : %.2f rad/s\n',P.wis);
fprintf('Output Zero (wz)           : %.2f rad/s\n',P.wz);

%% Controller Parameters

if isfield(P,'Ki')

    fprintf('\n');
    disp('--------------- CONTROLLER PARAMETERS ---------------');

    fprintf('Current Loop Gain (Ki)     : %.6f\n',P.Ki);
    fprintf('Voltage Loop Gain (Kv)     : %.6f\n',P.Kv);

    fprintf('Current Sense Gain (Ri)    : %.6f\n',P.Ri);
    fprintf('PWM Gain (Fm)              : %.6f\n',P.Fm);

    fprintf('Slope Compensation (Se)    : %.6f\n',P.Se);

    fprintf('\n');

    fprintf('Current Loop BW (wci)      : %.2f rad/s\n',P.wci);

    fprintf('Voltage Loop BW (wcr)      : %.2f rad/s\n',P.wcr);

    fprintf('Compensation Zero (wzc)    : %.2f rad/s\n',P.wzc);

    fprintf('Compensation Pole (wpc)    : %.2f rad/s\n',P.wpc);

end

disp('=========================================================');

end