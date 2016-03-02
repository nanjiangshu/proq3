#!/bin/bash
# Set environmental variables

SCRIPT_PATH=`realpath ${BASH_SOURCE[0]}`
rundir=`dirname $SCRIPT_PATH`

rosetta_path=$rundir/apps/rosetta/rosetta_2014.16.56682_bundle
export ROSETTA3=${rosetta_path}/main/source/bin
export ROSETTA3_DB=${rosetta_path}/main/database
export BLAST_DATABASE=$rundir/database/blastdb/uniref90.fasta
