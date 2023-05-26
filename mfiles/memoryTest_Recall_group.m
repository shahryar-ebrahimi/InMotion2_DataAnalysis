

clc
clear
close

%%


conditions           = {'RecallS1'};          
conditions_fignames  = {'Recall S1'};

% list of subjects you want to include in your condition. (it should be a cell of vectors if you have more than one condition)
list                 = {1:5};

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
   

%%

f1 = figure('color','w', 'position', [300, 500, 1000, 500]); hold on,

lgAll = [];
for cond = 1:numel(conditions)
    myFile = load([pwd, '/../data/', conditions{cond}, '/savedInfo_MemoryTest.mat']);
    
    nTrial = myFile.Design.totalTrials;
    nbase  = myFile.Design.baseline;
    nlearn = myFile.Design.learning;
    
    avg    = myFile.meanCond;
    sem    = myFile.semCond;
    
    avg_BC = myFile.meanCond_biasCorrected;
    sem_BC = myFile.semCond_biasCorrected;
    
    
    if cond == 1
        draw_backlines(1, myFile.Design);
    end
    
    lg = shadedErrorBar(1:nbase, avg(1:nbase), sem(1:nbase), {'color', col(cond, :)}, 1, 1);
         shadedErrorBar(nbase+1:nTrial, avg(nbase+1:nTrial), sem(nbase+1:nTrial), {'color', col(cond, :)}, 1, 1);
    
    lgAll = [lgAll, lg.patch];
end

figure_axis_set

legend(lgAll, conditions_fignames,'Location','north', 'FontSize', 18)
axis off
legend box off



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
    x_end      = 175;
    x_tip_adj  = .3;
    x_ticks    = [1, 25, 175];
    x_tickLen  = 1;
    x_tick_adj = 1.5;
    x_title    = 'Trial Number';
    x_title_s  = 25;
    x_title_adj = 5;
    xlimit     = [-10, 175];

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