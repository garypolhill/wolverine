#!/bin/sh
for file in *.csv
do
  mv "$file" "$file.bak"
  cat "$file.bak" | sed -e 's/å/a/g' -e 's/Å/A/g' -e 's/ü/u/g' -e 's/Ü/U/g' -e 's/ö/o/g' -e 's/Ö/O/g' -e 's/ø/o/g' -e 's/Ø/O/g' -e 's/ä/a/g' -e 's/Ä/A/g' > "$file"
done
