#!/bin/bash
# Return the elastic constants of olivine from:
#	Abramson et al.  The elastic constants of San Carlos olivine to 17 GPa.
#	JGR, 102, 12,253-12,263, doi:10.1029/97JB00682
# given the value of P.

usage () {
	cat <<-END >&2
	Usage: $(basename $0) [Pressure / GPa]
	Returns the 36 elastic constants of San Carlos olivine as a function of pressure,
	plus density in column 37, as given by Abramson et al.
	Experimental range is 0 - 17 GPa.
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
	return 3355 + 26.1244*p - 0.23872*p^2
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
	c[1,1] = 320.5
	c[1,2] =  68.1
	c[1,3] =  71.6
	c[2,2] = 196.5
	c[2,3] =  76.8
	c[3,3] = 233.5
	c[4,4] =  64.0
	c[5,5] =  77.0
	c[6,6] =  78.7
	
	# First derivatives with pressure
	cp[1,1] = 6.54
	cp[1,2] = 3.86
    cp[1,3] = 3.57
    cp[2,2] = 5.38
    cp[2,3] = 3.37
    cp[3,3] = 5.51
    cp[4,4] = 1.67
    cp[5,5] = 1.81
    cp[6,6] = 1.93
	
	# Second derivatives
	cpp[5,5] = -0.070
	
	# Make symmetrical
	for (i=1; i<=6; i++) {
		for (j=i+1; j<=6; j++) {
			c[j,i] = c[i,j]
			cp[j,i] = cp[i,j]
			cpp[j,i] = cpp[i,j]
		}
	}
	
	if (P > 17) print name ": Warning: "\
		"Extrapolating values beyond experimental range" > "/dev/stderr"
	# Output 36 constants, normalised by density...
	for (i=1; i<=6; i++) {
		for (j=1; j<=6; j++) {
			printf("%f ", 1.e9*(c[i,j] + P*cp[i,j] + P^2*cpp[i,j]/2.)/rho(P))
		}
	}
	# ...and density
	printf("%f\n", rho(P))
}'
