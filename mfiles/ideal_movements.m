
clc
clear
close  

%% CSV file generating Settings

% If you want to generate new set of data for memory test for the specified conditions
% below, other than what already exists, switch this on.

GEN_Data        = 0;

conditions      = {'imClampS1', 'imClampM1', 'imClampSham', ...
                   '24ClampS1', '24ClampM1', '24ClampSham', ...
                   ...
                   ...
                   ...
                   'imNull', 'imClamp', '24Clamp'};


% number of subjects per condition
nSubject        = 20;


% other needed info is specified below in the design plot settings

%% Design Plot Settings

% Either 0 or 1 
TMSpresent      = 1;

nBaseNofeed     = 0;
nBaseFeed       = 30;
nClamp          = 150;
ClampValue      = 1;
distanceTMS     = 30;


candidateDir    = -10:5:30;
repcandidateDir = 18;

nBaseline       = nBaseNofeed+nBaseFeed;
nCandidateDir   = numel(candidateDir);
nTest           = nCandidateDir*repcandidateDir;
nTotal          = nTest + nBaseline + nClamp;


x0 = nClamp+nBaseline+distanceTMS;
y0 = ClampValue/2;
a  = 20;
b  = .5*ClampValue;

dist = distanceTMS*TMSpresent;


%% Random Seq

    % a block consisted of nCandRep of Canidate directions is made and shuffled
    nCandRep    = 2;

    % No consecutive Trials can have a rotation difference equal or more than
    % threshold value defined below
    thr         = 80;

    len_block   = nCandRep*numel(candidateDir);
    block       = repmat(candidateDir, [1, nCandRep]);
    
    if ~GEN_Data
        conditions = 1;
        nSubject   = 1;
    end
    
    for cond = 1:numel(conditions)
        for sbj = 1:nSubject

            %------------------------------------------------------------------
            % generating a random order for a single subject

            step        = 0;
            trig_in     = 0;
            trig_out    = 0;
            TestRot     = [];

            while numel(TestRot) < nTest    
                step = step + 1;    
                while ~trig_in    
                    tmp = block(randperm(len_block));
                    if sum(abs(diff(tmp)) >= thr) == 0
                        trig_in = 1;
                    end
                end

                trig_in = 0;
                TestRot = [TestRot, tmp];

                if step > 1 
                    if abs(diff(TestRot((step-1)*len_block:(step-1)*len_block+1))) >= thr
                        step     = step - 1;
                        trig_out = 1;
                        TestRot((step-1)*len_block+1:step*len_block) = [];
                    end
                    trig_out = 0;
                end
            end

            TestRot = TestRot(1:nTest);

            % figure('color', 'w', 'Position', [300, 400, 1500, 400]);
            % plot(TestRot, '-k', 'LineWidth', 2); hold on
            % plot(TestRot, 'o', 'MarkerFaceColor', 'r');
            % box off


            %------------------------------------------------------------------
            % Storing the generated random order in a CSV file used in robot

            Table       = TestRot(:);
            Table(:, 2) = Table;
            Table(:, 1) = 0:length(Table)-1;
            Table       = num2cell(Table);
            Table(:, 4) = num2cell(1:length(Table));
            Table(:, 5) = num2cell(zeros(length(Table), 1));

            for i = 1:length(Table)
                Table{i, 3} = ['direction', num2str(Table{i, 2})];
            end

            title = {'', 'direction', 'type', 'trial', 'target.direction'};

            Table  = [title; Table];
            
            if GEN_Data
            
                if ~exist([pwd, '/../csv_files/'], 'dir')
                    mkdir([pwd, '/../csv_files/'])
                end

                if ~exist([pwd, '/../csv_files/', conditions{cond}], 'dir')
                    mkdir([pwd, '/../csv_files/', conditions{cond}])
                end

                if sbj < 10
                    SN = ['Sub00', num2str(sbj)];
                else
                    SN = ['Sub0', num2str(sbj)];
                end

                if ~exist([pwd, '/../csv_files/', conditions{cond}, '/', conditions{cond}, '_', SN], 'dir')
                    mkdir([pwd, '/../csv_files/', conditions{cond}, '/', conditions{cond}, '_', SN]);
                end

                nFiles = dir([pwd, '/../csv_files/', conditions{cond}, '/', conditions{cond}, '_', SN, '/*.csv']);
                nFiles = size(nFiles, 1); 
                if ~nFiles
                    writecell(Table, [pwd, '/../csv_files/', conditions{cond}, '/', conditions{cond}, '_', SN, '/', conditions{cond}, '_', SN,'_RecogTest_v1.csv']);
                else
                    writecell(Table, [pwd, '/../csv_files/', conditions{cond}, '/', conditions{cond}, '_', SN, '/', conditions{cond}, '_', SN,'_RecogTest_v', num2str(nFiles+1),'.csv']);
                end
                
            end
            clear Table

        end
    end

