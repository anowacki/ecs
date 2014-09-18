#!/bin/bash
# Return the elastic constants of olivine (Fo90) at a given P and T, using both
# the P-derivatives of Abramson et al. (1997) and T-derivatines of Isaak (1992).
# This may or may not be the correct thing to do...

usage () {
	cat <<-END >&2
	Usage: $(basename $0) [P] [T]
	Returns the 36 elastic constants of forsterite-90 at a given P and T
	as given by the T-derivatives of Isaak (1992), and the P-derivatives
	of Abramson et al. (1997).
	Experimental range is 0-17 GPa and 295-1500 K.
	END
	exit 1
}

# Check arguments
[ $# -ne 2 ] && usage
printf "%f" "$1" >/dev/null 2>&1 || printf "%f" "$2" >/dev/null 2>&1 || usage
P="$1"
[ "${P:0:1}" = "-" ] && { echo "P must be positive" >&2; exit 1; }
T="$2"
[ "${T:0:1}" = "-" ] && { echo "T must be positive" >&2; exit 1; }

PVALS="$(dirname $0)/Abramson_JGR_1997_table4_dCdP.text"
TVALS="$(dirname $0)/Isaak_JGR_1992_table5_dCdT.text"
# Check input files exist
for f in "$PVALS" "$TVALS"; do
	[ -f "$f" ] || { echo "Can't find file $f">&2; exit 1; }
done

awk -v P="$P" -v T="$T" -v PVALS="$PVALS" -v TVALS="$TVALS" '
BEGIN {
	if (P > 17) print "Warning: Extrapolating beyond experimental range in P (0-17 GPa)" \
		> "/dev/stderr"
	if (T > 1500) print "Warning: Extrapolating beyond experiment range in T (295-1700 K)" \
		> "/dev/stderr"
}

FILENAME == PVALS {
	# Read in P derivatives (in GPa, Gpa/GPa and GPa^-1)
	if (substr($1,1,1) == "C") {
		i = substr($1,2,1)
		j = substr($1,3,1)
		p[i,j] = $2
		pp[i,j] = $3
		ppp[i,j] = $4
	}
	# Density, in kg/m^3, kg.m^-3/GPa and kg.m^-3/GPa^2
	if ($1 == "rho") {
		rho0p = $2
		rhop = $3
		rhopp = $4
	}
}

FILENAME == TVALS {
	# Read in T derivatives (in GPa, 10^-2/GPa)
	if ($1 == "RAM") {
		t[1,1]  =  $2/100
		t[2,2]  =  $4/100
		t[3,3]  =  $6/100
		t[4,4]  =  $8/100
		t[5,5]  = $10/100
		t[6,6]  = $12/100
		t[2,3]  = $14/100
		t[1,3]  = $16/100
		t[1,2]  = $18/100
		tt[1,1] = $28/100
		tt[2,2] = $29/100
		tt[3,3] = $30/100
		tt[4,4] = $31/100
		tt[5,5] = $32/100
		tt[6,6] = $33/100
		tt[2,3] = $34/100
		tt[1,3] = $35/100
		tt[1,2] = $36/100
		# rho derivatives are in kg/m^3 and derivatives thereof.
		rho0t   = $41
		rhot    = $42
		rhott   = $43
	}
}

END {
	# Make arrays symmetrical
	for (i=1; i<=6; i++) {
		for (j=i+1; j<=6; j++) {
			p[j,i] = p[i,j]
			pp[j,i] = pp[i,j]
			ppp[j,i] = ppp[i,j]
			t[j,i] = t[i,j]
			tt[j,i] = tt[i,j]
		}
	}
	# Produce elastic constants divided by density, and density
	# NB: Pressure must be in GPa and temperature in K.  We keep everything in
	# these units until the last minute, where we convert to GPa.
	rho = rho0p + rhop*P + rhopp*P^2/2 + rhot*(T-300) + rhott*(T-300)^2/2  # kg/m^3
	for (i=1; i<=6; i++) {
		for (j=1; j<=6; j++) {
			c = p[i,j] + pp[i,j]*P + ppp[i,j]*P^2/2 + tt[i,j]*(T-300)
			printf("%f ", 1e9*c/rho)
		}
	}
	printf("%f\n", rho)
}
' "$PVALS" "$TVALS"