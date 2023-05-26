
clc
clear
close all;

%% Input check

dataStructure         = 'MergedMemory';
name_of_your_study    = 'recog';          % the name you have specified for your study in the robot python code

target_drection       = 90;               % located target direction in case you have one target. If you are in a 2target condition 45, 135 will be chosen automatically
Fs_kin                = 200;              % Sampling frequnecy (Hz)

MOVE_LNG              = 150;              % distance between the target and start points (mm)
fam                   = 0;
baseline              = 30;               % number of trials in baseline phase
learning              = 150;              % number of trials in learning phase
recall                = 162;                % number of trials in recall phase

% Your conditions in the study, which is typically the base name of all
% your data file.
conditions  = {'Arc30inst', 'RecallS1', 'RecallM1', 'RecallSham'};

% different phases throughout the experiment
phases      = {'Baseline', 'Learning', 'Recall'};

butter_order          = 2;                % Butterworth filter order
lp_cutoff             = 10;               % lowpass filter cut-off freq. (Hz)
crit_for_trial_length = 0.05;             % Criterion for the algorithm to calculate the start and stop time for each trial. (default: 5 percentage of peak velocity) 

set(0,'units','pixels');
sc     = get(0,'screensize');
ratio  = (sc(3)*sc(4))/(2560*1440);

%%

% start and end of each phase
baseline_start        = 1;
baseline_end          = baseline;

learning_start        = baseline + 1;
learning_end          = baseline + learning;

recall_start          = baseline + learning + 1;
recall_end            = baseline + learning + recall;


cond      = input(['Please enter the condition of your study (arc30i):', ...
                   '\ni.e. The base name of your data folders: \n\n ', ...
                   'arc30i     -> Arc30inst  \n ', ...
                   '\n = '], 's');

while ~(strcmp(cond, 'arc30i') || strcmp(cond, 'rls1') || strcmp(cond, 'rlm1') || strcmp(cond, 'rls'))
    fprintf('\nIncorrect input... Please try again!!!');
    cond  = input('\nPlease enter the condition of your study  (imc/imcr/imn/24c): ', 's');
end

switch cond % condition of study (Basename of data folders)
    
    case 'arc30i'
        cond = conditions{1};
    case 'rls1'
        cond = conditions{2};
    case 'rlm1'
        cond = conditions{3};
    case 'rls'
        cond = conditions{4};

end

sn        = input('\n\nPlease enter subject number: ');

while sn < 1 || sn~=round(sn)
    sn        = input('\nPlease enter subject number: ');
end

if sn < 10
    SN = ['00', num2str(sn)];
elseif sn >= 10 && sn < 100
    SN = ['0', num2str(sn)];
else
    SN = num2str(sn);
end



directory  = [pwd, '/../data/', cond, '/', cond, '_Sub', SN, '/'];
fileNames  = dir([directory, '*dump.mat']);

data     = [];
for i = 1:numel(fileNames)
    data = [data, load([directory, fileNames(i).name]).pickle_data];
end

if strcmp(dataStructure, 'seperateMemory')
    data = data(fam+1:fam+baseline+learning+recall);
elseif strcmp(dataStructure, 'MergedMemory')
    data = data(fam+baseline+learning+1:fam+baseline+learning+recall);
end

if isempty(data)
    error('no data found');
end

if numel(target_drection) == 1
    targetdirect = repelem(target_drection, recall_end)';  
else
    directory2    = [pwd, '/../csv_2target_20/Sub', SN, '/'];
    csvNames      = dir([directory2, '*.csv']);
    targetdirect  = [];
    for i = 1:numel(csvNames)
        targetdirect = [targetdirect; readtable([directory2, csvNames(i).name], 'ReadVariableNames',false).Var3];
    end
    
    targetdirect = targetdirect + 90;
end

%% Loading data

x         = 0;

save_name = [directory, cond, '_Sub', SN, '_Scored_MemoryTest'];
minuss    = [0, baseline_end, learning_end];

if exist(strcat(save_name,'.mat'), 'file') ~= 0
    load(save_name);
    next_set = size(saved_data, 2) + 1;
else
    next_set = 1;
end

saved_data{1, next_set}       = ['Set ', num2str(next_set)]; 

for i = 1:numel(phases)
    saved_data{2, next_set}{1, i} = phases{i};
end
saved_data{2, next_set}{1, numel(phases)+1} = 'Total';

 % caculate velocity and filter positional data
[B, A]                = butter(butter_order, lp_cutoff/(Fs_kin/2));

all_maxv              = zeros(numel(data), 1);
ref                   = zeros(numel(data), 2);


i        = 1;     %% Trial Number
counter  = 0;

