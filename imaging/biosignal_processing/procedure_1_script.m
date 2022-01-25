load('Procedure_1.mat');
%the code works better if we subset x to remove the last sample.
% x = x(1:end-1);
signal_length = length(x);

%subtract 1 from number of samples to account for t = 0
n_seconds = (signal_length - 1) / fs; %n_seconds = 5

%time vector is from 0 to n_seconds, length = length of x
time_domain = 0:1/fs:n_seconds;

%plot(time_domain, x) % cannot determine Nyquist frequency visually, too high frequency

%take fft
fft_x = fft(x);

%for the fft, index 1 is the dc offset, the max frequency is fs/2
%(nyquist). therefore, the frequency is ind - 1, and the output is
%symmetric around fs/2 + 1. if this value is not an integer,
%then the nyquist frequency is not included in the fft. if it's an integer,
%the nyquist is included, and only included once.
%note that when the signal duration, N/fs, is not 1, the frequencies are
%scaled by fs/N

%i fucking hate matlab. 1-indexing is so annoying to deal with

one_sided_fft = fft_x(1:floor(signal_length/2)+1);
amplitudes = abs(one_sided_fft)/signal_length;

%because we've halved the length of the signal, we need to double the
%amplitude of the non-repeated components. 0 is not repeated, and if the signal
%has an even length, the last value is not repeated, whereas if the signal
%has an odd length, the last value is repeated, hence the use of modulo
amplitudes(2:end-mod(signal_length+1,2)) = 2*amplitudes(2:end-mod(signal_length+1,2));

frequencies=fs/signal_length*(0:length(amplitudes)-1);
%plot(frequencies, amplitudes);

angles = angle(one_sided_fft);

%to recreate the signal, we use the values that exceed a given amplitude
%threshold:
threshold = 0.001;
amplitudes_filtered = amplitudes(amplitudes > threshold);
frequencies_filtered = frequencies(amplitudes > threshold);
angles_filtered = angles(amplitudes > threshold);

recreation = zeros(1, length(x));
for i = 1:length(amplitudes_filtered)
    recreation = recreation+amplitudes_filtered(i)*cos(2*pi*frequencies_filtered(i)*time_domain+angles_filtered(i));
end

%for whatever reason the recreation is offset by like half a sample. i
%think this is an artifact caused by there being an odd number of samples
%to deal with this, we can try:
x_offset = x(2:end);
x_combine = x(1:end-1) + x_offset;
x_combine = x_combine/2;

hold on
plot(time_domain(end-300:end), recreation(end-300:end), 'r')
plot(time_domain(end-300:end), x_combine(end-300:end), 'b')

%plotting the two signals seems to suggest we're pretty close. there's a
%few artifacts but overall looks reasonably correct.
%this is unnecessary if we subset x to remove the last sample, justifying
%our assumption that it's due to having an odd number of samples



