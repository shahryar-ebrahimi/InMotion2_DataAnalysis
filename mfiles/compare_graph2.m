
function f = compare_graph2(x, y1, y2, sem1, sem2, tmp1, tmp2, list, conditions_fignames, col, type, holded, learning_start, learning_end, titlee, flg, norm, shft, legend_order, meantmprecallstart)



if norm == 1
    txtt = '%';
else
    txtt = 'deg';
end

ck    = .6*[1, 1, 1];


f = figure('color', 'w', 'Position', [400, 250, 1000, 700]);
% subplot(2, 2, 1)


if strcmp(type, 'recall')

    aa = [];
    xx = numel(x{1});
    for i = 1:length(conditions_fignames)
        aaa =  shadedErrorBar(x{i}+shft(i), y1{i}(x{i}), sem1{i}(x{i}), {'-', 'color', col(i, :),'MarkerSize', 8}, 1, flg, 0, {'single', 45, 15, 1});
        aa  = [aa, aaa.patch];
        hold on
        if numel(x{i}) > xx
            xx = numel(x{i});
        end
    end
    


    if norm ~= 1
        if numel(conditions_fignames) == 4, ylim([5, 30]); else, ylim([-10, 35]); end
    else
        if numel(conditions_fignames) == 4, ylim([15, 100]); else, ylim([-20, 100]); end
    end
    
    
    xlim([learning_end, learning_end+xx]);
    %xlim([learning_end, learning_end+25])
    
else
    
    if norm == 1
        line([learning_start, holded], [0, 100], 'LineWidth', 1.5, 'color', ck); hold on
        line([holded, learning_end], [100, 100], 'LineWidth', 1.5, 'color', ck); hold on
    else
        line([learning_start, holded], [0, 15], 'LineWidth', 1.5, 'color', ck); hold on
        line([holded, learning_end], [15, 15], 'LineWidth', 1.5, 'color', ck); hold on
        
%         line([learning_start, holded], [0, 30], 'LineWidth', 1.5, 'color', ck); hold on
%         line([holded, learning_end], [30, 30], 'LineWidth', 1.5, 'color', ck); hold on
    end
    
    line([1, 190], [0, 0], 'LineWidth', 1.5, 'color', ck); hold on
        
    for i = 1:length(conditions_fignames)
        shadedErrorBar(x{1}, y1{i}(x{1}), sem1{i}(x{1}), {'-', 'color', col(i, :),'MarkerSize', 8, 'LineWidth', 0.1}, 1, flg);
        hold on
    end
    aa = [];
    for i = 1:length(conditions_fignames)
        aaa =  shadedErrorBar(x{2}, y1{i}(x{2}), sem1{i}(x{2}), {'-', 'color', col(i, :),'MarkerSize', 8, 'LineWidth', 0.1}, 1, flg);
        aa  = [aa, aaa.patch];
        hold on
    end
    
    xlim([0, 197]);
    
    if norm ~= 1
        ylim([-5, 20]);
    else
        ylim([-20, 135]);
    end
    
end



hold on

for i = 1:length(conditions_fignames) 
    nanfinder1 = tmp1(1:numel(list{i}), i);
    nanfinder1 = nanfinder1(~isnan(nanfinder1));
    
    meanall_data(i) = mean(nanfinder1);
    semall_data(i)  = std(nanfinder1)/sqrt(numel(nanfinder1));
    
    nanfinder2 = tmp2(1:numel(list{i}), i);
    nanfinder2 = nanfinder2(~isnan(nanfinder2));
    
    mean0_data(i) = mean(nanfinder2);
    sem0_data(i)  = std(nanfinder2)/sqrt(numel(nanfinder2));
end

if ~strcmp(type, 'recall')
    axii = [195, 197, 195, 197, 195, 197];
    for i = 1:length(conditions_fignames) 
            clrrr = col(i, :)+(1-col(i, :))*0.55;
            plot(axii(i), mean0_data(i), '.', 'MarkerSize', 30, 'MarkerFaceColor', clrrr, 'MarkerEdgeColor', clrrr); hold on; 
            errorbar(axii(i), mean0_data(i), sem0_data(i), 'color', clrrr, 'LineWidth', 3, 'LineStyle', 'none'); hold on; 
    end
