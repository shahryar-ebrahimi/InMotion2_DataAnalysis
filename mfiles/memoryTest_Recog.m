
clc
clear
close all

%%


conditions = {'RecogM1', 'RecogS1' 'RecogSham' 'RecallS1', 'RecallM1'}; 
conditions_fignames  = {' Recog M1', 'Recog S1', 'Recog Control', 'Recall S1', 'Recall M1'};
recogList  = [1, 1, 1, 0, 0];

list    = {1:10, 1:10, 1:10, 1:5, 1:3};

% window length and number of bins
bin_max = 10;

%%

gauss_func  = @(x, a1, b1, c1) a1*exp(-((x-b1)/c1).^2);

%%

col = [255, 0, 0; 
       0, 0, 255;
       50, 50, 50;
       252, 138, 50;
       0, 255, 0]/255;
   
%%

lgAll = [];
repnew1 = 0;
repnew2 = 0;

for rep = 1:length(conditions)

        target     = conditions{rep};
        directory  = [pwd, '/../data/', target];

        all_files  = dir([directory, '/', target(1:2),'*']);
        all_files  = struct2cell(all_files([all_files(:).isdir]));
        all_files  = all_files(1, :);

        clear chk
        for mvgt = 1:numel(list{rep})
            chk{mvgt} = [conditions{rep}, '_Sub00', num2str(list{rep}(mvgt))];
            if list{rep}(mvgt) >= 10
                chk{mvgt} = [conditions{rep}, '_Sub0', num2str(list{rep}(mvgt))];
            end
        end

        files = intersect(chk, all_files);

        % determine figure shape
        f1 = figure('color', 'w');
        f2 = figure('color', 'w');

        if recogList(rep)
        
        repnew1 = repnew1 + 1;
        for numb = 1:numel(files)

            if numb >= 10
                SN{numb} = ['Sub0', num2str(numb)]; %num2str(list{rep}(numb))
            else
                SN{numb} = ['Sub00', num2str(numb)];
            end

            directory1 = [directory, '/', files{numb}];
            fileName   = dir([directory1, '/*yesno.json']).name;

            str        = fileread([directory1, '/', fileName]);   % dedicated for reading files as text 
            data       = jsondecode(str);      % Using the jsondecode function to parse JSON from string 


            for i = 1:numel(data)
                direction(i) = data(i).direction;
                answer(i)    = data(i).answer(1);
            end

            direction_set = unique(direction);
            dir_sampled   = direction_set(1)-20:.01:direction_set(end);

            for i = 1:numel(direction_set)
                idx                   = find(direction == direction_set(i));
                dir_ans               = answer(idx);
                dir_probYes(numb, i)  = 100*sum(dir_ans == 'y')/numel(idx);   
            end


            % 3-step Fitting
            % ====================================
            % estimating mean

                dir_tmp = dir_probYes(numb, :);
                maxInd  = max(dir_tmp);
                mu      = mean(direction_set(dir_tmp == maxInd));

                initial_sigma = 3;

                fo    = fitoptions('gauss1', 'lower',[0, -Inf sqrt(2)*initial_sigma],'upper',[100, Inf, sqrt(2)*initial_sigma]);
                fitt1 = fit(direction_set', dir_probYes(numb, :)', 'gauss1', fo);

                % forcing mean and amplitude and estimating std
                fo   = fitoptions('gauss1', 'lower',[fitt1.a1, fitt1.b1 0],'upper',[fitt1.a1, fitt1.b1, Inf]);
                fitt2 = fit(direction_set', dir_probYes(numb, :)', 'gauss1', fo);

                % forcing std and estimating mean and amplitude
                fo   = fitoptions('gauss1', 'lower',[0, -Inf fitt2.c1],'upper',[100, Inf, fitt2.c1]);
                fitt3 = fit(direction_set', dir_probYes(numb, :)', 'gauss1', fo);

                data_fit_all{repnew1}(numb, :) = gauss_func(dir_sampled, fitt3.a1, fitt3.b1, fitt3.c1);

            % ====================================
            % plotting individual raw and fit data (gaussian fits)

                figure(f1);
                nexttile;
                plot(direction_set, dir_probYes(numb, :), 'o', 'MarkerEdgeColor', col(repnew1, :),'MarkerFaceColor', col(repnew1, :)+(1-col(repnew1, :))*0.7, 'MarkerSize', 10); hold on
                plot(dir_sampled, gauss_func(dir_sampled, fitt3.a1, fitt3.b1, fitt3.c1), 'color', [0, 0.4470, 0.7410], 'LineWidth', 1.5);
                set(gca,'linewidth',2.6)
                set(gca, 'FontSize',18)

                title(SN{numb}, 'FontSize', 15);

                box off

            % ====================================

                [~, idxxx] = max(data_fit_all{repnew1}(numb, :));
                Mean_overall{repnew1}(numb) = dir_sampled(idxxx);

        end
        
        sgtitle(['Overall IND - ', conditions_fignames{rep}])

        sem_fit{repnew1}   = std(data_fit_all{repnew1}, 0, 1)/sqrt(numel(files));
        mean_fit{repnew1}  = mean(data_fit_all{repnew1}, 1);



            clear dir_probYes
            step = numel(direction_set);
            wl   = numel(direction) - step*(bin_max-1);

            for bin = 1:bin_max
                for numb = 1:numel(list{rep})

                    directory1 = [directory, '/', files{numb}];
                    fileName = dir([directory1, '/*yesno.json']).name;

                    str        = fileread([directory1, '/', fileName]);   % dedicated for reading files as text 
                    data       = jsondecode(str);      % Using the jsondecode function to parse JSON from string 


                    for i = 1:numel(data)
                        direction(i) = data(i).direction;
                        answer(i)    = data(i).answer(1);
                    end

                    direction_wl = direction(step*(bin-1)+1:step*(bin-1)+wl);
                    answer_wl    = answer(step*(bin-1)+1:step*(bin-1)+wl);

                    for i = 1:numel(direction_set)
                        idx                        = find(direction_wl == direction_set(i));
                        dir_ans                    = answer_wl(idx);
                        dir_probYes(numb, i, bin)  = 100*sum(dir_ans == 'y')/numel(idx);   
                    end


                % 3-step Fitting
                % ====================================
                % estimating mean
                fo   = fitoptions('gauss1', 'lower',[0, -35 sqrt(2)*initial_sigma],'upper',[100, 35, sqrt(2)*initial_sigma]);
                fitt = fit(direction_set', squeeze(dir_probYes(numb, :, bin))', 'gauss1', fo);

                % forcing mean and amplitude and estimating std
                fo   = fitoptions('gauss1', 'lower',[fitt.a1, fitt.b1 0],'upper',[fitt.a1, fitt.b1, Inf]);
                fitt = fit(direction_set', squeeze(dir_probYes(numb, :, bin))', 'gauss1', fo);

                % forcing std and estimating mean and amplitude
                fo   = fitoptions('gauss1', 'lower',[0, -35 fitt.c1],'upper',[100, 35, fitt.c1]);
                fitt = fit(direction_set', squeeze(dir_probYes(numb, :, bin))', 'gauss1', fo);

                data_fit_bin{repnew1}(numb, :, bin) = gauss_func(dir_sampled, fitt.a1, fitt.b1, fitt.c1);

                % ====================================

                end

                clear dir_probYes

            end



            for i = 1:size(data_fit_bin{repnew1}, 1)
                for j = 1:size(data_fit_bin{repnew1}, 3)
                    [~, idx_max] = max(data_fit_bin{repnew1}(i, :, j));
                    IND{repnew1}(i, j)    = dir_sampled(idx_max);
                end

                % ====================================
                % plotting individual binned data

                figure(f2);
                nexttile;
                plot(0:bin_max-1, IND{repnew1}(i, :), 'o', 'MarkerEdgeColor', col(repnew1, :),'MarkerFaceColor', col(repnew1, :)+(1-col(repnew1, :))*0.7, 'MarkerSize', 10); hold on
                plot(0:bin_max-1, IND{repnew1}(i, :), 'color', [0, 0.4470, 0.7410], 'LineWidth', 1.5);
                ylim([-5, 30])
                set(gca,'linewidth',2.6)
                set(gca, 'FontSize',18)
                box off

                title(SN{i}, 'FontSize', 15);

            end
            
            sgtitle(['Binned IND - ', conditions_fignames{rep}])
            
            sem_max{rep}    = std(IND{repnew1})/sqrt(numel(list{repnew1}));
            mean_max{rep}   = mean(IND{repnew1});
        
        else

            repnew2 = repnew2 + 1;
        
            myFile = load([pwd, '/../data/', conditions{rep}, '/savedInfo_MemoryTest.mat']);

            nlearn = myFile.Design.recall;

            avg{rep}    = myFile.meanCond;
            sem{rep}    = myFile.semCond;

            avg_BC = myFile.meanCond_biasCorrected;
            sem_BC = myFile.semCond_biasCorrected;

            if repnew1 == 1
                draw_backlines(1, myFile.Design);
            end

            for numb = 1:1:numel(files)
                
                depvar = myFile.total_depvar(numb, :);
                out    = myFile.total_outlier(numb, :);
                
                for bin = 1:bin_max
                    depvartmp = depvar(step*(bin-1)+1:step*(bin-1)+wl);
                    outtmp    = out(step*(bin-1)+1:step*(bin-1)+wl);
                    
                    depvarbin{repnew2}(numb, bin) = mean(depvartmp(outtmp == 0));
                end
            end
            
            
