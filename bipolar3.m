%     This file is part of STN_LFP_Model.
% 
%     STN_LFP_Model is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     any later version.
% 
%     STN_LFP_Model is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with STN_LFP_Model.  If not, see <https://www.gnu.org/licenses/>.
% 
% 
%     Copyright 2018 Nicholas Maling


import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.name('Reciprocity deal');

model.modelPath('C:\Users\Nick\Desktop');

model.param.set('Scon', '0.5[mm]');
model.param.descr('Scon', 'Contact Spacing');
model.param.set('Lcon', '1.5[mm]');
model.param.descr('Lcon', 'Contact Length');
model.param.set('Rcon', '1.27[mm]/2');
model.param.descr('Rcon', 'Contact Radius');
model.param.set('Ddis', '1.5[mm]');
model.param.descr('Ddis', 'Distance from bottom of contact 0 to distal tip');
model.param.set('DistElec', '4*Lcon+3*Scon');
model.param.descr('DistElec', 'Effective electrode span');
model.param.set('Offset', 'Rcon-.15[mm]');
model.param.descr('Offset', 'Distance from contact to center of shaft');
model.param.set('Med', '100[mm]');
model.param.descr('Med', 'Dimension (s) of square medium');
model.param.set('Rscar', '.1[mm]');
model.param.descr('Rscar', 'Radius (thickness) of scar');

%% Create first component
% Active contact = contact 0 
%_______________________
model.modelNode.create('comp1');
model.geom.create('geom1', 2);
model.geom('geom1').axisymmetric(true);
model.mesh.create('mesh1', 'geom1');
model.physics.create('ec', 'ConductiveMedia', 'geom1');

% Geometry
%________
model.geom('geom1').lengthUnit('mm');

model.geom('geom1').feature.create('r1', 'Rectangle');
model.geom('geom1').feature('r1').name('Contact 0');
model.geom('geom1').feature('r1').setIndex('size', 'Rcon', 0);
model.geom('geom1').feature('r1').setIndex('size', 'Lcon', 1);
model.geom('geom1').feature('r1').setIndex('pos', '0', 0);

model.geom('geom1').feature.create('r2', 'Rectangle');
model.geom('geom1').feature('r2').name('Contact 1');
model.geom('geom1').feature('r2').setIndex('size', 'Rcon-Offset', 0);
model.geom('geom1').feature('r2').setIndex('size', 'Lcon', 1);
model.geom('geom1').feature('r2').setIndex('pos', 'Offset', 0);
model.geom('geom1').feature('r2').setIndex('pos', 'Lcon+Scon', 1);

model.geom('geom1').feature.create('r3', 'Rectangle');
model.geom('geom1').feature('r3').name('Contact 2');
model.geom('geom1').feature('r3').setIndex('size', 'Rcon-Offset', 0);
model.geom('geom1').feature('r3').setIndex('size', 'Lcon', 1);
model.geom('geom1').feature('r3').setIndex('pos', 'Offset', 0);
model.geom('geom1').feature('r3').setIndex('pos', '(Lcon+Scon)*2', 1);

model.geom('geom1').feature.create('r4', 'Rectangle');
model.geom('geom1').feature('r4').name('Contact 3');
model.geom('geom1').feature('r4').setIndex('size', 'Rcon-Offset', 0);
model.geom('geom1').feature('r4').setIndex('size', 'Lcon', 1);
model.geom('geom1').feature('r4').setIndex('pos', 'Offset', 0);
model.geom('geom1').feature('r4').setIndex('pos', '(Lcon+Scon)*3', 1);

model.geom('geom1').feature.create('r5', 'Rectangle');
model.geom('geom1').feature('r5').name('Shaft');
model.geom('geom1').feature('r5').setIndex('size', 'Rcon', 0);
model.geom('geom1').feature('r5').setIndex('size', 'Med/2+Ddis-Rcon', 1);
model.geom('geom1').feature('r5').setIndex('pos', 'Rcon-Ddis', 1);

model.geom('geom1').feature.create('r6', 'Rectangle');
model.geom('geom1').feature('r6').name('Medium');
model.geom('geom1').feature('r6').setIndex('size', 'Med', 0);
model.geom('geom1').feature('r6').setIndex('size', 'Med', 1);
model.geom('geom1').feature('r6').setIndex('pos', '-Med/2', 1);

model.geom('geom1').feature.create('c1', 'Circle');
model.geom('geom1').feature('c1').name('Distal Tip');
model.geom('geom1').feature('c1').set('r', 'Rcon');
model.geom('geom1').feature('c1').set('angle', '90');
model.geom('geom1').feature('c1').setIndex('pos', 'Rcon-Ddis', 1);
model.geom('geom1').feature('c1').set('rot', '-90');

model.geom('geom1').feature.create('r7', 'Rectangle');
model.geom('geom1').feature('r7').name('Proximal Scar');
model.geom('geom1').feature('r7').setIndex('size', 'Rscar', 0);
model.geom('geom1').feature('r7').setIndex('size', '(Med/2)-(2*DistElec)', 1);
model.geom('geom1').feature('r7').setIndex('pos', 'Rcon', 0);
model.geom('geom1').feature('r7').setIndex('pos', '2*DistElec', 1);

