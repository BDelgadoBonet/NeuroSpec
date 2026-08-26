function psptf_q1a(t,cl,lag_tot,lag_neg,n_contour,line_flag)
% function psptf_q1a(t,cl,lag_tot,lag_neg,n_contour,line_flag)
% Function to display time dependent cumulant estimate in current subplot window.
%
% Copyright (C) 2008, 2016, David M. Halliday.
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
% Inputs
%    t              Time matrix from type 2 analysis, over range of offset values.
%    cl             cl structure from type 2 analysis.
%    lag_tot        Total lag range for time domain including -ve lags (ms).
%    lag_neg        Negative lag range for time domain (ms).
%    n_contour      Optional number of contours to use (default 10).
%    line_flag      Optional flag to control drawing of contour lines - 0:No(default), 1:Yes.
%
% function psptf_q1a(t,cl,lag_tot,lag_neg,n_contour,line_flag)

% Revised plotting compatible with MATLAB R2014b graphics

% Check numbers of arguments. 
if (nargin<4)
  error('Not enough input arguments');
end
if (cl(1).type~=2)
  error('Not type 2 analysis')
end

% Defaults
n_seg=length(t(1,1,:));  % No of time slice segments.
if (n_seg<3)
  error('Less than 3 time offsets')
end
if (nargin<5)
  n_contour=10;
end  
if (nargin<6)
  line_flag=0;
end  

bin_start=cl(1).seg_size/2+1-round(lag_neg/cl(1).dt);
bin_stop=bin_start+round(lag_tot/cl(1).dt)-1;
%Check lag range
[x,y]=size(t(:,:,1));
if (bin_start<1 | bin_start>=bin_stop | bin_stop>x)
  error('Error in requested lag range.');
end

% Extract time axis values
dt=cl(1).dt; % Sampling interval (ms). 
time_axis=[];
for ind=1:n_seg
	time_axis=[time_axis; cl(ind).offset*dt];
end

% Lag axis in ms
lag_axis=t(bin_start:bin_stop,1,1);

% Plot Time dependent cumulant.
[C,h]=contourf(time_axis,lag_axis,squeeze(t(bin_start:bin_stop,2,:)),n_contour);
H1=gca;
if (line_flag==0)
  for ind=1:length(h)
    set(h(ind),'LineStyle','none')
  end
end
xlabel ('Offset (ms)')
ylabel ('Lag (ms)')
title([cl(1).what, ' - Time dependent cumulant'])

% Use jet colormap, no longer default from R2014b onwards
colormap(jet)
H=colorbar;
% For older graphics can add confidence limits as line to colorbar
if  verLessThan('matlab','8.4')
	v=get(H);
	axes(H)
	for q_ind=1:n_seg
	  q_c95u_vector=[v.XLim;cl(q_ind).q_c95,cl(q_ind).q_c95];
	  line(q_c95u_vector(1,:),q_c95u_vector(2,:),'Color','k')
	  q_c95l_vector=[v.XLim;-cl(q_ind).q_c95,-cl(q_ind).q_c95];
	  line(q_c95l_vector(1,:),q_c95l_vector(2,:),'Color','k')
	end
	axes(H1)
end	
