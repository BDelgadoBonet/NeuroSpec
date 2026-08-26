function [B,bias_table]=zt_bias_v1(z);
% [B,bias_table]=zt_bias_v1(z)
%
% Look up table for bias correction to apply to filtered/smoothed single segment
% coherence estimate, as function of estimated value of z.
% Bias of single segment estimators calculated based on MT estimate with NW=1.5, K=2 tapers.
% For use in conjunction with z-tracker  time varying coherence estimation.
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
%  z   Vector of z-transformed single segment coherence
%
% Output arguments
%  R          Bias correction to apply to each value, B(z), subtract from estimated z
%  bias_table (Optional) outputs bias table as defined in function
%
% [B,bias_table]=zt_bias_v1(z)
%
% This function called from sp2_fn2_ztb, see sp2_fn2_ztb listing for more details.

% Define bias table
bias_table=def_bias();

% Variable for output B(z), same size as input vector z
B=zeros(size(z));

% Below lower limit of bias table, set bias to 1.0
ind_1=find(z<bias_table(1,1));
B(ind_1)=1.0;

% Above upper limit of bias table, set bias to 0.5
ind_2=find(z>bias_table(length(bias_table),1));
B(ind_2)=0.5;

% Remaining values determined from look up table by interpolation.
ind_3=find(B==0);

% Using interp1 to interpolate values form table
B(ind_3)=interp1(bias_table(:,1),bias_table(:,2),z(ind_3));

return

function[bias_table]=def_bias();
% Two column table: z, B(z)
% z is estimated value
bias_table=[
    1.0005    0.9856
    1.0007    0.9712
    1.0032    0.9431
    1.0057    0.9160
    1.0096    0.8902
    1.0159    0.8658
    1.0218    0.8423
    1.0297    0.8199
    1.0386    0.7987
    1.0480    0.7785
    1.0592    0.7594
    1.0711    0.7413
    1.0838    0.7242
    1.0982    0.7083
    1.1131    0.6932
    1.1284    0.6788
    1.1453    0.6655
    1.1629    0.6531
    1.1813    0.6414
    1.2002    0.6305
    1.2204    0.6205
    1.2408    0.6111
    1.2624    0.6021
    1.2830    0.5937
    1.3064    0.5860
    1.3282    0.5787
    1.3522    0.5723
    1.3766    0.5663
    1.3996    0.5605
    1.4262    0.5557
    1.4507    0.5511
    1.4767    0.5468
    1.5030    0.5429
    1.5291    0.5390
    1.5548    0.5353
    1.5827    0.5325
    1.6100    0.5300
    1.6371    0.5273
    1.6649    0.5249
    1.6928    0.5228
    1.7206    0.5208
    1.7493    0.5191
    1.7771    0.5173
    1.8057    0.5154
    1.8330    0.5136
    1.8625    0.5125
    1.8920    0.5117
    1.9203    0.5104
    1.9490    0.5093
    1.9788    0.5086
    2.0077    0.5077
    2.0368    0.5068
    2.0661    0.5060
    2.0951    0.5054
    2.1252    0.5049
    2.1542    0.5045
    2.1845    0.5042
    2.4816    0.5018
    2.9915    0.5001
];
return
