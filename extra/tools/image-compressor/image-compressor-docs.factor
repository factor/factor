! Copyright (C) 2022-2024 nomennescio
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays help.markup help.syntax memory strings ;
FROM: tools.image-analyzer.vm => image-header ;
IN: tools.image-compressor

ARTICLE: "tools.image-compressor" "Compress Factor image file for loading by the VM"
"The " { $vocab-link "tools.image-compressor" } " vocabulary compresses Factor images such that the VM can load it and decompress it on the fly. Compressed and uncompressed Factor images are both supported by the VM and are only determined by their image headers." $nl
"You can also run the compressor on the current Factor image directly from the commandline:"  { $code "factor -run=tools.image-compressor" } $nl
"To uncompress a compressed Factor image, you can start Factor with" { $code "factor -i=<compressed image>" } "then " { $link save-image-and-exit } $nl
"Embedded images in executables such as those created by the " { $vocab-link "tools.deploy" } " tool, can also be directly loaded, compressed, and saved."
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

HELP: compression-level
{ $var-description "Compression parameter : 1 (least) .. 22 (most). Default value 12." } ;

HELP: compress
{ $values
    { "byte-array" byte-array }
    { "compressed" byte-array }
}
{ $description "Compresses bytes" }
;

HELP: compress-code
{ $values
    { "image" image }
    { "image'" image }
}
{ $description "Compresses code heap" }
;

HELP: compress-data
{ $values
    { "image" image }
    { "image'" image }
}
{ $description "Compresses data heap" }
;

HELP: compress-image
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

HELP: compress-factor-image
{ $values
    { "image-file" string }
    { "compressed-file" string }
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

HELP: compress-current-image
{ $description "Loads, compresses and saves current Factor image" }
;

ABOUT: "tools.image-compressor"
