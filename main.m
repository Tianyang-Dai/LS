clc;        % 清除命令窗口的内容
clear;      % 清除工作空间的所有变量
close all;  % 关闭所有的Figure窗口

% 参数设置
N = 200;            % 信号长度
L = 10;             % 数据向量长度
K = N / L;          % 数据向量个数
SNR_dB = 10;        % 信噪比（dB）
variance = 0.01;    % 噪声方差

% 生成发送信号
x = randi([0, 1], 1, N) * 2 - 1;

% 生成多径信道响应
h = [0.75, -0.42, 0.21];

% 生成高斯白噪声
w = sqrt(variance) * randn(1, N);

% 传输信号经过信道和噪声
y = filter(h, 1, x) + w;

% 初始化参数估计结果存储数组
h_hat_single = zeros(K, length(h));  % 存储单次训练数据的参数估计值
h_hat_avg = zeros(K, length(h));  % 存储平均参数估计值

% 蒙特卡洛仿真
for k = 1:K
    % 提取当前数据向量
    y_k = y((k-1)*L+1 : k*L);
    
    % 构建LS估计矩阵
    Phi = zeros(L, length(h));
    for i = 1:length(h)
        Phi(:, i) = circshift(x((k-1)*L+1 : k*L)', i-1);
    end
    
    % 计算LS估计值
    h_hat_single(k, :) = inv(Phi' * Phi) * Phi' * y_k';
end

% 计算平均参数估计值
h_hat_avg = mean(h_hat_single);

% 绘制结果
figure;

subplot(2, 1, 1);
plot(1:K, h_hat_single(:, 1), '-o', 1:K, h_hat_single(:, 2), '-s', 1:K, h_hat_single(:, 3), '-^');
title('单次训练数据的参数估计值');
xlabel('k');
ylabel('估计值');
legend('h1', 'h2', 'h3');

subplot(2, 1, 2);
plot(1:K, h_hat_avg(1) * ones(1, K), '--', 1:K, h_hat_avg(2) * ones(1, K), '--', 1:K, h_hat_avg(3) * ones(1, K), '--');
title('平均参数估计值');
xlabel('k');
ylabel('估计值');
legend('h1', 'h2', 'h3');
