#!/bin/bash
# Create the elastic constants from:
citation="
# First-principles investigation of hydrous post-perovskite
# Joshua P. Townsend, Jun Tsuchiya, Craig R. Bina and Steven D. Jacobsen.
# Phys. Earth Planet. Inter. 2015 (244) 42-48"

TABLE="Hy-Ppv_Townsend_PEPI_2015.text"

[ -f "$TABLE" ] || { echo "Cannot find table file \"$TABLE\"" >&2; exit 1; }

while read struct P c11 c22 c33 c44 c55 c66 c12 c13 c23 rho vp vs K G; do
	file="_0K_Townsend_PEPI_2015.ecs"
	case "$struct" in
		"#") continue;;
		ppv)            file="MgSiO3_ppv_${P}GPa${file}";;
		hy-ppv_1.14wt%) file="Mg0.938SiH0.125O3_hy-ppv_${P}GPa${file}";;
		hy-ppv_2.31wt%) file="Mg0.875SiH0.250O3_hy-ppv_${P}GPa${file}";;
		*) { echo "Unexpected structure name \"$struct"\" >&2; exit 1; };;
	esac
	cat > "$file" <<-END
	cat <<-END
	1 1 ${c11}.e9
	1 2 ${c12}.e9
	1 3 ${c13}.e9
	1 4 0.e9
	1 5 0.e9
	1 6 0.e9
	2 2 ${c22}.e9
	2 3 ${c23}.e9
	2 4 0.e9
	2 5 0.e9
	2 6 0.e9
	3 3 ${c33}.e9
	3 4 0.e9
	3 5 0.e9
	3 6 0.e9
	4 4 ${c44}.e9
	4 5 0.e9
	4 6 0.e9
	5 5 ${c55}.e9
	5 6 0.e9
	6 6 ${c66}.e9
	7 7 ${rho}
	$citation
	#
	# Input by $USER on $(hostname) on $(date)
	END
done < "$TABLE"