model.geom('geom1').feature.create('r8', 'Rectangle');
model.geom('geom1').feature('r8').name('Distal Scar');
model.geom('geom1').feature('r8').setIndex('size', 'Rscar', 0);
model.geom('geom1').feature('r8').setIndex('size', '2*DistElec+Ddis-Rcon', 1);
model.geom('geom1').feature('r8').setIndex('pos', 'Rcon', 0);
model.geom('geom1').feature('r8').setIndex('pos', 'Rcon-Ddis', 1);

model.geom('geom1').feature.create('c2', 'Circle');
model.geom('geom1').feature('c2').name('Scar Tip');
model.geom('geom1').feature('c2').set('r', 'Rcon+Rscar');
model.geom('geom1').feature('c2').set('angle', '90');
model.geom('geom1').feature('c2').setIndex('pos', 'Rcon-Ddis', 1);
model.geom('geom1').feature('c2').set('rot', '-90');

model.geom('geom1').feature.create('c3', 'Circle');
model.geom('geom1').feature('c3').name('Distal Tip Subtract');
model.geom('geom1').feature('c3').set('r', 'Rcon');
model.geom('geom1').feature('c3').set('angle', '90');
model.geom('geom1').feature('c3').setIndex('pos', 'Rcon-Ddis', 1);
model.geom('geom1').feature('c3').set('rot', '-90');

model.geom('geom1').run;

model.geom('geom1').feature.create('dif1', 'Difference');
model.geom('geom1').feature('dif1').selection('input').set({'r6'});
model.geom('geom1').feature('dif1').selection('input2').set({'r5' 'c1'});

model.geom('geom1').feature.create('dif2', 'Difference');
model.geom('geom1').feature('dif2').selection('input').set({'c2'});
model.geom('geom1').feature('dif2').selection('input2').set({'c3'});

model.geom('geom1').run;

% Material
%________
model.material.create('mat1');
model.material('mat1').name('Medium');
model.material('mat1').propertyGroup('def').set('electricconductivity', {'0.3'});
model.material('mat1').propertyGroup('def').set('relpermittivity', {'1e6'});
model.material('mat1').selection.set([1]);

model.material.create('mat2');
model.material('mat2').name('Scar');
model.material('mat2').selection.set([2 7 8]);
model.material('mat2').propertyGroup('def').set('electricconductivity', {'0.032'});
model.material('mat2').propertyGroup('def').set('relpermittivity', {'2.93e4'});

model.material.create('mat3');
model.material('mat3').name('Contacts');
model.material('mat3').selection.set([3 4 5 6]);
model.material('mat3').propertyGroup('def').set('electricconductivity', {'1e6'});
model.material('mat3').propertyGroup('def').set('relpermittivity', {'1'});

% Physics
%________
model.physics('ec').feature.create('gnd1', 'Ground', 1);
model.physics('ec').feature('gnd1').selection.set([2 31 32]);

model.physics('ec').feature.create('lcsa1', 'LineCurrentSourceAxis', 1);
model.physics('ec').feature('lcsa1').selection.set([4]);
model.physics('ec').feature('lcsa1').set('Qjl', 1, '1[A]/Lcon');

% Mesh
%________
model.mesh('mesh1').feature.create('ftri1', 'FreeTri');
model.mesh('mesh1').feature('ftri1').name('Contacts');
model.mesh('mesh1').feature('ftri1').feature.create('size1', 'Size');
model.mesh('mesh1').feature('ftri1').selection.geom('geom1', 2);
model.mesh('mesh1').feature('ftri1').selection.set([3 4 5 6]);
model.mesh('mesh1').feature('ftri1').feature('size1').set('custom', 'on');
model.mesh('mesh1').feature('ftri1').feature('size1').set('hmaxactive', 'on');
model.mesh('mesh1').feature('ftri1').feature('size1').set('hminactive', 'on');
model.mesh('mesh1').feature('ftri1').feature('size1').set('hmax', '.02');
model.mesh('mesh1').feature('ftri1').feature('size1').set('hmin', '.01');

model.mesh('mesh1').feature.create('ftri2', 'FreeTri');
model.mesh('mesh1').feature('ftri2').name('Scar');
model.mesh('mesh1').feature('ftri2').feature.create('size1', 'Size');
model.mesh('mesh1').feature('ftri2').selection.geom('geom1', 2);
model.mesh('mesh1').feature('ftri2').selection.set([2 7]);
model.mesh('mesh1').feature('ftri2').feature('size1').set('custom', 'on');
model.mesh('mesh1').feature('ftri2').feature('size1').set('hmaxactive', 'on');
model.mesh('mesh1').feature('ftri2').feature('size1').set('hminactive', 'on');
model.mesh('mesh1').feature('ftri2').feature('size1').set('hmax', '.02');
model.mesh('mesh1').feature('ftri2').feature('size1').set('hmin', '.01');

