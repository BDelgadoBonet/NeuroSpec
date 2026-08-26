% Script: ztrack_demo1.m
% Script to demonstrate use of NeuroSpec 2.2
% z-tracker estimate of time varying coherence over segmented data
%
% Copyright 2018, David M. Halliday.
% This file is part of NeuroSpec.
%
%    NeuroSpec is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    NeuroSpec is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with NeuroSpec; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
%    NeuroSpec is available at:  http://www.neurospec.org/
%    Contact:  contact@neurospec.org

% Surrogate data, using ramp modulation of target coherence, linear increase then decrease.
coh_start=0; % Target coherence modulated over full range [0 1]
coh_stop=1;  %
tau=20;      % 20 second duration, 10 sec increase + 10 sec decrease in target coherence
n_rep=10;    % 10 repetitions, 200 sec data generated
t_start=0;   % No initial lead in where coherence constant
n_sets=1;    % Only 1 set of data here
plot_flag=1; % Plot figure with target coherence
samp_rate=1000; % Assumed sampling rate for data
[dat1,ch_target1]=ztrack_dat_ramp1(coh_start,coh_stop,tau,samp_rate,n_rep,t_start,n_sets,plot_flag);

% z-tracker analysis
seg_pwr=7;  % Using T=128 segment length
[coh_z1,cl_z1]=sp2a2_zt(dat1(:,1),dat1(:,2),samp_rate,seg_pwr);
cl_z1.what=['\tau=',num2str(tau),' s.'];

% Plot coherence estimate, averaged over all frequencies,
ch_max=1;

% Frequency indices to average over, using all values give (T/2)-1 values. For T=128 this is 63.
freq_ind=(1:63)';

% Single frequency plot
freq_one_ind=5; % Arbitrary index

% Plotting over time without target coherence
figure
subplot(2,1,1)  % Averaged
  pspzt_ch1(coh_z1,cl_z1,freq_ind,ch_max) 
subplot(2,1,2)  % Single frequency
  pspzt_ch1(coh_z1,cl_z1,freq_one_ind,ch_max)
  
% Plotting over time with target coherence
figure
subplot(2,1,1)  % Averaged
  pspzt_ch1_target(coh_z1,cl_z1,ch_target1,freq_ind,ch_max) 
subplot(2,1,2)  % Single frequency
  pspzt_ch1_target(coh_z1,cl_z1,ch_target1,freq_one_ind,ch_max)

% Plotting at fixed segment
seg_no_plot=[79 153 199]; % These roughly at coherence maximum, minimum and ~0.5 for tau=20 data
freq_max=500;  % Frequency range
figure
subplot(3,1,1)
  pspzt_ch1_seg(coh_z1,cl_z1,seg_no_plot(1),freq_max,ch_max) 
subplot(3,1,2)
  pspzt_ch1_seg(coh_z1,cl_z1,seg_no_plot(2),freq_max,ch_max) 
subplot(3,1,3)
  pspzt_ch1_seg(coh_z1,cl_z1,seg_no_plot(3),freq_max,ch_max) 

% Plot coherence as heat map
freq_range=[0 100];
ch_max=1;
figure
h1=subplot(3,1,1);
  plot((0:length(dat1)-1)/samp_rate,dat1(:,1),'k')
  title(['Ramp data, \tau: ',num2str(tau),'s, Ch 1.'])
  xlabel('Time (s)')
h2=subplot(3,1,2);
  plot((0:length(dat1)-1)/samp_rate,dat1(:,2),'k')
  title(['Ramp data, \tau: ',num2str(tau),'s, Ch 2.'])
  xlabel('Time (s)')
subplot(3,1,3)
   [h_plot,h_bar]=pspzt_ch1_tf(coh_z1,cl_z1,freq_range,ch_max);

% Resize to align plots
drawnow
h1.Position(3)=h_plot.Position(3);
h2.Position(3)=h_plot.Position(3);
