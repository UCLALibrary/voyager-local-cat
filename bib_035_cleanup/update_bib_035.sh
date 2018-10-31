#!/bin/sh

BIN=/opt/local/bin

DIR=/m1/voyager/ucladb/local/bib_035_cleanup
cd $DIR

if [ -z "$1" ]; then
  echo "Usage: $0 EXT (aa*, etc.)"
  exit 1
else
  EXT="$1"
fi

for FILE in ${DIR}/leftovers.lst.${EXT}; do
  if [ -s ${FILE} ]; then
    echo Processing ${FILE}...
    /m1/voyager/ucladb/sbin/Pmarcexport -o${FILE}.before.mrc -rB -mM -t${FILE} -q 
    ${DIR}/delete_bib_035.pl ${FILE}.before.mrc ${FILE}.after.mrc
    ${BIN}/vger_bulkimport_file_NOKEY ${FILE}.after.mrc ucladb GDC_B_AU akohler
  fi
done

