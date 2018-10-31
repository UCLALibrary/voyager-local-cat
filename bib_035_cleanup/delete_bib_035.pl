#!/m1/shared/bin/perl -w

use lib "/usr/local/bin/voyager/perl";
use MARC::Batch;
use UCLA_Batch; #for UCLA_Batch::safenext to better handle data errors

if ($#ARGV != 1) {
  print "\nUsage: $0 infile outfile\n";
  exit 1;
}

my $infile = $ARGV[0];
my $outfile = $ARGV[1];

my $batch = MARC::Batch->new('USMARC', $infile);
open OUT, '>:utf8', $outfile;

# 20050526 akohler: turn off strict validation - otherwise, all records after error are lost
$batch->strict_off();

while ($record = UCLA_Batch::safenext($batch)) {
  # Get 001
  my $bib_id = $record->field('001')->data();
  # Get 035 fields and find the one which matches bib_id
  my @fields = $record->field('035');
  foreach my $fld035 (@fields) {
    my $s035a = $fld035->subfield('a');
    if ( $s035a && $s035a eq $bib_id ) {
      $record->delete_field($fld035);
      last;  # Just in case...
    }
  }
  print OUT $record->as_usmarc();
}
close OUT;

exit 0;

