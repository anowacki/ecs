#!/bin/bash
# Convert Table 1 of
#	The elastic properties and stability of fcc-Fe and fcc-FeNi alloys at inner-core conditions
#	Benjamí Martorell, John Brodholt, Ian G. Wood, and Lidunka Vočadlo
#	Geophys. J. Int. 2015 202: 94-101
# to .ecs files in this directory, and also ../hcp-Fe.

P=360 # GPa
TABLE="Martorelli et al., GJI., 2015.txt"
HCPDIR="../hcp-Fe"
[ -f "$TABLE" ] || { echo "Can't find the file \"$TABLE\"" >&2; exit 1; }
[ -d "$HCPDIR" ] || { echo "Can't find directory \"$HCPDIR\"" >&2; exit 1; }

# Remove previous files if any exist
for f in ./*Martorelli_GJI_2015.ecs "$HCPDIR/"*Martorelli_GJI_2015.ecs; do
	[ -f "$f" ] && rm "$f"
done

# Create .ecs files by calling enter-ecs
for l in {2..20}; do
	awk -v l=$l -v P=$P -v hcpdir="$HCPDIR" '
	BEGIN {
		# Label for the reference
		REF = "The elastic properties and stability of fcc-Fe and fcc-FeNi alloys at inner-core conditions\nBenjamí Martorell, John Brodholt, Ian G. Wood, and Lidunka Vočadlo\nGeophys. J. Int. 2015 202: 94-101"
	}
	NR == l {
		if ($1 == "hcp-Fe") {
			form = hcpdir "/Fe_hcp"
		} else {
			form = $1
		}
		if (form ~ /fcc/) {
			if (form == "fcc-Fe") {
				form = "Fe_fcc"
			} else {
				form = substr(form, 5) "_fcc"
			}
		}
		T = $2
		rho = $3
		if (form ~ /hcp/) {
			c11 = $4
			c12 = $5
			c33 = $6
			c13 = $7
			c44 = $8
		} else {
			c11 = $4
			c12 = $5
			c44 = $6
		}
		file = form "_" P "GPa_" T "K_Martorelli_GJI_2015.ecs"
		print "enter-ecs",file,"<<END > /dev/null"
		if (form ~ /hcp/) {
			print "h"
			print c11
			print c33
			print c12
			print c13
			print c44
		} else {
			print "c"
			print c11
			print c44
			print c12
		}
		print rho
		print REF
	}
	' "$TABLE" | sh
done
