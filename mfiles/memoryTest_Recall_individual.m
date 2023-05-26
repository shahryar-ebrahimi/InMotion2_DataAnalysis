
clc
clear 
close 

%%


% Normalization (YES(1)/NO(0))
Design.normaliz = 0;  

% Number of last trials in the learning phase as a measure learned
% direction
Design.learning_last = 20;

% Number of last trials in the baseline as a measure of baseline
baseline_last = 10;

% the same last trials, this time for no feedback trials
learning_lastnofeed  = 0;
baseline_lastnofeed  = 0;

% Num
recallstartmeanlength = 2;

conditions           = {'RecallM1'};          
conditions_fignames  = {'Recall M1'};

% list of subjects you want to include in your condition. (it should be a cell of vectors if you have more than one condition)
list                 = {1:5};
    

% which set of data for subjecs do you want to use? (if you have scored your subjects more than once, you can increase this value)
% default: first set
set_num = cell(size(list));
for i = 1:length(list)
	set_num{i} = ones(size(list{i}));
end


%%

fexp = @(b,x) b(1).*exp(-x./(b(2)))+b(3);                                     % Objective Function
flin = @(c, x) c(1)*x+c(2);

%% controlling whther the variables are set properly

if length(list) ~= length(set_num)
	error('list and set_num must have same dimensions');
end

for i = 1:numel(list)
	if length(list{i}) ~= length(set_num{i})
        error('All the vectors in list and set_num must have same dimensions');
	end
end

if ~(Design.normaliz == 1 || Design.normaliz == 0)
   error('"normaliz" must be 1/0'); 
end

if numel(conditions) ~= numel(conditions_fignames)
	error('length of "conditions_fignames" and "conditions" must be equal');
end

%% Controlling figure colors and texts

col = [255, 0, 0;
       25, 0, 255;
       255, 132, 0
       0, 157, 219;
       128, 55, 4;
       50, 50, 50;
       0, 0, 0;]/255;

textcontrollength = 6;

%% Design

% different phases throughout the experiment
Design.phases      = {'Recall'};

% maximum rotation value for each condition(feedback).  
Design.rotation    = 15;

% is your condition abrupt? (0/1). 0: gradual - 1: abrupt. 
% it should be a vector if you have more than one condition
Design.abr = ones(size(conditions));      

% if the condition is gradual, rotation value holded constant after 
% 75th trial of learning phase until the end
Design.hold_learning_start = 75;              

% number of trials in baseline phase
Design.baseline = 0;

% number of trials in learning phase
Design.learning = 0;

% number of trials in recall phase
Design.recall = 162;             

% trials numbers for nofeedback trials during learning
Design.nofeedback_learning = [];

% trials numbers for nofeedback trials during baseline
Design.nofeedback_baseline = [];

% feedback trials during baseline
Design.feedback_baseline   = 1:Design.baseline;
Design.feedback_baseline(Design.nofeedback_baseline) = [];

% start and end of baseline
Design.baseline_start        = 1;
Design.baseline_end          = Design.baseline;

% start and end of learning
Design.learning_start        = Design.baseline + 1;
Design.learning_end          = Design.baseline + Design.learning;

% start and end of recall
Design.recall_start          = Design.baseline + Design.learning + 1;
Design.recall_end            = Design.baseline + Design.learning + Design.recall;

% total number of trials
Design.totalTrials           = Design.recall_end;

%%


