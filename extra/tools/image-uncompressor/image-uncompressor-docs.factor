! Copyright (C) 2022-2024 nomennescio
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays help.markup help.syntax image.factor memory strings ;
IN: tools.image-uncompressor

ARTICLE: "tools.image-uncompressor" "Uncompress compressed Factor image files"
"The " { $vocab-link "tools.image-uncompressor" } " vocabulary uncompresses Factor images or deployed executables (embedded images) that were compressed with " { $vocab-link "tools.image-compressor" } "." $nl
"You can also run the uncompressor directly from the commandline:"  { $code "factor -run=tools.image-uncompressor <input> [ <output> ]" } $nl
"The following arguments are supported:" $nl
{ $snippet "<input>" } " image file or deployed executable to uncompress" $nl
{ $snippet "<output>" } " if given save result into this file instead of overwriting input file" $nl
$examples {
  { $code "factor -run=tools.image-uncompressor hello-ui.exe" }
  { $code "factor -run=tools.image-uncompressor factor.image factor.image.uncompressed" }
}
;

HELP: uncompress
{ $values
    { "byte-array" byte-array }
    { "uncompressed" byte-array }
}
{ $description "Compresses bytes" }
;

HELP: uncompress-code
{ $values
    { "image" image }
    { "image'" image }
}
{ $description "Compresses code heap" }
;

HELP: uncompress-data
{ $values
    { "image" image }
    { "image'" image }
}
{ $description "Compresses data heap" }
;

HELP: uncompress-image
{ $values
    { "image" image }
    { "image'" image }
}
{ $description "Compresses data- and code heaps and syncs header" }
;

HELP: uncompress-factor-image
{ $values
    { "compressed-image-file" string }
    { "uncompressed-file" string }
}
{ $description "Load, compresses and saves a Factor image" }
;

HELP: uncompress-current-image
{ $description "Loads, compresses and saves current Factor image" }
;

ABOUT: "tools.image-uncompressor"
