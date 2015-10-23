#!/bin/bash
# Values from:
#	Zhu Mao, Dawei Fan, Jung-Fu Lin, Jing Yang, Sergey N. Tkachev, Kirill Zhuravlev,
#	Vitali B. Prakapenka
#	Elasticity of single-crystal olivine at high pressures and temperatures
#	Earth Planet Sci Lett, 426, 204-215.  doi:doi:10.1016/j.epsl.2015.06.045

awk -F, '
	BEGIN{ OFS=" " }
	NR > 1 {
		gsub("\\([^\\(]*\\)","") # Remove uncertainties
		if ($1 == "") $1 = T; else $1 = $1 # Force output with new OFS
			$3 *= 1000
		print $0
		T = $1
	}' Mao_EPSL_2015_tableS1.text |
while read T P rho c11 c22 c33 c44 c55 c66 c12 c13 c23 K G rest; do
	file="$(printf "(Mg0.9Fe0.1)2SiO4_ol_%04.1fGPa_${T}K_Mao_EPSL_2015.ecs" $P)"
	[ -f "$file" ] && { echo "Skipping existing file \"$file\"" >&2; continue; }
	enter-ecs "$file" <<-END >/dev/null
	o
	$c11
	$c22
	$c33
	$c12
	$c13
	$c23
	$c44
	$c55
	$c66
	$rho
	Pressure: $P GPa
	Temperature: $T K
	Zhu Mao, Dawei Fan, Jung-Fu Lin, Jing Yang, Sergey N. Tkachev, Kirill Zhuravlev,
	Vitali B. Prakapenka
	Elasticity of single-crystal olivine at high pressures and temperatures
	Earth Planet Sci Lett, 426, 204-215.  doi:doi:10.1016/j.epsl.2015.06.045
	END
done
