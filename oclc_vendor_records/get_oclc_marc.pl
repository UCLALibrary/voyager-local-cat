#!/usr/bin/env perl
use strict;
use warnings;
use feature qw(say);
use Data::Dumper qw(Dumper);
use File::Slurp qw(read_file);

# Local libraries
use lib "/usr/local/bin/voyager/perl";
use UCLA::Worldcat::WSAPI;

# Include required API keys - needed for WSKEY
BEGIN { require './api_keys.pl'; }

# 1 required argument: file containing values to search
if ($#ARGV != 0) {
  print "\nUsage: $0 oclc_file\n";
  exit 1;
}
my $oclc_file = $ARGV[0];

# Capture MARC records here
my $oclc_marc_file = $oclc_file . '.mrc';

binmode STDOUT, ":utf8";
# Flush STDOUT buffers immediately so we can view output in real time
STDOUT->autoflush(1);

my $oclc = UCLA::Worldcat::WSAPI->new(WSKEY);

# Read search terms from file, one search per line.
my @oclc_numbers = read_file($oclc_file, chomp => 1);
foreach my $oclc_number (@oclc_numbers) {
  say "Retrieving $oclc_number...";
  eval {
    my $marc = $oclc->_get_marc_bare($oclc_number);
    save_marc($marc, $oclc_marc_file);
  } or do {
    my $error = $@ || 'Unknown failure';
	warn "Could not retrieve $oclc_number - $error";
  };
}

exit;

#############################
# Save MARC record to given file, as binary MARC
sub save_marc {
  my ($marc_record, $marc_file) = @_;
  open MARC, '>>:utf8', $marc_file;
  print MARC $marc_record->as_usmarc();
  close MARC;
}

