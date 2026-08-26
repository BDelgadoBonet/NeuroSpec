% Script: ztrack_ramp_demo2.m
%
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
%
% Reference: Halliday DM, Brittain J-S, Stevenson CW, Mason R (2018)
%  Adaptive Spectral Tracking for Coherence Estimation: The z-tracker.
%  Journal of Neural Engineering, 15(2), 026004.
%  https://doi.org/10.1088/1741-2552/aaa3b4
%
% This script generates data with linear increase and step decrease in target coherence
%  using randomly determined transition points.

% This for ascending ramp and step decrease
r2_trigger_min=0.8;   % Minimum values for triggering step
r2_target_min=0;      % Minimum value for step change
r2_trigger_range=0.2; % Range for trigger above minimum
r2_target_range=0.2;  % Range for target above minimum
r2_inc=1/9999;        % Increment for ramp at each segement before step (+ve or -ve)
r2_start_0=0;         % Start value of coherence (usually 0 or 1)
samp_rate=1000;
n_rep=10;             % No of step changes to include
n_sets=100;           % No of data sets to generate
plot_flag=1;

% Generate data
[dat_out,coh_all,trig_samp] = ztrack_dat_ramp_step1(r2_trigger_min,r2_target_min,r2_trigger_range,r2_target_range,r2_inc,r2_start_0,samp_rate,n_rep,n_sets,plot_flag);

% For analysis - see ztrack_ramp_demo1.m
