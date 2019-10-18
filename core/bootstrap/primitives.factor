! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: image
USING: alien arrays byte-arrays generic hashtables
hashtables-internals help io kernel-internals kernel math
modules namespaces parser sequences strings vectors words
quotations assocs ;

! Some very tricky code creating a bootstrap embryo in the
! host image.

"Creating primitives and basic runtime structures..." print flush

! Bring up a bare cross-compiling vocabulary.
"syntax" vocab

H{ } clone source-files set
H{ } clone vocabularies set
H{ } clone class<map set
V{ } clone modules set

vocabularies get [
    "syntax" set
    H{ } clone "scratchpad" set
] bind

H{ } clone articles set
help-tree off
crossref off
changed-words off

: make-primitive ( word vocab n -- ) >r create f r> define ;

{
    { "execute" "words"                     }
    { "call" "kernel"                       }
    { "if" "kernel"                         }
    { "dispatch" "kernel-internals"         }
    { "string>sbuf" "sbufs"                 }
    { "bignum>fixnum" "math-internals"      }
    { "float>fixnum" "math-internals"       }
    { "fixnum>bignum" "math-internals"      }
    { "float>bignum" "math-internals"       }
    { "fixnum>float" "math-internals"       }
    { "bignum>float" "math-internals"       }
    { "(fraction>)" "math-internals"        }
    { "string>float" "math-internals"       }
    { "float>string" "math-internals"       }
    { "float>bits" "math"                   }
    { "double>bits" "math"                  }
    { "bits>float" "math"                   }
    { "bits>double" "math"                  }
    { "<complex>" "math-internals"          }
    { "fixnum+" "math-internals"            }
    { "fixnum+fast" "math-internals"        }
    { "fixnum-" "math-internals"            }
    { "fixnum-fast" "math-internals"        }
    { "fixnum*" "math-internals"            }
    { "fixnum*fast" "math-internals"        }
    { "fixnum/i" "math-internals"           }
    { "fixnum-mod" "math-internals"         }
    { "fixnum/mod" "math-internals"         }
    { "fixnum-bitand" "math-internals"      }
    { "fixnum-bitor" "math-internals"       }
    { "fixnum-bitxor" "math-internals"      }
    { "fixnum-bitnot" "math-internals"      }
    { "fixnum-shift" "math-internals"       }
    { "fixnum<" "math-internals"            }
    { "fixnum<=" "math-internals"           }
    { "fixnum>" "math-internals"            }
    { "fixnum>=" "math-internals"           }
    { "bignum=" "math-internals"            }
    { "bignum+" "math-internals"            }
    { "bignum-" "math-internals"            }
    { "bignum*" "math-internals"            }
    { "bignum/i" "math-internals"           }
    { "bignum-mod" "math-internals"         }
    { "bignum/mod" "math-internals"         }
    { "bignum-bitand" "math-internals"      }
    { "bignum-bitor" "math-internals"       }
    { "bignum-bitxor" "math-internals"      }
    { "bignum-bitnot" "math-internals"      }
    { "bignum-shift" "math-internals"       }
    { "bignum<" "math-internals"            }
    { "bignum<=" "math-internals"           }
    { "bignum>" "math-internals"            }
    { "bignum>=" "math-internals"           }
    { "float+" "math-internals"             }
    { "float-" "math-internals"             }
    { "float*" "math-internals"             }
    { "float/f" "math-internals"            }
    { "float-mod" "math-internals"          }
    { "float<" "math-internals"             }
    { "float<=" "math-internals"            }
    { "float>" "math-internals"             }
    { "float>=" "math-internals"            }
    { "<word>" "words"                      }
    { "update-xt" "words"                   }
    { "word-xt" "words"                     }
    { "drop" "kernel"                       }
    { "2drop" "kernel"                      }
    { "3drop" "kernel"                      }
    { "dup" "kernel"                        }
    { "2dup" "kernel"                       }
    { "3dup" "kernel"                       }
    { "rot" "kernel"                        }
    { "-rot" "kernel"                       }
    { "dupd" "kernel"                       }
    { "swapd" "kernel"                      }
    { "nip" "kernel"                        }
    { "2nip" "kernel"                       }
    { "tuck" "kernel"                       }
    { "over" "kernel"                       }
    { "pick" "kernel"                       }
    { "swap" "kernel"                       }
    { ">r" "kernel"                         }
    { "r>" "kernel"                         }
    { "eq?" "kernel"                        }
    { "getenv" "kernel-internals"           }
    { "setenv" "kernel-internals"           }
    { "(stat)" "io"                         }
    { "(directory)" "io"                    }
    { "data-gc" "memory"                    }
    { "code-gc" "memory"                    }
    { "gc-time" "memory"                    }
    { "save-image" "memory"                 }
    { "datastack" "kernel"                  }
    { "retainstack" "kernel"                }
    { "callstack" "kernel"                  }
    { "set-datastack" "kernel"              }
    { "set-retainstack" "kernel"            }
    { "set-callstack" "kernel"              }
    { "exit" "kernel"                       }
    { "data-room" "memory"                  }
    { "code-room" "memory"                  }
    { "os-env" "kernel"                     }
    { "millis" "kernel"                     }
    { "type" "kernel"                       }
    { "tag" "kernel-internals"              }
    { "cwd" "io"                            }
    { "cd" "io"                             }
    { "add-compiled-block" "generator"      }
    { "dlopen" "alien"                      }
    { "dlsym" "alien"                       }
    { "dlclose" "alien"                     }
    { "<byte-array>" "byte-arrays"          }
    { "<bit-array>" "bit-arrays"            }
    { "<displaced-alien>" "alien"           }
    { "alien-signed-cell" "alien"           }
    { "set-alien-signed-cell" "alien"       }
    { "alien-unsigned-cell" "alien"         }
    { "set-alien-unsigned-cell" "alien"     }
    { "alien-signed-8" "alien"              }
    { "set-alien-signed-8" "alien"          }
    { "alien-unsigned-8" "alien"            }
    { "set-alien-unsigned-8" "alien"        }
    { "alien-signed-4" "alien"              }
    { "set-alien-signed-4" "alien"          }
    { "alien-unsigned-4" "alien"            }
    { "set-alien-unsigned-4" "alien"        }
    { "alien-signed-2" "alien"              }
    { "set-alien-signed-2" "alien"          }
    { "alien-unsigned-2" "alien"            }
    { "set-alien-unsigned-2" "alien"        }
    { "alien-signed-1" "alien"              }
    { "set-alien-signed-1" "alien"          }
    { "alien-unsigned-1" "alien"            }
    { "set-alien-unsigned-1" "alien"        }
    { "alien-float" "alien"                 }
    { "set-alien-float" "alien"             }
    { "alien-double" "alien"                }
    { "set-alien-double" "alien"            }
    { "alien>char-string" "alien"           }
    { "string>char-alien" "alien"           }
    { "alien>u16-string" "alien"            }
    { "string>u16-alien" "alien"            }
    { "throw" "errors"                      }
    { "string>memory" "kernel-internals"    }
    { "memory>string" "kernel-internals"    }
    { "alien-address" "alien"               }
    { "slot" "kernel-internals"             }
    { "set-slot" "kernel-internals"         }
    { "char-slot" "kernel-internals"        }
    { "set-char-slot" "kernel-internals"    }
    { "resize-array" "arrays"               }
    { "resize-string" "strings"             }
    { "(hashtable)" "hashtables-internals"  }
    { "<array>" "arrays"                    }
    { "begin-scan" "memory"                 }
    { "next-object" "memory"                }
    { "end-scan" "memory"                   }
    { "size" "memory"                       }
    { "die" "kernel"                        }
    { "finalize-compile" "generator"        }
    { "fopen"  "c-streams"                  }
    { "fgetc" "c-streams"                   }
    { "fread" "c-streams"                   }
    { "fwrite" "c-streams"                  }
    { "fflush" "c-streams"                  }
    { "fclose" "c-streams"                  }
    { "expired?" "alien"                    }
    { "<wrapper>" "kernel"                  }
    { "(clone)" "kernel-internals"          }
    { "array>vector" "vectors"              }
    { "<string>" "strings"                  }
    { "xt-map" "kernel-internals"           }
    { "(>tuple)" "kernel-internals"         }
    { "<quotation>" "quotations"            }
    { "<tuple>" "kernel-internals"          }
    { "tuple>array" "generic"               }
    { "profiling" "profiler"                }
    { "become" "kernel-internals"           }
}
dup length [ 3 + ] map
[ >r first2 r> make-primitive ] 2each