for rep = 1:length(conditions)
    
    fall = figure('color','w', 'position', [300, 500, 1000, 500]); hold on,
    
    % vector of recal trial numbers for each condition
    XFF{rep} = Design.recall_start:Design.recall_end;
    

	listname              = num2str(list{rep});
	listname              = listname(~isspace(listname));

	target     = conditions{rep};
	targetshow = target;


	directory  = [pwd, '/../data/', target, '/'];

	all_files  = dir([directory, target,'_Sub*']);
	all_files  = struct2cell(all_files([all_files(:).isdir]));
	all_files  = all_files(1, :);
        
	clear chk
	for mvgt = 1:numel(all_files)
        chk(mvgt) = str2double(all_files{mvgt}(end-1:end));
    end
        
	[~, chk] = intersect(chk, list{rep});
        
	all_files = all_files(chk);
        
	for numb = 1:numel(list{rep})
                           
        directory1 = [directory, all_files{numb}];
        directory2 = [directory, all_files{numb}, '/', all_files{numb}, '_Scored_MemoryTest.mat'];

        saved_data = load(directory2);
        saved_data = saved_data.saved_data;

        [~, loc] = find(strcmp(saved_data{2, set_num{rep}(numb)}, 'Total'));
                 
        for i = 1:Design.totalTrials
            depvar(i) = -saved_data{2, set_num{rep}(numb)}{2, loc}{i}.iadmaxv;
            outlier(i) = saved_data{2, set_num{rep}(numb)}{2, loc}{i}.outlier;
            % disttemp   = saved_data{2, set_num{rep}(numb)}{2, loc}{i}.pos;
            % dist(i)    = sqrt(sum((disttemp(end, :)-disttemp(1, :)).^2));
        end

        if Design.normaliz == 1 && Design.rotation(rep) ~= 0
            depvar = 100*depvar/rotation(rep);
        end

        limf     = zeros(1, Design.recall_end);
        limf([Design.nofeedback_baseline, Design.baseline_end+Design.nofeedback_learning, Design.recall_start:Design.recall_end]) = 1;
        limfrr   = limf;

        xidx     = 1:Design.recall_end;
        xidxrr   = xidx;

        limf(outlier == 1)    = [];
        xidx(outlier == 1)    = [];


        depvar_biascorrected              = depvar;
        bias                              = intersect(xidx, Design.nofeedback_baseline);
        biasblue                          = intersect(xidx, Design.feedback_baseline);
        depvarbias(numb, rep)             = mean(depvar(bias));
        depvarbiasblue(numb, rep)         = mean(depvar(biasblue));



        depvar_biascorrected([Design.feedback_baseline, Design.learning_start:Design.learning_end]) = depvar_biascorrected([Design.feedback_baseline, Design.learning_start:Design.learning_end]) - depvarbiasblue(numb, rep);
        depvar_biascorrected([Design.nofeedback_baseline, Design.recall_start:Design.recall_end])   = depvar_biascorrected([Design.nofeedback_baseline, Design.recall_start:Design.recall_end]) - depvarbias(numb, rep);

        depvar_show               = depvar;
        depvar_show(outlier == 1) = [];
        
        if Design.recall > 0
        
            xxxx = intersect(xidx, Design.recall_start:Design.recall_end);                

            B = fminsearch(@(b) norm(depvar(xxxx) - fexp(b, xxxx-Design.learning_end)), [15; 30; 15]);                    % Estimate Parameters
            C = fminsearch(@(c) norm(depvar(xxxx) - flin(c, xxxx-Design.learning_end)), [0; 15]);

            RSSexp = sum((depvar(xxxx) - fexp(B, xxxx-Design.learning_end)).^2);
            RSSlin = sum((depvar(xxxx) - flin(C, xxxx-Design.learning_end)).^2);

            AICexp = 6 + numel(xxxx)*log(RSSexp);
            AIClin = 4 + numel(xxxx)*log(RSSlin);

            BICexp = log(numel(xxxx))*3 + numel(xxxx)*log(RSSexp);
            BIClin = log(numel(xxxx))*2 + numel(xxxx)*log(RSSlin);


            datatmp        = fexp(B, xxxx-Design.learning_end);
            decayexp{numb} = (datatmp(1)-datatmp(end))/(Design.rotation(rep)+eps);

            datatmp        = flin(C, xxxx-Design.learning_end);
            decaylin{numb} = (datatmp(1)-datatmp(end))/(Design.rotation(rep)+eps);

            total_decayexp(numb, rep) = decayexp{numb};
            total_decaylin(numb, rep) = decaylin{numb};
                
            if AICexp <= AIClin
                BCaic{numb} = 'B'; 
                    
                datatmp        = fexp(B, xxxx-Design.learning_end);
                total_decayaic(numb, rep) = (datatmp(1)-datatmp(end))/(Design.rotation(rep)+eps);
                
            else
                BCaic{numb} = 'C';
                    
                datatmp        = flin(C, xxxx-Design.learning_end);
                total_decayaic(numb, rep) = (datatmp(1)-datatmp(end))/(Design.rotation(rep)+eps);
                    
            end
                
            if BICexp <= BIClin
                BCbic{numb} = 'B';
                    
                datatmp        = fexp(B, xxxx-Design.learning_end);
                total_decaybic(numb, rep) = (datatmp(1)-datatmp(end))/(Design.rotation(rep)+eps);
                    
            else
                BCbic{numb} = 'C';
                    
                datatmp        = flin(C, xxxx-Design.learning_end);
                total_decaybic(numb, rep) = (datatmp(1)-datatmp(end))/(Design.rotation(rep)+eps);
            end

               
                
            meanval = depvar(Design.recall_start:Design.recall_end);
            out     = outlier(Design.recall_start:Design.recall_end);
            meanval = mean(meanval(out==0));
                
            retention(numb)      = meanval;
                
        end

        % related to generating figures for each subject

        f1 = figure('color','w', 'position', [300, 500, 1000, 500]); hold on,

        txt = {'MemoryTest'};
        
        % ideal rotation
        draw_backlines(Design.abr(rep), Design);
        ln       = [.5];
        for i = 1:length(ln)
            xline(ln(i),'--k', txt(i), 'FontSize', 17);
        end

        yline(0,  '--k', {' '}, 'FontSize', 17);

        a = plot(xidx(limf==0), depvar_show(limf==0), 'bo', 'MarkerFaceColor', [0,0,1]+(1-[0,0,1])*(1-0.15), 'MarkerSize', 8);
        b = plot(xidx(limf==1), depvar_show(limf==1), 'ro', 'MarkerFaceColor', [1,0,0]+(1-[1,0,0])*(1-0.15), 'MarkerSize', 8); 

        
        if Design.recall > 0
            c = plot(Design.recall_start+(1:150), fexp(B, 1:150), 'r', 'LineWidth', 2);
            d = plot(Design.recall_start+(1:150), flin(C, 1:150), 'g', 'LineWidth', 2);
        end
        
        xlim([0.5 Design.recall_end+1]); 

        xlabel('Trial Number', 'FontSize', 20), ylabel('Angular Deviation', 'FontSize', 20); box on
        legend([a, b], {'Veridical Feedback Trials', 'Limited Feedback'}, 'Location', 'northeast', 'FontSize', 18);
        
        
        title(all_files{numb}(end-5:end), 'FontSize', 20)
        box off
        
        
        pause(1);
        f1.Position;
                

