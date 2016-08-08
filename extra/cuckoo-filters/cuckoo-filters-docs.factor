USING: byte-arrays checksums help.markup help.syntax kernel ;
IN: cuckoo-filters

HELP: cuckoo-insert
{ $values { "bytes" byte-array } { "cuckoo-filter" cuckoo-filter } { "?" boolean } }
{ $description "Insert the data into the " { $snippet "cuckoo-filter" } ", returning " { $link t } " if the data was inserted." }
{ $notes "Attempting to insert data twice will result in the hashed fingerprint of the data appearing twice and the " { $link cuckoo-filter } " size being incremented twice." } ;

HELP: cuckoo-lookup
{ $values { "bytes" byte-array } { "cuckoo-filter" cuckoo-filter } { "?" boolean } }
{ $description "Lookup the data from the " { $snippet "cuckoo-filter" } ", returning " { $link t } " if the data appears to be a member. This is a probabilistic test, meaning there is a possibility of false positives." } ;

HELP: cuckoo-delete
{ $values { "bytes" byte-array } { "cuckoo-filter" cuckoo-filter } { "?" boolean } }
{ $description "Remove the data from the " { $snippet "cuckoo-filter" } ", returning " { $link t } " if the data appears to be removed." } ;

ARTICLE: "cuckoo-filters" "Cuckoo Filters"
"Cuckoo Filters are probabilistic data structures similar to Bloom Filters that provides support for removing elements without significantly degrading space and performance."
$nl
"Instead of storing the elements themselves, it stores a fingerprint obtained by using a " { $link checksum } ". This allows for item removal without false negatives (assuming you do not try and remove an item not contained in the filter."
$nl
"For applications that store many items and target low false-positive rates, Cuckoo Filters can have a lower space overhead than Bloom Filters."
$nl
"More information is available in the paper by Andersen, Kaminsky, and Mitzenmacher titled \"Cuckoo Filter: Practically Better Than Bloom\":"
$nl
{ $url "http://www.pdl.cmu.edu/PDL-FTP/FS/cuckoo-conext2014.pdf" } ;

ABOUT: "cuckoo-filters"
