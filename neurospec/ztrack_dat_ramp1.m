function [dat_out,coh_all] = ztrack_dat_ramp1(coh_start,coh_stop,tau,samp_rate,n_rep,t_start,n_sets,plot_flag)
%function [dat_out,coh_all] = ztrack_dat_ramp1(coh_start,coh_stop,tau,samp_rate,n_rep,t_start,n_sets,plot_flag)
%
% Function to generate test data for z-tracker using weighted combination of randn signals.
% Generates two signals, with pre-specified target coherence.
%
% Copyright (C) 2018, David M. Halliday.
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
% Target coherence generated as ramp sections with linear increase and linear decrease.
% Can include constant coherence sections at start and end.
% Can generate several ramp increase/decrease sections in data.
%
%  Input    coh_start   Minimum value of coherence  (0<= coh_start < 1)
%           coh_stop    Maximum value of coherence  (0<  coh_stop <= 1)
%           tau         Duration of single ramp section, same value for increase and decrease, seconds.
%           samp_rate   Assumed sampling rate for data (samp/sec)
%           n_rep       No of repetitions or ramp increase/decease, integer.
%           t_start     Duration of any lead in and lead out times where coherence constant, seconds.
%           n_sets      No of sets of data to generate (integer)
%           plot_flag   Plot target coherence (0: No; 1: Yes)
%
% Output    dat_out     3D data matrix [samples,2,n_sets]
%           coh_all     Vector of target R^2 weights, same length as data matrix
%
%function [dat_out,coh_all] = ztrack_dat_ramp1(coh_start,coh_stop,tau,samp_rate,n_rep,t_start,n_sets,plot_flag)

if (nargin<7)
  error('Not enough input arguments')
end
if (nargin<8)
  plot_flag=0;
end 

% Single triangular modulation of coherence
triang_pts=round(tau*samp_rate);
% Only works with even number of points in duration tau (sec)
if mod(triang_pts,2)
  error(' Number of points in tau NOT even')
end
coh_up=linspace(coh_start,coh_stop,triang_pts/2)';
coh_triang=[coh_up;flipud(coh_up)];

% Starting section with constant coherence
coh_initial=coh_start*ones(round(t_start*samp_rate),1);

% Complete coherence specification
coh_all=coh_initial;
for ind=1:n_rep
  coh_all=[coh_all;coh_triang];
end
coh_all=[coh_all;coh_initial];

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
  xlabel('Time (s)')
end
