# STN_LFP_Model
Model to estimate beta oscillation source origins in subthalamic nucleus dbs-LFP recordings

Sample Workflow

1) Submit StnNeuronModel/STN.slurm to your computing cluster for batch processing. This should yield some number of txt files containing the transmembrane currents of each section the STN model

2) Convert these results to binaries using the convert.m script. Create a directory of STN activity using. For "synchronous" neuron ensure that the sigma_cell variable is set to 6.25 while for asynchronous neurons sigma_cell is 10.

3) Process your patient images to create a binary mask of the STN in nifti format. Use this mask to create a pointcloud using mask2pts2.m

4) Ensure that Comsol is configured to run with matlab.

5) Run coupled7.m. This will compute the voltage imposed in your volume conductor using bioplar3.m to run a comsol model, then import the currents from your directory where you saved the neuron results as binaries and then compute a model LFP using the parameters specified in coupled7.m

6) Process the model results using whatever post-processing you would like. The two examples provided will scan the model LFP to determine which model results have the best concordance with experimental LFPs. The other will add a 1/f distribution to the model LFP and plot it alonside the experimental LFP

For help contact nickmaling@gmail.com

Known Issues:
Directory pointers hardcoded throughout
Sparsley commented
Variables nonsecially named



    This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. 

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
