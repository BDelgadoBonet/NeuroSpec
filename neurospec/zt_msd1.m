function [msd]=zt_msd1(dat_target,dat_est)
%function [msd]=zt_msd1(dat_target,dat_est)
%
% function to estimate MSD between target and estimated data vector.
% If dat_est is matrix then MSD is estimated for each column.
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
% Input  dat_target  Vector of target values
%        dat_est     Vector or Matrix of estimated values,
%                      should have same no of rows as dat_target
%
% Output  msd        Vector of MSD values, 1 entry for each column in dat_est
%
% MSD: sqrt(E{(x - xhat)^2}), for target x and estimate xhat
%
% Used in z-tracker demonstration scripts to calculate MSD between target and estimated coherence.

[nrows ncols]=size(dat_est);

msd=zeros(ncols,1);

for ind=1:ncols
  msd(ind)=sqrt(mean((dat_target-dat_est(:,ind)).^2));
end
