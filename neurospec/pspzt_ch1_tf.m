function [h_plot,h_bar]=pspzt_ch1_tf(coh,cl,frange,ch_max,label)
% function [h_plot,h_bar]=pspzt_ch1_tf(coh,cl,frange,ch_max,label)
%
% function to plot z-tracker coherence estimate in current figure/subplot window as heat map using imagesc,
%  colorbar included.
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
%     Contact:  contact@neurospec.org
%
% coh,cl    Output from z-tracker analysis function, sp2a2_zt
% frange    Frequency range for plotting: [fmin fmax]
% label     Optional title instead of cl.what.
%
% Outputs
%    h_plot, h_bar  Optional handles to plot and colorbar, can use for re-alignment.
%
% function [h_plot,h_bar]=pspzt_ch1_tf(coh,cl,frange,ch_max,label)

% Check numbers of arguments. 
if (nargin<3)
  error('Not enough input arguments');
end
if (cl(1).type~=30)
  error('Not type 30 (z-tracker) analysis')
end

% Time index for z-tracker segments, using mid-point of each segment
%  start at T/2 for 1st segment
T=cl.seg_size;
n_seg=cl.seg_tot;
t_seg=(T/2+T*(0:n_seg-1)')/cl.samp_rate;

% Check frequency range
if (size(frange) == [1 2])
  if (frange(2)<=frange(1))
    error('frange values incorrect')
  end
else
  error('frange incorrectly specified. Use: [fmin fmax]')
end 
plot_ind=find(cl.ost_freqs>=frange(1) & cl.ost_freqs<=frange(2));
if (length(plot_ind)==0)
  error('No data to plot. Increase frequency range.')
end

% Frequency axis in Hz
freq_axis=cl.ost_freqs(plot_ind);

% Scale coherence
if (nargin>3)
  coh(max(plot_ind),end)=ch_max;
end

% Plot, invert frequency axis, minimum at bottom of plot
[h]=imagesc(t_seg,flipud(freq_axis),coh(plot_ind,:));

% Invert frequency axis labels.
h_plot=gca;
YTick_lab=get(gca,'YTickLabel');
YLim=get(gca,'YLim');
YTick_pos=get(gca,'YTick')';
set(h_plot,'YTick',YLim(2)-flipud(YTick_pos)+YLim(1),'YTickLabel',flipud(YTick_lab))

xlabel('Time (s)')
ylabel ('Frequency (Hz)')
if (nargin>4)
  title(label);
else
 title(['ztrack coh. ',cl.what]);
end  

% colorbar
h_bar=colorbar;
axes(h_plot)
if (nargout<=1)
  clear h_bar h_plot
end 