%% Area filling

figure('color', 'w', 'Position', [300, 400, 1300, 500]);
     

    fill([nBaseline+.5, nBaseline+75+.5, nBaseline+nClamp+.5, nBaseline+nClamp+.5, nBaseline+.5], ...
        [0, ClampValue, ClampValue, 0, 0], ...
            .95*[1, 1, 1], 'EdgeColor', .95*[1, 1, 1]); hold 


%% Lines

LW1 = 3;

% horizontal lines
adjH = 1;
% line([0, nTotal+2*dist], [0, 0], 'color', 'k')
line([1, nBaseline+.5], [0, 0], 'color', 'k', 'LineWidth', LW1);
line([1, 180+.5], [-.2, -.2], 'color', 'k', 'LineWidth', LW1);
line([nBaseline+75+.5, nBaseline+nClamp+.5], [ClampValue, ClampValue], 'color', 'k', 'LineWidth', LW1);
line([2*dist+nBaseline+nClamp+.5, 2*dist+nTotal+adjH], [-.2, -.2], 'color', 'k', 'LineWidth', LW1);


% diognal
line([nBaseline+.5, nBaseline+75+.5], [0, ClampValue], 'color', 'k', 'LineWidth', LW1);

% vertical lines
adjV = .004;
% line([nBaseline+.5, nBaseline+.5], [0-adjV, ClampValue+adjV], 'color', 'k', 'LineWidth', LW1);
line([nBaseline+nClamp+.5, nBaseline+nClamp+.5], [0-adjV, ClampValue+adjV], 'color', 'k', 'LineWidth', LW1); hold on

% More lines

line([1, 180.5], [-.1, -.1], 'color', .8*[1,1,1], 'LineWidth', 5);

nofeedtrials = [4, 7, 9, 10, 15, 17, 20, 24, 27, 29, 30+[10, 22, 30, 42, 51, 57, 66, 77, 89, 99, 109, 119, 128, 137, 146]];
for i = nofeedtrials
    line([i, i], [-.085, -.115], 'color', 'k', 'LineWidth', 2);
end


line([-7, -7], [0-adjV, 1+adjV], 'color', 'k', 'LineWidth', LW1);
line([-11, -7], [0, 0], 'color', 'k', 'LineWidth', LW1);
line([-11, -7], [1, 1], 'color', 'k', 'LineWidth', LW1);

text(-12, 0, '0', 'FontSize', 20, 'HorizontalAlignment', 'right')
text(-12, 1, '-30', 'FontSize', 20, 'HorizontalAlignment', 'right')
text(-30, .5, 'Applied Rotation (deg)', 'FontSize', 25, 'HorizontalAlignment', 'center', 'rotation', 90)


%% TMS

if TMSpresent == 1
    
x1 = x0-a:.1:x0-10;
x2 = x0+a:-.1:x0+10;

y1 = sqrt(b^2 - ((b/a)^2*(x1-x0).^2));
y2 = sqrt(b^2 - ((b/a)^2*(x2-x0).^2));

