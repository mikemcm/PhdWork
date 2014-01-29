cc

cd C:\UBC\_PhDThesis\_working\Caber\OM
load('Waveform_Final.mat');   % load the waveform data provided by Geotech
waveform_data = wave;

% Columns are ordered Voltage, Time, Current.

%% 
% subtract off time zero computed as 5.864 ms
waveform_data(:,2) = waveform_data(:,2) - 5864;

% convert times to seconds from us
waveform_data(:,2) = waveform_data(:,2) * 1e-6;

% Normalize to 1 Amp
%waveform_data(:,3) = waveform_data(:,3)./max(waveform_data(:,3));

% Load time gates (gate;start(ms);end(ms);middle(ms);window_length(ms))
load('VTEM35_Time_Gates.mat');
time_gates = times*1e-3; % times in seconds

% Number of on-time measurements
n_on = 10;

% Start of waveform (s)
start = -5.864e-3;

% Time step for on-time
dt_1 = abs(start/n_on);

% On-time discretization
t1 = (start:dt_1:0);

% Off-time discretization step length (us)
dt_2 = 32;
dt_3 = 100;
dt_4 = 200;
%dt_5 = 500;

% Number of off-time discretization steps: (total window length (us))
ndt_2 = 15; % (480)
ndt_3 = 15; % (1980)
ndt_4 = 11; % (4380)
%ndt_5 = 15;

% Off-time discretizations
t2 = 0*1e-6 + 1e-6*cumsum(dt_2*ones(1,ndt_2)); % time 0 - dt_2*ndt_2
t3 = t2(end) + 1e-6*cumsum(dt_3*ones(1,ndt_3));
t4 = t3(end) + 1e-6*cumsum(dt_4*ones(1,ndt_4));
%t5 = t4(end) + 1e-6*cumsum(dt_5*ones(1,ndt_5));
t = [t1 t2 t3 t4];% t5];

% Interpolate wave-form onto discretization
lt = length(t);
yi = interp1(waveform_data(:,2),waveform_data(:,3),t);
yi = yi ./ abs(max(yi));

% Set an on-time cutoff, so that everything beyond this time is zero amps.
ycut = 50*1e-6;
yi(t>=ycut) = 0;
yi(1)=0;

%%

used_time_channels = 4:27;
l = length(used_time_channels);
%used_times_channels = [18 20 22 24 25 26 27 28 29 30 32 34 36 38 39 40 41 42 43 44 45 46 47]-12;

figure(1)
plot(t,yi,'.-');hold on
plot(time_gates(used_time_channels,3),zeros(size(time_gates(used_time_channels))),'rx')
xlabel('Time(s)');ylabel('Normalized current')

% final time gates [t (sec); I (Amps)]
time_g = [t' yi']; 

% Save wave file
save VTEM35_waveform_Jan21.txt time_g -ascii

