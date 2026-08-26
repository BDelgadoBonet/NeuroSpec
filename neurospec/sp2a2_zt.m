function [coh,cl] = sp2a2_zt(dat1,dat2,samp_rate,seg_pwr,opt_str)
% [coh,cl] = sp2a2_zt(dat1,dat2,samp_rate,seg_pwr,opt_str)
%
% Two channel coherence tracking over disjoint segments using z-tracker,
%  outputs coherence over segments.
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
% Input arguments
%  dat1       Channel 1  (input) time series vector.
%  dat2       Channel 2 (output) time series vector.
%  samp_rate  Sampling rate (samples/sec).
%  seg_pwr    Segment length - specified as power of 2.
%  opt_str    Options string.
%
% Output arguments
%  coh  Matrix with coherence over segments, size [T/2-1, L], T=seg_size, L=seg_tot.
%  cl   single structure with scalar values related to analysis.
%
% Input Options
%  a  Specify value of alpha in q_l smoothing, default is alpha=0.9, option requires argument
%                     a<alpha>:  Specify alpha, valid range 0.1 <= alpha <= 0.9
%                     e.g. to change to alpha=0.1 use 'a0.1' as option
%  n  Normalise to unit variance within each segment.
%  r  Rectification - this options requires an argument, valid arguments are:[0, 1, 2].
%                      r0:  Rectify Input  channel  (dat1)
%                      r1:  Rectify Output channel  (dat2)
%                      r2:  Rectify Both   channels (dat1 & dat2)
%  t  linear De-trend - this options requires an argument, valid arguments are:[0, 1, 2].
%                      t0:  De-trend Input  channel  (dat1)
%                      t1:  De-trend Output channel  (dat2)
%                      t2:  De-trend Both   channels (dat1 & dat2)
%  T  Using only filtering in z-tracker, no smoothing.
%     Default is smoothing using forward then reverse Kalman filtering.
%
%  cl.ost_pts     No of frequency values, T/2-1, all frequencies except f_0 and f_N
%  cl.ost_freqs   Array of frequency values, Fourier frequencies
%  cl.ost_ek_ind  List of indices to calculate   E{e_l^2}, first term JNE (6)
%  cl.ost_ek_pts  No of points in calculation of E{e_l^2}, first term JNE (6)
%  cl.ost_alpha   Value of alpha in smoothing q_l, JNE equation (7)
%  cl.ost_R       Array of single segment variance, r_l, JNE section 2.3, l=1,...,L
%  cl.ost_e       Array of E{e_l^2} values for each segment, first term JNE (6), l=1,...,L
%  cl.ost_R_0     Array of E{e_l^2 |q=0) values each segment, JNE (5), l=1,...,L
%  cl.ost_Q       Array of smoothed q_l for each segment, JNE (7), l=1,...,L
%  cl.ost_Ql      Array of single segment q'_l, JNE (6), l=1,...,L
%  cl.ost_Pp      Array of apriori Kalman filter error terms for each segment, P^p_l, JNE (A.6)
%  cl.ost_P       Array of aposteriori Kalman filter error terms for each segment, P_l, JNE (A.4)
%  cl.ost_K       Array of Kalman filter gain, K_l, for each segment, JNE Appendix A
%  cl.ost_A       Array of Kalman filter gain, A_l, for backward pass for each segment, JNE Appendix A
%  cl.type        Analysis type, 30 for z-tracker analysis
%  cl.seg_size    Segment length, T                                   
%  cl. seg_tot    Number of segments, L                               
%  cl.samp_tot    Number of samples analysed, R=LT                    
%  cl.samp_rate   Sampling rate of data (samples/sec)                 
%  cl.df          Frequency domain bin width (Hz)                                                    
%  cl.MT          Flag indicating multi-taper (MT) estimate - 0: No, 1: Yes
%  cl.MT_NW       NW for MT estimates                                      
%  cl.MT_tap      No of tapers in MT estiamte                              
%  cl.MT_eig      Eigenvalues for individual eigen spectra in MT estimate  
%  cl.opt_str     Copy of options string
%  cl.what        Text label, used in plotting routines
%
% Reference:
% Halliday DM, Brittain J-S, Stevenson CW, Mason R (2018)
%  Adaptive Spectral Tracking for Coherence Estimation: The z-tracker.
%  Journal of Neural Engineering, 15(2), 026004.
%  https://doi.org/10.1088/1741-2552/aaa3b4
% Reference referred to in comments as JNE
%
% [coh,cl] = sp2a2_zt(dat1,dat2,samp_rate,seg_pwr,opt_str)