FORGET: make-primitive

! Okay, now we have primitives fleshed out. Bring up the generic
! word system.
: builtin-predicate ( class predicate -- )
    [
        over "type" word-prop dup
        \ tag-mask get < \ tag \ type ? , , \ eq? ,
    ] [ ] make define-predicate ;

: register-builtin ( class -- )
    dup "type" word-prop builtins get set-nth ;

: intern-slots ( spec -- spec )
    [
        [ dup array? [ first2 create ] when ] map
        { slot-spec f } swap append >tuple
    ] map ;

: define-builtin ( symbol type# predicate slotspec -- )
    >r >r >r
    dup r> "type" set-word-prop
    dup define-class
    dup r> builtin-predicate
    dup r> intern-slots 2dup "slots" set-word-prop
    define-slots
    register-builtin ;

H{ } clone typemap set
num-types get f <array> builtins set

! These symbols are needed by the code that executes below
{
    { "object" "generic" }
    { "null" "generic" }
} [ create drop ] assoc-each

"fixnum?" "math" create (inline)
"fixnum" "math" create 0 "fixnum?" "math" create { } define-builtin
"fixnum" "math" create ">fixnum" "math" create 1quotation "coercer" set-word-prop

"bignum?" "math" create (inline)
"bignum" "math" create 1 "bignum?" "math" create { } define-builtin
"bignum" "math" create ">bignum" "math" create 1quotation "coercer" set-word-prop

"word?" "words" create (inline)
"word" "words" create 2 "word?" "words" create
{
    {
        { "object" "generic" }
        "name"
        2
        { "word-name" "words" }
        { "set-word-name" "words" }
    }
    {
        { "object" "generic" }
        "vocabulary"
        3
        { "word-vocabulary" "words" }
        { "set-word-vocabulary" "words" }
    }
    {
        { "fixnum" "math" }
        "primitive"
        4
        { "word-primitive" "kernel-internals" }
        { "set-word-primitive" "kernel-internals" }
    }
    {
        { "object" "generic" }
        "def"
        5
        { "word-def" "words" }
        { "set-word-def" "words" }
    }
    {
        { "object" "generic" }
        "props"
        6
        { "word-props" "words" }
        { "set-word-props" "words" }
    }
    {
        { "object" "generic" }
        "?"
        7
        { "compiled?" "words" }
        f
    }
    {
        { "fixnum" "math" }
        "counter"
        8
        { "profile-counter" "profiler" }
        { "set-profile-counter" "profiler" }
    }
} define-builtin

"ratio?" "math" create (inline)
"ratio" "math" create 4 "ratio?" "math" create
{
    {
        { "integer" "math" }
        "numerator"
        1
        { "numerator" "math" }
        f
    }
    {
        { "integer" "math" }
        "denominator"
        2
        { "denominator" "math" }
        f
    }
} define-builtin

"float?" "math" create (inline)
"float" "math" create 5 "float?" "math" create { } define-builtin
"float" "math" create ">float" "math" create 1quotation "coercer" set-word-prop

"complex?" "math" create (inline)
"complex" "math" create 6 "complex?" "math" create
{
    {
        { "real" "math" }
        "real"
        1
        { "real" "math" }
        f
    }
    {
        { "real" "math" }
        "imaginary"
        2
        { "imaginary" "math" }
        f
    }
} define-builtin

"wrapper?" "kernel" create (inline)
"wrapper" "kernel" create 7 "wrapper?" "kernel" create
{
    {
        { "object" "generic" }
        "wrapped"
        1
        { "wrapped" "kernel" }
        f
    }
} define-builtin

"array?" "arrays" create (inline)
"array" "arrays" create 8 "array?" "arrays" create
{ } define-builtin

"!f" "!syntax" create 9 "not" "kernel" create
{ } define-builtin

"hashtable?" "hashtables" create (inline)
"hashtable" "hashtables" create 10 "hashtable?" "hashtables" create
{
    {
        { "array-capacity" "sequences-internals" }
        "count"
        1
        { "hash-count" "hashtables-internals" }
        { "set-hash-count" "hashtables-internals" }
    } {
        { "array-capacity" "sequences-internals" }
        "deleted"
        2
        { "hash-deleted" "hashtables-internals" }
        { "set-hash-deleted" "hashtables-internals" }
    } {
        { "array" "arrays" }
        "array"
        3
        { "hash-array" "hashtables-internals" }
        { "set-hash-array" "hashtables-internals" }
    }
} define-builtin

"vector?" "vectors" create (inline)
"vector" "vectors" create 11 "vector?" "vectors" create
{
    {
        { "array-capacity" "sequences-internals" }
        "fill"
        1
        { "length" "sequences" }
        { "set-fill" "sequences-internals" }
    } {
        { "array" "arrays" }
        "underlying"
        2
        { "underlying" "sequences-internals" }
        { "set-underlying" "sequences-internals" }
    }
} define-builtin

"string?" "strings" create (inline)
"string" "strings" create 12 "string?" "strings" create
{
    {
        { "array-capacity" "sequences-internals" }
        "length"
        1
        { "length" "sequences" }
        f
    }
} define-builtin

"sbuf?" "sbufs" create (inline) 
"sbuf" "sbufs" create 13 "sbuf?" "sbufs" create
{
    {
        { "array-capacity" "sequences-internals" }
        "length"
        1
        { "length" "sequences" }
        { "set-fill" "sequences-internals" }
    }
    {
        { "string" "strings" }
        "underlying"
        2
        { "underlying" "sequences-internals" }
        { "set-underlying" "sequences-internals" }
    }
} define-builtin

"quotation?" "quotations" create (inline)
"quotation" "quotations" create 14 "quotation?" "quotations" create
{ } define-builtin

"dll?" "alien" create (inline)
"dll" "alien" create 15 "dll?" "alien" create
{ { byte-array "path" 1 { "(dll-path)" "alien" } f } }
define-builtin

"alien" "alien" create 16 "alien?" "alien" create
{ { c-ptr "alien" 1 { "underlying-alien" "alien" } f } }
define-builtin

"tuple?" "kernel" create (inline)
"tuple" "kernel" create 17 "tuple?" "kernel" create
{ } define-builtin

"byte-array?" "byte-arrays" create (inline)
"byte-array" "byte-arrays" create 18
"byte-array?" "byte-arrays" create
{ } define-builtin

"bit-array?" "bit-arrays" create (inline) 
"bit-array" "bit-arrays" create 19
"bit-array?" "bit-arrays" create
{ } define-builtin

! Define general-t type, which is any object that is not f.
"general-t" "kernel" create
"!f" "!syntax" lookup builtins get remove [ ] subset
(define-union-class)

! Catch-all class for providing a default method.
"object" "generic" create [ drop t ] "predicate" set-word-prop
"object" "generic" create
builtins get [ ] subset (define-union-class)

! Null class with no instances.
"null" "generic" create [ drop f ] "predicate" set-word-prop
"null" "generic" create { } (define-union-class)

! Create special tombstone values
"tombstone" "hashtables-internals" create { } define-tuple-class

"((empty))" "hashtables-internals" create
T{ tombstone f } 1quotation define-compound

"((empty))" "hashtables-internals" lookup
(inline)

"((tombstone))" "hashtables-internals" create
T{ tombstone t } 1quotation define-compound

"((tombstone))" "hashtables-internals" lookup
(inline)

"c-ptr" "alien" create
{
    { "bit-array" "bit-arrays" }
    { "byte-array" "byte-arrays" }
    { "alien" "alien" }
    { "!f" "!syntax" }
} [ lookup ] { } assoc>map define-union-class

FORGET: builtin-predicate
FORGET: register-builtin
FORGET: define-builtin
FORGET: intern-slots
