function psp2_tf(f,t,cl,freq,lag_tot,lag_neg,t_inc,n_contour,line_flag,coh_contour)
% function psp2_tf(f,t,cl,freq,lag_tot,lag_neg,t_inc,n_contour,line_flag,coh_contour)
% Function to display results of type 2 spectral analysis, over range of offset values.
% Generates 3 plots. 1: Two time dependent spectra and coherence.
%                    2: Time dependent coherence and phase.
%                    3: Time dependent cumulant density.
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
% 
% Inputs f,t,cl      Output from spectral analysis routine.
%        freq        Frequency limit for plotting (Hz).
%        lag_tot     Total lag range for time domain including -ve lags (ms).
%        lag_neg     Negative lag range for time domain (ms).
%        t_inc       Optional increment for labels on time axis (0: auto scales).
%                     No longer used - value ignored.
%        n_contour   Optional number of contours to use (default 10).
%        line_flag   Optional flag to control drawing of contour lines - 0:No (default), 1:Yes.
%        coh_contour Optional vector of contour heights for coherence.
%
% function psp2_tf(f,t,cl,freq,lag_tot,lag_neg,t_inc,n_contour,line_flag,coh_contour)
%
% Revised July 2016, using revised plotting functions compatible with MATLAB R2014b graphics

% Check numbers of arguments. 
if (nargin<6)
  error('Not enough input arguments');
end

% Defaults
%if (nargin<7)
%  t_inc=0;  % Value not used, for backward compatability.
%end  
if (nargin<8)
  n_contour=10;  % Default is 10 contours
end  
if (nargin<9)
  line_flag=0;   % Default is NO contour lines
end  

% Mask coherence values below confidence limit, set to zero
mask_flag=0;  % Default is off

% Figure 1: two autospectra and coherence
figure
colorbar_flag=0;  % No colorbars in this plot
subplot(3,1,1)
psptf_fa1a(f,cl,freq,n_contour,colorbar_flag,line_flag)
subplot(3,1,2)
psptf_fb1a(f,cl,freq,n_contour,colorbar_flag,line_flag)
subplot(3,1,3)
if (nargin>9)
  psptf_ch1a(f,cl,freq,n_contour,colorbar_flag,line_flag,mask_flag,coh_contour)
else
  psptf_ch1a(f,cl,freq,n_contour,colorbar_flag,line_flag,mask_flag)
end

% Figure 2: coherence and phase
figure
colorbar_flag=1;  % Include colorbars in this plot
subplot(2,1,1)
if (nargin>9)
  psptf_ch1a(f,cl,freq,n_contour,colorbar_flag,line_flag,mask_flag,coh_contour)
else
  psptf_ch1a(f,cl,freq,n_contour,colorbar_flag,line_flag,mask_flag)
end
subplot(2,1,2)
psptf_ph1a(f,cl,freq,n_contour,colorbar_flag,line_flag)

% Figure 3: cumulant density
figure
psptf_q1a(t,cl,lag_tot,lag_neg,n_contour,line_flag)