%             lg = shadedErrorBar(1:nlearn, avg{rep}(1:nlearn), sem{rep}(1:nlearn), {'color', col(rep, :)}, 1, 1);

%             lgAll = [lgAll, lg.patch];
            

            %figure_axis_set

            legend(lgAll, conditions_fignames,'Location','northwest', 'FontSize', 18)
            %axis off
            legend box off

    
        end
    
    
    


        
end
    

%% Overall Gaussian Fit

figure('color', 'w', 'Position', [400, 250, 800, 600]);

haAll = [];
for rep = 1:numel(conditions(recogList == 1))
	ha1   = shadedErrorBar(dir_sampled, mean_fit{rep}, sem_fit{rep}, {'color', col(rep, :), 'LineWidth', 1}, 1, 1); hold on
    haAll = [haAll, ha1.patch];
end

set(gca,'FontSize',18)
set(gca,'linewidth',2)
box off
        
   
axis off
    
clear data

    x_loc      = -5;
    x_begin    = -30;
    x_end      = 40;
    x_tip_adj  = .1;
    x_ticks    = -30:10:40;
    x_tickLen  = 3;
    x_tick_adj = 4;
    x_title    = 'Direction (deg)';
    x_title_s  = 25;
    x_title_adj = 17;
    xlimit     = [-35, 40];

    y_loc      = -32;
    y_begin    = 0;
    y_end      = 100;
    y_tip_adj  = 0.4;
    y_ticks    = 0:20:100;
    y_tickLen  = 1;
    y_tick_adj = 0.3;
    y_title    = "\fontsize{25}Probablity of 'YES'";
    y_title_adj = 7;
    ylimit     = [-10, 120];


    xy_width       = 3;
    xy_tick_fontS  = 20;



    x_title_loc = [mean([x_begin, x_end]), x_loc-x_title_adj];
    y_title_loc = [y_loc-y_title_adj, mean([y_begin, y_end])];

    line([x_begin-x_tip_adj, x_end+x_tip_adj]  , [x_loc, x_loc], 'color', 'k', 'LineWidth', xy_width);
    line([y_loc, y_loc], [y_begin-y_tip_adj, y_end+y_tip_adj], 'color', 'k', 'LineWidth', xy_width);

    for i = 1:numel(x_ticks)
        line([x_ticks(i), x_ticks(i)], [x_loc, x_loc-x_tickLen], 'color', 'k', 'LineWidth', xy_width); 
        text(x_ticks(i), x_loc-x_tickLen-x_tick_adj, num2str(x_ticks(i)), 'FontSize', xy_tick_fontS, ...
                        'HorizontalAlignment','center');
    end

    for i = 1:numel(y_ticks)
        line([y_loc, y_loc-y_tickLen], [y_ticks(i), y_ticks(i)], 'color', 'k', 'LineWidth', xy_width); 
        text(y_loc-y_tickLen-y_tick_adj, y_ticks(i), num2str(y_ticks(i)), 'FontSize', xy_tick_fontS, ...
                        'HorizontalAlignment','right');
    end


    text(x_title_loc(1), x_title_loc(2), x_title, 'FontSize', x_title_s, ...
        'HorizontalAlignment','center');

    ht = text(y_title_loc(1), y_title_loc(2), y_title, ...
            'HorizontalAlignment','center');

    set(ht,'Rotation',90);

    xlim(xlimit);
    ylim(ylimit);
    
        
