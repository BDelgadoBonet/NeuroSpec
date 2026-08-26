function [coh,cl]=sp2_fn_ztb(z,z_alpha,params)
% [coh,cl]=sp2_fn_ztb(z,z_alpha,params)
% Function with core routines for  multi-taper single segment coherence estimates,
%  to support z-tracker analysis of coherence estimates over segments.
% This function implements z-tracker on input matrix of z-transformed coherency values.
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
% 
% Input arguments
%  z          Matrix of z values over frequencies and segments, size [T/2-1, L], T=seg_size, L=seg_tot.
%  z_alpha    Scalar value of alpha in q_l smoothing, JNE (7)
%  params     Structure with variables to control processing options.
%
% Output arguments
%  coh  Matrix with coherence over segments, same size as input matrix z.
%  cl   single structure with scalar values related to analysis.
%
% Reference:
% Halliday DM, Brittain J-S, Stevenson CW, Mason R
%    Journal of Neural Engineering, 15(2), 026004, 2018.
% Reference referred to in comments as JNE
%
% [coh,cl]=sp2_fn_ztb(z,z_alpha,params)
%
% NOTE: This routine is not intended to support analysis of raw data.
% It is intended as a support routine for the z-tracker spectral analysis function:
% sp2a2_zt.m. Refer to this function for further details.

% Size of input matrix z
[ost_pts,seg_tot]=size(z);

% OST variables
xp=zeros(ost_pts,seg_tot);    % Matrix for filtered apriori estimates
x=zeros(ost_pts,seg_tot);     % Matrix for filtered aposteriori estimates
Pp=zeros(seg_tot,1);          % Vector for apriori     error for each segment for filtered estimate
P=zeros(seg_tot,1);           % Vector for aposteriori error for each segment for filtered estimate
K=zeros(seg_tot,1);           % Vector for forward Kalman gain for each segment
e=zeros(seg_tot,1);           % Vector for ek each segment
Q=zeros(seg_tot,1);           % Vector for smoothed ql for each segment
Ql=zeros(seg_tot,1);          % Vector for q'_l for each segment
R=zeros(seg_tot,1);           % Vector for single segment variance from look up table (NB for NW=1.5 T=2^10)
R_0=zeros(seg_tot,1);         % Vector for E{e_l^2 |q=0) values each segment
res=zeros(seg_tot,1);         % Vector for measurement residual, for current segment

% Initialise filter for first segment
R(1)=zt_var_v1(0);  % Initial variance - assume uncorrelated data, z=0
x(:,1)=z(:,1);    % Estimate for first segment
P(1)=R(1);
K(1)=1;
Q(1)=0;
aQ=z_alpha;       % Weighting for  q_(l-1): alpha
aQ1=1-aQ;         % Weighting for current q'_l value: (1 - alpha)

% Indices for calculating e_l for each segment
if params.ost_ek
  ost_ek_range=params.ost_ek_range; % Pre-specified range of indices
else
  ost_ek_range=[1 ost_pts];         % Otherwise use full frequency range
end
ek_ind=(ost_ek_range(1):ost_ek_range(2))';
ek_pts=length(ek_ind);

% Forward pass, filtering, l=2,...,L
for ind=2:seg_tot
  % Prediction and measurement residual
  xp(:,ind)=x(:,ind-1);     % JNE (A.5) 
  res=(z(:,ind)-xp(:,ind)); % Used in JNE (A.3)

  % Calculation of single segment variance from look up table
  % Using single value, mean z across frequencies used to calculate ek
  R(ind)=zt_var_v1(mean(z(ek_ind,ind)));   % JNE section 2.3

  % Adaptive calculation of Q: % E{ek ek^T}
  e(ind)=res(ek_ind)'*res(ek_ind)/(ek_pts);  % first term JNE (6)

  R_0(ind)=P(ind-1)+R(ind);  % E{e_l^2 |q=0) value, JNE (5)
  Ql(ind)=e(ind)-R_0(ind);   % Single step estimate of q'_l, JNE (6)
  if (Ql(ind)<0)
    Ql(ind)=0;               % Apply Heaviside
  end
  % Smoothed q_l using exponential decay
  Q(ind)=aQ*Q(ind-1)+aQ1*Ql(ind);  % JNE (7)
  
  % Prediction error, based on JNE (A.6), with q_(l-1) replaced with Jazwinski estimate (1969, eq 13)
  % for single residual estimate, JNE(6), then exponential smoothing JNE (7)
  Pp(ind)=P(ind-1)+Q(ind);

  % Correction
  K(ind)=Pp(ind)/(Pp(ind)+R(ind)); % KF gain used in JNE (A.3)
  x(:,ind)=xp(:,ind)+K(ind)*res;   % aposteriori estimate, JNE (A.3)
  P(ind)=(1-K(ind))*Pp(ind);       % aposteriori error,    JNE (A.4)
