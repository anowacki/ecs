#!/bin/bash
# Plot up a reproduction of Mao et al.'s Figure 3 to check I've understood their
# convention with the values of the derivatives.

FIG=$(mktemp /tmp/Mao_EPSL_2015_test_derivs.shXXXXXX)
trap 'rm -f "$FIG"' EXIT

glob1="(Mg0.9Fe0.1)2SiO4_ol_"
glob2="_Mao_EPSL_2015.ecs"
SCRIPT="(Mg0.9Fe0.1)2SiO4_ol_xGPa_xK_Mao_EPSL_2015.sh"

[ -x "$SCRIPT" ] || { echo "Can't find script \"$SCRIPT\"" >&2; exit 1; }

for ij in 55; do #11 22 33 44 55 66 12 13 23; do
	i=${ij:0:1}
	j=${ij:1:1}

	# Get range
	read min max _ <<< $(awk -v i=$i -v j=$j '
		$1==i && $2 == j {if ($3<min || n==0) min=$3; if ($3>max||n==0) max=$3; n++}
		END{print 0.9*min/1.e9, 1.1*max/1.e9}' "$glob1"*"$glob2")

	# Draw axes
	psbasemap -JX8c/8c -R-1/20/$min/$max -P -K \
		-Ba6f3":Pressure / GPa:"/a30f15":C@-${i}${j}@- / GPa:"nSeW > "$FIG"

	for T in 300 500 750 900; do
		maxP=15
		case $T in
			300) c=blue; maxP=20;;
			500) c=darkgreen;;
			750) c=orange;;
			900) c=red;;
		esac

		# Plot data points
		awk -v i=$i -v j=$j '$1==i && $2==j {
			P=FILENAME; sub(".*_ol_", "", P); sub("GPa.*", "", P); print P,$3/1e9}' \
			"$glob1"*${T}K*"$glob2" |
		psxy -J -R -Sc0.2c -W0.5p,black -G$c -O -K >> "$FIG"

		# Plot fit
		column=$(((i - 1)*6 + j))
		for ((P=0; P<=maxP; P++)); do
			./"$SCRIPT" $P $T 2>/dev/null | awk -v c=$column -v P=$P '{print P,$c/1e9}'
		done | psxy -J -R -O -K -W1p,$c >> "$FIG"
	done &&
	psxy -J -R -T -O >> "$FIG" &&
	gv "$FIG"
done
