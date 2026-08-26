function pspzt_ch1(coh,cl,freq_ind,ch_max,label)
%  pspzt_ch1(coh,cl,freq_ind,ch_max,label)
%
% function to plot time varying z-tracker coherence estimate in current figure/subplot window
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
% freq_ind  Vector of frequency indices over which to average coherence,
%            use single index for single frequency. These integer indices.
% ch_max    Maximum value of y axis (Optional).
% label     Optional title instead of cl.what.
%
%  pspzt_ch1(coh,cl,freq_ind,ch_max,label)

if (nargin<3)
  error('Not enough input arguments')
end  
if (cl(1).type~=30)
  error('Not type 30 (z-tracker) analysis')
end

% Check indices
[n_freq,n_seg]=size(coh);
if (min(freq_ind)<1)
  error('Error in freq_ind: Minimum index is 1')
end 
if max(freq_ind)>n_freq
  error('Error in freq_ind: Requested range too large.');
end

% Time index for z-tracker segments, using mid-point of each segment
%  start at T/2 for 1st segment
T=cl.seg_size;
n_seg=cl.seg_tot;
t_seg=(T/2+T*(0:n_seg-1)')/cl.samp_rate;

% Extract coherence values
r2_dat=coh(freq_ind,:);

% Extract Pk values
Pk=cl.ost_P;

% Matrices with upper and lower point-wise confidence limits.
r2_dat_clu=atanh(sqrt(r2_dat));  % working in z-domain
r2_dat_cll=r2_dat_clu;
for ind_seg=1:n_seg
  r2_dat_clu(:,ind_seg)=r2_dat_clu(:,ind_seg)+1.96*sqrt(Pk(ind_seg));  % Upper 95% CL
  r2_dat_cll(:,ind_seg)=r2_dat_cll(:,ind_seg)-1.96*sqrt(Pk(ind_seg));  % Lower 95% CL
end
% Cap lower CL at zero
r2_dat_cll(find(r2_dat_cll<0))=0;
r2_dat_clu=tanh(r2_dat_clu).^2;  % Convert back to coherence domain
r2_dat_cll=tanh(r2_dat_cll).^2;

% Plot mean over frequencies, transpose to column format
plot(t_seg,mean(r2_dat',2),'k.')
hold on
% Add in Confidence limits
plot(t_seg,mean(r2_dat_clu',2),'k')
plot(t_seg,mean(r2_dat_cll',2),'k')
hold off

if (nargin<4)
  axis([0,Inf,0,Inf]);
else
  axis([0,Inf,0,ch_max]);
end  
xlabel('Time (s)')

% Frequency range
if length(freq_ind)==1
  freq_str=['Freq : ',num2str(cl.ost_freqs(freq_ind),' %.2f'),' Hz'];
else
  freq_str=['Freq range: ',num2str(min(cl.ost_freqs(freq_ind)),' %.2f'),' - ',num2str(max(cl.ost_freqs(freq_ind)),' %.2f'),' Hz (Tot: ',num2str(length(freq_ind)),')'];
end

if (nargin>4)
  title(label);
else
 title(['ztrack coh, ',freq_str,', ',cl.what]);
end  
