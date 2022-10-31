! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: classes.struct help.markup help.syntax kernel math ;
IN: compression.bzip3.ffi

HELP: bz3_bound
{ $values
    { "input_size" object }
    { "size_t" object }
}
{ $description "" } ;

HELP: bz3_compress
{ $values
    { "block_size" object } { "in" object } { "out" object } { "in_size" object } { "out_size" object }
    { "int" object }
}
{ $description Available in the high level API. Usage of { $link "compression.bzip3.compress" } is encouraged. } ;

HELP: bz3_decode_block
{ $values
    { "state" object } { "buffer" object } { "size" object } { "orig_size" object }
    { "int32_t" object }
}
{ $description "" } ;

HELP: bz3_decode_blocks
{ $values
    { "states[]" object } { "buffers[]" object } { "sizes[]" object } { "orig_sizes[]" object } { "n" integer }
}
{ $description "" } ;

HELP: bz3_decompress
{ $values
    { "in" object } { "out" object } { "in_size" object } { "out_size" object }
    { "int" object }
}
{ $description Available in the high level API. Usage of { $link "compression.bzip3.decompress" } is encouraged. } ;

HELP: bz3_encode_block
{ $values
    { "state" struct } { "buffer" object } { "size" object }
    { "int32_t" object }
}
{ $description "" } ;

HELP: bz3_encode_blocks
{ $values
    { "states[]" object } { "buffers[]" object } { "sizes[]" object } { "n" integer }
}
{ $description "" } ;

HELP: bz3_free
{ $values
    { "state" object }
}
{ $description "" } ;

HELP: bz3_last_error
{ $values
    { "state" object }
    { "int8_t" object }
}
{ $description "" } ;

HELP: bz3_new
{ $values
    { "block_size" object }
    { "bz3_state*" object }
}
{ $description "" } ;

HELP: bz3_state
{ $class-description "" } ;

HELP: bz3_strerror
{ $values
    { "state" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: bz3_version
{ $values
    { "c-string" object }
}
{ $description "" } ;

HELP: s16
{ $var-description "" } ;

HELP: s32
{ $var-description "" } ;

HELP: s8
{ $var-description "" } ;

HELP: state
{ $class-description "" } ;

HELP: u16
{ $var-description "" } ;

HELP: u32
{ $var-description "" } ;

HELP: u64
{ $var-description "" } ;

HELP: u8
{ $var-description "" } ;

ARTICLE: "compression.bzip3.ffi" "compression.bzip3.ffi"
This vocabulary contains mainly high-level documentation. 

Consult your local installation of { $snippet "libbz3.h" } , or read it at
{ $url "https://github.com/kspalaiologos/bzip3/blob/master/include/libbz3.h" } for details that are up-to-date.
;

ABOUT: "compression.bzip3.ffi"
