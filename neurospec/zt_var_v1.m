function [R,var_table]=zt_var_v1(z);
% [R,var_table]=zt_var_v1(z)
%
% Look up table for variance of single segment coherence estimate, as function of estimated value of z.
% Variance of single segment estimators calculated based on MT estimate with NW=1.5, K=2 tapers.
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
%  z    Scalar with mean z-transformed coherence across segment
%
% Output arguments
%  R         Scalar with estimated variance var{z}, dervied from look up table.
%  var_table (Optional) outputs variance table as defined in function
%
% [R,var_table]=zt_var_v1(z)
%
% This function called from sp2_fn2_ztb, see sp2_fn2_ztb listing for more details.

% Define look up table for variance
[var_table,var_min,var_max]=def_var();

% Variable for output var{z}, function will also accepted an input vector of values.
R=zeros(size(z));

% Below lower limit of var table: use minimum variance
ind_1=find(z<var_table(1,1));
R(ind_1)=var_min;

% Above upper limit of var table: use maximum variance
ind_2=find(z>var_table(length(var_table),1));
R(ind_2)=var_max;

% Remaining values determined from look up table by interpolation.
ind_3=find(R==0);

% Using interp1 to interpolate values form table
R(ind_3)=interp1(var_table(:,1),var_table(:,2),z(ind_3));

return

function[var_table,var_min,var_max]=def_var();
% Two column table: z, var{z}
% z is estimated value
var_table =[
    1.0005    0.3876
    1.0009    0.3880
    1.0029    0.3888
    1.0064    0.3900
    1.0101    0.3916
    1.0156    0.3936
    1.0221    0.3959
    1.0297    0.3986
    1.0388    0.4018
    1.0480    0.4053
    1.0593    0.4092
    1.0706    0.4134
    1.0839    0.4177
    1.0986    0.4223
    1.1125    0.4272
    1.1283    0.4318
    1.1449    0.4367
    1.1632    0.4421
    1.1809    0.4474
    1.2002    0.4528
    1.2208    0.4582
    1.2402    0.4631
    1.2615    0.4684
    1.2839    0.4739
    1.3061    0.4789
    1.3285    0.4836
    1.3523    0.4883
    1.3760    0.4929
    1.4013    0.4977
    1.4259    0.5025
    1.4515    0.5069
    1.4770    0.5108
    1.5021    0.5145
    1.5293    0.5186
    1.5555    0.5223
    1.5822    0.5256
    1.6102    0.5287
    1.6367    0.5317
    1.6645    0.5347
    1.6934    0.5376
    1.7202    0.5399
    1.7483    0.5419
    1.7765    0.5440
    1.8047    0.5464
    1.8334    0.5489
    1.8627    0.5510
    1.8914    0.5527
    1.9203    0.5543
    1.9492    0.5557
    1.9781    0.5571
    2.0082    0.5585
    2.0381    0.5600
    2.0667    0.5613
    2.0962    0.5622
    2.1258    0.5631
    2.1551    0.5639
    2.1846    0.5647
    2.2137    0.5655
    2.2437    0.5663
    2.2735    0.5670
    2.3035    0.5676
    2.3329    0.5684
    2.3618    0.5690
    2.3931    0.5695
    2.4222    0.5700
    2.4522    0.5702
    2.4820    0.5707
    2.5122    0.5711
    2.5420    0.5710
    2.5718    0.5708
    2.6013    0.5709
    2.6300    0.5714
    2.6615    0.5720
    2.6910    0.5723
    2.7203    0.5723
    2.7508    0.5725
    2.7809    0.5730
    2.8118    0.5732
    2.8408    0.5731
    2.8702    0.5731
    2.9009    0.5732
    2.9310    0.5733
    2.9613    0.5735
    2.9901    0.5736
];
% Minimum and maximum values
var_min=var_table(1,2);
var_max=var_table(length(var_table),2);
return
