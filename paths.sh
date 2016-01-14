#!/bin/bash

# Please set the paths here

ROSETTA_BIN=$ROSETTA3       # The directory should contain Rosetta executables, such as relax.linuxgccrelease, score.linuxgccrelease, etc. Leave it as it is if $ROSETTA3 environment variable is already set.
ROSETTA_DB=$ROSETTA3_DB     # The directory should contain Rosetta database. Leave it as it is if $ROSETTA3_DB environment variable is already set.
R_SCRIPT=""                 # The variable should point to "Rscript" executable (you can leave it empty if R and Rscript is already in your path)


# Here we check if the paths are set correctly. Don't modify this part.

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
