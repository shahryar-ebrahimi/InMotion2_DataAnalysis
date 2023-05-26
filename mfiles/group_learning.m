

clc
clear
close

%%


conditions           = {'RecogM1', 'RecogS1', 'RecogSham'};          
conditions_fignames  = {'M1', 'S1', 'Control'};


if numel(conditions) ~= numel(conditions_fignames)
	error('length of "conditions_fignames" and "conditions" must be equal');
end



%% Controlling figure colors and texts

col = [255, 0, 0; 
       0, 0, 255;
       50, 50, 50;]/255;
   
   
textcontrollength = 6;
   

%%

f1 = figure('color','w', 'position', [300, 500, 1000, 500]); hold on,

lgAll = [];
for cond = 1:numel(conditions)
    myFile = load([pwd, '/../data/', conditions{cond}, '/savedInfo.mat']);
    
    nTrial = myFile.Design.totalTrials;
    nbase  = myFile.Design.baseline;
    nlearn = myFile.Design.learning;
    
    avg    = myFile.meanCond;
    sem    = myFile.semCond;
    
    avg_BC = myFile.meanCond_biasCorrected;
    sem_BC = myFile.semCond_biasCorrected;
    
    
    if cond == 1
        draw_backlines(0, myFile.Design);
    end
    
    lg = shadedErrorBar(1:nbase, avg(1:nbase), sem(1:nbase), {'color', col(cond, :)}, 1, 1);
         shadedErrorBar(nbase+1:nTrial, avg(nbase+1:nTrial), sem(nbase+1:nTrial), {'color', col(cond, :)}, 1, 1);
    
    lgAll = [lgAll, lg.patch];
end

figure_axis_set

lgd = legend(lgAll, conditions_fignames, 'Location','northwest', 'FontSize', 18);
lgd.Position = lgd.Position + [0, -0.06, .1, 0];
axis off
legend box off

%%

f2 = figure('color','w', 'position', [300, 500, 1000, 500]); hold on,

lgAll = [];
for cond = 1:numel(conditions)
    myFile = load([pwd, '/../data/', conditions{cond}, '/savedInfo.mat']);
    
    nTrial = myFile.Design.totalTrials;
    nbase  = myFile.Design.baseline;
    nlearn = myFile.Design.learning;
    
    nfb_trials = myFile.Design.nofeedback_baseline;
    nfl_trials = myFile.Design.nofeedback_learning;
    
    avg    = myFile.meanCond_nofeedback;
    sem    = myFile.semCond_nofeedback;
    
    avg_BC = myFile.meanCond_biasCorrected_nofeedback;
    sem_BC = myFile.semCond_biasCorrected_nofeedback;
    
    
    TrBase(:, cond) = myFile.MtmpbaselineEnd;
    TrLast(:, cond) = myFile.Mtrlast;
    
    TrBase_nf(:, cond) = myFile.Mtrnofeed_baseline;
    TrLast_nf(:, cond) = myFile.Mtrnofeed;
    
    nList(cond) = numel(myFile.listtt);
    
    if cond == 1
        draw_backlines(0, myFile.Design);
    end
    
    lg = shadedErrorBar(nfb_trials, avg(1:numel(nfb_trials)), sem(1:numel(nfb_trials)), {'color', col(cond, :)}, 1, 1);
         shadedErrorBar(nfl_trials+nbase, avg(numel(nfb_trials)+1:end), sem(numel(nfb_trials)+1:end), {'color', col(cond, :)}, 1, 1);
    
    lgAll = [lgAll, lg.patch];
end

figure_axis_set

lgd = legend(lgAll, conditions_fignames, 'Location','northwest', 'FontSize', 18);
lgd.Position = lgd.Position + [0, -0.06, .1, 0];
axis off
legend box off


%%

f3 = figure('color','w', 'position', [300, 500, 1000, 500]); hold on,

MTrBase = mean(TrBase);
MTrLast = mean(TrLast);

