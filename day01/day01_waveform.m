% day01_waveform.m
% Simple waveform plot

% WAVファイル読み込み
[signal, fs] = audioread("loop100302.wav");

% 時間軸を作成
t = (0:length(signal)-1) / fs;

% モノラル化（ステレオの場合）
if size(signal, 2) > 1
    signal = signal(:,1);
end

% 波形プロット
figure;
plot(t, signal);
xlabel("Time [s]");
ylabel("Amplitude");
title("Waveform");
grid on;