lgd = legend(haAll, conditions_fignames(recogList==1), 'Location', 'north', 'Orientation','horizontal');
lgd.Position = lgd.Position + [0, 0, 0, 0];
legend boxoff  

%%

figure('color','w', 'position', [300, 500, 1000, 600]); hold on,

for rep = 1:numel(conditions(recogList == 1))
    for ind = 1:numel(list{rep})
    
        [~, idx_tmp]             = max(data_fit_all{rep}(ind, :));
        dir_ind(ind, rep)        = dir_sampled(idx_tmp); 
    end
    
	[~, idx_tmp]    = max(mean_fit{rep});
	dir_avg(rep)    = dir_sampled(idx_tmp);
    
end

Mdir_ind = mean(dir_ind);

b = bar([dir_avg', Mdir_ind'], .9, ...
            'FaceColor','flat', 'EdgeColor','flat'); hold on

    for i = 1:sum(recogList)
        for k = 1:2
            
            
            
            b(1).CData(i,:) = col(i, :)+(1-col(i, :))*0.8;
            b(2).CData(i,:) = col(i, :)+(1-col(i, :))*0.6;
            
            b(k).BaseLine.Color = 'white';
            
            clrt2 = col(i, :)+(1-col(i, :))*0.75;
            clrt = col(i, :)+(1-col(i, :))*0.55;
            
            clrsem2 = col(i, :)+(1-col(i, :))*0.5;
            clrsem = col(i, :)+(1-col(i, :))*0.3;
            
            SemInd(i) = std(dir_ind(:, i))/sqrt(numel(list{i}));
            
            if k == 1
                
                errorbar(i+0.14, Mdir_ind(i), SemInd(i), 'color', clrsem, ...
                    'LineWidth', 3, 'LineStyle', 'none'); hold on; 
                scatter(i+.08+.15*rand(1, numel(list{i})), dir_ind(1:numel(list{i}), i), ...
                    'MarkerEdgeColor', col(i, :), 'MarkerFaceColor', clrt,'SizeData',60, 'MarkerFaceAlpha', 0.7); hold on
                
            end

        end
    end