model.mesh('mesh1').feature.create('ftri3', 'FreeTri');
model.mesh('mesh1').feature('ftri3').name('Medium');
model.mesh('mesh1').feature('ftri3').feature.create('size1', 'Size');
model.mesh('mesh1').feature('ftri3').feature('size1').set('custom', 'on');
model.mesh('mesh1').feature('ftri3').feature('size1').set('hgradactive', 'on');
model.mesh('mesh1').feature('ftri3').feature('size1').set('hgrad', '1.05');

%% Create second component
% Active contact = contact 1
%________________________
model.modelNode.create('comp2');
model.geom.create('geom2', 2);
model.geom('geom2').axisymmetric(true);
model.mesh.create('mesh2', 'geom2');
model.physics.create('ec2', 'ConductiveMedia', 'geom2');

% Geometry
%________
model.geom('geom2').lengthUnit('mm');

model.geom('geom2').feature.create('r1', 'Rectangle');
model.geom('geom2').feature('r1').name('Contact 0');
model.geom('geom2').feature('r1').setIndex('size', 'Rcon-Offset', 0);
model.geom('geom2').feature('r1').setIndex('size', 'Lcon', 1);
model.geom('geom2').feature('r1').setIndex('pos', 'Offset', 0);

model.geom('geom2').feature.create('r2', 'Rectangle');
model.geom('geom2').feature('r2').name('Contact 1');
model.geom('geom2').feature('r2').setIndex('size', 'Rcon', 0);
model.geom('geom2').feature('r2').setIndex('size', 'Lcon', 1);
model.geom('geom2').feature('r2').setIndex('pos', '0', 0);
model.geom('geom2').feature('r2').setIndex('pos', 'Lcon+Scon', 1);

model.geom('geom2').feature.create('r3', 'Rectangle');
model.geom('geom2').feature('r3').name('Contact 2');
model.geom('geom2').feature('r3').setIndex('size', 'Rcon-Offset', 0);
model.geom('geom2').feature('r3').setIndex('size', 'Lcon', 1);
model.geom('geom2').feature('r3').setIndex('pos', 'Offset', 0);
model.geom('geom2').feature('r3').setIndex('pos', '(Lcon+Scon)*2', 1);

model.geom('geom2').feature.create('r4', 'Rectangle');
model.geom('geom2').feature('r4').name('Contact 3');
model.geom('geom2').feature('r4').setIndex('size', 'Rcon-Offset', 0);
model.geom('geom2').feature('r4').setIndex('size', 'Lcon', 1);
model.geom('geom2').feature('r4').setIndex('pos', 'Offset', 0);
model.geom('geom2').feature('r4').setIndex('pos', '(Lcon+Scon)*3', 1);

model.geom('geom2').feature.create('r5', 'Rectangle');
model.geom('geom2').feature('r5').name('Shaft');
model.geom('geom2').feature('r5').setIndex('size', 'Rcon', 0);
model.geom('geom2').feature('r5').setIndex('size', 'Med/2+Ddis-Rcon', 1);
model.geom('geom2').feature('r5').setIndex('pos', 'Rcon-Ddis', 1);

model.geom('geom2').feature.create('r6', 'Rectangle');
model.geom('geom2').feature('r6').name('Medium');
model.geom('geom2').feature('r6').setIndex('size', 'Med', 0);
model.geom('geom2').feature('r6').setIndex('size', 'Med', 1);
model.geom('geom2').feature('r6').setIndex('pos', '-Med/2', 1);

model.geom('geom2').feature.create('c1', 'Circle');
model.geom('geom2').feature('c1').name('Distal Tip');
model.geom('geom2').feature('c1').set('r', 'Rcon');
model.geom('geom2').feature('c1').set('angle', '90');
model.geom('geom2').feature('c1').setIndex('pos', 'Rcon-Ddis', 1);
model.geom('geom2').feature('c1').set('rot', '-90');

model.geom('geom2').feature.create('r7', 'Rectangle');
model.geom('geom2').feature('r7').name('Proximal Scar');
model.geom('geom2').feature('r7').setIndex('size', 'Rscar', 0);
model.geom('geom2').feature('r7').setIndex('size', '(Med/2)-(2*DistElec)', 1);
model.geom('geom2').feature('r7').setIndex('pos', 'Rcon', 0);
model.geom('geom2').feature('r7').setIndex('pos', '2*DistElec', 1);

model.geom('geom2').feature.create('r8', 'Rectangle');
model.geom('geom2').feature('r8').name('Distal Scar');
model.geom('geom2').feature('r8').setIndex('size', 'Rscar', 0);
model.geom('geom2').feature('r8').setIndex('size', '2*DistElec+Ddis-Rcon', 1);
model.geom('geom2').feature('r8').setIndex('pos', 'Rcon', 0);
model.geom('geom2').feature('r8').setIndex('pos', 'Rcon-Ddis', 1);

model.geom('geom2').feature.create('c2', 'Circle');
model.geom('geom2').feature('c2').name('Scar Tip');
model.geom('geom2').feature('c2').set('r', 'Rcon+Rscar');
model.geom('geom2').feature('c2').set('angle', '90');
model.geom('geom2').feature('c2').setIndex('pos', 'Rcon-Ddis', 1);
model.geom('geom2').feature('c2').set('rot', '-90');

