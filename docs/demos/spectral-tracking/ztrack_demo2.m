% Script: ztrack_demo2.m
% Script to demonstrate use of NeuroSpec 2.2
% z-tracker estimate of time varying coherence over segmented data
%
% Copy of demo 1, explores use of different values of alpha  and filtering/smoothing options in z-tracker
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
n_rep=3;     % 3 repetitions, 60 sec data generated
t_start=0;   % No initial lead in where coherence constant
n_sets=1;    % Only 1 set of data here
plot_flag=1; % Plot figure with target coherence
samp_rate=1000; % Assumed sampling rate for data
[dat1,ch_target1]=ztrack_dat_ramp1(coh_start,coh_stop,tau,samp_rate,n_rep,t_start,n_sets,plot_flag);

% z-tracker analysis
seg_pwr=7;  % Using T=128 segment length

% Different values of alpha in z-tracker, alpha = 0.1, exp(-1), exp(-1/2), 0.9 (default is 0.9)
alpha_str1=[{'a0.1'},{'a0.3679'},{'a0.6065'},{'a0.9'}]; % These with filtering and smoothing

% For filtering only include 'T' options, NB uppercase T
alpha_str2=[{'a0.1 T'},{'a0.3679 T'},{'a0.6065 T'},{'a0.9 T'}]; % These filtering only

alpha_str=alpha_str1; % Select filtering and smoothing (default) or filtering/tracking only.
[coh_z1,cl_z1]=sp2a2_zt(dat1(:,1),dat1(:,2),samp_rate,seg_pwr,alpha_str{1});
[coh_z2,cl_z2]=sp2a2_zt(dat1(:,1),dat1(:,2),samp_rate,seg_pwr,alpha_str{2});
[coh_z3,cl_z3]=sp2a2_zt(dat1(:,1),dat1(:,2),samp_rate,seg_pwr,alpha_str{3});
[coh_z4,cl_z4]=sp2a2_zt(dat1(:,1),dat1(:,2),samp_rate,seg_pwr,alpha_str{4});
cl_z1.what=['\tau=',num2str(tau),' s, ',alpha_str{1}];
cl_z2.what=['\tau=',num2str(tau),' s, ',alpha_str{2}];
cl_z3.what=['\tau=',num2str(tau),' s, ',alpha_str{3}];
cl_z4.what=['\tau=',num2str(tau),' s, ',alpha_str{4}];

% Plots including target coherence
ch_max=1;
% Frequency indices to average over, using all values give (T/2)-1 values. For T=128 this is 63.
freq_ind=(1:63)';
figure
subplot(4,1,1)
  pspzt_ch1_target(coh_z1,cl_z1,ch_target1,freq_ind,ch_max)
subplot(4,1,2)
  pspzt_ch1_target(coh_z2,cl_z2,ch_target1,freq_ind,ch_max)
subplot(4,1,3)
  pspzt_ch1_target(coh_z3,cl_z3,ch_target1,freq_ind,ch_max)
subplot(4,1,4)
  pspzt_ch1_target(coh_z4,cl_z4,ch_target1,freq_ind,ch_max)

% Single frequency plots
freq_one_ind=5; % Arbitrary index
figure
subplot(4,1,1)
  pspzt_ch1_target(coh_z1,cl_z1,ch_target1,freq_one_ind,ch_max)
subplot(4,1,2)
  pspzt_ch1_target(coh_z2,cl_z2,ch_target1,freq_one_ind,ch_max)
subplot(4,1,3)
  pspzt_ch1_target(coh_z3,cl_z3,ch_target1,freq_one_ind,ch_max)
subplot(4,1,4)
  pspzt_ch1_target(coh_z4,cl_z4,ch_target1,freq_one_ind,ch_max)

  