end   

set(gca,'FontSize',25)
set(gca,'linewidth',3)
axis off
box off


title([titlee, ' - Bias Uncorrected'], 'Units', 'normalized', 'Position', [1.4, 1.1, 0], 'FontSize', 17)
xlabel('Trial Number', 'FontSize', 40);
ylabel({['\fontsize{40}Hand Direction (', txtt,')']; ...
        '\fontsize{30}counter-clockwise'; '\fontsize{30}from body midline'})

    

    
    %% new bar
    
    
    
    
    
    
    
    
    
    
    
    

%%

if strcmp(type, 'recall')

    x_loc      = -5;
    x_begin    = 191;
    x_end      = 340;
    x_tip_adj  = .3;
    x_ticks    = [191, 215, 240, 265, 290, 315, 340];
    x_tickLen  = 1;
    x_tick_adj = 1.5;
    x_title    = 'Trial Number';
    x_title_s  = 30;
    x_title_adj = 5;
    xlimit     = [175, 346];

    y_loc      = 185;
    y_begin    = 0;
    y_end      = 30;
    y_tip_adj  = .1;
    y_ticks    = [0, 5, 10, 15, 20, 25, 30];
    y_tickLen  = 3;
    y_tick_adj = 4;
    y_title    = {'\fontsize{30}Remembered Direction (deg)', ...
                    '\fontsize{27}counter-clockwise', '\fontsize{27}from body midline'};
    y_title_adj = 26;
    ylimit     = [-10, 35];


    xy_width       = 3;
    xy_tick_fontS  = 25;


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
    
    
else

    x_loc      = -2;
    x_begin    = 1;
    x_end      = 190;
    x_tip_adj  = .3;
    x_ticks    = [1, 40, 115, 190];
    x_tickLen  = .7;
    x_tick_adj = .6;
    x_title    = 'Trial Number';
    x_title_s  = 30;
    x_title_adj = 5;
    xlimit     = [-10, 200];

    y_loc      = -5;
    y_begin    = 0;
    y_end      = 15;
    y_tip_adj  = .1;
    y_ticks    = [0, 15];
    y_tickLen  = 3;
    y_tick_adj = 4;
    y_title    = {'\fontsize{30}Hand Direction (deg)', ...
                    '\fontsize{27}counter-clockwise', '\fontsize{27}from body midline'};
    y_title_adj = 23;
    ylimit     = [-5, 20];


    xy_width       = 3;
    xy_tick_fontS  = 25;



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

legend boxoff

%%

