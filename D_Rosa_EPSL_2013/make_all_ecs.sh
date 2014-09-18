#!/bin/bash
# Make axially-symmetric textures for all the inverse pole figures from Angelika Rosa.

ECS="$HOME/Work/ECs/D/Mg1.0Fe0.11Al0.03Si1.9H2.5O6_D_0GPa_300K_Rosa_2012_GRL.ecs"

for f in ForAndy/ODF_Figure4/*D/*GPa/*.XIO; do
	out=${f%\.XIO}_axial_average_0001.ecs
	./XIO2axial_texture.sh "$f" "$ECS" > "$out"
done
