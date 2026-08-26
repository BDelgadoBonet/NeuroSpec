% Script: ztrack_ramp_demo1.m
%
% Script to demonstrate use of NeuroSpec 2.2
% z-tracker estimate of time varying coherence over segmented data
% This script generates data used in figures in accompanying publication, reference below.
% To plot figures use scripts:
%   ztrack_ramp_demo1_plot1.m
%   ztrack_ramp_demo1_plot_msd1.m
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
%
% Reference: Halliday DM, Brittain J-S, Stevenson CW, Mason R (2018)
%  Adaptive Spectral Tracking for Coherence Estimation: The z-tracker.
%  Journal of Neural Engineering, 15(2), 026004.
%  https://doi.org/10.1088/1741-2552/aaa3b4
%
% This script generates surrogate data with known modulation of coherence.
% Triangular modulation of coherence, linear increase then decrease.
% Two time scales: 1)tau=20 sec, 10 repetitions 2) tau=2 sec, 100 repetitions
% Coherence modulated from 0 -> 1 over thes tau values (tau is increase and decrease)
%  Five values of T: T=2^7, 2^8, 2^9, 2^10
%  Four values of alpha in OST: 0.1, exp(-1), exp(-1/2), 0.9
% Number of repeat runs (100) generated for each configuration
%
% Note: This script will generate around 2.8GB of data in default configuration,
% and will require 10+ minutes run time.

% Start and stop target values for coherence ramps.
coh_start=0;
coh_stop=1;

% Define tau values and number of repetitions for triangular modulation of coherence
%  these are rise+fall times and number repetitions of this within each run.
% 20 sec
tau=20;    % tau=20 s
n_rep=10;  % 10 of these -> 200 sec

% 2 sec - uncomment to use tau=2 sec ramp increase/decrease in coherence
%tau=2;      % tau=2 s
%n_rep=100;  % 100 of these -> 200 sec

t_start=0; % No additional lead in lead out sections

n_sets=100;   % No of sets of data for each configuration
% Assumed sampling rate.
samp_rate=1000;

% Segment powers and segment sizes in z-tracker
seg_pwr_all=[7 8 9 10];
seg_size_all=2.^seg_pwr_all;

% z-tracker options: four values of alpha tracking & four values of alpha smoothing
% alpha = 0.1, exp(-1), exp(-1/2), 0.9
Q_str_all=[{'a0.1 T'},{'a0.3679 T'},{'a0.6065 T'},{'a0.9 T'},{'a0.1'},{'a0.3679'},{'a0.6065'},{'a0.9'}];

% Storage for OST outputs
coh=cell(length(seg_size_all),1);
cl=cell(length(seg_size_all),length(Q_str_all));

% Storage for data and target coherence
dat=cell(1,1);
w=cell(1,1);
% Plotting of target coherence
w_plot_flag=0;  % 0/1 0: No; 1: Yes

% Generate data and target coherence over samples
[dat{1},ch_target{1}]=ztrack_dat_ramp1(coh_start,coh_stop,tau,samp_rate,n_rep,t_start,n_sets,w_plot_flag);

% z-tracker analysis 
for ind_seg=1:length(seg_size_all)  % Loop over segment sizes
  seg_pwr=seg_pwr_all(ind_seg);
  seg_size=seg_size_all(ind_seg);

  for ind=1:n_sets                  % Loop over sets
    disp(['                                                     Tau, Seg, run: ',num2str([tau seg_size ind])])

    for ind_q=1:length(Q_str_all)   % Loop over z-tracker configuration (alpha, track/smooth)
      [coh_tmp1,cl_tmp1]=sp2a2_zt(dat{1}(:,1,ind),dat{1}(:,2,ind),samp_rate,seg_pwr,Q_str_all{ind_q});
      coh{ind_seg}(:,:,ind_q,ind)=coh_tmp1;  % Store coherence matrix
      cl{ind_seg,ind_q}(ind)=cl_tmp1;        % Store cl
    end  % z-tracker configurations
  end    % sets
end      % segment sizes


% To save as MAT file, NB -v7.3 for large cell structures
% save ztrack_ramp_demo1 -v7.3