LW2 = 2;
plot(x1, y1+y0, 'color', 'k', 'LineWidth', LW2); hold on
plot(x1, -y1+y0, 'color', 'k', 'LineWidth', LW2); hold on
plot(x2, y2+y0, 'color', 'k', 'LineWidth', LW2); hold on
plot(x2, -y2+y0, 'color', 'k', 'LineWidth', LW2); hold on

text(x0, y0, {'cTBS', 'M1/S1'}, 'HorizontalAlignment', 'Center', 'FontSize', 20);

end


%% Random Seq in Design plot


col1      = [0, 0, 0];
col2      = [1, 0, 0];

fade_rate = .92;
col1_fade = col1+(1-col1)*fade_rate;
col2_fade = col2+(1-col2)*fade_rate;

adj_deg          = .8;
adj_trial        = 2;


exampleTestRot   = adj_deg*(TestRot-min(TestRot))/max(TestRot-min(TestRot))+(1-adj_deg)/2;
exampleTestTrial = adj_trial+2*dist+nBaseline+nClamp+(1:nTest)*((nTest-adj_trial)/nTest);

plot(exampleTestTrial, exampleTestRot, ...
        '-', 'LineWidth', 1, 'color', col1_fade); hold on
plot(exampleTestTrial, exampleTestRot, ...
        'o', 'MarkerFaceColor', col2_fade, 'MarkerEdgeColor', col2_fade);



%% Title text

fntSize = 20;

% % Limited Feedback
% text(nBaseNofeed/2, ClampValue/2, 'Limited Feedback', ...
%         'HorizontalAlignment', 'Center', 'FontSize', fntSize, 'Rotation',90);

% Veridical Feedback   
text((nBaseNofeed+nBaseFeed)/2, 1.1*ClampValue, 'Baseline', ...
        'HorizontalAlignment', 'Center', 'FontSize', fntSize, 'Rotation',0);

%Clamped Feedback
text(nBaseNofeed+nBaseFeed+nClamp/2, 1.1*ClampValue, 'Training', ...
         'HorizontalAlignment', 'Center', 'FontSize', fntSize);

% Memory Test
text(2*dist+nBaseNofeed+nBaseFeed+nClamp+nTest/2, 1.1*ClampValue, 'Memory Test', ...
        'HorizontalAlignment', 'Center', 'FontSize', fntSize);

    
%% Text

text(nBaseline+75+75/2, .95*ClampValue, 'Hold', ...
    'HorizontalAlignment', 'Center', 'FontSize', fntSize-2);
text(nBaseline+75/2+5, .48, 'Ramp', ...
    'HorizontalAlignment', 'Center', 'FontSize', fntSize-2, 'Rotation',60);


putTick(1, LW1, 0, dist);
putTick(nBaseline+75+1, LW1, 0, dist);
% putTick(nBaseNofeed, LW1, 0, dist);
putTick(nBaseline, LW1, 0, dist);
putTick(nBaseline+nClamp, LW1, 0, dist);
putTick(nTotal, LW1, 1, dist);

if TMSpresent == 1
    putTick(nBaseline+nClamp+.001, LW1, 1, dist);
end


%% Figure Control

axis off

xlim([-15, nTotal+2*dist+1.5]);
ylim([-.25, ClampValue+.1]);
text((nTotal+2*distanceTMS)/2, -.15-.2, 'Trial Number', 'FontSize', 25, ...
        'HorizontalAlignment', 'Center');

%% Functions

function putTick(loc, linewidth, TMSpresent, dist)

    if (TMSpresent)    
        line([2*dist+loc+.5, 2*dist+loc+.5], [0.004, -.03]-.2, 'color', 'k', 'LineWidth', linewidth);
        text(2*dist+loc+.5, -.07-.2, num2str(ceil(loc)), ...
                'HorizontalAlignment', 'Center', 'FontSize', 20);
    else    
        line([loc+.5, loc+.5], [0.004, -.03]-.2, 'color', 'k', 'LineWidth', linewidth);
        text(loc+.5, -.07-.2, num2str(loc), ...
                'HorizontalAlignment', 'Center', 'FontSize', 20);      
    end

end
