#!/m1/shared/bin/perl -w
# Removes serials (LDR/07 = s) from a MARC file of bibliographic records.

use strict;
use lib "/usr/local/bin/voyager/perl";
use MARC::Batch;
use UCLA_Batch; #for UCLA_Batch::safenext to better handle data errors


my ($infile, $mono_file, $serial_file) = @ARGV;
# Must have at least first 3 input parameters
die "nUsage: $0 infile mono_file serial_file\n" if not defined $serial_file;

# Assume records are in UTF-8
my $batch = MARC::Batch->new('USMARC', $infile);
open MONOS, '>:utf8', $mono_file or die "Cannot open output file: $!\n";
open SERIALS, '>:utf8', $serial_file or die "Cannot open output file: $!\n";

# Turn off strict validation - otherwise, all records after error are lost
$batch->strict_off();

while (my $record = UCLA_Batch::safenext($batch)) {
  # Assume serials are LDR/07 = s, and everything else is a monograph, for convenience
  if ( (substr($record->leader(), 7, 1)) eq 's' ) {
    print SERIALS $record->as_usmarc();
  } else {
    print MONOS $record->as_usmarc();
  }
}

# Clean up
close MONOS;
close SERIALS;
exit 0;

