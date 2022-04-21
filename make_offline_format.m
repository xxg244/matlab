%% MATLABリセット
clear; close all; clc

%% .xlsmデータ読込
% 【前提】補正対象のトピックデータにおいて，ROStime_transformationマクロとmulti_graphマクロの実行有無は問わない．
%　　　　　ただし，基準トピックデータのROStime_transformationマクロは実行済みであること．

% 基準トピックのデータ読込
[num0,txt0,~] = xlsread("aa.xlsm"); 

% 補正したいトピックのデータ読込
[num1,txt1,~] = xlsread("bb.xlsm");
[num2,txt2,~] = xlsread("cc.xlsm");

%% メイン処理
num1 = transfer_Time(num0,num1,txt1);
bb_resample_table = VLOOKUPtable(num0,txt0,num1,txt1,[3]); % 取得したい列番号を配列に入力

num2 = transfer_Time(num0,num2,txt2);
cc_resample_table = VLOOKUPtable(num0,txt0,num2,txt2,[2]); % 取得したい列番号を配列に入力

% 基準トピック用のデータテーブルを定義
base_table = table();
for j = 1:size(num0,2)
    base_table.(j) = num0(:,j);
    base_table.Properties.VariableNames{"Var"+j} = txt0{1,j};
end

% 各トピックデータを列方向に連結
assembled_table = horzcat(base_table,bb_resample_table(:,2:end),cc_resample_table(:,2:end));

%% 補正したトピックデータ保存
writetable(assembled_table, "2022processed_data.xlsx")

%% 補正対象トピックを基準トピックの時間軸に変換
function [transfered_num1] = transfer_Time(num0,num1,txt1)

% 格納用のデータテーブルを定義
transfered_table = table();
for j = 1:size(num1,2)
    transfered_table.(j) = num1(:,j);
    transfered_table.Properties.VariableNames{"Var"+j} = txt1{1,j};
end

% 基準トピックの開始ROS時刻[s]を取得
start_rostime = num0(1,2); % 累積時間の列を指定

for k = 1:size(num1,1)
    % "補正対象の時刻-基準トピックの開始時刻(=定数)"を計算
    transfered_timePoint = num1(k,1)*10^-9 - start_rostime; 
    
    % 値をテーブルに格納
    transfered_table.(txt1{1,1})(k) = transfered_timePoint;
end

% 作成したテーブルを配列に変換
transfered_num1 = table2array(transfered_table);

end

%% VLOOKUP関数を模擬し，基準トピックの時間軸に整形
function [resampled_table] = VLOOKUPtable(num0,txt0,num1,txt1,column_array)

% 格納用のデータテーブルを定義
resampled_table = table(num0(:,1));
resampled_table.Properties.VariableNames{"Var1"} = txt0{1,1};

% 補正したいトピックのデータ範囲を選択
range = num1(:,:);

% 取得したい列数だけループ
for j = 1:size(column_array,2)
    
    column_num = column_array(j);

    % 基準トピックの行数だけループ 
    for k = 1:size(num0,1)
        % 基準時刻の検索値を選択
        search_val = num0(k,1);
    
        % 検索方法は近似一致(TRUE)を模擬．
        % 補正したいトピック時間の近似値を検索し，最近傍の行インデックスを取得
        [~, nearest_rowId] = min(abs(range(:,1) - search_val));
        
        % 最近傍の値を取得
        nearest_val = range(nearest_rowId,column_num);
    
        % 値をテーブルに格納
        resampled_table.(txt1{1,column_num})(k) = nearest_val;
    end
end
end
