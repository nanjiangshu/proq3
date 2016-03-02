#!/bin/sh
if [ $# -ne 2 ]
then
	echo "need two parameters:seq_file, output_file." 
	exit 1
fi
/big/software/proq3/apps/sspro4/script/generate_flatblast.pl /big/software/proq3/apps/sspro4/blast2.2.8/ /big/software/proq3/apps/sspro4/script/ /big/software/proq3/apps/sspro4/data/big/big_98_X /big/software/proq3/apps/sspro4/data/nr/nr $1 $2 
