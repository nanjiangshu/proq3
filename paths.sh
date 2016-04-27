#!/bin/bash

############# Please set the paths here #############

rosetta_path=/scratch3/uziela/software/rosetta_2014wk05_bundle          # Path to Rosetta installation
ROSETTA_BIN=${rosetta_path}/main/source/bin                             # The directory should contain Rosetta executables, such as relax.linuxgccrelease, score.linuxgccrelease
ROSETTA_DB=${rosetta_path}/main/database                                # The directory should contain Rosetta database.
export BLAST_DATABASE=/scratch3/uziela/data_sets/uniref/uniref90.fasta  # Path to formatted blast database (such as uniref90)

R_SCRIPT=""                                                             # The variable should point to "Rscript" executable (you can leave it empty if R and Rscript is already in your path)

############# Here we check if the paths are set correctly. Don't modify this part. #############

if [[ ! -f $ROSETTA_BIN/relax.linuxgccrelease || ! -f $ROSETTA_BIN/extract_pdbs.linuxgccrelease || ! -f $ROSETTA_BIN/score.linuxgccrelease || ! -f $ROSETTA_BIN/minimize_with_cst.linuxgccrelease || ! -f $ROSETTA_BIN/per_residue_energies.linuxgccrelease ]] ; then
    echo "ERROR: One of required Rosetta executables does not exist. Check if Rosetta was installed properly and \$ROSETTA_BIN variable was set in <ProQ3_dir>/paths.sh file"
    exit 1
fi

if [[ ! -d $ROSETTA_DB/chemical ]] ; then
    echo "ERROR: Rosetta database path was not set properly. Please, set \$ROSETTA_DB variable in <ProQ3_dir>/paths.sh file"
    exit 1
fi

Rscript_path=`which Rscript 2>/dev/null`

if [[ $Rscript_path == "" && ! -f $R_SCRIPT ]] ; then
    echo "ERROR: Rscript executable is not found. Make sure it is in your path or set \$R_SCRIPT variable in <ProQ3_dir>/paths.sh file."
    exit 1
fi

needle_path=`which needle 2>/dev/null`
if [[ $needle_path == "" ]] ; then
    echo "ERROR: Package EMBOSS has not been installed properly. Please, download it from http://emboss.sourceforge.net/download/ and install it. Make sure that 'needle' program is in your path."
    exit 1
fi
