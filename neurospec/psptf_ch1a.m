function psptf_ch1a(f,cl,freq,n_contour,colorbar_flag,line_flag,mask_flag,coh_contour)
% function psptf_ch1a(f,cl,freq,n_contour,colorbar_flag,line_flag,mask_flag,coh_contour)
% Function to display time dependent coherence estimate in current subplot window.
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
%    f              Frequency matrix from type 2 analysis, over range of offset values.
%    cl             cl structure from type 2 analysis.
%    freq           Frequency limit for plotting.
%    n_contour      Optional number of contours to use (default 10).
%    colorbar_flag  Optional flag to control drawing of colorbar      - 0:No(default), 1:Yes.
%    line_flag      Optional flag to control drawing of contour lines - 0:No(default), 1:Yes.
%    mask_flag      Optional flag to mask coherence values below confidence limit - 0:No(default), 1:Yes.
%    coh_contour    Optional vector of contour heights for coherence.
%
% function psptf_ch1a(f,cl,freq,n_contour,colorbar_flag,line_flag,mask_flag,coh_contour)

% Revised plotting compatible with MATLAB R2014b graphics

% Check numbers of arguments. 
if (nargin<3)
  error('Not enough input arguments');
end
if (cl(1).type~=2)
  error('Not type 2 analysis')
end

% Defaults
n_seg=length(f(1,1,:));  % No of time slice segments.
if (n_seg<3)
  error('Less than 3 time offsets')
end

if (nargin<4)
  n_contour=10;
end  
if (nargin<5)
  colorbar_flag=0;
end  
if (nargin<6)
  line_flag=0;
end  
if nargin<7
	mask_flag=0;
end

% Extract frequency range
plot_ind=find(f(:,1,1)<=freq);
% Frequency axis in Hz
freq_axis=f(plot_ind,1,1);

% Extract time axis values
dt=cl(1).dt; % Sampling interval (ms). 
time_axis=[];
for ind=1:n_seg
	time_axis=[time_axis; cl(ind).offset*dt];
end

% Contour values
if (nargin<8)
  ch_max=max(max(f(plot_ind,4,:)));
  ch_min=cl(1).ch_c95;
  ch_int=(ch_max-ch_min)/(n_contour-1);
  coh_contour=[0 ch_min:ch_int:ch_max];
else
  coh_contour=[0 cl(1).ch_c95 coh_contour];  
end

% Extract coherence
ch=squeeze(f(plot_ind,4,:));

% Mask values below confidence limit
if mask_flag
	ch(find(ch<cl(1).ch_c95))=0.0; % Mask at zero
end

% Plot Time dependent Coherence.
[C,h]=contourf(time_axis,freq_axis,ch,coh_contour);
if (line_flag==0)
  for ind=1:length(h)
    set(h(ind),'LineStyle','none')
  end
end
xlabel ('Offset (ms)')
ylabel ('Frequency (Hz)')
title([cl(1).what,' Time dependent Coherence'])

% Use jet colormap, no longer default from R2014b onwards
colormap(jet)
if (colorbar_flag)
	H1=gca;
  H=colorbar;
% For older graphics can add confidence limit as line to colorbar
	if  verLessThan('matlab','8.4')
		v=get(H);
	  axes(H)
	  for sect_ind=1:n_seg
	    ch_c95_vector=[v.XLim;cl(sect_ind).ch_c95,cl(sect_ind).ch_c95];
	    line(ch_c95_vector(1,:),ch_c95_vector(2,:),'Color','k')
	  end
  	axes(H1)
	end	
end
