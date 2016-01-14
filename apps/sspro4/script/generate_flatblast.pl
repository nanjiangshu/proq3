#!/usr/bin/perl -w
#generate blast flat alignment
#depend on: process-blast.pl

#input parameters
#1. path of blastpgp: e.g: /home/baldig/blast/
#2. path of support perl script(installation dir)
#3. fullpath to big database: e.g: /home/baldig/Data/big/big_98_X
#4. fullpath to nr database: e.g.: /home/baldig/Data/nr/nr
#5. fullpath of input file: fasta format
#6. fullpath of outputfile 

#Author: Jianlin Cheng, 4/5/04

if(@ARGV != 6)
{
	die "need six parameters: path of blastpgp tool, path of perl script, fullpath of big database, fullpath of nr database, fullpath of input file(fasta format), fullpath of outputfile.\n"; 
}


$blast_dir = $ARGV[0];
if (! -d $blast_dir)
{
	die "the blast directory doesn't exists.\n"; 
}
if ( substr($blast_dir, length($blast_dir) - 1, 1) ne "/" )
{
	$blast_dir .= "/"; 
}

#the directory where process-blast.pl resides.  (usually it is the installation directory of this package
$exec_dir = $ARGV[1]; 
if (! -d $exec_dir)
{
	die "the perl script directory doesn't exists.\n"; 
}
if ( substr($exec_dir, length($exec_dir) - 1, 1) ne "/" )
{
	$exec_dir .= "/"; 
}

$big_x = $ARGV[2];
$big_nr = $ARGV[3];
$input_file = $ARGV[4]; 
$output_file = $ARGV[5]; 

if(!-e "$input_file.blastpgp") {
    print STDERR "run create_profile.sh to create blast output\n";
    exit;
    system("${blast_dir}blastpgp -a 4 -i $input_file -o $input_file.tmp -C $input_file.chk -j 3 -e 0.001 -h 1e-10 -d $big_x");
    system("${blast_dir}blastpgp -a 4 -i $input_file -R $input_file.chk -o $input_file.blastpgp -j 1 -e 0.001 -h 1e-10 -d $big_nr");
} #else {
    #print STDERR "$input_file.blastpgp exist skipping psiblast stuff...\n"
#}

$ret = system("${exec_dir}process-blast.pl $input_file.blastpgp $output_file $input_file");
if ($ret != 0)
{
    print "fail to create profile for $input_file\n";
}

#exit;
#remove the temporay file. 

#`rm $input_file.tmp $input_file.chk $input_file.blastpgp`; 

