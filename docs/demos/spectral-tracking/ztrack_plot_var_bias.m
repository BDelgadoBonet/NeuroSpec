% Script: ztrack_plot_var_bias.m
% Script to demonstrate use of NeuroSpec 2.2
% Plot of var{z} and B{z} lookup tables used in z-tracker
%
% Copyright 2018, David M. Halliday.
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

% Use 2nd optional arguments to get var table and bias table
[tmp1,var_table]=zt_var_v1(0); % var{z} lookup table
[tmp2,bias_table]=zt_bias_v1(0); % B{z} lookup table

figure
subplot(2,1,1)
  plot(var_table(:,1),var_table(:,2),'k')
  box off
  title('$$var\{\hat{z}\}$$','interpreter','latex')
  xlabel('$$\hat{z}$$','interpreter','latex')
  axis([0.99 3 0.3 0.6 ])

subplot(2,1,2)
  plot(bias_table(:,1),bias_table(:,2),'k')
  box off
  title('$$B\{\hat{z}\}$$','interpreter','latex')
  xlabel('$$\hat{z}$$','interpreter','latex')
  axis([0.99 3 0.49 1])

