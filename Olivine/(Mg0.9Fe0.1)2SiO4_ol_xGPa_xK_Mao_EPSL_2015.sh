#!/bin/bash

usage () {
	cat <<-END >&2
	Usage: $(basename $0) [P] [T]
	Returns the 36 elastic constants of forsterite-90 at a given P and T
	as given by  Mao et al. (EPSL, 2015).
	Experimental range is 0-19.2 GPa and 300-900 K.
	END
	exit 1
}

# NB: I currently can't reproduce Mao et al.'s Figure 3 with their numbers!
# See the script Maco_EPSL_2015_test_derivs.sh
echo "At the moment, the numbers given by Mao et al. don't seem to give you
the right values for Cij at high P (although the T derivative seems okay)." >&2
exit 1

# Check arguments
[ $# -ne 2 ] && usage
printf "%f" "$1" >/dev/null 2>&1 || printf "%f" "$2" >/dev/null 2>&1 || usage
P="$1"
[ "${P:0:1}" = "-" ] && { echo "P must be positive" >&2; exit 1; }
T="$2"
[ "${T:0:1}" = "-" ] && { echo "T must be positive" >&2; exit 1; }

# Check files exist
VALS="$(dirname "$0")/Mao_EPSL_2015_tableS1.text"
DERIVS="$(dirname "$0")/Mao_EPSL_2015_tableS2.text"
[ -f "$VALS" ] || { echo "Can't find file \"$VALS\"" >&2; exit 1; }
[ -f "$DERIVS" ] || { echo "Can't find file \"$DERIVS\"" >&2; exit 1; }

awk -v P="$P" -v T="$T" -v VALS="$VALS" -v DERIVS="$DERIVS" -F, '
BEGIN {
	if (P > 19.2) print "Warning: Extrapolating beyond experimental range in P (0-19.2 GPa)" \
		> "/dev/stderr"
	if (T > 900) print "Warning: Extrapolating beyond experiment range in T (300-900 K)" \
		> "/dev/stderr"
}

# Read in 300K, 0 GPa values
FILENAME == VALS && NR == 2 {
	gsub("\\([^\\(]*\\)","") # Remove uncertainties
	rho0 = $3
	C0[1,1] = $4
	C0[2,2] = $5
	C0[3,3] = $6
	C0[4,4] = $7
	C0[5,5] = $8
	C0[6,6] = $9
	C0[1,2] = $10
	C0[1,3] = $11
	C0[2,3] = $12
	KT0 = $13
	GT0 = $14
}

# Read in derivatives
FILENAME == DERIVS && NR > 2 {
	gsub("\\([^\\(]*\\)","") # Remove uncertainties
	gsub("[ab]", "") # Remove notes
	if (substr($1,1,1) == "C") {
		i = substr($1,2,1)
		j = substr($1,3,1)
		dCdP[i,j] = $2
		if (i == 1 && j == 2) dCdT[i,j] = -0.015 - 0.00021*T
		if (i == 1 && j == 3) dCdT[i,j] = -0.015 - 0.00021*T
		d2CdP2[i,j] = $3
		dCdT[i,j] = $4
	}
}

# Evaluate the constants
END {
	# Make arrays symmetrical
	for (i=1; i<=6; i++) {
		for (j=i+1; j<=6; j++) {
			C0[j,i] = p[i,j]
			dCdP[j,i] = pp[i,j]
			d2CdP2[j,i] = t[i,j]
			dCdT[j,i] = tt[i,j]
		}
	}
	
	for (i = 1; i <= 6; i++) {
		for (j = 1; j<=6; j++) {
			c = C0[i,j] + dCdP[i,j]*P + d2CdP2[i,j]*P^2/2 + dCdT[i,j]*(T - 300)
			printf("%f ", c*1.e9)
		}
	}
	printf("\n")
}
' "$VALS" "$DERIVS"
