#!/bin/sh
#predict the solvent acc for one sequence. Don't change this script.
if [ $# -ne 3 ]
then
	echo "need three parameters:seq_file, ali_dir, data_format."
	exit 1
fi
#format: 1:9-line, 2:3-line, all seq must have a title line(1 20 3).

/big/software/proq3/apps/sspro4/server/predict_seq_sa /big/software/proq3/apps/sspro4/model/accpro.model $1 $2 $3 5
