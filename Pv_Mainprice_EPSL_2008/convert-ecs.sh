#!/bin/bash
#
# Convert the elastic constants from David Mainprice from:
# 
#   Predicted glide systems and crystal preferred orientations of polycrystalline 
#   silicate {Mg}-Perovskite at high pressure: Implications for the seismic
#   anisotropy in the lower mantle.
#   
#   Mainprice D, Tommasi A, Ferr\'e D, Carrez P, Cordier P.
#   
#   Earth Planet.\ Sci.\ Lett., 271, (1--4), pp.\ 135--144.
#   
#   http://dx.doi.org/10.1016/j.epsl.2008.03.058
#
# into .ecs format.  The script uses the email to find the densities.
# 1 MBar == 1e11 Pa == 100 GPa

EMAIL="Fwd_ Elastic constants.eml"

for f in *.txt; do
	a=(${f//_/ }) # split into arrays
	fig=${a[0]} # Figure no.
	s=${a[1]}   # Equivalent strain
	if [ "$fig" = Fig7 ]; then
		P=38 # GPa
		PT=${a[2]}
		T=${PT:5:4} # K
	else
		P=88
		T=${a[4]}
		T=${T:1:4}
	fi
	rho=`grep "P=3D${P}" "$EMAIL" | grep "T=3D${T}K" | head -n 1 |
		cut -d " " -f 7 | sed s/density=3D//` # g/cm^3
	
	ofile=MgSiO3_pv_${P}Pa_${T}K_${s}strain_Mainprice_EPSL_2008.ecs
	
	awk -v rho=$rho '
		NR > 3 {i=NR-3; for (j=1; j<=6; j++) c[i,j] = $j*100}
		END {for (i=1; i<=6; i++) {
				for (j=i; j<=6; j++) printf("%d %d %0.4fe9\n",i,j,c[i,j])}
			printf("%d %d %f\n",7,7,rho*1000)}' $f > $ofile
done