% related to pausing on each figure to accept it or not
                
        w      = waitforbuttonpress;
        value  = double(get(gcf,'CurrentCharacter'));
                
        while isempty(value)
            w      = waitforbuttonpress;
            value  = double(get(gcf,'CurrentCharacter'));
        end
                
        while ~(value == 32 || value == 27)
            w      = waitforbuttonpress;
            value  = double(get(gcf,'CurrentCharacter'));
        end
                
        if value == 32
            button = 1;
            cntcnt = 0;
            clear xxtotal w 
            while button == 1   % read ginputs until a mouse right-button occurs   
                [xxxxx, yyyyy, button] = ginput(1);
                if button == 1
                    cntcnt             = cntcnt + 1;
                    xxtotal(cntcnt)    = round(xxxxx); 
                    plot(xxxxx, yyyyy, 'ko', 'MarkerEdgeColor', 'w', 'MarkerFaceColor', 'w', 'MarkerSize', 15);
                    fflg = 1;
                end
            end
                    
            if fflg == 1
                fflg = 0;
                for ppp = 1:numel(xxtotal)
                    saved_data{2, set_num{rep}(numb)}{2, loc}{xxtotal(ppp)}.outlier = 1;
                    outlier(xxtotal(ppp)) = 1;
                    save(directory2, 'saved_data');
                end
            end
                    
        end



% saving figure

        if Design.normaliz == 1              
%             saveas(gcf, [directory2(1:end-10), 'LearningCurve_normalized.bmp']);
            saveas(gcf, [directory2(1:end-10), 'LearningCurve_normalized.jpeg']);
%             saveas(gcf, [directory2(1:end-10), 'LearningCurve_normalized.fig']);                 
        else                   
%             saveas(gcf, [directory2(1:end-10), 'LearningCurve.bmp']);
            saveas(gcf, [directory2(1:end-10), 'LearningCurve.jpeg']);
%             saveas(gcf, [directory2(1:end-10), 'LearningCurve.fig']);                
        end

        
