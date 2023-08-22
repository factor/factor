! Copyright (C) 2022 Your name.
! See https://factorcode.org/license.txt for BSD license.
USING: classes.struct help.markup help.syntax kernel math compression.bzip3 ;
IN: compression.bzip3.ffi

HELP: bz3_bound
{ $values
    { "input_size" object }
    { "size_t" object }
}
{ $description Given an input size, outputs a possible output size after compression. Used in compression only. } ;

HELP: bz3_compress
{ $values
    { "block_size" object } { "in" object } { "out" object } { "in_size" object } { "out_size" object }
    { "int" object }
}
{ $description Available in the high level API. Usage of { $snippet "compress" } from the parent vocabulary is encouraged instead. } ;

HELP: bz3_decode_block
{ $values
    { "state" object } { "buffer" object } { "size" object } { "orig_size" object }
    { "int32_t" object }
}
{ $description Consult { $link "compression.bzip3.ffi" } for more details. } ;

HELP: bz3_decode_blocks
{ $values
    { "states[]" object } { "buffers[]" object } { "sizes[]" object } { "orig_sizes[]" object } { "n" integer }
}
{ $description Consult { $link "compression.bzip3.ffi" } for more details. } ;

HELP: bz3_decompress
{ $values
    { "in" object } { "out" object } { "in_size" object } { "out_size" object }
    { "int" object }
}
{ $description Available in the high level API. Usage of { $snippet "decompress" } from the parent vocabulary is encouraged instead. } ;

HELP: bz3_encode_block
{ $values
    { "state" struct } { "buffer" object } { "size" object }
    { "int32_t" object }
}
{ $description Consult { $link "compression.bzip3.ffi" } for more details. } ;

HELP: bz3_encode_blocks
{ $values
    { "states[]" object } { "buffers[]" object } { "sizes[]" object } { "n" integer }
}
{ $description Consult { $link "compression.bzip3.ffi" } for more details. } ;

HELP: bz3_free
{ $values
    { "state" object }
}
{ $description Consult { $link "compression.bzip3.ffi" } for more details. } ;

HELP: bz3_last_error
{ $values
    { "state" object }
    { "int8_t" object }
}
{ $description Consult { $link "compression.bzip3.ffi" } for more details. } ;

HELP: bz3_new
{ $values
    { "block_size" object }
    { "bz3_state*" object }
}
{ $description Consult { $link "compression.bzip3.ffi" } for more details. } ;

HELP: bz3_state
{ $class-description Structure for holding and passing state between low-level bzip3 functions. Consult { $link "compression.bzip3.ffi" } for more details. } ;

HELP: bz3_strerror
{ $values
    { "state" object }
    { "c-string" object }
}
{ $description Consult { $link "compression.bzip3.ffi" } for more details. } ;

HELP: bz3_version
{ $values
    { "c-string" object }
}
{ $description "Pushes the bzip3 version present on your system. compression.bz3's " { $snippet "version" } "is an alias for this word." } ;


ARTICLE: "compression.bzip3.ffi" "Compression.bzip3.ffi"
This vocabulary contains mainly high-level documentation. The words present in this vocabulary link to C functions and hence
must be used carefully. Some functions mutate their arguments.

Consult your local installation of { $snippet "libbz3.h" } , or read it at
{ $url "https://github.com/kspalaiologos/bzip3/blob/master/include/libbz3.h" "GitHub" } for details that are up-to-date.

For an idea of how to use bzip3's compression functions, see the { $url "https://github.com/kspalaiologos/bzip3/blob/master/examples" "bzip3 examples" } .
;

ABOUT: "compression.bzip3.ffi"
