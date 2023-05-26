
function canvas_draw(pos, MOVE_LNG, num, iadmaxv, tardeg, t, max_vel, baseline_end, learning_end, rx, recall)

ctar      = 10*[cos(0:2*pi/100:2*pi);sin(0:2*pi/100:2*pi)];
c         = 6*[cos(0:2*pi/100:2*pi);sin(0:2*pi/100:2*pi)];


t    = t - t(1);

[~, t200] = min(abs(t-0.2));
t200      = t200(1);

line([0, MOVE_LNG*cosd(tardeg)], [0, MOVE_LNG*sind(tardeg)], 'LineWidth', 2*rx); hold on
     
% patch(s(1, :)+MOVE_LNG, s(2, :), 'y'); hold on
% patch(s(1, :)-MOVE_LNG, s(2, :), 'y'); hold on
% patch(s(1, :), s(2, :)-MOVE_LNG, 'y'); hold on            
% patch(s(3, :)+MOVE_LNG*cosd(45), s(4, :)+MOVE_LNG*cosd(45), 'y'); hold on
% patch(s(3, :)-MOVE_LNG*cosd(45), s(4, :)-MOVE_LNG*cosd(45), 'y'); hold on
% patch(s(3, :)+MOVE_LNG*cosd(45), s(4, :)-MOVE_LNG*cosd(45), 'y'); hold on
% patch(s(3, :)-MOVE_LNG*cosd(45), s(4, :)+MOVE_LNG*cosd(45), 'y'); hold on

pp = patch(ctar(1, :)+MOVE_LNG*cosd(tardeg), ctar(2, :)+MOVE_LNG*sind(tardeg), 'y'); hold on
pp.EdgeColor = [0, 0.4470, 0.7410];
pp.LineWidth = 2*rx;

plot(0, 0, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'MarkerSize', 10*rx);
plot(0, 0, 'o', 'MarkerEdgeColor', 'b','MarkerFaceColor', [109, 169, 201]/255, 'MarkerSize', 12*rx); hold on

patch(c(1, :)+pos(end,1)-pos(1, 1), c(2, :)+pos(end,2)-pos(1, 2), 'r'); hold on

plot(pos(:,1)-pos(1, 1),pos(:,2)-pos(1, 2), 'color', [109, 169, 201]/255, 'LineWidth', 4*rx);

h1 = plot(pos(max_vel, 1)-pos(1, 1), pos(max_vel, 2)-pos(1, 2), 'h', 'MarkerEdgeColor', 'k',...
    'MarkerSize', 25*rx, 'MarkerFaceColor', [227, 154, 18]/255); 

h2 = plot(pos(t200, 1)-pos(1, 1),pos(t200,2)-pos(1, 2), 'h', 'MarkerEdgeColor', 'k',...
    'MarkerSize', 25*rx, 'MarkerFaceColor', [235, 52, 152]/255); 

% text(MOVE_LNG, 0+dist, '0 deg','HorizontalAlignment','center')
% text(-MOVE_LNG, 0+dist, '180 deg','HorizontalAlignment','center')
%text(0, -MOVE_LNG+dist, '270 deg','HorizontalAlignment','center')

% text(MOVE_LNG*cosd(45),   MOVE_LNG*cosd(45)+dist, '45 deg','HorizontalAlignment','center')
%text(-MOVE_LNG*cosd(45), -MOVE_LNG*cosd(45)+dist, '225 deg','HorizontalAlignment','center')
%text(MOVE_LNG*cosd(45),  -MOVE_LNG*cosd(45)+dist, '315 deg','HorizontalAlignment','center')
% text(-MOVE_LNG*cosd(45),  MOVE_LNG*cosd(45)+dist, '135 deg','HorizontalAlignment','center')

    
    
axis equal;  grid on, grid minor
if cosd(tardeg) < 0
    
    xlim([round(MOVE_LNG*cosd(tardeg)/10)*10-30 20]); ylim([-20 round(MOVE_LNG*sind(tardeg)/10)*10+30]); 
    
    txt = 'Angular Deviation at Maximum Velocity:                   ';
    text(-50, 0, txt, 'FontSize', 22*rx, 'HorizontalAlignment', 'center');
    text(-50+30.53, 0,[num2str(round(iadmaxv, 2)), char(176)], 'FontSize', 22*rx, ...
        'HorizontalAlignment','center', 'color', 'r');
    
    text(MOVE_LNG*cosd(tardeg), MOVE_LNG*sind(tardeg), ['Target at 120', char(176)],'HorizontalAlignment','center')
    
elseif cosd(tardeg) > 0
    
    xlim([-20 round(MOVE_LNG*cosd(tardeg)/10)*10+30]); ylim([-20 round(MOVE_LNG*sind(tardeg)/10)*10+30]); 
    
    txt = 'Angular Deviation at Maximum Velocity:                   ';
    text(80, 0, txt, 'FontSize', 22*rx, 'HorizontalAlignment', 'center');
    text(80+32.53, 0,[num2str(round(iadmaxv, 2)), char(176)], 'FontSize', 22*rx, ...
        'HorizontalAlignment','center', 'color', 'r');
    
    text(MOVE_LNG*cosd(tardeg), MOVE_LNG*sind(tardeg), ['Target at 45', char(176)],'HorizontalAlignment','center')
else
    
    xlim([-90 90]); ylim([-20 round(MOVE_LNG*sind(tardeg)/10)*10+30]); 
    
    txt = 'Angular Deviation at Maximum Velocity:                   ';
    text(3, -10, txt, 'FontSize', 22*rx, 'HorizontalAlignment', 'center');
    text(39, -10,[num2str(round(iadmaxv, 2)), char(176)], 'FontSize', 22*rx, ...
        'HorizontalAlignment','center', 'color', 'r');
    
    text(MOVE_LNG*cosd(tardeg), MOVE_LNG*sind(tardeg), ['Target at 90', char(176)],'HorizontalAlignment','center')
end

xlabel('X (mm)', 'FontSize', 15*rx); ylabel('Y (mm)', 'FontSize', 15*rx); 
lgd = legend([h1, h2], 'Maximum Velocity', '200 ms', 'Location','northeast');
lgd.FontSize = 14*rx;

if num <= baseline_end
	sgtitle(['Baseline Phase - Trial ', num2str(num), '/', num2str(baseline_end)], 'FontSize', 20*rx); 
elseif num > baseline_end && num <= learning_end
	sgtitle(['Learning Phase - Trial ', num2str(num-baseline_end), '/', num2str(learning_end-baseline_end)], 'FontSize', 20*rx); 
else
	sgtitle(['Recall Phase - Trial ', num2str(num-learning_end), '/', num2str(recall)], 'FontSize', 20*rx);
end

set(gcf,'color','w');
set(lgd,'color', [.9 .9 .9]);
