#!/bin/bash
# Return the elastic constants for phase A as determined by
# Carmen Sanchez-Vallea,b,∗, Stanislav V. Sinogeikinc, Joseph R. Smythd, Jay D. Bass
# Sound velocities and elasticity of DHMS phase A to high pressure and implications for seismic velocities and anisotropy in subducted slabs
# PEPI (2008) 170, 229-239
# at any given pressure

usage () {
	cat <<-END >&2
	Usage: $(basename $0) [Pressure / GPa]
	Returns the 36 elastic constants of phase A as a function of pressure,
	plus density in column 37, as given by Sanchez-Valle et al. (2008) PEPI.
	Experimental range is 0 - 12.4 GPa.
	END
	exit 1
}

[ $# -ne 1 ] && usage

P="$1"
printf "%f" >/dev/null 2>&1 ||
	{ echo "Must supply pressure as first argument" >&2; usage; }
[ "${P:0:1}" = "-" ] && { echo "Pressure must be positive" >&2; exit 1; }

awk -v P="$P" -v name=$(basename $0) '

# Fit to density from experiments using 2nd order polynomial
function rho(p) {
	return 2976 + 27.481*p - 0.3805*p^2
}

BEGIN {
	# Zero arrays
	for (i=1; i<=6; i++) {
		for (j=i; j<=6; j++) {
			c[i,j] = 0.0
			cp[i,j] = 0.0
			cpp[i,j] = 0.0
		}
	}
	
	# Constants at 0.0 GPa
	c[1,1] = 180.8
	c[3,3] = 227.6
	c[4,4] = 62.7
	c[6,6] = 50.1
	c[1,2] =  80.6
	c[1,3] =  51.2
	c[2,2] = c[1,1]
	c[2,3] = c[1,3]
	c[5,5] = c[4,4]
	
	# First derivatives with pressure
	cp[1,1] = 6.78
    cp[3,3] = 6.91
    cp[4,4] = 3.25
    cp[6,6] = 1.75
	cp[1,2] = 4.92
    cp[1,3] = 4.95
    cp[2,2] = cp[1,1]
    cp[2,3] = cp[1,3]
    cp[5,5] = cp[4,4]
	
	# Second derivatives
	cpp[4,4] = -0.086
	cpp[5,5] = cpp[4,4]
	cpp[6,6] = -0.071
	cpp[1,3] = -0.076
	cpp[2,3] = cpp[1,3]
	
	# Make symmetrical
	for (i=1; i<=6; i++) {
		for (j=i+1; j<=6; j++) {
			c[j,i] = c[i,j]
			cp[j,i] = cp[i,j]
			cpp[j,i] = cpp[i,j]
		}
	}
	
	if (P > 12.4) print name ": Warning: "\
		"Extrapolating values beyond experimental range" > "/dev/stderr"
	# Output 36 constants, normalised by density...
	for (i=1; i<=6; i++) {
		for (j=1; j<=6; j++) {
			# printf("%f ", 1.e9*(c[i,j] + P*cp[i,j] + P^2*cpp[i,j]/1.)/rho(P))
			# ECs do not look right when dividing cpp by two...
			printf("%f ", 1.e9*(c[i,j] + P*cp[i,j] + P^2*cpp[i,j]/1.)/rho(P))
		}
	}
	# ...and density
	printf("%f\n", rho(P))
}'
