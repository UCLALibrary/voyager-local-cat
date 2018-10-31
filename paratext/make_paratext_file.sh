#!/bin/sh

# Export file of ISBNs for materials published after 1980,
# for Paratext Reference Universe service.

# Extract the data using isbn.sql in current directory
vger_sqlplus_run ucla_preaddb isbn

# Filter out some obviously-bad data; not worth full ISBN validation
# Output to Paratext-specified filename
sort -u isbn.out | grep "^[0-9]" > ucla1315.txt
rm isbn.out

