function [dat_out,coh_all,trig_samp] = ztrack_dat_ramp_step1(r2_trigger_min,r2_target_min,r2_trigger_range,r2_target_range,r2_inc,r2_start_0,samp_rate,n_rep,n_sets,plot_flag)
%function [dat_out,coh_all,trig_samp] = ztrack_dat_ramp_step1(r2_trigger_min,r2_target_min,r2_trigger_range,r2_target_range,r2_inc,r2_start_0,samp_rate,n_rep,n_sets,plot_flag)
%
% Function to generate test data for z-tracker using weighted combination of randn signals.
% Generates two signals, with pre-specified target coherence.
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
% Coherence generated as ramp sections with linear increase and step change at end of each ramp.
%
%  Input
%   r2_trigger_min    Minimum value for trigger point to stop ramp increase or decrease (scalar, range: 0, 1)
%   r2_target_min     Minimum value for target point for step change at end of each ramp (scalar, range: 0, 1)
%   r2_trigger_range  Range of trigger zone (scalar, >0)
%   r2_target_range   Range of target zone  (scalar <0)
%   r2_inc            Increment for ramp, can be +ve or -ve
%   r2_start_0        Start value for first ramp, 0: for increasing; 1: for decreasing
%   samp_rate         Assumed sampling rate
%   n_rep             No of repetitions in each data set, i.e. no of ramp sections
%   n_sets            No of data sets to generate with same target coherence
%   plot_flag         Plot target coherence (0: No; 1: Yes)
%
% Output    dat_out     3D data matrix [samples,2,n_sets]
%           coh_all     Vector of target R^2 weights, same length as data matrix
%           trig_samp   Location of R^2 jumps, sample value for end of each ramp
%
%function [dat_out,coh_all,trig_samp] = ztrack_dat_ramp_step1(r2_trigger_min,r2_target_min,r2_trigger_range,r2_target_range,r2_inc,r2_start_0,samp_rate,n_rep,n_sets,plot_flag)

if (nargin<7)
  error('Not enough input arguments')
end
if (nargin<8)
  plot_flag=0;
end 

% Generate random trigger and target points for ramp
r2_trigger=r2_trigger_min+rand(n_rep+1,1)*r2_trigger_range;
r2_target=r2_target_min+rand(n_rep+1,1)*r2_target_range;

% Initialise target coherence
coh_all=[];
r2_start=r2_start_0;

% Array for trigger samples, location of step changes
trig_samp=[];

% Generate target coherence with one ramp every repetition
for ind_rep=1:n_rep+1
   coh_all=[coh_all; (r2_start:r2_inc:r2_trigger(ind_rep))'];
   trig_samp=[trig_samp; length(coh_all)];
   r2_start=r2_target(ind_rep);
end
trig_samp=trig_samp(1:n_rep);

% Generate n_sets of data as output
dat_pts=length(coh_all);
dat_out=zeros(dat_pts,2,n_sets);

for ind_out=1:n_sets
  dat=randn(dat_pts,2);
  % Generate data, sqrt() weigthing
  dat_out(:,1,ind_out)=dat(:,1);
  dat_out(:,2,ind_out)=sqrt(coh_all).*dat(:,1)+sqrt(1-coh_all).*dat(:,2);
end
  
% Plotting
if (plot_flag)
  figure
  plot((0:length(coh_all)-1)'/samp_rate,coh_all,'k')
  grid on
  axis([0 inf -0.02 1.02])
  title(['Target coherence. Pts: ',num2str(length(coh_all)),'.  Rate: ',num2str(samp_rate)])
  hold on
  plot(trig_samp/1000,coh_all(trig_samp),'r+')
  hold off
  xlabel('Time (s)')
end