model.geom('geom2').feature.create('c3', 'Circle');
model.geom('geom2').feature('c3').name('Distal Tip Subtract');
model.geom('geom2').feature('c3').set('r', 'Rcon');
model.geom('geom2').feature('c3').set('angle', '90');
model.geom('geom2').feature('c3').setIndex('pos', 'Rcon-Ddis', 1);
model.geom('geom2').feature('c3').set('rot', '-90');

model.geom('geom2').run;

model.geom('geom2').feature.create('dif1', 'Difference');
model.geom('geom2').feature('dif1').selection('input').set({'r6'});
model.geom('geom2').feature('dif1').selection('input2').set({'r5' 'c1'});

model.geom('geom2').feature.create('dif2', 'Difference');
model.geom('geom2').feature('dif2').selection('input').set({'c2'});
model.geom('geom2').feature('dif2').selection('input2').set({'c3'});

model.geom('geom2').run;

% Material
%________
model.material.create('mat4');
model.material('mat4').name('Medium');
model.material('mat4').propertyGroup('def').set('electricconductivity', {'0.3'});
model.material('mat4').propertyGroup('def').set('relpermittivity', {'1e6'});
model.material('mat4').selection.set([1]);

model.material.create('mat5');
model.material('mat5').name('Scar');
model.material('mat5').selection.set([2 7 8]);
model.material('mat5').propertyGroup('def').set('electricconductivity', {'0.032'});
model.material('mat5').propertyGroup('def').set('relpermittivity', {'2.93e4'});

model.material.create('mat6');
model.material('mat6').name('Contacts');
model.material('mat6').selection.set([3 4 5 6]);
model.material('mat6').propertyGroup('def').set('electricconductivity', {'1e6'});
model.material('mat6').propertyGroup('def').set('relpermittivity', {'1'});

% Physics
%________
model.physics('ec2').feature.create('gnd1', 'Ground', 1);
model.physics('ec2').feature('gnd1').selection.set([2 31 32]);

model.physics('ec2').feature.create('lcsa1', 'LineCurrentSourceAxis', 1);
model.physics('ec2').feature('lcsa1').selection.set([4]);
model.physics('ec2').feature('lcsa1').set('Qjl', 1, '1[A]/Lcon');

% Mesh
%________
model.mesh('mesh2').feature.create('ftri1', 'FreeTri');
model.mesh('mesh2').feature('ftri1').name('Contacts');
model.mesh('mesh2').feature('ftri1').feature.create('size1', 'Size');
model.mesh('mesh2').feature('ftri1').selection.geom('geom2', 2);
model.mesh('mesh2').feature('ftri1').selection.set([3 4 5 6]);
model.mesh('mesh2').feature('ftri1').feature('size1').set('custom', 'on');
model.mesh('mesh2').feature('ftri1').feature('size1').set('hmaxactive', 'on');
model.mesh('mesh2').feature('ftri1').feature('size1').set('hminactive', 'on');
model.mesh('mesh2').feature('ftri1').feature('size1').set('hmax', '.02');
model.mesh('mesh2').feature('ftri1').feature('size1').set('hmin', '.01');

model.mesh('mesh2').feature.create('ftri2', 'FreeTri');
model.mesh('mesh2').feature('ftri2').name('Scar');
model.mesh('mesh2').feature('ftri2').feature.create('size1', 'Size');
model.mesh('mesh2').feature('ftri2').selection.geom('geom2', 2);
model.mesh('mesh2').feature('ftri2').selection.set([2 7]);
model.mesh('mesh2').feature('ftri2').feature('size1').set('custom', 'on');
model.mesh('mesh2').feature('ftri2').feature('size1').set('hmaxactive', 'on');
model.mesh('mesh2').feature('ftri2').feature('size1').set('hminactive', 'on');
model.mesh('mesh2').feature('ftri2').feature('size1').set('hmax', '.02');
model.mesh('mesh2').feature('ftri2').feature('size1').set('hmin', '.01');

model.mesh('mesh2').feature.create('ftri3', 'FreeTri');
model.mesh('mesh2').feature('ftri3').name('Medium');
model.mesh('mesh2').feature('ftri3').feature.create('size1', 'Size');
model.mesh('mesh2').feature('ftri3').feature('size1').set('custom', 'on');
model.mesh('mesh2').feature('ftri3').feature('size1').set('hgradactive', 'on');
model.mesh('mesh2').feature('ftri3').feature('size1').set('hgrad', '1.05');

%% Create third component
% Active contact = contact 2
%_______________________
model.modelNode.create('comp3');
model.geom.create('geom3', 2);
model.geom('geom3').axisymmetric(true);
model.mesh.create('mesh3', 'geom3');
model.physics.create('ec3', 'ConductiveMedia', 'geom3');

% Geometry
%________
model.geom('geom3').lengthUnit('mm');

model.geom('geom3').feature.create('r1', 'Rectangle');
model.geom('geom3').feature('r1').name('Contact 0');
model.geom('geom3').feature('r1').setIndex('size', 'Rcon-Offset', 0);
model.geom('geom3').feature('r1').setIndex('size', 'Lcon', 1);
model.geom('geom3').feature('r1').setIndex('pos', 'Offset', 0);