while i <= numel(data)
    
    clear tmp
    
    flg1          = 0;
    
    temp_data     = 1000*data{1, i}.captured(:, 1:2);
    temp_force    = data{1, i}.captured(:, 3:end);
    temp_time     = (1/Fs_kin)*(0:length(temp_data)-1);
    
    tmp(:, 1)     = temp_data(:, 1)-temp_data(1, 1);
    tmp(:, 2)     = temp_data(:, 2)-temp_data(1, 2);
    
    tmp           = filtfilt(B, A, tmp);
    temp_force    = filtfilt(B, A, temp_force);
    
    
    [~, temp_vel] = gradient(tmp, 1/Fs_kin);
    
    refvel        = crit_for_trial_length*max(sqrt(temp_vel(:,2) .^2+temp_vel(:,1) .^2));

    data_lng      = size(temp_vel, 1);

    [mx, max_vel] = max(sqrt(temp_vel(:,2) .^2+temp_vel(:,1) .^2));
    
    start = [];
    stop  = [];
    for j=max_vel:-1:1
        if sqrt(temp_vel(j,2).^2 + temp_vel(j,1).^2) < refvel
            start = j;
            break
        end
    end
    for j=max_vel:1:data_lng
        if sqrt(temp_vel(j,2).^2 + temp_vel(j,1).^2) < refvel
            stop = j;
            break
        end
    end
    
    if isempty(stop)
        stop = data_lng;
    end
    if isempty(start)
        start = 1;
    end
    
    pos  = temp_data(start:stop, :);
    vel  = temp_vel(start:stop, :);

    [maxv, mxidx]  = max(sqrt(vel(:,1).^2 + vel(:,2).^2));
    all_maxv(i, 1) = maxv;
    ref(i, :)      = [start stop];
    
    
    [~, ~, ~, ~, ~, ~, ~, ~, iadmaxv] = kin_charsigned(pos, vel, temp_time(start:stop), targetdirect(i), MOVE_LNG);

    f = figure(1); 
%     f.Position = [0, 0, 1000, 600];
    
    hold on;
    f.WindowState = 'maximized';
    
    if i == 1
        pause(1)
    end
    
    subplot(6, 4, [1:2, 5:6, 9:10, 13:14, 17:18, 21:22]), cla reset
    canvas_draw(pos, MOVE_LNG, i, iadmaxv, targetdirect(i), temp_time(start:stop), mxidx, baseline_end, learning_end, ratio, recall);

    subplot(6, 4, [3:4, 7:8]), cla reset
    velocity_draw(temp_vel, start, stop, temp_time(start:stop), crit_for_trial_length, ratio);
    
    subplot(6, 4, [11:12, 15:16]), cla reset
    velocityXY_draw(temp_vel, start, stop, temp_time(start:stop), ratio);
    
    subplot(6, 4, [19:20, 23:24]), cla reset
    force_draw(temp_force, start, stop, temp_time(start:stop), temp_vel, ratio);

        
    cf = gcf;
    
    accept = uicontrol(cf, ...			% continue button
        'style', 'togglebutton', ...
        'units', 'normalized', ...
        'string', 'Accept', ...
        'position', [.31 .001 .15 .06], ...
        'userData', 1,'enable','on', ...
        'callback','uiresume', 'FontSize', 20);
    reject = uicontrol(cf, ...			% continue button
        'style', 'togglebutton', ...
        'units', 'normalized', ...
        'string', 'Reject', ...
        'position', [.08 .001 .15 .06], ...
        'userData', 1,'enable','on', ...
        'callback','uiresume', 'FontSize', 20);
    outlier = uicontrol(cf, ...			% continue button
        'style', 'togglebutton', ...
        'units', 'normalized', ...
        'string', 'Outlier', ...
        'position', [.54 .001 .15 .06], ...
        'userData', 1,'enable','on', ...
        'callback','uiresume', 'FontSize', 20);
    
    back = uicontrol(cf, ...			% continue button
        'style', 'togglebutton', ...
        'units', 'normalized', ...
        'string', 'Previous', ...
        'position', [.77 .001 .15 .06], ...
        'userData', 1,'enable','on', ...
        'callback','uiresume', 'FontSize', 20);
    
    
    out_lier = 0;