end % Forward pass

% Initialise smoothing
xs=zeros(ost_pts,seg_tot);   % Matrix for smoothed aposteriori estimates
A=zeros(seg_tot,1);          % Vector for backward Kalman gain for each segment
Ps=zeros(seg_tot,1);         % Vector for smoothed aposteriori error for each segment

if (params.ost_track_only)
  % Coherence from forward pass, using only filtering
  % Apply bias correction using look up table
  coh=tanh(abs(x)-zt_bias_v1(x)).^2;    % JNE (8)
else
  % Otherwise use backward pass to generate smoothed estimate
  % Last segment already fully conditioned
  xs(:,seg_tot)=x(:,seg_tot);
  Ps(seg_tot)=P(seg_tot);
  
  % Backward pass, l=L-1,...,1
  for ind=seg_tot-1:-1:1
    A(ind)=P(ind)/Pp(ind+1);     % KF backward gain used in JNE (A.7)
    xs(:,ind)=x(:,ind)+A(ind)*(xs(:,ind+1)-xp(:,ind+1));  % smoothed estimate,   JNE (A.7)
    Ps(ind)=P(ind)+A(ind)*(Ps(ind+1)-Pp(ind+1))*A(ind);   % error for smoothing, JNE (A.8)
  end

  % Coherence from backward pass, using smoothed estimate
  % Apply bias correction using look up table
  coh=tanh(abs(xs)-zt_bias_v1(xs)).^2;  % JNE (8)
  % Error from smoothed error
  P=Ps;
end

% cl structure
cl.ost_pts=ost_pts;   % No of frequency values, T/2-1, all frequencies except f_0 and f_N
cl.ost_freqs=(params.ch_ind-1)*params.deltaf; % Array of frequency values, Fourier frequencies
cl.ost_ek_ind=ek_ind; % List of indices to calculate   E{e_l^2}, first term JNE (6)
cl.ost_ek_pts=ek_pts; % No of points in calculation of E{e_l^2}, first term JNE (6)
cl.ost_alpha=z_alpha; % Value of alpha in smoothing q_l, JNE equation (7)
cl.ost_R=R;           % Array of single segment variance, r_l, JNE section 2.3, l=1,...,L
cl.ost_e=e;           % Array of E{e_l^2} values for each segment, first term JNE (6), l=1,...,L
cl.ost_R_0=R_0;       % Array of E{e_l^2 |q=0) values each segment, JNE (5), l=1,...,L
cl.ost_Q=Q;           % Array of smoothed q_l for each segment, JNE (7), l=1,...,L
cl.ost_Ql=Ql;         % Array of single segment q'_l, JNE (6), l=1,...,L
cl.ost_Pp=Pp;         % Array of apriori Kalman filter error terms for each segment, P^p_l, JNE (A.6)
cl.ost_P=P;           % Array of aposteriori Kalman filter error terms for each segment, P_l, JNE (A.4)
cl.ost_K=K;           % Array of Kalman filter gain, K_l, for forwars pass for each segment, JNE Appendix A
cl.ost_A=A;           % Array of Kalman filter gain, A_l, for backward pass for each segment, JNE Appendix A