model.geom('geom3').feature.create('r2', 'Rectangle');
model.geom('geom3').feature('r2').name('Contact 1');
model.geom('geom3').feature('r2').setIndex('size', 'Rcon-Offset', 0);
model.geom('geom3').feature('r2').setIndex('size', 'Lcon', 1);
model.geom('geom3').feature('r2').setIndex('pos', 'Offset', 0);
model.geom('geom3').feature('r2').setIndex('pos', 'Lcon+Scon', 1);

model.geom('geom3').feature.create('r3', 'Rectangle');
model.geom('geom3').feature('r3').name('Contact 2');
model.geom('geom3').feature('r3').setIndex('size', 'Rcon', 0);
model.geom('geom3').feature('r3').setIndex('size', 'Lcon', 1);
model.geom('geom3').feature('r3').setIndex('pos', '0', 0);
model.geom('geom3').feature('r3').setIndex('pos', '(Lcon+Scon)*2', 1);

model.geom('geom3').feature.create('r4', 'Rectangle');
model.geom('geom3').feature('r4').name('Contact 3');
model.geom('geom3').feature('r4').setIndex('size', 'Rcon-Offset', 0);
model.geom('geom3').feature('r4').setIndex('size', 'Lcon', 1);
model.geom('geom3').feature('r4').setIndex('pos', 'Offset', 0);
model.geom('geom3').feature('r4').setIndex('pos', '(Lcon+Scon)*3', 1);

model.geom('geom3').feature.create('r5', 'Rectangle');
model.geom('geom3').feature('r5').name('Shaft');
model.geom('geom3').feature('r5').setIndex('size', 'Rcon', 0);
model.geom('geom3').feature('r5').setIndex('size', 'Med/2+Ddis-Rcon', 1);
model.geom('geom3').feature('r5').setIndex('pos', 'Rcon-Ddis', 1);

model.geom('geom3').feature.create('r6', 'Rectangle');
model.geom('geom3').feature('r6').name('Medium');
model.geom('geom3').feature('r6').setIndex('size', 'Med', 0);
model.geom('geom3').feature('r6').setIndex('size', 'Med', 1);
model.geom('geom3').feature('r6').setIndex('pos', '-Med/2', 1);

model.geom('geom3').feature.create('c1', 'Circle');
model.geom('geom3').feature('c1').name('Distal Tip');
model.geom('geom3').feature('c1').set('r', 'Rcon');
model.geom('geom3').feature('c1').set('angle', '90');
model.geom('geom3').feature('c1').setIndex('pos', 'Rcon-Ddis', 1);
model.geom('geom3').feature('c1').set('rot', '-90');

model.geom('geom3').feature.create('r7', 'Rectangle');
model.geom('geom3').feature('r7').name('Proximal Scar');
model.geom('geom3').feature('r7').setIndex('size', 'Rscar', 0);
model.geom('geom3').feature('r7').setIndex('size', '(Med/2)-(2*DistElec)', 1);
model.geom('geom3').feature('r7').setIndex('pos', 'Rcon', 0);
model.geom('geom3').feature('r7').setIndex('pos', '2*DistElec', 1);

model.geom('geom3').feature.create('r8', 'Rectangle');
model.geom('geom3').feature('r8').name('Distal Scar');
model.geom('geom3').feature('r8').setIndex('size', 'Rscar', 0);
model.geom('geom3').feature('r8').setIndex('size', '2*DistElec+Ddis-Rcon', 1);
model.geom('geom3').feature('r8').setIndex('pos', 'Rcon', 0);
model.geom('geom3').feature('r8').setIndex('pos', 'Rcon-Ddis', 1);

model.geom('geom3').feature.create('c2', 'Circle');
model.geom('geom3').feature('c2').name('Scar Tip');
model.geom('geom3').feature('c2').set('r', 'Rcon+Rscar');
model.geom('geom3').feature('c2').set('angle', '90');
model.geom('geom3').feature('c2').setIndex('pos', 'Rcon-Ddis', 1);
model.geom('geom3').feature('c2').set('rot', '-90');

model.geom('geom3').feature.create('c3', 'Circle');
model.geom('geom3').feature('c3').name('Distal Tip Subtract');
model.geom('geom3').feature('c3').set('r', 'Rcon');
model.geom('geom3').feature('c3').set('angle', '90');
model.geom('geom3').feature('c3').setIndex('pos', 'Rcon-Ddis', 1);
model.geom('geom3').feature('c3').set('rot', '-90');

model.geom('geom3').run;

model.geom('geom3').feature.create('dif1', 'Difference');
model.geom('geom3').feature('dif1').selection('input').set({'r6'});
model.geom('geom3').feature('dif1').selection('input2').set({'r5' 'c1'});

model.geom('geom3').feature.create('dif2', 'Difference');
model.geom('geom3').feature('dif2').selection('input').set({'c2'});
model.geom('geom3').feature('dif2').selection('input2').set({'c3'});

model.geom('geom3').run;

% Material
%________
model.material.create('mat7');
model.material('mat7').name('Medium');
model.material('mat7').propertyGroup('def').set('electricconductivity', {'0.3'});
model.material('mat7').propertyGroup('def').set('relpermittivity', {'1e6'});
model.material('mat7').selection.set([1]);

