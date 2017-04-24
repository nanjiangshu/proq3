#!/bin/bash
#module add blast/2.0.11
# This is a simple script which will carry out all of the basic steps
# required to make a PSIPRED V2 prediction. Note that it assumes that the
# following programs are in the appropriate directories:
# blastpgp - PSIBLAST executable (from NCBI toolkit)
# makemat - IMPALA utility (from NCBI toolkit)
# psipred - PSIPRED V2 program
# psipass2 - PSIPRED V2 program

dirname=`dirname $0`;
dirname=`( cd $dirname && pwd )`
echo $dirname
basename=${1%.*}
outfile=$basename.mtx
echo $basename
#exit
# The name of the BLAST data bank
dbname=$2 # /local/www/services/ProQ2/DB/uniref90.fasta
ncores=$3

# Where the NCBI programs have been installed
ncbidir=$dirname/../apps/blast-2.2.26/bin/
if [ ! -f ".ncbirc" ] 
    then
echo "[ncbi]" > .ncbirc
echo "Data=$dirname/../apps/blast-2.2.26/data/" >> .ncbirc
fi
#set ncbidir = /usr/ebiotools/bin/



# Where the PSIPRED V2 programs have been installed
execdir=$dirname/../apps/psipred25/bin/

# Where the PSIPRED V2 data files have been installed
datadir=$dirname/../apps/psipred25/data/

if [ -f  $outfile ] 
    then
echo Already exist $outfile ...
exit
#else
#echo "Let's go!!!!"
fi

#echo $outfile
#echo $rootname
#echo $basename
#exit;


#\cp -f $1 $basename.psitmp.fasta
echo cp -f $1 $basename.psitmp.$$.fasta
cp -f $1 $basename.psitmp.$$.fasta

echo "Running PSI-BLAST with sequence" $1 "..."
#ncores=`cat /proc/$$/status | grep Cpus_allowed_list | awk '{print $2}' | sed "s/-/ /g" | awk '{if ($2>0){print 1+$2-$1}else{print 1}}'`

echo $ncbidir/blastpgp -a $ncores -j 3 -h 0.001 -d $dbname -F F -i $basename.psitmp.$$.fasta -C $basename.psitmp.$$.chk -Q $basename.psitmp.$$.psi
#cpu=`grep -c CPU /proc/cpuinfo`;

$ncbidir/blastpgp -a $ncores -j 3 -h 0.001 -d $dbname -F F -i $basename.psitmp.$$.fasta -C $basename.psitmp.$$.chk -o $basename.psitmp.$$.blastpgp -Q $basename.psitmp.$$.psi > /dev/null #& $rootname.blast


echo "Running Makemat..."
echo $basename.psitmp.$$.chk > $basename.psitmp.$$.pn
echo $basename.psitmp.$$.fasta > $basename.psitmp.$$.sn
$ncbidir/makemat -P $basename.psitmp.$$
#cp $basename.psitmp.$$.mtx $rootname.mtx
#cp $basename.psitmp.$$.chk $rootname.chk
#cp $basename.psitmp.$$.psi $rootname.psi
#echo Cleaning up ...
#rm -f $basename.psitmp.$$.* error.log 
#exit;
echo "Predicting secondary structure..."
echo Pass1 ...

$execdir/psipred $basename.psitmp.$$.mtx $datadir/weights.dat $datadir/weights.dat2 $datadir/weights.dat3 $datadir/weights.dat4 > $basename.psitmp.$$.ss

echo Pass2 ...

$execdir/psipass2 $datadir/weights_p2.dat 1 1.0 1.0 $basename.psitmp.$$.ss2 $basename.psitmp.$$.ss 
cp $basename.psitmp.$$.ss2 $basename.ss2
cp $basename.psitmp.$$.mtx $basename.mtx
cp $basename.psitmp.$$.chk $basename.chk
$dirname/../bin/check_psiblast_matrix.py $basename.psitmp.$$.psi $basename.psitmp.$$.fasta $basename.psitmp.$$.psi.corrected
cp $basename.psitmp.$$.psi.corrected $basename.psi
cp $basename.psitmp.$$.blastpgp $basename.fasta.blastpgp # this is for accpro will skip the psiblast runs
# Remove temporary files
#exit
echo Cleaning up ...
rm -f $basename.psitmp.$$.* error.log
exit

#rm $rootname.ss $rootname.blast $rootname.ss2 #$rootname.horiz

#echo "Final output files:" $rootname.ss2 $rootname.horiz
echo "Final output files:" $rootname.horiz $rootname.ss2 
echo "Finished."
