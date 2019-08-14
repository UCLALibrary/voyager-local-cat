#!/m1/shared/bin/perl -w
# Prepares vendor-supplied OCLC records for load by BatchCat OCLC loader:
# * Remove vendor-specific 001 and 003
# * Create new 001/003 from 035 OCLC number
# * Set 005 to YYYYMMDD if optional 3rd parameter YYYYMMDD is provided

use strict;
use lib "/usr/local/bin/voyager/perl";
use MARC::Batch;
use UCLA_Batch; #for UCLA_Batch::safenext to better handle data errors


my ($infile, $outfile, $date) = @ARGV;
# Must have at least first 2 input parameters
die "nUsage: $0 infile outfile [YYYYMMDD]\n" if not defined $outfile;

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
  # Some records have multiple 035: iterate until you find the first OCLC one.
  # Example 035:  $a(OCoLC)949370237
  my @f035s = $record->field('035');
  foreach my $f035 (@f035s) {
    my $f035a = $f035->subfield('a');
    if ($f035a =~ /OCoLC/) {
	  # Who says perl is cryptic?
      my ($oclc) = $f035a =~ /(\d+)/;
	  $record->insert_fields_ordered(new MARC::Field('001', $oclc));
	  $record->insert_fields_ordered(new MARC::Field('003', 'OCoLC'));
	  last;
    }
  }

  # If date was provided, change/set the 005 to use it
  # 005 needs to look like this: YYYYMMDD000000.0
  # Example 005:20160527093929.0
  if (defined $date) {
    # TODO: check for valid YYYYMMDD?
	# For now, just append zeros for hours/minutes/seconds
	my $f005_date = $date.'000000.0';
	my $f005 = $record->field('005');
	if ($f005) {
	  $f005->update($f005_date);
	} else {
	  $f005->insert_fields_ordered(new MARC::Field('005', $f005_date));
	}
  }

  print OUT $record->as_usmarc();
}

# Clean up
close OUT;
exit 0;

