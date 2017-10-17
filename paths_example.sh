#!/bin/bash

############# Please set the paths here #############
SCRIPT_PATH=`readlink -f ${BASH_SOURCE[0]}`
rundir=`dirname $SCRIPT_PATH`

rosetta_path=$rundir/apps/rosetta/                                 # Path to Rosetta installation
ROSETTA_BIN=${rosetta_path}/main/source/bin                        # The directory should contain Rosetta executables, such as relax.linuxgccrelease, score.linuxgccrelease
ROSETTA_DB=${rosetta_path}/main/database                           # The directory should contain Rosetta database.
export BLAST_DATABASE=$rundir/database/blastdb/uniref90.fasta      # Path to formatted blast database (such as uniref90)

R_SCRIPT=""                                                        # The variable should point to "Rscript" executable (you can leave it empty if R and Rscript is already in your path)
PYTHON_BIN=""                                                      # The variable should point to python executable (you can leave it empty if python is already in your path)

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
elif [[ "$R_SCRIPT" == "" ]] ; then
    R_SCRIPT=$Rscript_path
fi

needle_path=`which needle 2>/dev/null`
if [[ $needle_path == "" ]] ; then
    echo "ERROR: Package EMBOSS has not been installed properly. Please, download it from http://emboss.sourceforge.net/download/ and install it. Make sure that 'needle' program is in your path."
    exit 1
fi

DEEP_INSTALLED="yes"
python_path=`which python 2>/dev/null`

if [[ $python_path == "" && ! -f $PYTHON_BIN ]] ; then
    echo "WARNING: python executable is not found. Make sure it is in your path or set \$PYTHON_BIN variable in <ProQ3_dir>/paths.sh file. Otherwise you will not be able to use deep learning version of the predictor (ProQ3D)"
    DEEP_INSTALLED="no"
elif [[ "$PYTHON_BIN" == "" ]] ; then
    PYTHON_BIN=$python_path
fi

if [[ -f $PYTHON_BIN ]] ; then
    KERAS_BACKEND=theano $PYTHON_BIN -c "import keras" &>/dev/null
    if [[ "$?" == "1" ]] ; then
        echo "WARNING: python package 'keras' is not installed. Please install the package using 'pip install keras'. Otherwise you will not be able to use deep learning version of the predictor (ProQ3D)"
        DEEP_INSTALLED="no"
    fi
    $PYTHON_BIN -c "import numpy" &>/dev/null
    if [[ "$?" == "1" ]] ; then
        echo "WARNING: python package 'numpy' is not installed. Please install the package using 'pip install numpy'. Otherwise you will not be able to use deep learning version of the predictor (ProQ3D)"
        DEEP_INSTALLED="no"
    fi
fi