% saving data  

        total_depvar(numb, :)               = depvar;
        total_depvar_biascorrected(numb, :) = depvar_biascorrected;
        total_outlier(numb, :)              = outlier;
                
        if Design.recall > 0
            total_fitexp{numb, rep}          = B;
            total_fitlin{numb, rep}          = C;
        end
                
        % total_dist(numb, :)            = dist;
                
        close
        
        %-----
        
        figure(fall);
        
        nexttile;
        
        txt = {'Baseline', 'Training'};
        
        % ideal rotation
        draw_backlines(Design.abr(rep), Design);
        ln       = [.5, Design.baseline_end+.5];
        for i = 1:length(ln)
            xline(ln(i),'--k', txt(i), 'FontSize', 17);
        end

        yline(0,  '--k', {' '}, 'FontSize', 17);

        a = plot(xidx(limf==0), depvar_show(limf==0), 'bo', 'MarkerFaceColor', [0,0,1]+(1-[0,0,1])*(1-0.15), 'MarkerSize', 8);
        b = plot(xidx(limf==1), depvar_show(limf==1), 'ro', 'MarkerFaceColor', [1,0,0]+(1-[1,0,0])*(1-0.15), 'MarkerSize', 8); 

        
        if Design.recall > 0
            c = plot(Design.recall_start+(1:150), fexp(B, 1:150), 'r', 'LineWidth', 2);
            d = plot(Design.recall_start+(1:150), flin(C, 1:150), 'g', 'LineWidth', 2);
        end
        
        xlim([0.5 Design.recall_end+1]); 

        xlabel('Trial Number', 'FontSize', 20), ylabel('Angular Deviation', 'FontSize', 20); box on
%         legend([a, b], {'Veridical Feedback Trials', 'Limited Feedback'}, 'Location', 'north', 'FontSize', 18);
        
        
        title(all_files{numb}(end-5:end), 'FontSize', 20)
        box off

    end
    
    
    for i = 1:size(total_outlier, 2)
           tmp              = total_depvar(total_outlier(:, i) == 0, i);
           tmp(isnan(tmp))  = [];
           meanCond(i)      = mean(tmp);
           semCond(i)       = std(tmp)/sqrt(length(tmp)); 

           tmp                       = total_depvar_biascorrected(total_outlier(:, i) == 0, i);
           tmp(isnan(tmp))           = [];
           meanCond_biasCorrected(i) = mean(tmp);
           semCond_biasCorrected(i)  = std(tmp)/sqrt(length(tmp)); 

    %        tmp             = total_dist(total_outlier(:, i) == 0, i);
    %        tmp(isnan(tmp)) = [];
    %        meandist(i)     = mean(tmp);
    %        SEMdist(i)       = std(tmp)/sqrt(length(tmp)); 

    end

% ====== Distance plot =======

    %     f4 = figure('WindowState','maximized'); hold on,
    %                
    % 
    %             for i = 2:length(ln)
    %                xline(ln(i),'--k', txt(i), 'FontSize', 17);
    %             end
    %             
    %             if normaliz ~= 1
    %                 yline(rotation(rep), '--k', {['g = ', num2str(rotation(rep))]}, 'FontSize', 17);
    %             else
    %                 yline(100, '--k', {['g = ', num2str(100)]}, 'FontSize', 17);
    %             end
    %             
    %             shadedErrorBar(fam+1:baseline_end-nofeedback_baseline, meandist(fam+1:baseline_end-nofeedback_baseline), SEMdist(fam+1:baseline_end-nofeedback_baseline), {'bo', 'MarkerSize', 8}); hold on
    %             shadedErrorBar(baseline_end-nofeedback_baseline+1:baseline_end, meandist(baseline_end-nofeedback_baseline+1:baseline_end), SEMdist(baseline_end-nofeedback_baseline+1:baseline_end), {'ro', 'MarkerSize', 8}); hold on
    %             shadedErrorBar(learning_start:learning_end, meandist(learning_start:learning_end), SEMdist(learning_start:learning_end), {'bo', 'MarkerSize', 8}); hold on
    %             shadedErrorBar(recall_start:recall_end, meandist(recall_start:recall_end), SEMdist(recall_start:recall_end), {'ro', 'MarkerSize', 8}); hold on
    %             
    %             xlim([1 recall_end]);
    %             ylim_curr = get(gca,'ylim');
    % 
    % 
    %             set(gcf,'color','w'); box off
    %             
    %             if abr(rep) == 0
    %                 title(['Mean Distance relative to center over ', num2str(numel(list{rep})), ' Subjects - Condition: ', conditions{rep}], 'FontSize', 20), 
    %             else
    %                 title(['Mean Distance relative to center over ', num2str(numel(list{rep})), ' Subjects - Condition: ', conditions{rep}, '(abrupt)'], 'FontSize', 20), 
    %             end
    %     
    %             
    %             xlabel('Trial Number', 'FontSize', 20), ylabel('Distance relative to center', 'FontSize', 20); box on
    %             grid minor;
    %             
    %             pause(1);
    %             f4.Position;
    %             
    %             saveas(gcf, [directory, '/MeanDist_', conditions{rep}, '_', listname,'.fig']);
    %             saveas(gcf, [directory, '/MeanDist_', conditions{rep}, '_', listname,'.bmp']);
    %             saveas(gcf, [directory, '/MeanDist_', conditions{rep}, '_', listname,'.jpg']);
    %             

    
