

clc
clear 
close all

% file for creating the retention test order

n_sbj       = 30;
condition   = 'Recog24hSham';
set         = -5:5:30;
repeat_n    = 30;
    
%% 

ord = 5*[-1	7	0	6	1	5	2	4	3;
        0	-1	1	7	2	6	3	5	4;
        1	0	2	-1	3	7	4	6	5;
        2	1	3	0	4	-1	5	7	6;
        3	2	4	1	5	0	6	-1	7;
        4	3	5	2	6	1	7	0	-1;
        5	4	6	3	7	2	-1	1	0;
        6	5	7	4	-1	3	0	2	1
        7	6	-1	5	0	4	1	3	2;


        3	4	2	5	1	6	0	7	-1;
        4	5	3	6	2	7	1	-1	0;
        5	6	4	7	3	-1	2	0	1;
        6	7	5	-1	4	0	3	1	2;
        7	-1	6	0	5	1	4	2	3;
        -1	0	7	1	6	2	5	3	4;
        0	1	-1	2	7	3	6	4	5;
        1	2	0	3	-1	4	7	5	6;
        2	3	1	4	0	5	-1	6	7]';

%




for reppp = 1:n_sbj
     
    clearvars -except n_sbj set repeat_n reppp condition ord
    
    
    data = ord(:, randperm(18));
    
    
    data       = data(:);
    data(:, 2) = data;
    data(:, 1) = 0:length(data)-1;
    data       = num2cell(data);
    data(:, 4) = num2cell(1:length(data));
    data(:, 5) = num2cell(zeros(length(data), 1));

    for i = 1:length(data)
        data{i, 3} = ['direction', num2str(data{i, 2})];
    end

    % plot(abs(diff(data)), 'o');

    title = {'', 'direction', 'type', 'trial', 'target.direction'};

    data  = [title; data];

    if ~exist([pwd, '/../csv_files/'], 'dir')
        mkdir([pwd, '/../csv_files/'])
    end
    
    if ~exist([pwd, '/../csv_files/', condition], 'dir')
        mkdir([pwd, '/../csv_files/', condition])
    end
    
    if reppp < 10
        SN = ['Sub00', num2str(reppp)];
    else
        SN = ['Sub0', num2str(reppp)];
    end
    
    if ~exist([pwd, '/../csv_files/', condition, '/', condition, '_', SN], 'dir')
        mkdir([pwd, '/../csv_files/', condition, '/', condition, '_', SN])
    end
    
    writecell(data, [pwd, '/../csv_files/', condition, '/', condition, '_', SN,'/', condition, '_', SN,'_RecogTest.csv']);

end


%% Functions

 function v=shuffle(v)
     v=v(randperm(length(v)));
 end

