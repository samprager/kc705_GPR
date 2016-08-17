f_off = 10.00125e6; BW = 46.08e6;
fc = BW/2 + f_off;
w = 2*pi*fc; R1 = 10; R2 = 10;
eps = 8.85e-12; u0 = pi*4e-7;
er_a = 1; er_w = 81; er_s = 4; s_p = .5; VWC = .1; EC = 1e-2;
er = ((1-s_p)*er_s^.5+(s_p-VWC)*er_a^.5+VWC*er_w^.5)^2;
alpha = w*sqrt(er*eps*u0)*sqrt(.5*(sqrt(1+(EC/(w*er*eps))^2)-1))
v = 1/(sqrt(u0*er*eps/2)*sqrt(sqrt(1+(EC/(w*er*eps))^2)+1))
aperture = 4*pi*fc/v
abs_loss1 = R1*10*2*log10(exp(1))*alpha
abs_loss2 = R2*10*2*log10(exp(1))*alpha
spread_loss = 10*log10(8*R1^3*(3e8)/(aperture^4)*fc*er^.5)
%spread_loss = 10*log10(8*R^3/(aperture^4)*fc*v)
spread_loss = 10*log10(8*R1^3/((4*pi)^4*fc^3)*v^5)
TPL = spread_loss + abs_loss1 + abs_loss2

%% 
R_tx = 10; R_rx = 10;
f_off = 10.00125e6; BW = 46.08e6;
fc = BW/2 + f_off;
w = 2*pi*fc;
e0 = 8.85e-12; u0 = pi*4e-7;
er_a = 1; er_w = 81; er_s = 4; s_p = .5; VWC = .1; cond_e = 1e-2;
er = ((1-s_p)*er_s^.5+(s_p-VWC)*er_a^.5+VWC*er_w^.5)^2
loss_m = 0; loss_e = cond_e/(w*er*e0);

prop_const = sqrt((0+1i*w*u0)*(cond_e+1i*w*er*e0))
atten_const = w*sqrt(er*e0*u0)*sqrt(.5*(sqrt(1+(loss_e)^2)-1))
phase_const = w*sqrt(er*e0*u0)*sqrt(.5*(sqrt(1+(loss_e)^2)+1))

lambda = 2*pi/phase_const
v = w/phase_const

linkbudget = struct('wavelength',{},'velocity',{},'prop_const',{},'rel_perm',{},'spread_loss',{},'freq_loss',{},'atten_loss',{},'total_loss',{});
linkbudget(1).wavelength = lambda;
linkbudget.velocity = v;
linkbudget.prop_const = prop_const;
linkbudget.rel_perm = er;
tx_spread_loss = 10*log10(4*pi*R_tx^2)
rx_spread_loss = 10*log10(4*pi*R_rx^2)
freq_dep_loss = 10*log10(4*pi/(lambda^2))
tx_atten_loss = 20*log10(exp(atten_const*R_rx));
rx_atten_loss = 20*log10(exp(atten_const*R_tx));

linkbudget.spread_loss = [tx_spread_loss,rx_spread_loss];
linkbudget.freq_loss = freq_dep_loss;
linkbudget.atten_loss = [tx_atten_loss,rx_atten_loss];
linkbudget.total_loss = tx_spread_loss+rx_spread_loss+freq_dep_loss+tx_atten_loss+rx_atten_loss;
linkbudget

antenna_aper = lambda^2/(4*pi)

total_path_loss = 10*log10(8*(R_tx)^3*(3e8)/(fc*sqrt(er)*antenna_aper^4))+2*R_tx*atten_const*10*log10(exp(2))