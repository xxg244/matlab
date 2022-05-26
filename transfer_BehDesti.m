clear all; close all; clc

%% read me
% 【目的】：ros1のHTML形式出力を戻す処理を自動で行う
% 【前提】：example1.xlsmをexample1_transfer.xlsmにする．

%% read file
% 基準トピックのデータ読込
[num0,txt0,~] = xlsread("example1.xlsm"); 

%% process main
% 格納用のデータテーブルを定義
assembled_table = table(num0(:,1),txt0(2:end,2),txt0(2:end,2),txt0(2:end,2));
assembled_table.Properties.VariableNames{"Var1"} = txt0{1,1};
assembled_table.Properties.VariableNames{"Var2"} = txt0{1,2};
assembled_table.Properties.VariableNames{"Var3"} = 'field.a';
assembled_table.Properties.VariableNames{"Var4"} = 'field.b';

% field.aを整形
data_num = size(num0(:,1),1);
for j = 1:1:data_num
    str_array1 = split(assembled_table{j,3});
    str_array2 = split(str_array1(4),"<br>");
    assembled_table{j,3} = num2cell(str2double(str_array2(1)));
end

% field.bを整形
for k = 1:1:data_num
    str_array3 = split(assembled_table{k,4});
    if size(str_array3,1) == 4
        assembled_table{k,4} = {1};
    elseif size(str_array3,1) == 5
        str_array4 = split(str_array3(5),"<br>");
        assembled_table{k,4} = num2cell(str2double(str_array4(1)));
    end
end

%% save file
writetable(assembled_table, "example1_transfer.xlsm")