% Check numbers of arguments
if (nargin<4)
  error(' Not enough input arguments');
end
if (nargout<2)
  error(' Not enough output arguments');
end

% Check for single column data
[nrow,ncol]=size(dat1);
if (ncol~=1)
  error(' Input NOT single column: dat1')
end
[nrow,ncol]=size(dat2);
if (ncol~=1)
  error(' Input NOT single column: dat2')
end

pts_tot=length(dat1);           % Determine size of data vector.
if (length(dat2)~=pts_tot)      % Check that input vectors are equal length. 
  error (' Unequal length data arrays');
end

if (max(size(samp_rate)) ~= 1)
  error(' Non scalar value for: samp_rate');
end
if (max(size(seg_pwr)) ~= 1)
  error(' Non scalar value for: seg_pwr');
end
seg_size=2^seg_pwr;                    % DFT segment length (T).
seg_tot=fix(pts_tot/seg_size);         % Number of complete segments (L).
samp_tot=seg_tot*seg_size;             % Number of samples to analyse: R=LT.
seg_samp_start=(1:seg_size:samp_tot)'; % Start times for each segment.
seg_samp_no(1:seg_tot,1)=seg_size;     % Fixed number of data points per segment, T.

% Create data matrices, T rows, L columns.
rd1=zeros(seg_size,seg_tot);
rd2=zeros(seg_size,seg_tot);

% z-tracker uses MT analysis
% These values should not be changed, variance and bias look up tables assume K=2, NW=1.5.
NW=1.5;               % Fixed value of NW supported, 
MT_tap=round(2*NW)-1; % K ~ 2NW - 1, K=2 here.
flags.MT=1;  
flags.seg_pwr=seg_pwr;
flags.NW=NW;
flags.MT_tap=MT_tap;

% seg_pwr limits for Multi-taper analysis
MT_seg_pwr_min=6;
MT_seg_pwr_max=14;
if (seg_pwr<MT_seg_pwr_min | seg_pwr>MT_seg_pwr_max)
  error(['seg_pwr outside allowed range for Multi-taper otpion:',num2str([MT_seg_pwr_min MT_seg_pwr_max])]);
end

% Set option defauts
flags.sp_type=30;  % Define z-tracker analysis
norm_chan=0;
trend_chan_1=0; 
trend_chan_2=0;
rect_chan_1=0;
rect_chan_2=0;
z_alpha=0.9;       % Default alpha in q_l smoothing
z_alpha_min=0.1;   % Range for alpha 0.1<= alpha <=0.9
z_alpha_max=0.9;
flags.ost_track_only=0; % Set to 1 for z-tracker with filtering only.
if (nargin<5)
  opt_str='';
