chirp_type = 'lin';
fs = 245.76e6;
%n = 4096-512;
n = 4096-512-17;  % subtract 17 for clock delay in FPGA
f0 = 60e6; f1 = 110e6;
t = linspace(0,n/fs,n);
ti  = linspace(-n/(1*fs),n/(1*fs),n);
f = 10;
scale = double(intmax('int16'));
%win = getBlackmanHarris(n)';
win = getHamming(n)';
%win = linspace(1,1,n);

Q_gaus = gauspuls(ti,50E6,.1).*win;
I_gaus = gauspuls(ti,50E6,.1).*win;
I_quad =chirp(t,f0,t(end),f1,'q',[],'convex').*win;
Q_quad =chirp(t,f0,t(end),f1,'q',[],'convex').*win;
I_log =chirp(t,f0,t(end),f1,'logarithmic').*win;
Q_log =chirp(t,f0,t(end),f1,'logarithmic').*win;
I_lin =chirp(t,f0,t(end),f1).*win;
Q_lin =chirp(t,f0,t(end),f1).*win;

% I = cos(2*pi*f*t);
% Q = sin(2*pi*f*t);

switch chirp_type
    case 'gaus'
       data_i = int16(scale*I_gaus);
       data_q = int16(scale*Q_gaus); 
    case 'lin'
       data_i = int16(scale*I_lin);
       data_q = int16(scale*Q_lin); 
    case 'log'
       data_i = int16(scale*I_log);
       data_q = int16(scale*Q_log); 
    case 'quad'
       data_i = int16(scale*I_quad);
       data_q = int16(scale*Q_quad);           
end

data = reshape([data_i;data_q],1,2*n);
fileID = fopen('/Users/sam/outputs/waveform_data.bin','w');
frewind(fileID);
fwrite(fileID,data,'int16');
fclose(fileID);

data_i_lin = int16(scale*I_lin);
data_q_lin = int16(scale*Q_lin); 
data_i_log = int16(scale*I_log);
data_q_log = int16(scale*Q_log); 
data_i_quad = int16(scale*I_quad);
data_q_quad = int16(scale*Q_quad); 
data_i_gaus = int16(scale*I_gaus);
data_q_gaus = int16(scale*Q_gaus); 

data_lin = reshape([data_i_lin;data_q_lin],1,2*n);
data_log = reshape([data_i_log;data_q_log],1,2*n);
data_quad = reshape([data_i_quad;data_q_quad],1,2*n);
data_gaus = reshape([data_i_gaus;data_q_gaus],1,2*n);

fileID = fopen('/Users/sam/outputs/waveform_data_lin.bin','w');
frewind(fileID);
fwrite(fileID,data_lin,'int16');
fclose(fileID);

fileID = fopen('/Users/sam/outputs/waveform_data_log.bin','w');
frewind(fileID);
fwrite(fileID,data_log,'int16');
fclose(fileID);

fileID = fopen('/Users/sam/outputs/waveform_data_quad.bin','w');
frewind(fileID);
fwrite(fileID,data_quad,'int16');
fclose(fileID);

fileID = fopen('/Users/sam/outputs/waveform_data_gaus.bin','w');
frewind(fileID);
fwrite(fileID,data_gaus,'int16');
fclose(fileID);

% figure; plot(I);title('I');
% figure; plot(Q);title('Q');
% figure; obw(Q,fs);

%%
packet_size = 552;
header_size = 24+16;
num_packets = (n*4)/(packet_size-header_size)
full_pkts = floor(num_packets)
partial_pkt_size = n*4-full_pkts*(packet_size-header_size)+header_size