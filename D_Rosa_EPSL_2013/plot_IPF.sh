#!/bin/bash
# Plot invers pole figure files in XIO format (from Beartex)

usage () {
	cat <<-END >&2
	Usage: $(basename $0) [.XIO file]
	Plot up inverse pole figures using files in 
	END
	exit 1
}

[ "$1" ] && IN="$1" || usage

CPT=$(mktemp /tmp/plot_IPF.cptXXXXXX)
GRD=$(mktemp /tmp/plot_IPF.grdXXXXXX)
FIG=$(mktemp /tmp/plot_IPF.psXXXXXX)

trap "rm -f $CPT $GRD $FIG" EXIT

max=$(tr -d '\r' < "$IN" | awk 'NR>=8{for (i=1; i<=NF; i++) if ($i > max) max=$i}END{print max}')
makecpt -T$(echo "-1*$max/8" | bc -l)/$max/$(echo "$max/8" | bc -l) > "$CPT"

tr -d '\r' < "$IN" | awk '
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
	max = 0
	min = 1e36
}

NR >= 8 {
	# Field number is angle away from phi1 and record number is
	# angular distance from theta1
	if (NR%2 == 0) {
		phi = phi1
	}
	for (i=1; i<=NF; i++) {
		print phi, theta, $i
		phi += dphi
		if ($i > max) max = $i
		if ($i < min) min = $i
	}
	if (NR%2 != 0) {
		theta += dtheta
	}
}
' | awk '$2<=90{$2=90-$2; print}' | surface -G$GRD -R0/120/0/90 -I1 &&
grdimage $GRD -JA-90/90/10c -R0/120/0/90 -C"$CPT" -K -Bnsew > "$FIG" &&
pstext -J -R -O -N <<END >> "$FIG"
0  90 10 0 0 RM [0001]
0   0 10 0 0 LM [-12-10]
40  0 10 0 0 BL [10-10]
80  0 10 0 0 BL [01-10]
120 0 10 0 0 RM [2-1-10]
END
gv "$FIG" 2>/dev/null

