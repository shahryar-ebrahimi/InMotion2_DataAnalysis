
function [h1, h2, h3, h4] = velocityXY_draw(temp_vel, start, stop, t, rx)

t    = t - t(1);

[~, t200] = min(abs(t-0.2));
t200 = t200(1);


col = [255, 0, 0]/255;
col2 = col+(1-col)*0.8;

plot(1:length(temp_vel), temp_vel(:, 2)/10, 'LineWidth', 1.5*rx, 'color', col), hold on;
h2 = area(start:stop, temp_vel(start:stop, 2)/10, 'FaceColor', col2, 'EdgeColor', col, 'LineWidth', 1*rx); hold on


col = [127, 0, 255]/255;
col2 = col+(1-col)*0.8;

plot(1:length(temp_vel), temp_vel(:, 1)/10, 'LineWidth', 1.5*rx, 'color', col), hold on;
h1 = area(start:stop, temp_vel(start:stop, 1)/10, 'FaceColor', col2, 'EdgeColor', col, 'LineWidth', 1*rx); hold on


xlim([1 length(temp_vel)]); grid on, grid minor
xlabel('Sample Number', 'FontSize', 15*rx); ylabel('XY Velocity [cm/s]', 'FontSize', 15*rx); 

plot([start stop], [temp_vel(start, 1), temp_vel(stop, 1)]/10, ...
        'o','MarkerSize',7*rx,...
        'MarkerEdgeColor','r',...
        'MarkerFaceColor','r');

plot([start stop], [temp_vel(start, 2), temp_vel(stop, 2)]/10, ...
        'o','MarkerSize',7*rx,...
        'MarkerEdgeColor','r',...
        'MarkerFaceColor','r');
    

miny = min(temp_vel/10,[],'all');
maxy = max(temp_vel/10,[],'all');

if miny < 0 
    miny = 1.1*miny;
else
    miny = 0.9*miny;
end

if maxy < 0
    maxy = 0.9*maxy;
else
    maxy = 1.1*maxy;
end

ylim([miny, maxy]);


line([start, start], [miny, maxy], 'color', 'r');
line([stop, stop], [miny, maxy], 'color', 'r');


[~, max_vel] = max(sqrt(temp_vel(start:stop, 2).^2 + temp_vel(start:stop, 1).^2)/10);

plot(max_vel+start-1, temp_vel(max_vel+start-1, 1)/10, 'h', 'MarkerEdgeColor', 'k',...
    'MarkerSize', 15*rx, 'MarkerFaceColor', [227, 154, 18]/255); 

plot(start+t200-1, temp_vel(start+t200-1, 1)/10, 'h', 'MarkerEdgeColor', 'k',...
    'MarkerSize', 15*rx, 'MarkerFaceColor', [235, 52, 152]/255); 

h3 = plot(max_vel+start-1, temp_vel(max_vel+start-1, 2)/10, 'h', 'MarkerEdgeColor', 'k',...
    'MarkerSize', 15*rx, 'MarkerFaceColor', [227, 154, 18]/255); 

h4 = plot(start+t200-1, temp_vel(start+t200-1, 2)/10, 'h', 'MarkerEdgeColor', 'k',...
    'MarkerSize', 15*rx, 'MarkerFaceColor', [235, 52, 152]/255); 


lgd = legend([h1, h2, h3, h4], 'X Velocity [cm/s]', 'Y Velocity [cm/s]', 'Maximum Velocity', '200 ms');
lgd.FontSize = 14*rx;
set(lgd,'color', [.9 .9 .9]);

alpha(0.6)

set(gcf,'color','w'); box off
