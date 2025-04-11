#!/bin/bash
# we are now inside the linux environment of our PostGIS container
echo "Hi from the import script"

### PARALLEL RASTER2PGSQL
cd /importdata 
files_gain=$(ls Hansen_GFC_gain_*)
echo "HERE COMES THE GAIN FILES: $files_gain --> NOW USING PARALLELIZATION"
parallel --tty -j 8 'raster2pgsql -s 4326 -I -C -t 100x100 -l 128 -d {} public.gain_{} -Y 1000 | psql -d johndoe_db -U johndoe -h localhost -p 5432' ::: $files_gain

cd /importdata 
files_cover=$(ls Hansen_GFC_treecover*)
echo "HERE COMES THE GAIN FILES: $files_cover --> NOW USING PARALLELIZATION"
parallel --tty -j 8 'raster2pgsql -s 4326 -I -C -t 100x100 -l 128 -d {} public.cover_{} -Y 1000 | psql -d johndoe_db -U johndoe -h localhost -p 5432' ::: $files_cover

# FOR LANCZOS FILES:
# cd /importdata 
# files_cover=$(ls treecover*_lanczos.tif)
# echo "HERE COMES THE GAIN FILES: $files_cover --> NOW USING PARALLELIZATION"
# parallel --tty -j 8 'raster2pgsql -s 4326 -I -C -t 100x100 -d {} public.{} -Y 1000 | psql -d johndoe_db -U johndoe -h localhost -p 5432' ::: $files_cover

cd /importdata 
files_loss=$(ls Hansen_GFC_lossyear_*)
echo "HERE COMES THE LOSSYEAR FILES: $files_loss --> NOW USING PARALLELIZATION"
parallel --tty -j 8 'raster2pgsql -s 4326 -I -C -t 100x100 -l 128 -d {} public.lossyear_{} -Y 1000 | psql -d johndoe_db -U johndoe -h localhost -p 5432' ::: $files_loss

echo ".sh scriptm completed --> END OF THE IMPORT SCRIPT"