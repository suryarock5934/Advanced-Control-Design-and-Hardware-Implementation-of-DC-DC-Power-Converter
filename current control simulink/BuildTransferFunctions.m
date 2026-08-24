function TF = BuildTransferFunctions(P)
%% Generates all power stage transfer functions

s = tf('s');


% Common Second-Order Denominator

Den = 1 + s/(P.Q*P.w0) + (s/P.w0)^2;


%% RHP Zero Factor
if strcmpi(P.converter,'buck')

    RHZ = 1;

else

    RHZ = (1 - s/P.wrhp);

end

%% ESR Zero Factor

ESR = (1 + s/P.wesr);


%% Transfer Functions


%--------------------------------------------------------------
% Input-to-Output Voltage
%--------------------------------------------------------------

TF.Gvs = P.Kvs * ESR / Den;

%--------------------------------------------------------------
% Control-to-Output Voltage
%--------------------------------------------------------------

TF.Gvd = P.Kvd * RHZ * ESR / Den;

%--------------------------------------------------------------
% Input-to-Inductor Current
%--------------------------------------------------------------

TF.Gis = P.Kis * (1 + s/P.wis) / Den;

%--------------------------------------------------------------
% Control-to-Inductor Current
%--------------------------------------------------------------

TF.Gid = P.Kid * (1 + s/P.wid) / Den;

%--------------------------------------------------------------
% Open-Circuit Output Impedance
%--------------------------------------------------------------

TF.Zp = P.Kp * RHZ * ESR / Den;

%--------------------------------------------------------------
% Output Impedance
%--------------------------------------------------------------

TF.Zq = P.Kq * (1 + s/P.wz) / Den;

%% ===========================================================
% Display
%% ===========================================================

disp(' ');
disp('===============================================');
disp('TRANSFER FUNCTIONS');
disp('===============================================');

fprintf('\nGvs(s)\n');
TF.Gvs

fprintf('\nGvd(s)\n');
TF.Gvd

fprintf('\nGis(s)\n');
TF.Gis

fprintf('\nGid(s)\n');
TF.Gid

fprintf('\nZp(s)\n');
TF.Zp

fprintf('\nZq(s)\n');
TF.Zq

disp('===============================================');

end