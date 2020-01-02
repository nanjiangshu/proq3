#!/bin/bash
fasta_file=$1          # Fasta file for target protein sequence
pdb_list_file=$2       # A file with a list of pdbs 
outpath=$3             # Output directory
ncores=$4              # Number of cores

./run_proq3.sh -ncores $ncores -only-build-profile -fasta $fasta_file -outpath $outpath 

fasta_basename=`basename $fasta_file`

parallel -j$ncores ./run_proq3.sh -profile $outpath/$fasta_basename -keep_files yes -outpath $outpath -quality sscore :::: $pdb_list_file
wait
parallel -j$ncores -E stop ./run_proq3.sh -profile $outpath/$fasta_basename  -keep_files yes -outpath $outpath -quality ::: tmscore lddt cad stop :::: $pdb_list_file

