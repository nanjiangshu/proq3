#!/usr/bin/perl -w
use Cwd 'abs_path';
use File::Basename;

my $INSTALL_DIR=dirname(abs_path($0));
if(scalar(@ARGV)==0) {
    
    print "\nThis script will copy sequence based features calculated for the full length sequence\n";
    print "USAGE:\n";
    print "\tcopy_features_from_master.pl <pdbfile> <basename-template>\n\n";
    exit;
}
my $pdb=$ARGV[0];
my $basename=$ARGV[1];
my $fasta="$pdb.fasta";
my $seq=`$INSTALL_DIR/aa321CA.pl $pdb`;
open(OUT,">$fasta");
print OUT ">$pdb\n$seq\n";
close(OUT);

`$INSTALL_DIR/acc_subset.pl $basename.acc $basename.fasta $fasta $pdb.acc`;

`$INSTALL_DIR/profile_subset.pl $basename.psi $fasta $pdb.psi`;
`$INSTALL_DIR/profile_subset.pl $basename.mtx $fasta $pdb.mtx`;
`$INSTALL_DIR/ss2_subset.pl $basename.ss2 $fasta $pdb.ss2`;


