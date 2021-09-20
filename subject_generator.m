% Input i index and you will get 4 subjects
% S_i_1_1, S_i_2_1, S_i_1_2, S_i_2_2
clear; clc
id = input('Subject main index? ');

% Make main random matrix
M = randperm(48);
mkdir('./',['Subjects']);
save(['./Subjects','/M_', num2str(id)], 'M');

for j = 1:2
    for k = 1:2
        mkdir('./Subjects',['S_', num2str(id), '_', num2str(j), '_', num2str(k)]);
    end
end

K = [M(1:12) M(13:24) M(25:36) M(37:48)];
save(['./Subjects/','S_', num2str(id), '_', num2str(1), '_', num2str(1), '/K'], 'K');
K = [M(13:24) M(1:12) M(37:48) M(25:36)];
save(['./Subjects/','S_', num2str(id), '_', num2str(1), '_', num2str(2), '/K'], 'K');
K = [M(25:36) M(37:48) M(1:12) M(13:24)];
save(['./Subjects/','S_', num2str(id), '_', num2str(2), '_', num2str(1), '/K'], 'K');
K = [M(37:48) M(25:36) M(13:24) M(1:12)];
save(['./Subjects/','S_', num2str(id), '_', num2str(2), '_', num2str(2), '/K'], 'K');