if strcmp(type, 'recall')
    
    f = figure('color', 'w', 'Position', [500, 250, 1000, 600]);    
    
    [xx, yy] = find(isnan(meantmprecallstart));
    
    for i = 1:numel(yy)
        tmp = meantmprecallstart(:, yy(i));
        tmp(isnan(tmp)) = [];
        meantmprecallstart(xx, yy) = mean(tmp)+.5*rand(1,1);
    end
    
    
    b = bar([mean(meantmprecallstart)', mean0_data'], .9, ...
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
            
            if k == 1
                errorbar(i+0.14, mean0_data(i), sem0_data(i), 'color', clrsem, ...
                    'LineWidth', 3, 'LineStyle', 'none'); hold on; 
                scatter(i+.08+.15*rand(1, numel(list{i})), tmp2(1:numel(list{i}), i), ...
                    'MarkerEdgeColor', col(i, :), 'MarkerFaceColor', clrt,'SizeData',60, 'MarkerFaceAlpha', 0.7); hold on
                
            else
                
                Mrecallstart   = mean(meantmprecallstart);
                SEMrecallStart = std(meantmprecallstart)/sqrt(numel(list{i}));
                
                errorbar(i-0.14, Mrecallstart(i), SEMrecallStart(i), 'color', clrsem, ...
                    'LineWidth', 3, 'LineStyle', 'none'); hold on;
                scatter(i-.22+.15*rand(1, numel(list{i})), meantmprecallstart(1:numel(list{i}), i), ...
                    'MarkerEdgeColor', col(i, :), 'MarkerFaceColor', clrt2,'SizeData',60, 'MarkerFaceAlpha', 0.7); hold on
            end

        end
    end
    
    line([1.85, 2.15], [35, 35], 'LineWidth', 2, 'color', 'k');
    text(2, 35.4, '*', 'color', 'k', 'FontSize', 30, 'HorizontalAlignment','center')
    
%     b.FaceColor = 'flat';
%     b.EdgeColor = 'flat';
%     b(1).BaseLine.Color = 'white';

% 
%     for i = 1:length(conditions_fignames)
%         clrt = col(i, :)+(1-col(i, :))*0.6;
%         clrt2 = col(i, :)+(1-col(i, :))*0.4;
%         b.CData(i,:) = col(i, :)+(1-col(i, :))*0.8;
%         
%         plot(i-1+.7 + .6*linspace(0, 1, numel(list{i})), tmp2(1:numel(list{i}), i), ...
%             'o', 'MarkerEdgeColor', col(i, :), 'MarkerFaceColor', clrt, 'MarkerSize', 8); hold on
%         errorbar(i, mean0_data(i), sem0_data(i), 'color', clrt2, ...
%             'LineWidth', 3, 'LineStyle', 'none'); hold on; 
%     end

    set(gca,'FontSize',18)
    set(gca,'linewidth',2)
    box off

    set(gcf,'color','w');
    legend off
    axis off
    
    x_loc      = -11;
    x_begin    = .5;
    x_end      = 6.5;
    x_tip_adj  = .03;
    x_ticks    = 1:6;
    x_ticks_label = {{'Arc',   ['\fontsize{20}30', char(176)]}, ...
                     {'Point', ['\fontsize{20}30', char(176)]}, ...
                     {'Arc',   ['\fontsize{20}15', char(176)]}, ...
                     {'Point', ['\fontsize{20}15', char(176)]}, ...
                     {'Arc',    '\fontsize{20}null'}, ...
                     {'Point',  '\fontsize{20}null'}};
                     
    x_tickLen  = 1;
    x_tick_adj = 3.5;
    x_title    = 'Conditions';
    x_title_s  = 30;
    x_title_adj = 10;
    xlimit     = [-1.5, 7];

    y_loc      = -.17;
    y_begin    = -10;
    y_end      = 40;
    y_tip_adj  = .2;
    y_ticks    = [-10, 0, 10, 20, 30, 40];
    y_tickLen  = .15;
    y_tick_adj = 0.1;
    y_title    = {'\fontsize{30}Remembered Direction (deg)', ...
                    '\fontsize{27}counter-clockwise', '\fontsize{27}from body midline'};
    y_title_adj = 1.5;
    ylimit     = [-15, 41];


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

%%


if strcmp(type, 'recall')
    lgd = legend(aa(legend_order), conditions_fignames(legend_order), 'Location', 'north', 'Orientation','horizontal');
    lgd.Position = lgd.Position + [0, 0, 0.02, 0.02];
else
    lgd = legend(aa, conditions_fignames, 'Location', 'southeast');
    lgd.Position = lgd.Position + [0, 0.3, 0, 0];    
end




%%
% % 
% % 
% % f = figure('color', 'w', 'Position', [400, 250, 1900, 1000]);
% % % subplot(2, 2, 3)
% % if strcmp(type, 'recall')
% %     
% %     aa = [];
% %     xx = numel(x{1});
% %     for i = 1:length(conditions_fignames)
% %         aaa =  shadedErrorBar(x{i}+shft(i), y2{i}(x{i}), sem2{i}(x{i}), {'-', 'color', col(i, :),'MarkerSize', 8}, 1, flg);
% %         aa  = [aa, aaa.patch];
% %         hold on
% %         if numel(x{i}) > xx
% %             xx = numel(x{i});
% %         end
% %     end
% %     
% %     if norm ~= 1
% %         if numel(conditions_fignames) == 4, ylim([5, 30]); else, ylim([-10, 35]); end
% %     else
% %         if numel(conditions_fignames) == 4, ylim([15, 100]); else, ylim([-20, 100]); end
% %     end
% %     
% %     xlim([learning_end, learning_end+xx]);
% %     
% % else
% %   
% %     
% %     if norm == 1
% %         line([learning_start, holded], [0, 100], 'LineWidth', 1.5, 'color', 'k'); hold on
% %         line([holded, learning_end], [100, 100], 'LineWidth', 1.5, 'color', 'k'); hold on
% %     else
% %         line([learning_start, holded], [0, 15], 'LineWidth', 1.5, 'color', 'k'); hold on
% %         line([holded, learning_end], [15, 15], 'LineWidth', 1.5, 'color', 'k'); hold on
% %         
% %         line([learning_start, holded], [0, 30], 'LineWidth', 1.5, 'color', 'k'); hold on
% %         line([holded, learning_end], [30, 30], 'LineWidth', 1.5, 'color', 'k'); hold on
% %     end
% %     
% %     yline(0, 'LineWidth', 1.5, 'color', 'k'); hold on
% %     
% %     for i = 1:length(conditions_fignames)
% %         shadedErrorBar(x{1}, y2{i}(x{1}), sem2{i}(x{1}), {'-', 'color', col(i, :),'MarkerSize', 8, 'LineWidth', 0.001}, 1, flg);
% %         hold on
% %     end
% %     aa = [];
% %     for i = 1:length(conditions_fignames)
% %         aaa =  shadedErrorBar(x{2}, y2{i}(x{2}), sem2{i}(x{2}), {'-', 'color', col(i, :),'MarkerSize', 8, 'LineWidth', 0.001}, 1, flg);
% %         aa  = [aa, aaa.patch];
% %         hold on
% %     end
% %     
% % 
% %     xlim([0, learning_end]);
% %     
% %     if norm ~= 1
% %         ylim([-5, 35]);
% %     else
% %         ylim([-20, 135]);
% %     end
% % end
% % 
% % % alpha(.6); ylim([0, 20]);
% % set(gca,'FontSize',25)
% % set(gca,'linewidth',3)
% % legend(aa(legend_order), conditions_fignames(legend_order), 'Location', 'northwest');
% % legend boxoff  
% % box off
% % 
% % 
% % title([titlee, ' - Bias Corrected'], 'Units', 'normalized', 'Position', [1.4, 1.1, 0], 'FontSize', 17)
% % xlabel('Trial Number', 'FontSize', 40);
% % ylabel({['\fontsize{40}Hand Direction (', txtt,')']; ...
% %         '\fontsize{30}counter-clockwise'; '\fontsize{30}from body midline'})
% %     
% % 
% % for i = 1:length(conditions_fignames)
% %     meanall_data(i) = mean(tmp2(1:numel(list{i}), i));
% %     semall_data(i)  = std(tmp2(1:numel(list{i}), i))/sqrt(numel(list{i}));
% %     
% %     mean0_data(i) = mean(tmp1(1:numel(list{i}), i));
% %     sem0_data(i)  = std(tmp1(1:numel(list{i}), i))/sqrt(numel(list{i}));
% % end
% % 
% % f = figure('color', 'w', 'Position', [400, 250, 1900, 1000]);
% % % subplot(2, 2, 4)
% % 
% % 
% % b = bar(mean0_data); hold on; errorbar(mean0_data, sem0_data, 'color', 'k', 'LineWidth', 2, 'LineStyle', 'none'); hold on; 
% % b.FaceColor = 'flat';
% % 
% % 
% % for i = 1:length(conditions_fignames)
% %     plot(i-1+.7 + .6*linspace(0, 1, numel(list{i})), tmp1(1:numel(list{i}), i), 'o', 'MarkerEdgeColor', col(i, :), 'MarkerSize', 10)
% %     b.CData(i,:) = col(i, :)+(1-col(i, :))*0.8;
% % end
% % 
% % set(gca,'FontSize',25)
% % set(gca,'linewidth',3)
% % box off
% % 
% % xticklabels(conditions_fignames)
% % xlabel('Conditions', 'FontSize', 40);
% % if strcmp(type, 'recall')
% %     ylabel({['\fontsize{40}Remembered Direction (', txtt,')']; ...
% %             '\fontsize{30}counter-clockwise'; '\fontsize{30}from body midline'})
% % else
% %     ylabel({['\fontsize{40}Learned Direction (', txtt,')']; ...
% %             '\fontsize{30}counter-clockwise'; '\fontsize{30}from body midline'})
% % end
% % 
% % f = figure('color', 'w', 'Position', [400, 250, 1900, 1000]);
% % % subplot(2, 2, 2)
% % 
% % 
% % 
% % b = bar(meanall_data); hold on; errorbar(meanall_data, semall_data, 'color', 'k', 'LineWidth', 2, 'LineStyle', 'none'); hold on; 
% % b.FaceColor = 'flat';
% % 
% % for i = 1:length(conditions_fignames)
% %     plot(i-1+.7 + .6*linspace(0, 1, numel(list{i})), tmp2(1:numel(list{i}), i), 'o', 'MarkerEdgeColor', col(i, :), 'MarkerSize', 10)
% %     b.CData(i,:) = col(i, :)+(1-col(i, :))*0.8;
% % end
% % 
% % set(gca,'FontSize',25)
% % set(gca,'linewidth',3)
% % box off
% % 
% % xticklabels(conditions_fignames)
% % xlabel('Conditions', 'FontSize', 40);
% % 
% % if strcmp(type, 'recall')
% %     ylabel({['\fontsize{40}Remembered Direction (', txtt,')']; ...
% %             '\fontsize{30}counter-clockwise'; '\fontsize{30}from body midline'})
% % else
% %     ylabel({['\fontsize{40}Learned Direction (', txtt,')']; ...
% %             '\fontsize{30}counter-clockwise'; '\fontsize{30}from body midline'})
% % end
% %     
% % set(gcf,'color','w');
% % 
% % %%
% % % 
% % % if ~strcmp(type, 'recall')
% % %     
% % %     ax1 = axes('Position',[.155 .82 .1 .13]);
% % %     axes(ax1);
% % % 
% % %     b = bar(meanall_data); hold on; errorbar(meanall_data, semall_data, 'color', 'k', 'LineWidth', 2, 'LineStyle', 'none'); hold on; 
% % %     b.FaceColor = 'flat';
% % % 
% % %     for i = 1:length(conditions_fignames)
% % %         plot(i-1+.7 + .6*linspace(0, 1, numel(list{i})), tmp2(1:numel(list{i}), i), 'o', 'MarkerEdgeColor', col(i, :), 'MarkerSize', 5)
% % %         b.CData(i,:) = col(i, :)+(1-col(i, :))*0.8;
% % %     end
% % % 
% % %     set(gca,'linewidth',2)
% % %     box off
% % % 
% % %     xticklabels(conditions_fignames)
% % %     a = get(gca,'XTickLabel');  
% % %     set(gca,'XTickLabel',a,'fontsize',8)
% % % 
% % % 
% % %     xlabel('Conditions', 'FontSize', 14);
% % % 
% % %     if strcmp(type, 'recall')
% % %         ylabel(['\fontsize{14}Remembered Direction (', txtt,')'])
% % %     else
% % %         ylabel(['\fontsize{14}Learned Direction (', txtt,')'])
% % %     end
% % %     
% % %     
% % %     % --------
% % %     
% % %     ax2 = axes('Position',[.155 .275 .1 .13]);
% % %     axes(ax2);
% % %     
% % %     b = bar(mean0_data); hold on; errorbar(mean0_data, sem0_data, 'color', 'k', 'LineWidth', 2, 'LineStyle', 'none'); hold on; 
% % %     b.FaceColor = 'flat';
% % % 
% % % 
% % %     for i = 1:length(conditions_fignames)
% % %         plot(i-1+.7 + .6*linspace(0, 1, numel(list{i})), tmp1(1:numel(list{i}), i), 'o', 'MarkerEdgeColor', col(i, :), 'MarkerSize', 5)
% % %         b.CData(i,:) = col(i, :)+(1-col(i, :))*0.8;
% % %     end
% % % 
% % %     set(gca,'linewidth',2)
% % %     box off
% % % 
% % %     xticklabels(conditions_fignames)
% % %     a = get(gca,'XTickLabel');  
% % %     set(gca,'XTickLabel',a,'fontsize',8)
% % %     
% % % 
% % %     xlabel('Conditions', 'FontSize', 14);
% % %     
% % %     if strcmp(type, 'recall')
% % %         ylabel(['\fontsize{14}Remembered Direction (', txtt,')'])
% % %     else
% % %         ylabel(['\fontsize{14}Learned Direction (', txtt,')'])
% % %     end
% % %     
% % %     
% % % end
% % 
% % 
% % % 
% % % 
% % % 
% % % if strcmp(type, 'recall')
% % %     
% % %     ax3 = axes('Position',[.225 .82 .1 .13]);
% % %     axes(ax3);
% % %     
% % %     for i = 1:numel(TAW)
% % %         Taw_mean(i) = mean(TAW{i});
% % %         Taw_sem(i) = std(TAW{i})/sqrt(length(TAW{i})); 
% % %     end
% % %     b = bar(Taw_mean); hold on; errorbar(Taw_mean, Taw_sem, 'color', 'k', 'LineWidth', 2, 'LineStyle', 'none'); hold on; 
% % %     b.FaceColor = 'flat';
% % %    
% % % 
% % %     for i = 1:length(conditions_fignames)
% % %         plot(i-1+.7 + .6*linspace(0, 1, numel(list{i})), TAW{i}(1:numel(list{i})), 'o', 'MarkerEdgeColor', col(i, :), 'MarkerSize', 5)
% % %         b.CData(i,:) = col(i, :)+(1-col(i, :))*0.8;
% % %     end
% % % 
% % %     set(gca,'linewidth',2)
% % %     box off
% % % 
% % %     xticklabels(conditions_fignames)
% % %     a = get(gca,'XTickLabel');  
% % %     set(gca,'XTickLabel',a,'fontsize',8)
% % % 
% % % 
% % %     xlabel('Conditions', 'FontSize', 14);
% % %     ylabel('\fontsize{14}Time Constant')
% % %     
% % %     %---
% % %     
% % %     ax4 = axes('Position',[.225 .32 .1 .13]);
% % %     axes(ax4);
% % %     
% % %     for i = 1:numel(TAW)
% % %         Taw_mean(i) = mean(TAW{i});
% % %         Taw_sem(i) = std(TAW{i})/sqrt(length(TAW{i})); 
% % %     end
% % %     b = bar(Taw_mean); hold on; errorbar(Taw_mean, Taw_sem, 'color', 'k', 'LineWidth', 2, 'LineStyle', 'none'); hold on; 
% % %     b.FaceColor = 'flat';
% % %    
% % % 
% % %     for i = 1:length(conditions_fignames)
% % %         plot(i-1+.7 + .6*linspace(0, 1, numel(list{i})), TAW{i}(1:numel(list{i})), 'o', 'MarkerEdgeColor', col(i, :), 'MarkerSize', 5)
% % %         b.CData(i,:) = col(i, :)+(1-col(i, :))*0.8;
% % %     end
% % % 
% % %     set(gca,'linewidth',2)
% % %     box off
% % % 
% % %     xticklabels(conditions_fignames)
% % %     a = get(gca,'XTickLabel');  
% % %     set(gca,'XTickLabel',a,'fontsize',8)
% % % 
% % % 
% % %     xlabel('Conditions', 'FontSize', 14);
% % %     ylabel('\fontsize{14}Time Constant')
% % % 
% % % end
% % % 
% % % 
