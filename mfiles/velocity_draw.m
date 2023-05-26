
function [h1, h2, h3, h4] = velocity_draw(temp_vel, start, stop, t, crit_for_trial_length, rx)

t    = t - t(1);

[~, t200] = min(abs(t-0.2));
t200 = t200(1);

col  = [21, 233, 221]/255;
col2 = col+(1-col)*0.8;

plot(1:length(temp_vel), sqrt(temp_vel(:, 2).^2 + temp_vel(:, 1).^2)/10, 'color', 'b', 'LineWidth', 1.5*rx), hold on;
h1 = area(start:stop, sqrt(temp_vel(start:stop, 2).^2 + temp_vel(start:stop, 1).^2)/10, 'FaceColor', col2, 'EdgeColor', 'b'); hold on

h2 = plot([start stop], [sqrt(temp_vel(start, 2).^2 + temp_vel(start, 1).^2) sqrt(temp_vel(stop, 2).^2 + temp_vel(stop, 1).^2)]/10, ...
        'o','MarkerSize',7*rx,...
        'MarkerEdgeColor','r',...
        'MarkerFaceColor','r');

[mx, max_vel] = max(sqrt(temp_vel(start:stop, 2).^2 + temp_vel(start:stop, 1).^2)/10);

h3 = line([0 length(temp_vel)],[crit_for_trial_length*mx crit_for_trial_length*mx], 'color', 'r');


h4 = plot(max_vel+start-1, mx, 'h', 'MarkerEdgeColor', 'k',...
    'MarkerSize', 15*rx, 'MarkerFaceColor', [227, 154, 18]/255); 

h5 = plot(start+t200-1, sqrt(temp_vel(start+t200-1, 2).^2 + temp_vel(start+t200-1, 1).^2)/10, 'h', 'MarkerEdgeColor', 'k',...
    'MarkerSize', 15*rx, 'MarkerFaceColor', [235, 52, 152]/255); 


xlim([1 length(temp_vel)]); grid on, grid minor
xlabel('Sample Number', 'FontSize', 15*rx); ylabel('Total Velocity [cm/s]', 'FontSize', 15*rx); 

line([start, start],[min(sqrt(temp_vel(start:stop, 2).^2 + temp_vel(start:stop, 1).^2)/10,[],'all')-5, max(sqrt(temp_vel(start:stop, 2).^2 + temp_vel(start:stop, 1).^2)/10,[],'all')+5], 'color', 'r');
line([stop, stop],[min(sqrt(temp_vel(start:stop, 2).^2 + temp_vel(start:stop, 1).^2)/10,[],'all')-5, max(sqrt(temp_vel(start:stop, 2).^2 + temp_vel(start:stop, 1).^2)/10,[],'all')+5], 'color', 'r');

ylim([0, max(sqrt(temp_vel(:, 2).^2 + temp_vel(:, 1).^2)/10, [],'all')+5]);
   

lgd = legend([h4, h5], 'Maximum Velocity', '200 ms');
lgd.FontSize = 14*rx;

set(lgd,'color', [.9 .9 .9]);


set(gcf,'color','w'); box off