figure_axis_set_2


for i = 1:repnew2
    depvarbin_mean{i} = mean(depvarbin{i});
    depvarbin_sem{i}  = std(depvarbin{i})/sqrt(size(depvarbin{i}, 1)); 
end


%% recog only


f2 = figure('Position', [400, 250, 700, 450], 'color', 'w');      

haAll = [];
nexttile
for rep = 1:repnew1
	ha2   = shadedErrorBar(0:bin_max-1, mean_max{rep}, sem_max{rep}, {'color', col(rep, :), 'LineWidth', 1}, 1, 1); hold on    
    haAll = [haAll, ha2.patch];
    
end  
    
    ylabel('\fontsize{22}Remembered Direction (deg)')
	xlabel({'\fontsize{22}Bin Number'})
    
	set(gca,'FontSize',18)
	set(gca,'linewidth',2)
       
    lgd1 = legend(haAll, conditions_fignames(1:repnew1), 'Location', 'northoutside', 'Orientation','horizontal');
    lgd1.Position = lgd1.Position + [0, 0, 0, 0];
    legend boxoff  

	box off
    xlim([0, bin_max-1])
	ylim([-5, 25])
    
    %SeparateAxes
    
    xticklabels({'1','2','3','4','5','6','7', '8', '9', '10'})

    
    
%% recall only


f2 = figure('Position', [400, 250, 700, 450], 'color', 'w');      

haAll = [];
nexttile
for rep = 1:repnew2
	ha2   = shadedErrorBar(0:bin_max-1, depvarbin_mean{rep}, depvarbin_sem{rep}, {'color', col(repnew1+rep, :), 'LineWidth', 1}, 1, 1); hold on
    haAll = [haAll, ha2.patch];
end  
    
    ylabel('\fontsize{22}Remembered Direction (deg)')
	xlabel({'\fontsize{22}Bin Number'})
    
	set(gca,'FontSize',18)
	set(gca,'linewidth',2)
       
    lgd1 = legend(haAll, conditions_fignames(repnew1+1:end), 'Location', 'northoutside', 'Orientation','horizontal');
    lgd1.Position = lgd1.Position + [0, 0, 0, 0];
    legend boxoff  

	box off
    xlim([0, bin_max-1])
	ylim([-5, 25])
    
    %SeparateAxes
    
    xticklabels({'1','2','3','4','5','6','7', '8', '9', '10'})

    
%% all

f1 = figure('Position', [400, 250, 700, 450], 'color', 'w');      

haAll = [];
nexttile
for rep = 1:numel(conditions)
    
    if recogList(rep)
        ha2   = shadedErrorBar(0:bin_max-1, mean_max{rep}, sem_max{rep}, {'color', col(rep, :), 'LineWidth', 1}, 1, 1); hold on    
    else
        %ha2   = shadedErrorBar(linspace(0, bin_max-1, 162), avg{rep}, sem{rep}, {'color', col(rep, :), 'LineWidth', 1}, 1, 1); hold on
        ha2   = shadedErrorBar(0:bin_max-1, depvarbin_mean{rep-repnew1}, depvarbin_sem{rep-repnew1}, {'color', col(rep, :), 'LineWidth', 1}, 1, 1); hold on
        
    end
	
    haAll = [haAll, ha2.patch];
    
    
    
    ylabel('\fontsize{22}Remembered Direction (deg)')
	xlabel({'\fontsize{22}Bin Number'})
    
	set(gca,'FontSize',18)
	set(gca,'linewidth',2)
       
    lgd = legend(haAll, conditions_fignames, 'Location', 'northoutside', 'Orientation','horizontal');
    lgd.Position = lgd.Position + [0, 0, 0, 0];
    legend boxoff  

	box off
    xlim([0, bin_max-1])
	ylim([-5, 25])
    
    SeparateAxes
    
    xticklabels({'1','2','3','4','5','6','7', '8', '9', '10'})
    
