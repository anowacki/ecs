#!/bin/bash
# Values from:
#	Isaak, Donald G. (1992) High-temperature elasticity of iron-bearing olivine
#	JGR, 97 (B2), 1871-1885.
# Take Tables 3a and 3b (combined with density in Tables 4a and 4b), and
# write out files for each experimental temperature.

OLA=Isaak_JGR_1992_table3a_OLA.text
RAM=Isaak_JGR_1992_table3b_RAM.text

P=0.0

for sample in $OLA $RAM; do
	s=${sample: -8:3}
	case $s in
		OLA) formula="(Mg0.921Fe0.077)2SiO4" ;;
		RAM) formula="(Mg0.903Fe0.095)2SiO4" ;;
	esac
	awk -v formula="$formula" -v P="$P" '
	$1 == "T" {
		for (i=2; i<=NF; i++) {
			T[i] = $i
			# print "T["i"] = " T[i]
		}
	}
	$1 ~ /C/ || $1 ~ /rho/ {
		if ($1 ~ /C/) {
			I = substr($1,2,1)
			J = substr($1,3,1)
		} else {
			I = 7
			J = 7
		}
		j = 2
		for (i=2; i<=NF; i++) {
			if (substr($i,1,1) == "-") {
				# print "   Skipping uncertainty value of " $i
				continue
			}
			c[I,J,j] = $i
			# print "C["I","J"] at "T[j]"K = " c[I,J,j]
			j++
		}
	}
	
	END {
		for (i=2; i<=length(T)+1; i++) {
			file = formula "_ol_" P "GPa_" T[i] "K_Isaak_JGR_1992.ecs"
			print "Writing out to file "file
			printf("") > file
			for (I=1; I<=6; I++) {
				for (J=I; J<=6; J++) {
					printf("%d %d %7.2fe9\n", I, J, c[I,J,i]) >> file
				}
			}
			printf("%d %d %4.1f\n", 7, 7, 1000*c[7,7,i]) >> file
		}
	}
	' "$sample"
done