model.material.create('mat8');
model.material('mat8').name('Scar');
model.material('mat8').selection.set([2 7 8]);
model.material('mat8').propertyGroup('def').set('electricconductivity', {'0.032'});
model.material('mat8').propertyGroup('def').set('relpermittivity', {'2.93e4'});

model.material.create('mat9');
model.material('mat9').name('Contacts');
model.material('mat9').selection.set([3 4 5 6]);
model.material('mat9').propertyGroup('def').set('electricconductivity', {'1e6'});
model.material('mat9').propertyGroup('def').set('relpermittivity', {'1'});

% Physics
%________
model.physics('ec3').feature.create('gnd1', 'Ground', 1);
model.physics('ec3').feature('gnd1').selection.set([2 31 32]);

model.physics('ec3').feature.create('lcsa1', 'LineCurrentSourceAxis', 1);
model.physics('ec3').feature('lcsa1').selection.set([4]);
model.physics('ec3').feature('lcsa1').set('Qjl', 1, '1[A]/Lcon');

% Mesh
%________
model.mesh('mesh3').feature.create('ftri1', 'FreeTri');
model.mesh('mesh3').feature('ftri1').name('Contacts');
model.mesh('mesh3').feature('ftri1').feature.create('size1', 'Size');
model.mesh('mesh3').feature('ftri1').selection.geom('geom3', 2);
model.mesh('mesh3').feature('ftri1').selection.set([3 4 5 6]);
model.mesh('mesh3').feature('ftri1').feature('size1').set('custom', 'on');
model.mesh('mesh3').feature('ftri1').feature('size1').set('hmaxactive', 'on');
model.mesh('mesh3').feature('ftri1').feature('size1').set('hminactive', 'on');
model.mesh('mesh3').feature('ftri1').feature('size1').set('hmax', '.02');
model.mesh('mesh3').feature('ftri1').feature('size1').set('hmin', '.01');

model.mesh('mesh3').feature.create('ftri2', 'FreeTri');
model.mesh('mesh3').feature('ftri2').name('Scar');
model.mesh('mesh3').feature('ftri2').feature.create('size1', 'Size');
model.mesh('mesh3').feature('ftri2').selection.geom('geom3', 2);
model.mesh('mesh3').feature('ftri2').selection.set([2 7]);
model.mesh('mesh3').feature('ftri2').feature('size1').set('custom', 'on');
model.mesh('mesh3').feature('ftri2').feature('size1').set('hmaxactive', 'on');
model.mesh('mesh3').feature('ftri2').feature('size1').set('hminactive', 'on');
model.mesh('mesh3').feature('ftri2').feature('size1').set('hmax', '.02');
model.mesh('mesh3').feature('ftri2').feature('size1').set('hmin', '.01');

model.mesh('mesh3').feature.create('ftri3', 'FreeTri');
model.mesh('mesh3').feature('ftri3').name('Medium');
model.mesh('mesh3').feature('ftri3').feature.create('size1', 'Size');
model.mesh('mesh3').feature('ftri3').feature('size1').set('custom', 'on');
model.mesh('mesh3').feature('ftri3').feature('size1').set('hgradactive', 'on');
model.mesh('mesh3').feature('ftri3').feature('size1').set('hgrad', '1.05');

%% Create fourth component
% Active contact = contact 3
%_______________________
model.modelNode.create('comp4');
model.geom.create('geom4', 2);
model.geom('geom4').axisymmetric(true);
model.mesh.create('mesh4', 'geom4');
model.physics.create('ec4', 'ConductiveMedia', 'geom4');

% Geometry
%________
model.geom('geom4').lengthUnit('mm');

model.geom('geom4').feature.create('r1', 'Rectangle');
model.geom('geom4').feature('r1').name('Contact 0');
model.geom('geom4').feature('r1').setIndex('size', 'Rcon-Offset', 0);
model.geom('geom4').feature('r1').setIndex('size', 'Lcon', 1);
model.geom('geom4').feature('r1').setIndex('pos', 'Offset', 0);

model.geom('geom4').feature.create('r2', 'Rectangle');
model.geom('geom4').feature('r2').name('Contact 1');
model.geom('geom4').feature('r2').setIndex('size', 'Rcon-Offset', 0);
model.geom('geom4').feature('r2').setIndex('size', 'Lcon', 1);
model.geom('geom4').feature('r2').setIndex('pos', 'Offset', 0);
model.geom('geom4').feature('r2').setIndex('pos', 'Lcon+Scon', 1);

model.geom('geom4').feature.create('r3', 'Rectangle');
model.geom('geom4').feature('r3').name('Contact 2');
model.geom('geom4').feature('r3').setIndex('size', 'Rcon-Offset', 0);
model.geom('geom4').feature('r3').setIndex('size', 'Lcon', 1);
model.geom('geom4').feature('r3').setIndex('pos', 'Offset', 0);
model.geom('geom4').feature('r3').setIndex('pos', '(Lcon+Scon)*2', 1);