end       
        




%% Functions

function draw_backlines(abr, Design)

nr   = Design.normaliz;
rot  = Design.rotation;
holdd = Design.hold_learning_start;
base = Design.baseline;
l    = Design.learning;

LW1  = 1;

if nr == 1
	rot = 100;
end
    
if abr
	line([1, base+.5], [0, 0], 'color', [0, 0, 0], 'LineWidth', LW1); hold on
	line([base+.5, base+l+.5], rot*[1, 1], 'color', [0, 0, 0], 'LineWidth', LW1)
	line([base+.5, base+.5], [0, rot], 'color', [0, 0, 0], 'LineWidth', LW1)
	line([base+l+.5, base+l+.5], [0, rot], 'color', [0, 0, 0], 'LineWidth', LW1)
else
    line([1, base+1], [0, 0], 'color', [0, 0, 0], 'LineWidth', LW1); hold on
	plot(base+(1:holdd), (rot/(holdd-1))*(0:holdd-1), 'k', 'LineWidth', LW1)
    line([base+holdd, base+l+.5], [rot, rot], 'color', [0, 0, 0], 'LineWidth', LW1); hold on
	line([base+l+.5, base+l+.5], [0, rot], 'color', [0, 0, 0], 'LineWidth', LW1)
end

end




function figure_axis_set_2

    set(gca,'FontSize',18)
    set(gca,'linewidth',2)
    box off

    set(gcf,'color','w');
    legend off
    axis off
    
    x_loc      = -5;
    x_begin    = .7;
    x_end      = 3.3;
    x_tip_adj  = .03;
    x_ticks    = 1:3;
    x_ticks_label = {'M1', 'S1', 'Control'};
                     
    x_tickLen  = 1;
    x_tick_adj = 2;
    x_title    = 'Conditions';
    x_title_s  = 30;
    x_title_adj = 8;
    xlimit     = [-.5, 4];

    y_loc      = 0.5;
    y_begin    = 0;
    y_end      = 30;
    y_tip_adj  = .1;
    y_ticks    = [0, 10, 20, 30];
    y_tickLen  = .06;
    y_tick_adj = 0.02;
    y_title    = {'\fontsize{30}Remembered Direction', '\fontsize{30}(deg)'};
    y_title_adj = .55;
    ylimit     = [-10, 35];


    xy_width       = 3;
    xy_tick_fontS  = 25;



    x_title_loc = [mean([x_begin, x_end]), x_loc-x_title_adj];
    y_title_loc = [y_loc-y_title_adj, mean([y_begin, y_end])];

    line([x_begin-x_tip_adj, x_end+x_tip_adj]  , [x_loc, x_loc], 'color', 'k', 'LineWidth', xy_width);
    line([y_loc, y_loc], [y_begin-y_tip_adj, y_end+y_tip_adj], 'color', 'k', 'LineWidth', xy_width);

    for i = 1:numel(x_ticks)
        line([x_ticks(i), x_ticks(i)], [x_loc, x_loc-x_tickLen], 'color', 'k', 'LineWidth', xy_width); 
        text(x_ticks(i), x_loc-x_tickLen-x_tick_adj, x_ticks_label{i}, 'FontSize', xy_tick_fontS, ...
                        'HorizontalAlignment','center');
    end

    for i = 1:numel(y_ticks)
        line([y_loc, y_loc-y_tickLen], [y_ticks(i), y_ticks(i)], 'color', 'k', 'LineWidth', xy_width); 
        text(y_loc-y_tickLen-y_tick_adj, y_ticks(i), num2str(y_ticks(i)), 'FontSize', xy_tick_fontS, ...
                        'HorizontalAlignment','right');
    end


    text(x_title_loc(1), x_title_loc(2), x_title, 'FontSize', x_title_s, ...
        'HorizontalAlignment','center');

    ht = text(y_title_loc(1), y_title_loc(2), y_title, ...
            'HorizontalAlignment','center');

    set(ht,'Rotation',90);

    xlim(xlimit);
    ylim(ylimit);

end