end
options=deblank(opt_str);
while (any(options))              % Parse individual options from string.
  [opt,options]=strtok(options);
  optarg=opt(2:length(opt));      % Determine option argument.
  switch (opt(1))
    case 'a'             % Change value of alpha in q_l smoothing, JNE(7)
      z_alpha=str2num(optarg);
    if (z_alpha<z_alpha_min | z_alpha>z_alpha_max)
      error(['error in option argument -- a',optarg]);
    end  
    case 'n'             % Normalisation to unit variance within each segment.
      norm_chan=1;
    case 'r'             % Rectification option.        
      i=str2num(optarg);
    if (i<0 | i>2)
      error(['error in option argument -- r',optarg]);
    end  
    if (i~=1)
      rect_chan_1=1;     % Rectify ch 1.
    end  
    if (i>=1)
      rect_chan_2=1;     % Rectify ch 2.
    end  
    case 't'             % Linear de-trend option.
      i=str2num(optarg);
    if (i<0 | i>2)
      error(['error in option argument -- t',optarg]);
    end  
    if (i~=1)
      trend_chan_1=1;    % De-trend ch 1.
    end  
    if (i>=1)
      trend_chan_2=1;    % De-trend ch 2.
    end  
    case 'T'             % Use tracking only, no smoothing in z-tracker
      flags.ost_track_only=1;
    otherwise
      error (['Illegal option -- ',opt]);  % Illegal option.
  end
end

if (trend_chan_1 | trend_chan_2)       % Index for fitting data with polynomial.
  trend_x=(1:seg_size)';
end

for ind=1:seg_tot                     % Loop across columns/segments, same structure as sp2a2_R2_mt
  seg_pts=seg_samp_no(ind);           % No of data points in segment.
  seg_start=seg_samp_start(ind);      % Start sample in data vector.
  seg_stop=seg_start+seg_pts-1;       % Stop  sample in data vector.
  dat_seg1=dat1(seg_start:seg_stop);  % Extract segment from dat1.
  dat_seg2=dat2(seg_start:seg_stop);  % Extract segment from dat2.
  md1=mean(dat_seg1);                 % Mean of segment from dat1.
  md2=mean(dat_seg2);                 % Mean of segment from dat2.

  rd1(1:seg_pts,ind)=dat_seg1-md1;    % Subtract mean from ch 1.
  rd2(1:seg_pts,ind)=dat_seg2-md2;    % Subtract mean from ch 2.
  if rect_chan_1
    rd1(1:seg_pts,ind)=abs(rd1(1:seg_pts,ind));            % Rectification of ch 1 (Full wave).
  end
  if rect_chan_2
    rd2(1:seg_pts,ind)=abs(rd2(1:seg_pts,ind));            % Rectification of ch 2 (Full wave).  
  end
  if trend_chan_1                               % Linear trend removal.
    p=polyfit(trend_x(1:seg_pts,1),rd1(1:seg_pts,ind),1);                 % Fit 1st order polynomial.
    rd1(1:seg_pts,ind)=rd1(1:seg_pts,ind)-p(1)*trend_x(1:seg_pts,1)-p(2); % Subtract from ch 1.
  end  
  if trend_chan_2                               % Linear trend removal.
    p=polyfit(trend_x(1:seg_pts,1),rd2(1:seg_pts,ind),1);                 % Fit 1st order polynomial.
    rd2(1:seg_pts,ind)=rd2(1:seg_pts,ind)-p(1)*trend_x(1:seg_pts,1)-p(2); % Subtract from ch 2.
  end
  if norm_chan
    rd1(1:seg_pts,ind)=rd1(1:seg_pts,ind)/std(rd1(1:seg_pts,ind));
    rd2(1:seg_pts,ind)=rd2(1:seg_pts,ind)/std(rd2(1:seg_pts,ind));
  end
end

% Call sp2_fn2_zta MT based z-tracker for coherence estimation across segments
[coh,cl]=sp2_fn2_zta(rd1,rd2,samp_rate,z_alpha,flags);

% Set additional data and type dependent elements in cl structure.
cl.opt_str=opt_str; % Copy of options string.
cl.what='';         % Field for plot label.

% Display No of segments & resolution
disp(['Segments: ',num2str(seg_tot),', Segment length: ',num2str(seg_size/samp_rate),' sec,  Resolution: ',num2str(cl.df),' Hz.']);
