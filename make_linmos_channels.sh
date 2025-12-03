#!/usr/bin/bash -l
#SBATCH --job-name=flint
#SBATCH --export=NONE
#SBATCH --cpus-per-task=4
#SBATCH --ntasks=1
#SBATCH --mem=32GB
#SBATCH --time=1-23:00:00
#SBATCH -A OD-207757
#SBATCH --array=0-73%73

export OMP_NUM_THREADS=4

module load apptainer
conda activate flint_jollytractor

NAME="small_beam02_cube"
CUBE="${NAME}.fits"
fitscube_combine wsclean*000*image.fits "${CUBE}" -v --overwrite

OUTPUT="linmoscube"
HOLOFILE="/scratch3/gal16b/emu_download/raw/47138/LinmosBeamImages/akpb.iquv.closepack36.54.943MHz.SB45636.cube.fits"
YANDA="/scratch3/gal16b/containers/yanda/yandasoft_development_20240819.sif"

mkdir -p "${OUTPUT}"

DATAPARSET="${OUTPUT}/cube_data.parset"

names="[${NAME}]"
beamorder="[2]"

echo "linmos.names = ${names}" > "${DATAPARSET}"
echo "linmos.beams = ${beamorder}" >> "${DATAPARSET}"
echo "linmos.imagetype        = fits" >> "${DATAPARSET}"
echo "linmos.outname          = ${OUTPUT}/example_cube_linmos" >> "${DATAPARSET}"
echo "linmos.outweight        = ${OUTPUT}/example_cube_linmos_weight" >> "${DATAPARSET}"
echo "linmos.weighttype      = FromPrimaryBeamModel" >> ${DATAPARSET}
echo "linmos.primarybeam      = ASKAP_PB" >> "${DATAPARSET}"
echo "linmos.primarybeam.ASKAP_PB.image = ${HOLOFILE}" >>  "${DATAPARSET}"
    
cat "${DATAPARSET}"

apptainer run "${YANDA}" linmos -c "${DATAPARSET}"

