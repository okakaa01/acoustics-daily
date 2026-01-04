% day02_features.m
% Day2: Compute RMS and ZCR (Zero Crossing Rate) and visualize them.
% Place this script in a folder with "example.wav".

clear; clc;

% === Input ===
wavPath = "example.wav";

% === Read WAV ===
[x, fs] = audioread(wavPath);

% Mono conversion if stereo
if size(x, 2) > 1
    x = x(:, 1);
end

N = length(x);
t = (0:N-1) / fs;

% === Frame settings ===
frame_ms = 25;          % 25 ms frame
hop_ms   = 10;          % 10 ms hop
frameLen = round(frame_ms/1000 * fs);
hopLen   = round(hop_ms/1000   * fs);

if frameLen < 2 || hopLen < 1
    error("Frame/hop is too small. Check fs.");
end

% === Frame-wise RMS & ZCR ===
numFrames = floor((N - frameLen) / hopLen) + 1;
rmsVals = zeros(numFrames, 1);
zcrVals = zeros(numFrames, 1);
frameTime = zeros(numFrames, 1);

for i = 1:numFrames
    idxStart = (i-1) * hopLen + 1;
    idxEnd   = idxStart + frameLen - 1;
    frame = x(idxStart:idxEnd);

    % RMS
    rmsVals(i) = sqrt(mean(frame.^2));

    % ZCR: rate of sign changes per sample (simple)
    s = sign(frame);
    s(s==0) = 1; % treat zeros as positive to avoid extra flips
    zcrVals(i) = sum(abs(diff(s)) > 0) / (frameLen - 1);

    % time at center of frame
    frameTime(i) = (idxStart - 1 + frameLen/2) / fs;
end

% === Global (whole signal) RMS & ZCR ===
globalRMS = sqrt(mean(x.^2));
sx = sign(x);
sx(sx==0) = 1;
globalZCR = sum(abs(diff(sx)) > 0) / (N - 1);

% === Plot ===
figure;

subplot(3,1,1);
plot(t, x);
grid on;
title("Waveform");
xlabel("Time [s]");
ylabel("Amplitude");

subplot(3,1,2);
plot(frameTime, rmsVals);
grid on;
title(sprintf("Frame RMS (frame=%dms hop=%dms)", frame_ms, hop_ms));
xlabel("Time [s]");
ylabel("RMS");

subplot(3,1,3);
plot(frameTime, zcrVals);
grid on;
title("Frame ZCR");
xlabel("Time [s]");
ylabel("ZCR");

% === Save results text ===
outPath = "results.txt";
fid = fopen(outPath, "w");
fprintf(fid, "Day2 Features\n");
fprintf(fid, "File: %s\n", wavPath);
fprintf(fid, "Sampling rate: %d Hz\n", fs);
fprintf(fid, "Length: %d samples (%.3f sec)\n", N, N/fs);
fprintf(fid, "\nGlobal RMS: %.6f\n", globalRMS);
fprintf(fid, "Global ZCR: %.6f\n", globalZCR);
fprintf(fid, "\nFrame setting: frame=%dms, hop=%dms\n", frame_ms, hop_ms);
fprintf(fid, "Frames: %d\n", numFrames);
fclose(fid);

disp("Done! Saved results.txt and plotted waveform/RMS/ZCR.");