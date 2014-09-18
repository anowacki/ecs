#!/bin/bash
# Convert the ODF files in XIO (from Beartex) format into one where we assume
# symmetry about the compression direction, averaging out the variations in
# concentration around [0001].

usage () {
	cat <<-END >&2
	Usage: $(basename $0) [.XIO texture file] [.ecs file]
	Sends ECs in .ecs format to stdout
	END
	exit 1
}

[ "$1" ] && XIO="$1" || usage
[ "$2" ] && CIJ="$2" || usage

# Single-crystal elastic constants to use
cij=$(ecs2ij $CIJ)
rho=$(awk '$1==7{print $3}' $CIJ)

tr -d '\r' < "$XIO" | awk '
BEGIN {
	phi = 0
	theta = 0
}

NR == 7 {
	theta1 = $4
	theta2 = $5
	dtheta = $6
	phi1 = $7
	phi2 = $8
	dphi = $9
	theta = theta1
	nphi = (phi2 - phi1)/dphi + 1
	ntheta = (theta2 - theta1)/dtheta + 1
}

NR >= 8 {
	if (NR%2 == 0) {
		phi = phi1
		mean = 0
		n = 0
	}
	for (i=1; i<=NF; i++) {
		mean += $i
	}
	if (NR%2 != 0) {
		print theta, mean/nphi
		theta += dtheta
	}
}
' | while read line; do
	a=($line)
	theta=${a[0]}
	vf=${a[1]}
	ecs=$(echo $cij | CIJ_rot3 0 $theta 0)
	echo $vf $ecs $rho
done | CIJ_VRH | CIJ_axial_average 3 36 | CIJ_normalise 1/$rho | ij2ecs -r $rho
