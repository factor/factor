! Copyright (C) 2022-2024 nomennescio
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays help.markup help.syntax memory strings ;
FROM: tools.image-analyzer.vm => image-header ;
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

HELP: image
{ $class-description "In-memory Factor image" } ;

HELP: image-header
{ $class-description "Factor image header structure" } ;

HELP: >compression-header
{ $values
    { "headerv4" image-header }
    { "headerv4+" image-header }
}
{ $description "Converts any header into a compression supporting header" }
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

HELP: load-factor-image
{ $values
    { "filename" string }
    { "image" image }
}
{ $description "Load Factor image into memory" }
;

HELP: save-factor-image
{ $values
    { "image" image }
    { "filename" string }
}
{ $description "Save Factor image from memory" }
;

HELP: uncompress-factor-image
{ $values
    { "compressed-image-file" string }
    { "uncompressed-file" string }
}
{ $description "Load, compresses and saves a Factor image" }
;

HELP: sync-header
{ $values
    { "image" image }
    { "image'" image }
}
{ $description "Sync header from actual data and code sizes" }
;

HELP: uncompress-current-image
{ $description "Loads, compresses and saves current Factor image" }
;

ABOUT: "tools.image-uncompressor"
