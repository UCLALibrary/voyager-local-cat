#!/usr/bin/env perl
use strict;
use warnings;
use feature qw(say);
use Data::Dumper qw(Dumper);
use File::Slurp qw(read_file);

# Local libraries
use lib "/usr/local/bin/voyager/perl";
use UCLA::Worldcat::WSAPI;
use UCLA_Batch; #for UCLA_Batch::safenext to better handle data errors

binmode STDOUT, ":utf8";
# Flush STDOUT buffers immediately so we can view output in real time
STDOUT->autoflush(1);

# Input and output files of MARC records
my ($infile, $outfile) = @ARGV;
# Must have 2 input parameters
die "\nUsage: $0 infile outfile\n" if not defined $outfile;

# Include required API keys - needed for WSKEY
BEGIN { require './api_keys.pl'; }
my $oclc = UCLA::Worldcat::WSAPI->new(WSKEY);
$oclc->max_records(25); # increase from default of 10

# Iterate through file of vendor MARC records
# Records are in UTF-8
my $batch = MARC::Batch->new('USMARC', $infile);
open OUT, '>:utf8', $outfile or die "Cannot open output file: $!\n";

# Turn off strict validation - otherwise, all records after error are lost
$batch->strict_off();

while (my $record = UCLA_Batch::safenext($batch)) {
  # Get ISBN from record's 001
  #my $isbn = $record->field('020')->subfield('a');
  my $isbn = $record->field('001')->data();

  # Search WorldCat by ISBN
  my @records = $oclc->search_sru($isbn, 'srw.bn');
  my $count = scalar(@records);
  say "$isbn: $count records";

  # Iterate through results, finding best matching record; report if no match
  my $oclc_record = get_best_record (\@records);

  # If there was no match, $oclc_record->holdings_count will be -1
  if ($oclc_record->holdings_count >= 0) {
    say "\tKeeping: " . $oclc_record->oclc_number();

	# Remove 029 and 856 fields from OCLC records
	$oclc_record->delete_fields($oclc_record->field('029'));
	$oclc_record->delete_fields($oclc_record->field('856'));

    # Copy 049/856/910/948 from vendor record into OCLC record
	foreach my $tag (qw(049 856 910 948)) {
	  my @flds = $record->field($tag);
	  $oclc_record->insert_fields_ordered(@flds);
	}

	# Save final record
	print OUT $oclc_record->as_usmarc();
  } else {
    say "\tWARNING: No acceptable OCLC record found for ISBN " . $isbn;
  }
}

# Clean up
close OUT;
exit 0;

# Filter out unacceptable records and return the best remaining one, if any
sub get_best_record {
  # These records are from OCLC, enhanced by local WSAPI library
  my $oclc_records = shift; # array reference
  # Initialize $best_record with placeholders: empty MARC record, 0 (false) held by CLU, and -1 holdings in OCLC
  my $best_record = UCLA::Worldcat::MARC->new(MARC::Record->new(), 0, -1);

  foreach my $record (@$oclc_records) {
	# Mandatory: LDR/07 = 'm'
	next if $record->bib_level() ne 'm';

    # Mandatory: 008/23 = 'o'
    my $fld008 = $record->field('008')->data();
	next if substr($fld008, 23, 1) ne 'o';

	# Mandatory: 040 $b = 'eng'
	my $lang = $record->field('040')->subfield('b');  # 040 $b not repeatable, but may not exist
	next if ($lang && $lang ne 'eng');

	# Print warning if candidate record is held by CLU - unlikely, for these licensed resources, so just warn
	#say "\t" . $record->oclc_number() . "\t" . $record->held_by_clu() . "\t" . $record->holdings_count();    ### For testing
	my $oclc_number = $record->oclc_number();
	say "\tWARNING: Held by CLU: $oclc_number" if $record->held_by_clu() == 1; 

	# If we passed those tests, check number of OCLC holdings and keep the one with the most.
	if ($record->holdings_count() >= $best_record->holdings_count()) {
	  $best_record = $record;
	}
  } #foreach record

  return $best_record;
}