b = bar([MTrBase', MTrLast'], .9, ...
            'FaceColor','flat', 'EdgeColor','flat'); hold on


    for i = 1:length(conditions_fignames)
        for k = 1:2
            
            
            
            b(1).CData(i,:) = col(i, :)+(1-col(i, :))*0.8;
            b(2).CData(i,:) = col(i, :)+(1-col(i, :))*0.6;
            
            b(k).BaseLine.Color = 'white';
            
            clrt2 = col(i, :)+(1-col(i, :))*0.75;
            clrt = col(i, :)+(1-col(i, :))*0.55;
            
            clrsem2 = col(i, :)+(1-col(i, :))*0.5;
            clrsem = col(i, :)+(1-col(i, :))*0.3;
            
            
            SemTrBase(i) = std(TrBase(:, i))/sqrt(nList(i));
            SemTrLast(i) = std(TrLast(:, i))/sqrt(nList(i));

            
            if k == 1
                
                errorbar(i+0.14, MTrLast(i), SemTrLast(i), 'color', clrsem, ...
                    'LineWidth', 3, 'LineStyle', 'none'); hold on; 
                scatter(i+.08+.15*rand(1, nList(i)), TrLast(1:nList(i), i), ...
                    'MarkerEdgeColor', col(i, :), 'MarkerFaceColor', clrt,'SizeData',60, 'MarkerFaceAlpha', 0.7); hold on
                
            else
                
                errorbar(i-0.14, MTrBase(i), SemTrBase(i), 'color', clrsem, ...
                    'LineWidth', 3, 'LineStyle', 'none'); hold on;
                scatter(i-.22+.15*rand(1, nList(i)), TrBase(1:nList(i), i), ...
                    'MarkerEdgeColor', col(i, :), 'MarkerFaceColor', clrt2,'SizeData',60, 'MarkerFaceAlpha', 0.7); hold on
            end

        end
    end

figure_axis_set_2



%%

f4 = figure('color','w', 'position', [300, 500, 1000, 500]); hold on,

MTrBase_nf = mean(TrBase_nf);
MTrLast_nf = mean(TrLast_nf);

b = bar([MTrBase_nf', MTrLast_nf'], .9, ...
            'FaceColor','flat', 'EdgeColor','flat'); hold on


    for i = 1:length(conditions_fignames)
        for k = 1:2
            
            
            
            b(1).CData(i,:) = col(i, :)+(1-col(i, :))*0.8;
            b(2).CData(i,:) = col(i, :)+(1-col(i, :))*0.6;
            
            b(k).BaseLine.Color = 'white';
            
            clrt2 = col(i, :)+(1-col(i, :))*0.75;
            clrt = col(i, :)+(1-col(i, :))*0.55;
            
            clrsem2 = col(i, :)+(1-col(i, :))*0.5;
            clrsem = col(i, :)+(1-col(i, :))*0.3;
            
            
            SemTrBase_nf(i) = std(TrBase_nf(:, i))/sqrt(nList(i));
            SemTrLast_nf(i) = std(TrLast_nf(:, i))/sqrt(nList(i));

            
            if k == 1
                
                errorbar(i+0.14, MTrLast_nf(i), SemTrLast_nf(i), 'color', clrsem, ...
                    'LineWidth', 3, 'LineStyle', 'none'); hold on; 
                scatter(i+.08+.15*rand(1, nList(i)), TrLast_nf(1:nList(i), i), ...
                    'MarkerEdgeColor', col(i, :), 'MarkerFaceColor', clrt,'SizeData',60, 'MarkerFaceAlpha', 0.7); hold on
                
            else
                
                errorbar(i-0.14, MTrBase_nf(i), SemTrBase_nf(i), 'color', clrsem, ...
                    'LineWidth', 3, 'LineStyle', 'none'); hold on;
                scatter(i-.22+.15*rand(1, nList(i)), TrBase_nf(1:nList(i), i), ...
                    'MarkerEdgeColor', col(i, :), 'MarkerFaceColor', clrt2,'SizeData',60, 'MarkerFaceAlpha', 0.7); hold on
            end

        end
    end

figure_axis_set_2



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






function figure_axis_set

    x_loc      = -5;
    x_begin    = 1;
    x_end      = 180;
    x_tip_adj  = .3;
    x_ticks    = [1, 31, 180];
    x_tickLen  = 1;
    x_tick_adj = 1.5;
    x_title    = 'Trial Number';
    x_title_s  = 25;
    x_title_adj = 5;
    xlimit     = [-10, 181];

    y_loc      = -5;
    y_begin    = 0;
    y_end      = 30;
    y_tip_adj  = .1;
    y_ticks    = [0, 5, 10, 15, 20, 25, 30];
    y_tickLen  = 2;
    y_tick_adj = 4;
    y_title    = {'\fontsize{25} Movement Direction (deg)'};
    y_title_adj = 17;
    ylimit     = [-10, 35];


    xy_width       = 2;
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
                        'HorizontalAlignment','center');
    end


    text(x_title_loc(1), x_title_loc(2), x_title, 'FontSize', x_title_s, ...
        'HorizontalAlignment','center');

    ht = text(y_title_loc(1), y_title_loc(2), y_title, ...
            'HorizontalAlignment','center');

    set(ht,'Rotation',90);

    xlim(xlimit);
    ylim(ylimit);
    
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
    y_title    = {'\fontsize{30}Baseline vs. Learned', '\fontsize{30}(deg)'};
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