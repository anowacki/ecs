#!/bin/bash
# Make a few different cases of VTI for testing within MSAT

write_vals() {
	# Write the values to a file appropriately named.
	# Check variables exist
	[[ -z "$vp" || -z "$vs" || -z "$rho" || -z "$xi" || -z "$phi" || -z "$eta" ]] &&
	{ echo "write_vals: Need all vars vp vs rho xi phi eta to be set" 1>&2; exit 1; }
	# Calculate ECs, normalise to density and save in current directory to file
	CIJ_global_VTI $vp $vs $rho $xi $phi $eta |
		CIJ_normalise 1/$rho | CIJ_36to21 |
		awk -v rho=$rho '{print $0,rho}' > \
			vp${vp}_vs${vs}_rho${rho}_xi${xi}_phi${phi}_eta${eta}.ecs
}

# Upper mantle values, eta and phi 1
vp=8000  vs=4400  rho=3300  xi=1.1  phi=1  eta=1  write_vals

# Lower mantle values, all parameters vary
vp=13700 vs=7300  rho=5500  xi=0.95 phi=1.01 eta=1.2  write_vals

# PREM at r=6151 km (x = r/6371):
# Vpv =  0.8317 +7.2180*x = 7.80045
# Vph =  3.5908 +4.6172*x = 8.04856
# Vsv =  5.8582 -1.4678*x = 4.44109
# Vsh = -1.0839 +5.7176*x = 4.43626
# eta =  3.3687 -2.4778*x = 0.976462
# rho =  2.6910 +0.6924*x = 3.35949
# xi = 0.9989
# phi = 0.9692
# Isotropic average quoted at
# <Vp> = 4.1875 +3.9382*x = 7.9897
# <Vs> = 2.1519 +2.3481*x = 4.4152
