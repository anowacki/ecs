#!/bin/bash
# Convert the data in Table 2 of:
#	Li Li, Donald J. Weidner, John Brodholt, Dario Alfè, G. David Price
#	Ab initio molecular dynamics study of elasticity of akimotoite MgSiO3 at mantle conditions
#	Physics of the Earth and Planetary Interiors, Volume 173, Issues 1–2, March 2009, Pages 115–120
#	http://dx.doi.org/10.1016/j.pepi.2008.11.005
# from CSV form to input into the enter-ecs script
#
# Ilemnite is trigonal with 7 constants; enter-ecs expects them in the following order:
#	11 33 12 13 14 25 44
# Density is then calculated from the unit cell volume and atomic constants.  There
# are four formula units per unit cell (i.e., there are 4xMg, 4xSi and 12xO), and the
# volumes quoted by Li et al are for a 120-atom cell.  Hence there are 120/5 each of Mg
# and Si, and 3*120/5 O (i.e., 24xMg, 24xSi, 72xO).

# Remove old runs
/bin/rm -f MgSiO3_ilm_*GPa_*K_Li_PEPI_2009.ecs

awk -F, '
	BEGIN {
		# Initialise arrays
		for (i=1; i<=9; i++) {
			V[i] = 0
			T[i] = 0
			P[i] = 0
			C11[i] = 0
			C12[i] = 0
			C13[i] = 0
			C14[i] = 0
			C33[i] = 0
			C44[i] = 0
			C25[i] = 0
		}
	}
	
	# Function which fills array elements with columns 2 to 9
	function read_in_line(a,   i) {
		for (i=2; i<=NF; i++) a[i-1] = $i
	}
	
	NR >=3 && NR <= 12 {
		if (NR == 3) read_in_line(V)
		if (NR == 4) read_in_line(T)
		if (NR == 5) read_in_line(P)
		if (NR == 6) read_in_line(C11)
		if (NR == 7) read_in_line(C12)
		if (NR == 8) read_in_line(C13)
		if (NR == 9) read_in_line(C14)
		if (NR == 10) read_in_line(C33)
		if (NR == 11) read_in_line(C44)
		if (NR == 12) read_in_line(C25)
	}
	
	END {
		print "cd",ENVIRON["PWD"]
		# Write out constants to different files.
		for (i=1; i<=9; i++) {
			f = sprintf("MgSiO3_ilm_%sGPa_%sK_Li_PEPI_2009.ecs",P[i],T[i])
			print "enter-ecs << END > /dev/null",f
			print "trig7"
			printf("%f\n%f\n%f\n%f\n%f\n%f\n%f\n", \
				C11[i],C33[i],C12[i],C13[i],C14[i],C25[i],C44[i])
			print V[i],"Mg 24 Si 24 O 72"
			print "END"
		}
	}
' MgSiO3_ilm_Li_PEPI_2009_Table2.csv | sh
