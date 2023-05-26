
function [t_meanpd, t_area, t_pd, t_pdmaxv, t_pd100, t_pd200, t_pdend, t_lng, t_iadmaxv, t_iad100, t_iad200, t_iadend] = kin_charsigned(trial_samples, vel_kin, t, tardeg, MOVE_LNG)

% In this program we calculate some kinematic characteristics, signed area, Perpendicular Deviation, Path Length
% and Initial Angular Deviation

t       = t - t(1);

L       = size(trial_samples,1);
strx    = trial_samples(1, 1);                 %start_point
stry    = trial_samples(1,2);                  %start_point
stpx    = round(MOVE_LNG*cosd(tardeg));        %trial_samples(L,1);     %stop_point
stpy    = round(MOVE_LNG*sind(tardeg));        %trial_samples(L,2);     %stop_point

area(1) = 0;
pd(1)   = 0;
dd(1)   = 0;

for i = 2:L
    
    datax     = trial_samples(i,1);  % Each point of data
    datay     = trial_samples(i,2);  % Each point of data
    datax1    = trial_samples(i-1,1);% Previous point of data
    datay1    = trial_samples(i-1,2);% Previous point of data
    vector1   = [datax-strx,datay-stry,0]./sqrt(sum([datax-strx,datay-stry].^2));
    vector2   = [stpx, stpy,0]./sqrt(sum([stpx,stpy].^2));
    theta     = abs(acosd(dot(vector1,vector2)));
    
    if sum(cross(vector1,vector2))<0
        theta = -theta;
    end
    
    iad(i)  = theta; % Initial angular deviation
    lng(i)  = sqrt(sum([datax-datax1,datay-datay1].^2)); % distance between two points
    pd(i)   = sind(theta) * sqrt(sum([datax-strx,datay-stry].^2)); % Perpendicular distance
    dd(i)   = cosd(theta) * sqrt(sum([datax-strx,datay-stry].^2)); % directional distance
    area(i) = (pd(i)+pd(i-1))*(dd(i)-dd(i-1))/2;
    
end

[~, place] = max(sqrt(vel_kin(:,1).^2 + vel_kin(:,2).^2));

[~, t200]  = min(abs(t-0.2));
t200       = t200(1);

[~, t100]  = min(abs(t-0.1));
t100       = t100(1);

t_area     = sum(area);
t_pdmaxv   = pd(place);
t_pd200    = pd(t200);
t_pd100    = pd(t100);
t_pdend    = pd(end);
[~, dummy] = max(abs(pd));
t_pd       = pd(dummy);

t_lng      = sum(lng);
t_iadmaxv  = iad(place);  % The initial diviation, at the maximum tangantial velociy
t_iad200   = iad(t200);   % The initial diviation, 200ms into the movement
t_iad100   = iad(t100);   % The initial diviation, 100ms into the movement
t_iadend   = iad(end);    % The initial diviation, end of the movement
t_meanpd   = mean(pd);
