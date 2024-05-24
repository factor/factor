! Copyright (C) 2024 nomennescio
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math strings ;
IN: image.factor

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

HELP: sync-header
{ $values
    { "image" image }
    { "image'" image }
}
{ $description "Sync header from actual data and code sizes" }
;

HELP: check-header
{ $values
    { "header" object }
    { "header/*" object }
}
{ $description "Checks for a valid header, else throws error" } ;

HELP: embedded-image-footer
{ $class-description "Embedded footer at end of file indicates this is an embedded image" } ;

HELP: image-magic
{ $values
    { "value" object }
}
{ $description "Magic value for a valid Factor image" } ;

HELP: image-version
{ $values
    { "value" object }
}
{ $description "Current supported Factor image format version" } ;

HELP: read*
{ $values
    { "n" integer }
    { "bytes" object }
}
{ $description "read n bytes, return empty byte array if n equals 0" } ;

HELP: read-footer
{ $values
    { "footer-offset" object } { "footer" object }
}
{ $description "read the footer at given offset from beginning of file. Reads footer from end of file, while returning to current file position. Also returns offset to footer from beginning of file." } ;

HELP: read-footer*
{ $values
    { "footer-offset" object } { "footer/f" object }
}
{ $description "Read footer if it exists, return f otherwise" } ;

HELP: read-header
{ $values
    { "header/*" object }
}
{ $description "Read header" } ;

HELP: uncompressed-code?
{ $values
    { "image" object }
    { "?" boolean }
}
{ $description "Check if stored code heap is uncompressed" } ;

HELP: uncompressed-data?
{ $values
    { "image" object }
    { "?" boolean }
}
{ $description "Check if stored data heap is uncompressed" } ;

HELP: unsupported-image-header
{ $description "Throws an " { $link unsupported-image-header } " error." }
{ $error-description "Thrown when an image header is not recognized" } ;

HELP: valid-footer?
{ $values
    { "footer" object }
    { "?" boolean }
}
{ $description "Is it a valid footer?" } ;

HELP: valid-header?
{ $values
    { "header" object }
    { "?" boolean }
}
{ $description "Is it a valid header?" } ;

ARTICLE: "image.factor" "image.factor"
{ $vocab-link "image.factor" }
;

ABOUT: "image.factor"
