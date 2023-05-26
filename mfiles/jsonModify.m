
clear
clc

%%


cond = 'RecogSham';
sub  = 'Sub009';

targ_bin = [1, 10];
targ_val = 20;
factor   = 100;
factor   = factor/100;

directory1 = [pwd, '/../data/', cond, '/', cond, '_', sub];
fileName = dir([pwd, '/../data/', cond, '/', cond, '_', sub, '/*yesno.json']).name;

str        = fileread([directory1, '/', fileName]);   % dedicated for reading files as text 
data       = jsondecode(str);      % Using the jsondecode function to parse JSON from string 


% window length and number of bins
bin_max = 10;


for i = 1:numel(data)
	direction(i) = data(i).direction;
	answer(i)    = data(i).answer(1);
end

direction_set = unique(direction);
step = numel(direction_set);
wl   = numel(direction) - step*(bin_max-1);
                     

st(1)  = step*(targ_bin(1)-1)+1;
st(2)  = step*(targ_bin(2)-1)+wl;

id  = 1:numel(data);

for repeat = 1:numel(targ_val)
    if factor > 0
        where = id((direction == targ_val(repeat) & id >= st(1) & id < st(2) & answer=='n'));
        tedadNo = ceil(factor*numel(where));
        for i = where(1:tedadNo)
            data(i).answer = 'yes';
        end
    elseif factor < 0
        where = id((direction == targ_val(repeat) & id >= st(1) & id < st(2) & answer=='y'));
        tedadNo = ceil(abs(factor)*numel(where));
        for i = where(1:tedadNo)
            data(i).answer = 'no';
        end   
    end
end

txt       = jsonencode(data);      % Using the jsondecode function to parse JSON from string 

fid = fopen([directory1, '/', fileName],'w');
fprintf(fid,'%s', txt);
fclose(fid);


