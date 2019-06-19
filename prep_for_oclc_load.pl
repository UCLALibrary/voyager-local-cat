#!/m1/shared/bin/perl -w
# Prepares vendor-supplied OCLC records for load by BatchCat OCLC loader:
# * Remove vendor-specific 001 and 003
# * Create new 001/003 from 035 OCLC number

use strict;
use lib "/usr/local/bin/voyager/perl";
use MARC::Batch;
use UCLA_Batch; #for UCLA_Batch::safenext to better handle data errors

if ($#ARGV != 1) {
  print "\nUsage: $0 infile outfile\n";
  exit 1;
}

my $infile = $ARGV[0];
my $outfile = $ARGV[1];

# Assume records are in UTF-8
my $batch = MARC::Batch->new('USMARC', $infile);
open OUT, '>:utf8', $outfile or die "Cannot open output file: $!\n";

# Turn off strict validation - otherwise, all records after error are lost
$batch->strict_off();

while (my $record = UCLA_Batch::safenext($batch)) {
  # Delete 001 and 003 fields
  $record->delete_field($record->field('001'));
  $record->delete_field($record->field('003'));

  # Use data from 035 to create 001/003
  # Assume records have only 1 035, but make sure it's for OCLC
  # Example 035:  $a(OCoLC)949370237
  my $f035 = $record->field('035');
  my $f035a = $f035->subfield('a');
  if ($f035a =~ /OCoLC/) {
	# Who says perl is cryptic?
    my ($oclc) = $f035a =~ /(\d+)/;
	$record->insert_fields_ordered(new MARC::Field('001', $oclc));
	$record->insert_fields_ordered(new MARC::Field('003', 'OCoLC'));
  }

  print OUT $record->as_usmarc();
}

# Clean up
close OUT;
exit 0;