model.geom('geom4').feature.create('r4', 'Rectangle');
model.geom('geom4').feature('r4').name('Contact 3');
model.geom('geom4').feature('r4').setIndex('size', 'Rcon', 0);
model.geom('geom4').feature('r4').setIndex('size', 'Lcon', 1);
model.geom('geom4').feature('r4').setIndex('pos', '0', 0);
model.geom('geom4').feature('r4').setIndex('pos', '(Lcon+Scon)*3', 1);

model.geom('geom4').feature.create('r5', 'Rectangle');
model.geom('geom4').feature('r5').name('Shaft');
model.geom('geom4').feature('r5').setIndex('size', 'Rcon', 0);
model.geom('geom4').feature('r5').setIndex('size', 'Med/2+Ddis-Rcon', 1);
model.geom('geom4').feature('r5').setIndex('pos', 'Rcon-Ddis', 1);

model.geom('geom4').feature.create('r6', 'Rectangle');
model.geom('geom4').feature('r6').name('Medium');
model.geom('geom4').feature('r6').setIndex('size', 'Med', 0);
model.geom('geom4').feature('r6').setIndex('size', 'Med', 1);
model.geom('geom4').feature('r6').setIndex('pos', '-Med/2', 1);

model.geom('geom4').feature.create('c1', 'Circle');
model.geom('geom4').feature('c1').name('Distal Tip');
model.geom('geom4').feature('c1').set('r', 'Rcon');
model.geom('geom4').feature('c1').set('angle', '90');
model.geom('geom4').feature('c1').setIndex('pos', 'Rcon-Ddis', 1);
model.geom('geom4').feature('c1').set('rot', '-90');

model.geom('geom4').feature.create('r7', 'Rectangle');
model.geom('geom4').feature('r7').name('Proximal Scar');
model.geom('geom4').feature('r7').setIndex('size', 'Rscar', 0);
model.geom('geom4').feature('r7').setIndex('size', '(Med/2)-(2*DistElec)', 1);
model.geom('geom4').feature('r7').setIndex('pos', 'Rcon', 0);
model.geom('geom4').feature('r7').setIndex('pos', '2*DistElec', 1);

model.geom('geom4').feature.create('r8', 'Rectangle');
model.geom('geom4').feature('r8').name('Distal Scar');
model.geom('geom4').feature('r8').setIndex('size', 'Rscar', 0);
model.geom('geom4').feature('r8').setIndex('size', '2*DistElec+Ddis-Rcon', 1);
model.geom('geom4').feature('r8').setIndex('pos', 'Rcon', 0);
model.geom('geom4').feature('r8').setIndex('pos', 'Rcon-Ddis', 1);

model.geom('geom4').feature.create('c2', 'Circle');
model.geom('geom4').feature('c2').name('Scar Tip');
model.geom('geom4').feature('c2').set('r', 'Rcon+Rscar');
model.geom('geom4').feature('c2').set('angle', '90');
model.geom('geom4').feature('c2').setIndex('pos', 'Rcon-Ddis', 1);
model.geom('geom4').feature('c2').set('rot', '-90');

model.geom('geom4').feature.create('c3', 'Circle');
model.geom('geom4').feature('c3').name('Distal Tip Subtract');
model.geom('geom4').feature('c3').set('r', 'Rcon');
model.geom('geom4').feature('c3').set('angle', '90');
model.geom('geom4').feature('c3').setIndex('pos', 'Rcon-Ddis', 1);
model.geom('geom4').feature('c3').set('rot', '-90');

model.geom('geom4').run;

model.geom('geom4').feature.create('dif1', 'Difference');
model.geom('geom4').feature('dif1').selection('input').set({'r6'});
model.geom('geom4').feature('dif1').selection('input2').set({'r5' 'c1'});

model.geom('geom4').feature.create('dif2', 'Difference');
model.geom('geom4').feature('dif2').selection('input').set({'c2'});
model.geom('geom4').feature('dif2').selection('input2').set({'c3'});

model.geom('geom4').run;

% Material
%________
model.material.create('mat10');
model.material('mat10').name('Medium');
model.material('mat10').propertyGroup('def').set('electricconductivity', {'0.3'});
model.material('mat10').propertyGroup('def').set('relpermittivity', {'1e6'});
model.material('mat10').selection.set([1]);

model.material.create('mat11');
model.material('mat11').name('Scar');
model.material('mat11').selection.set([2 7 8]);
model.material('mat11').propertyGroup('def').set('electricconductivity', {'0.032'});
model.material('mat11').propertyGroup('def').set('relpermittivity', {'2.93e4'});

model.material.create('mat12');
model.material('mat12').name('Contacts');
model.material('mat12').selection.set([3 4 5 6]);
model.material('mat12').propertyGroup('def').set('electricconductivity', {'1e6'});
model.material('mat12').propertyGroup('def').set('relpermittivity', {'1'});

% Physics
%________
model.physics('ec4').feature.create('gnd1', 'Ground', 1);
model.physics('ec4').feature('gnd1').selection.set([2 31 32]);

model.physics('ec4').feature.create('lcsa1', 'LineCurrentSourceAxis', 1);
model.physics('ec4').feature('lcsa1').selection.set([4]);
model.physics('ec4').feature('lcsa1').set('Qjl', 1, '1[A]/Lcon');