%     uiwait(cf)   

	if get(back, 'value') == 1
        if i > 1
            i = i - 1; 
            subplot(6, 4, 1:24), cla reset
        end
        continue;
	end

    if get(reject, 'value')==1
        while get(accept, 'value')== 0 && get(outlier, 'value')== 0

            flg1           = 1;
            [x, ~]         = ginput(2);
            x              = round(x);

            hd = [];
            while (x(2) <= x(1) || isempty(x(1)) || isempty(x(2)) || x(1) <= 0 || x(2) <= 0)
                vvv = max(sqrt(vel(:,1).^2 + vel(:,2).^2));
                hd  = text(length(temp_data)/2, vvv, 'TRY AGAIN!!!', ...
                        'HorizontalAlignment','center', 'FontSize', 20, 'color', 'r');
                [x, ~]     = ginput(2);
                x          = round(x);
            end

            if ~isempty(hd)
                delete(hd);
            end

            pos            = temp_data(x(1):x(2), :);
            vel            = temp_vel(x(1):x(2), :);
            [maxv, maxv_i] = max(sqrt(vel(:,1).^2 + vel(:,2).^2));

            [~, ~, ~, ~, ~, ~, ~, ~, iadmaxv] = kin_charsigned(pos, vel, temp_time(x(1):x(2)), targetdirect(i), MOVE_LNG);

            subplot(6, 4, [1:2, 5:6, 9:10, 13:14, 17:18, 21:22]), cla reset
            canvas_draw(pos, MOVE_LNG, i, iadmaxv, targetdirect(i), temp_time(x(1):x(2)), maxv_i, baseline_end, learning_end, ratio, recall);

            subplot(6, 4, [3:4, 7:8]), cla reset
            velocity_draw(temp_vel, x(1), x(2),  temp_time(x(1):x(2)), crit_for_trial_length, ratio);

            subplot(6, 4, [11:12, 15:16]), cla reset
            velocityXY_draw(temp_vel, x(1), x(2), temp_time(x(1):x(2)), ratio);

            subplot(6, 4, [19:20, 23:24]), cla reset
            force_draw(temp_force, x(1), x(2), temp_time(x(1):x(2)), temp_vel, ratio);

            out_lier = 0;
            set(reject,'value',0);
            
           
            uiwait(cf)   

        end
    end
    
	if  get(accept, 'value') == 1
        set(accept,'value',0);
        out_lier = 0;
    elseif get(outlier,'value') == 1 
        set(outlier,'value',0);
        out_lier = 1;
	end

    
    if flg1 == 1
       start = x(1);
       stop  = x(2);
    end
    
[meanpd, area, pd, pdmaxv, pd100, pd200, pdEnd, lng, iadmaxv, iad100, iad200, iadEnd] = kin_charsigned(pos, vel, temp_time(start:stop), targetdirect(i), MOVE_LNG);
    

if i <= baseline_end
        type = 1;
elseif i > baseline_end && i <= learning_end
        type = 2;
elseif i > learning_end
        type = 3;
end


saved_data{2, next_set}{2, type}{i-minuss(type)}.pos     = pos;
saved_data{2, next_set}{2, type}{i-minuss(type)}.lng     = lng;
saved_data{2, next_set}{2, type}{i-minuss(type)}.maxv    = maxv;
saved_data{2, next_set}{2, type}{i-minuss(type)}.pd      = pd;
saved_data{2, next_set}{2, type}{i-minuss(type)}.pdmaxv  = pdmaxv;
saved_data{2, next_set}{2, type}{i-minuss(type)}.pd100   = pd100;
saved_data{2, next_set}{2, type}{i-minuss(type)}.pd200   = pd200;
saved_data{2, next_set}{2, type}{i-minuss(type)}.pdEnd   = pdEnd;
saved_data{2, next_set}{2, type}{i-minuss(type)}.iadmaxv = iadmaxv;

saved_data{2, next_set}{2, type}{i-minuss(type)}.iad100  = iad100;
saved_data{2, next_set}{2, type}{i-minuss(type)}.iad200  = iad200;
saved_data{2, next_set}{2, type}{i-minuss(type)}.iadEnd  = iadEnd;
saved_data{2, next_set}{2, type}{i-minuss(type)}.area   = area;
saved_data{2, next_set}{2, type}{i-minuss(type)}.meanpd  = meanpd;
saved_data{2, next_set}{2, type}{i-minuss(type)}.outlier = out_lier;

saved_data{2, next_set}{2, 4}{i}.pos     = pos;
saved_data{2, next_set}{2, 4}{i}.lng     = lng;
saved_data{2, next_set}{2, 4}{i}.maxv    = maxv;
saved_data{2, next_set}{2, 4}{i}.pd      = pd;
saved_data{2, next_set}{2, 4}{i}.pdmaxv  = pdmaxv;
saved_data{2, next_set}{2, 4}{i}.pd100   = pd100;
saved_data{2, next_set}{2, 4}{i}.pd200   = pd200;
saved_data{2, next_set}{2, 4}{i}.pdEnd   = pdEnd;
saved_data{2, next_set}{2, 4}{i}.iadmaxv = iadmaxv;
saved_data{2, next_set}{2, 4}{i}.iad100  = iad100;
saved_data{2, next_set}{2, 4}{i}.iad200  = iad200;
saved_data{2, next_set}{2, 4}{i}.iadEnd  = iadEnd;
saved_data{2, next_set}{2, 4}{i}.area    = area;
saved_data{2, next_set}{2, 4}{i}.meanpd  = meanpd;
saved_data{2, next_set}{2, 4}{i}.outlier = out_lier;


i = i + 1;

end

if ~exist(directory, 'dir')
	mkdir(directory);
end

save(save_name, 'saved_data');

close all