#!/m1/shared/bin/perl -w
# QAD script to extract MARC records with a certain tag from a file
# 20080721 akohler

use lib "/usr/local/bin/voyager/perl";
use MARC::Batch;
use UCLA_Batch;	#for UCLA_Batch::safenext to better handle data errors

my $marcfile = $ARGV[0] or die "Must provide marc input filename\n";
my $tag = $ARGV[1];

# Working with Voyager records, always in UTF-8
binmode STDOUT, ":utf8";

my $batch = MARC::Batch->new('USMARC', $marcfile);
# 20050526 akohler: turn off strict validation - otherwise, all records after error are lost
$batch->strict_off();

#while ($record = $batch->next()) {
while ($record = UCLA_Batch::safenext($batch)) {
  # Get first field with given tag
  $field = $record->field($tag);
  if ($field) {
    print $record->as_usmarc();
  } else {
    next;
  }
}

exit 0;