% Mesh
%________
model.mesh('mesh4').feature.create('ftri1', 'FreeTri');
model.mesh('mesh4').feature('ftri1').name('Contacts');
model.mesh('mesh4').feature('ftri1').feature.create('size1', 'Size');
model.mesh('mesh4').feature('ftri1').selection.geom('geom4', 2);
model.mesh('mesh4').feature('ftri1').selection.set([3 4 5 6]);
model.mesh('mesh4').feature('ftri1').feature('size1').set('custom', 'on');
model.mesh('mesh4').feature('ftri1').feature('size1').set('hmaxactive', 'on');
model.mesh('mesh4').feature('ftri1').feature('size1').set('hminactive', 'on');
model.mesh('mesh4').feature('ftri1').feature('size1').set('hmax', '.02');
model.mesh('mesh4').feature('ftri1').feature('size1').set('hmin', '.01');

model.mesh('mesh4').feature.create('ftri2', 'FreeTri');
model.mesh('mesh4').feature('ftri2').name('Scar');
model.mesh('mesh4').feature('ftri2').feature.create('size1', 'Size');
model.mesh('mesh4').feature('ftri2').selection.geom('geom4', 2);
model.mesh('mesh4').feature('ftri2').selection.set([2 7]);
model.mesh('mesh4').feature('ftri2').feature('size1').set('custom', 'on');
model.mesh('mesh4').feature('ftri2').feature('size1').set('hmaxactive', 'on');
model.mesh('mesh4').feature('ftri2').feature('size1').set('hminactive', 'on');
model.mesh('mesh4').feature('ftri2').feature('size1').set('hmax', '.02');
model.mesh('mesh4').feature('ftri2').feature('size1').set('hmin', '.01');

model.mesh('mesh4').feature.create('ftri3', 'FreeTri');
model.mesh('mesh4').feature('ftri3').name('Medium');
model.mesh('mesh4').feature('ftri3').feature.create('size1', 'Size');
model.mesh('mesh4').feature('ftri3').feature('size1').set('custom', 'on');
model.mesh('mesh4').feature('ftri3').feature('size1').set('hgradactive', 'on');
model.mesh('mesh4').feature('ftri3').feature('size1').set('hgrad', '1.05');

%% Create study and solve

model.study.create('std1');
model.study('std1').feature.create('stat', 'Stationary');
model.study('std1').feature('stat').activate('ec', true);

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').feature.create('st1', 'StudyStep');
model.sol('sol1').feature('st1').set('study', 'std1');
model.sol('sol1').feature('st1').set('studystep', 'stat');
model.sol('sol1').feature.create('v1', 'Variables');
model.sol('sol1').feature('v1').set('control', 'stat');
model.sol('sol1').feature.create('s1', 'Stationary');
model.sol('sol1').feature('s1').feature.create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').feature('fc1').set('linsolver', 'dDef');
model.sol('sol1').feature('s1').feature.remove('fcDef');
model.sol('sol1').attach('std1');

model.sol('sol1').runAll;
checklin = ((0:1:3)*2)+18;

model.result.numerical.create('int1', 'IntLine');
model.result.numerical('int1').selection.set(checklin(1));
model.result.numerical('int1').set('expr', 'ec.normJ');
model.result.numerical('int1').set('descr', 'Current density norm');
model.result.table.create('tbl1', 'Table');
model.result.table('tbl1').comments('Line Integration 1 (ec.normJ)');
model.result.numerical('int1').set('table', 'tbl1');
model.result.numerical('int1').setResult;

model.result.numerical.create('int2', 'IntLine');
model.result.numerical('int2').set('data', 'dset2');
model.result.numerical('int2').selection.set(checklin(2));
model.result.numerical('int2').set('expr', 'ec2.normJ');
model.result.numerical('int2').set('descr', 'Current density norm');
model.result.table.create('tbl2', 'Table');
model.result.table('tbl2').comments('Line Integration 2 (ec2.normJ)');
model.result.numerical('int2').set('table', 'tbl2');
model.result.numerical('int2').setResult;

model.result.numerical.create('int3', 'IntLine');
model.result.numerical('int3').set('data', 'dset3');
model.result.numerical('int3').selection.set(checklin(3));
model.result.numerical('int3').set('expr', 'ec3.normJ');
model.result.numerical('int3').set('descr', 'Current density norm');
model.result.table.create('tbl3', 'Table');
model.result.table('tbl3').comments('Line Integration 3 (ec3.normJ)');
model.result.numerical('int3').set('table', 'tbl3');
model.result.numerical('int3').setResult;

model.result.numerical.create('int4', 'IntLine');
model.result.numerical('int4').set('data', 'dset4');
model.result.numerical('int4').selection.set(checklin(4));
model.result.numerical('int4').set('expr', 'ec4.normJ');
model.result.numerical('int4').set('descr', 'Current density norm');
model.result.table.create('tbl4', 'Table');
model.result.table('tbl4').comments('Line Integration 4 (ec4.normJ)');
model.result.numerical('int4').set('table', 'tbl4');
model.result.numerical('int4').setResult;