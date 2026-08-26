function [coh,cl] = sp2_fn2_zta(d1,d2,samp_rate,z_alpha,flags)
% function [coh,cl] = sp2_fn2_zta(d1,d2,samp_rate,z_alpha,flags)
%
% Function with core routines for  multi-taper single segment coherence estimates,
%  to support z-tracker analysis of coherence estimates over segments.
% This function constructs single segment coherence estimates prior to calling z-tracker.
% see NOTE below about calling this routine.
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
%  Inputs are two matrices containing pre processed data.
%  Matrices have L columns with T rows.
%   L = Number of segments: seg_tot.
%   T = DFT segment length: seg_size.
% 
% Input arguments
%  d1          Channel 1 data matrix.
%  d2          Channel 2 data matrix.
%  samp_rate   Sampling rate (samples/sec)
%  z_alpha     alpha in q_l smoothing, JNE (7)
%  flags       Structure with flags to control processing options.
%
% Output arguments
%  coh  Matrix with coherence estimate over segments, size [T/2-1, L], T=seg_size, L=seg_tot.
%  cl   single structure with scalar values related to analysis.
%
% Reference:
% Halliday DM, Brittain J-S, Stevenson CW, Mason R
%    Journal of Neural Engineering, 15(2), 026004, 2018.
% Reference referred to in comments as JNE
%
% function [coh,cl] = sp2_fn2_zta(d1,d2,samp_rate,flags)
%
% NOTE: This routine is not intended to support analysis of raw data.
% It is intended as a support routine for the z-tracker spectral analysis function:
% sp2a2_zt.m. Refer to this function for further details.

[seg_size,seg_tot]=size(d1); % Calculate seg_size (T) & seg_tot (L) from data matrices.
samp_tot=seg_size*seg_tot;   % Total no of samples analysed.

% Load dpss sequences, needs additional file NS_dpss_dat.mat
global NS_dpss
if isempty(NS_dpss)
  load NS_dpss_dat
end
eval_str=['NS_dpss.pwr',num2str(flags.seg_pwr),'.tap',num2str(flags.MT_tap),';'];
taper=eval(eval_str);  % Extract dpss tapers

eval_str=['NS_dpss.pwr',num2str(flags.seg_pwr),'.eig',num2str(flags.MT_tap),';'];
MT_eig=eval(eval_str);  % Extract eigenvalues

% 3-D Matrices for fd1 and fd2
fd1=zeros(seg_size,seg_tot,flags.MT_tap);
fd2=zeros(seg_size,seg_tot,flags.MT_tap);
% Matrices with 1 column for each taper
dat_mt1=zeros(seg_size,flags.MT_tap);
dat_mt2=zeros(seg_size,flags.MT_tap);
% U2 factor for DPSS tapers
u2_norm=sqrt(1/seg_size);

for ind=1:seg_tot
  for ind_MT=1:flags.MT_tap
    dat_mt1(:,ind_MT)=d1(:,ind);  % Copy data into all columns
    dat_mt2(:,ind_MT)=d2(:,ind);
  end
  fd1(:,ind,:)=fft(dat_mt1.*taper)/u2_norm; % DFT of single segment, using multiple windows, JNE(1)
  fd2(:,ind,:)=fft(dat_mt2.*taper)/u2_norm; % DFT of single segment, using multiple windows, JNE(1)
end

% Frequency indices to use in tracking: f_1 to f_(N-1), don't include f_0 or f_N, DC or Nyquist.
ch_ind=(2:seg_size/2)';

% Single segment coherency estimate, JNE(3)
chy_seg=abs(sum(fd2(ch_ind,:,:).*conj(fd1(ch_ind,:,:)),3))./sqrt(sum(abs(fd1(ch_ind,:,:).*fd1(ch_ind,:,:)),3).*sum(abs(fd2(ch_ind,:,:).*fd2(ch_ind,:,:)),3));
% Single segment z estimate, JNE(4)
z=atanh(chy_seg);

% Spacing of Fourier frequencies in Hz.
deltaf=samp_rate/seg_size;

% Call function sp2_fn_ztb for z-tracker analysis
params.deltaf=deltaf;
params.ch_ind=ch_ind;
params.ost_ek=0;
% Default uses all frequencies in calculation of e_l, JNE (6)
params.ost_ek_range=[]; 
% Filtering only option, no smoothing.
params.ost_track_only=flags.ost_track_only;
[coh,cl_zt]=sp2_fn2_ztb(z,z_alpha,params);

% Construct cl structure, confidence limits for parameter estimates.
cl=cl_zt;                % Values returned by sp2_fn2_ztb

cl.type=flags.sp_type;   % Analysis type.
cl.seg_size=seg_size;    % T.
cl.seg_tot=seg_tot;      % L.
cl.samp_tot=samp_tot;    % R.
cl.samp_rate=samp_rate;  % Sampling rate.
cl.df=deltaf;            % Delta f.
cl.MT=flags.MT;          % Flag indicating multi-taper (MT) estimate - 0: No, 1: Yes
cl.MT_NW=flags.NW;       % NW for MT estimates
cl.MT_tap=flags.MT_tap;  % No of tapers in MT estimate
cl.MT_eig=MT_eig;        % Eigenvalues for individual eigen spectra in MT estimate  

return