%         close all

        for i = 1:length(list{rep})
            
            
            if Design.recall > 0

                tmpAll = total_depvar_biascorrected(i, end-Design.recall+1:end);
                outAll = total_outlier(i, end-Design.recall+1:end);
                tmpAll(outAll == 1) = [];
                tmpAll(isnan(tmpAll)) = [];

                if ~isempty(tmpAll)
                    meantmpAll(i, rep) = mean(tmpAll);
                else
                    meantmpAll(i, rep) = NaN;
                end

                tmprecallstart = total_depvar(i, Design.recall_start:Design.recall_start+recallstartmeanlength-1);
                outrecallstart = total_outlier(i, Design.recall_start:Design.recall_start+recallstartmeanlength-1);
                tmprecallstart(outrecallstart == 1) = [];
                tmprecallstart(isnan(tmprecallstart)) = [];

                if ~isempty(tmprecallstart)
                    meantmprecallstart(i, rep) = mean(tmprecallstart);
                else
                    meantmprecallstart(i, rep) = NaN;
                end

                tmp10 = total_depvar_biascorrected(i, end-10+1:end);
                out10 = total_outlier(i, end-10+1:end);
                tmp10(out10 == 1) = [];
                tmp10(isnan(tmp10)) = [];

                if ~isempty(tmp10)
                    mean10(i, rep) = mean(tmp10);
                else
                    mean10(i, rep) = NaN;
                end

                tmp20 = total_depvar_biascorrected(i, end-20+1:end);
                out20 = total_outlier(i, end-20+1:end);
                tmp20(out20 == 1) = [];
                tmp20(isnan(tmp20)) = [];

                if ~isempty(tmp20)
                    mean20(i, rep) = mean(tmp20);
                else
                    mean20(i, rep) = NaN;
                end

                tmp30 = total_depvar_biascorrected(i, end-30+1:end);
                out30 = total_outlier(i, end-30+1:end);
                tmp30(out30 == 1) = [];
                tmp30(isnan(tmp30)) = [];

                if ~isempty(tmp30)
                    mean30(i, rep) = mean(tmp30);
                else
                    mean30(i, rep) = NaN;
                end


                tmp40 = total_depvar_biascorrected(i, end-40+1:end);
                out40 = total_outlier(i, end-40+1:end);
                tmp40(out40 == 1) = [];
                tmp40(isnan(tmp40)) = [];

                if ~isempty(tmp40)
                    mean40(i, rep) = mean(tmp40);
                else
                    mean40(i, rep) = NaN;
                end 

          
            
                tmp0 = total_depvar(i, end-Design.recall+1:end);
                out0 = total_outlier(i, end-Design.recall+1:end);
                tmp0(out0 == 1) = [];
                tmp0(isnan(tmp0)) = [];

                if ~isempty(tmp0)
                    meantmp0(i, rep) = mean(tmp0);
                else
                    meantmp0(i, rep) = NaN;
                end
            
            
                tmp010 = total_depvar(i, end-10+1:end);
                out010 = total_outlier(i, end-10+1:end);
                tmp010(out010 == 1) = [];
                tmp010(isnan(tmp010)) = [];

                if ~isempty(tmp010)
                    mean010(i, rep) = mean(tmp010);
                else
                    mean010(i, rep) = NaN;
                end

                tmp020 = total_depvar(i, end-20+1:end);
                out020 = total_outlier(i, end-20+1:end);
                tmp020(out020 == 1) = [];
                tmp020(isnan(tmp020)) = [];

                if ~isempty(tmp020)
                    mean020(i, rep) = mean(tmp020);
                else
                    mean020(i, rep) = NaN;
                end
            
                tmp030 = total_depvar(i, end-30+1:end);
                out030 = total_outlier(i, end-30+1:end);
                tmp030(out030 == 1) = [];
                tmp030(isnan(tmp030)) = [];

                if ~isempty(tmp030)
                    mean030(i, rep) = mean(tmp030);
                else
                    mean030(i, rep) = NaN;
                end
            
            
                tmp040 = total_depvar(i, end-40+1:end);
                out040 = total_outlier(i, end-40+1:end);
                tmp040(out040 == 1) = [];
                tmp040(isnan(tmp040)) = [];

                if ~isempty(tmp040)
                    mean040(i, rep) = mean(tmp040);
                else
                    mean040(i, rep) = NaN;
                end 
            
            
            end

        end
        
        
        if Design.recall > 0
            M10           = mean10(:, rep);
            M20           = mean20(:, rep);
            M30           = mean30(:, rep);
            M40           = mean40(:, rep);

            M010          = mean010(:, rep);
            M020          = mean020(:, rep);
            M030          = mean030(:, rep);
            M040          = mean040(:, rep);
            
            Mtmp0           = meantmp0(:, rep);
            Mtmpall         = meantmpAll(:, rep);
            Mtmprecallstart = meantmprecallstart(:, rep);
        end
        
        listtt          = list{rep};
        
        
        if Design.normaliz == 1
            if Design.recall > 0
                save([directory, 'savedInfo_MemoryTest_normalized.mat'], 'Design', 'listtt', 'Mtmprecallstart', 'Mtmpall', 'Mtmp0', 'meanCond', 'meanCond_biasCorrected', 'semCond', 'semCond_biasCorrected', 'M10','M20', 'M30', 'M40', 'M010', 'M020', 'M030', 'M040', 'BCaic', 'BCbic', 'decayexp', 'decaylin', 'total_depvar', 'total_depvar_biascorrected', 'total_outlier');
            else
                save([directory, 'savedInfo_MemoryTest_normalized.mat'], 'Design', 'listtt', 'Maftertrnofeed0', 'Mtrnofeed0', 'Mtrnofeed_all', 'Mtrlast0', 'Mtrlast_all', 'meanCond', 'meanCond_biasCorrected', 'semCond', 'semCond_biasCorrected','total_depvar', 'total_depvar_biascorrected', 'total_outlier');
            end
        else  
            if Design.recall > 0
                save([directory, 'savedInfo_MemoryTest.mat'], 'Design', 'listtt', 'Mtmprecallstart', 'Mtmpall', 'Mtmp0', 'meanCond', 'meanCond_biasCorrected', 'semCond', 'semCond_biasCorrected', 'M10','M20', 'M30', 'M40', 'M010', 'M020', 'M030', 'M040', 'BCaic', 'BCbic', 'decayexp', 'decaylin', 'total_depvar', 'total_depvar_biascorrected', 'total_outlier');
            else
                save([directory, 'savedInfo_MemoryTest.mat'], 'Design', 'listtt', 'Maftertrnofeed0', 'Mtrnofeed0', 'Mtrnofeed_all', 'Mtrlast0', 'Mtrlast_all', 'meanCond', 'meanCond_biasCorrected', 'semCond', 'semCond_biasCorrected', 'total_depvar', 'total_depvar_biascorrected', 'total_outlier');
            end    
        end

        clear total_iad_maxv total_iad_maxv_modall total_outlier
        clear semCond semCond_biascorrected  meanCond meanCond_biasCorrected taw fit BCaic BCbic decayexp decaylin

end




%% Functions

function draw_backlines(abr, Design)

nr   = Design.normaliz;
rot  = Design.rotation;
holdd = Design.hold_learning_start;
base = Design.baseline;
l    = Design.learning;

if nr == 1
	rot = 100;
end
    
if abr
	line([1, base+.5], [0, 0], 'color', [0, 0, 0], 'LineWidth', 2); hold on
	line([base+.5, base+l+.5], rot*[1, 1], 'color', [0, 0, 0], 'LineWidth', 2)
	line([base+.5, base+.5], [0, rot], 'color', [0, 0, 0], 'LineWidth', 2)
	line([base+l+.5, base+l+.5], [0, rot], 'color', [0, 0, 0], 'LineWidth', 2)
else
    line([1, base+1], [0, 0], 'color', [0, 0, 0], 'LineWidth', 2); hold on
	plot(base+(1:holdd), (rot/(holdd-1))*(0:holdd-1), 'k', 'LineWidth', 2)
    line([base+holdd, base+l+.5], [rot, rot], 'color', [0, 0, 0], 'LineWidth', 2); hold on
	line([base+l+.5, base+l+.5], [0, rot], 'color', [0, 0, 0], 'LineWidth', 2)
end

end


