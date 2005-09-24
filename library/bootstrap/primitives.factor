! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: image
USING: arrays alien generic hashtables io kernel
kernel-internals lists math namespaces sequences strings vectors
words ;

! Some very tricky code creating a bootstrap embryo in the
! host image.

"Creating primitives and basic runtime structures..." print

! These symbols need the same hashcode in the target as in the
! host.
{ vocabularies typemap builtins }

! Bring up a bare cross-compiling vocabulary.
"syntax" vocab

{{ }} clone vocabularies set
f crossref set

vocabularies get [ "syntax" set [ reveal ] each ] bind

: make-primitive ( { vocab word } n -- )
    >r first2 create r> f define ;

{
    { "execute" "words"                     }
    { "call" "kernel"                       }
    { "if" "kernel"                         }
    { "dispatch" "kernel-internals"         }
    { "cons" "lists"                        }
    { "<vector>" "vectors"                  }
    { "rehash-string" "strings"             }
    { "<sbuf>" "strings"                    }
    { "sbuf>string" "strings"               }
    { ">fixnum" "math"                      }
    { ">bignum" "math"                      }
    { ">float" "math"                       }
    { "(fraction>)" "math-internals"        }
    { "string>float" "math-internals"       }
    { "float>string" "math-internals"       }
    { "float>bits" "math"                   }
    { "double>bits" "math"                  }
    { "bits>float" "math"                   }
    { "bits>double" "math"                  }
    { "<complex>" "math-internals"          }
    { "fixnum+" "math-internals"            }
    { "fixnum-" "math-internals"            }
    { "fixnum*" "math-internals"            }
    { "fixnum/i" "math-internals"           }
    { "fixnum/f" "math-internals"           }
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
    { "bignum/f" "math-internals"           }
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
    { "float=" "math-internals"             }
    { "float+" "math-internals"             }
    { "float-" "math-internals"             }
    { "float*" "math-internals"             }
    { "float/f" "math-internals"            }
    { "float<" "math-internals"             }
    { "float<=" "math-internals"            }
    { "float>" "math-internals"             }
    { "float>=" "math-internals"            }
    { "facos" "math-internals"              }
    { "fasin" "math-internals"              }
    { "fatan" "math-internals"              }
    { "fatan2" "math-internals"             }
    { "fcos" "math-internals"               }
    { "fexp" "math-internals"               }
    { "fcosh" "math-internals"              }
    { "flog" "math-internals"               }
    { "fpow" "math-internals"               }
    { "fsin" "math-internals"               }
    { "fsinh" "math-internals"              }
    { "fsqrt" "math-internals"              }
    { "<word>" "words"                      }
    { "update-xt" "words"                   }
    { "compiled?" "words"                   }
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
    { "stat" "io"                           }
    { "(directory)" "io"                    }
    { "gc" "memory"                         }
    { "gc-time" "memory"                    }
    { "save-image" "memory"                 }
    { "datastack" "kernel"                  }
    { "callstack" "kernel"                  }
    { "set-datastack" "kernel"              }
    { "set-callstack" "kernel"              }
    { "exit" "kernel"                       }
    { "room" "memory"                       }
    { "os-env" "kernel"                     }
    { "millis" "kernel"                     }
    { "(random-int)" "math"                 }
    { "type" "kernel"                       }
    { "tag" "kernel-internals"              }
    { "cwd" "io"                            }
    { "cd" "io"                             }
    { "compiled-offset" "assembler"         }
    { "set-compiled-offset" "assembler"     }
    { "literal-top" "assembler"             }
    { "set-literal-top" "assembler"         }
    { "address" "memory"                    }
    { "dlopen" "alien"                      }
    { "dlsym" "alien"                       }
    { "dlclose" "alien"                     }
    { "<alien>" "alien"                     }
    { "<byte-array>" "arrays"               }
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
    { "alien-c-string" "alien"              }
    { "set-alien-c-string" "alien"          }
    { "throw" "errors"                      }
    { "string>memory" "kernel-internals"    }
    { "memory>string" "kernel-internals"    }
    { "alien-address" "alien"               }
    { "slot" "kernel-internals"             }
    { "set-slot" "kernel-internals"         }
    { "integer-slot" "kernel-internals"     }
    { "set-integer-slot" "kernel-internals" }
    { "char-slot" "kernel-internals"        }
    { "set-char-slot" "kernel-internals"    }
    { "resize-array" "arrays"               }
    { "resize-string" "strings"             }
    { "<hashtable>" "hashtables"            }
    { "<array>" "arrays"                    }
    { "<tuple>" "kernel-internals"          }
    { "begin-scan" "memory"                 }
    { "next-object" "memory"                }
    { "end-scan" "memory"                   }
    { "size" "memory"                       }
    { "die" "kernel"                        }
    { "flush-icache" "assembler"            }
    { "fopen"  "io-internals"               }
    { "fgetc" "io-internals"                }
    { "fwrite" "io-internals"               }
    { "fflush" "io-internals"               }
    { "fclose" "io-internals"               }
    { "expired?" "alien"                    }
    { "<wrapper>" "kernel"                  }
    { "(clone)" "kernel-internals"          }
    { "array>tuple" "generic"               }
    { "tuple>array" "generic"               }
    { "array>vector" "vectors"              }
} dup length 3 swap [ + ] map-with [ make-primitive ] 2each

: set-stack-effect ( { vocab word effect } -- )
    first3 >r lookup r> "stack-effect" set-word-prop ;

{
    { "drop" "kernel" " x -- " }
    { "2drop" "kernel" " x y -- " }
    { "3drop" "kernel" " x y z -- " }
    { "dup" "kernel"  " x -- x x " }
    { "2dup" "kernel"  " x y -- x y x y " }
    { "3dup" "kernel"  " x y z -- x y z x y z " }
    { "rot" "kernel"  " x y z -- y z x " }
    { "-rot" "kernel"  " x y z -- z x y " }
    { "dupd" "kernel"  " x y -- x x y " }
    { "swapd" "kernel"  " x y z -- y x z " }
    { "nip" "kernel"  " x y -- y " }
    { "2nip" "kernel"  " x y z -- z " }
    { "tuck" "kernel"  " x y -- y x y " }
    { "over" "kernel" " x y -- x y x " }
    { "pick" "kernel" " x y z -- x y z x " }
    { "swap" "kernel" " x y -- y x " }
    { ">r" "kernel"   " x -- r: x " }
    { "r>" "kernel"   " r: x -- x " }
    { "datastack" "kernel" " -- ds " }
    { "callstack" "kernel" " -- cs " }
    { "set-datastack" "kernel" " ds -- " }
    { "set-callstack" "kernel" " cs -- " }
    { "flush-icache" "assembler" " -- " }
} [
    set-stack-effect
] each

FORGET: make-primitive
FORGET: set-stack-effect

! Okay, now we have primitives fleshed out. Bring up the generic
! word system.
: builtin-predicate ( class predicate -- )
    [
        over "type" word-prop dup
        tag-mask < \ tag \ type ? , , \ eq? ,
    ] [ ] make define-predicate ;

: register-builtin ( class -- )
    dup "type" word-prop builtins get set-nth ;

: define-builtin ( symbol type# predicate slotspec -- )
    >r >r >r
    dup intern-symbol
    dup r> "type" set-word-prop
    dup define-class
    dup r> builtin-predicate
    dup r> intern-slots 2dup "slots" set-word-prop
    define-slots
    register-builtin ;

{{ }} clone typemap set
num-types <array> builtins set

! These symbols are needed by the code that executes below
"object" "generic" create drop
"null" "generic" create drop

"fixnum?" "math" create t "inline" set-word-prop
"fixnum" "math" create 0 "fixnum?" "math" create { } define-builtin
"fixnum" "math" create 0 "math-priority" set-word-prop
"fixnum" "math" create ">fixnum" [ "math" ] search unit "coercer" set-word-prop

"bignum?" "math" create t "inline" set-word-prop
"bignum" "math" create 1 "bignum?" "math" create { } define-builtin
"bignum" "math" create 1 "math-priority" set-word-prop
"bignum" "math" create ">bignum" [ "math" ] search unit "coercer" set-word-prop

"cons?" "lists" create t "inline" set-word-prop
"cons" "lists" create 2 "cons?" "lists" create
{ { 0 { "car" "lists" } f } { 1 { "cdr" "lists" } f } } define-builtin

"ratio?" "math" create t "inline" set-word-prop
"ratio" "math" create 4 "ratio?" "math" create
{ { 0 { "numerator" "math" } f } { 1 { "denominator" "math" } f } } define-builtin
"ratio" "math" create 2 "math-priority" set-word-prop

"float?" "math" create t "inline" set-word-prop
"float" "math" create 5 "float?" "math" create { } define-builtin
"float" "math" create 3 "math-priority" set-word-prop
"float" "math" create ">float" [ "math" ] search unit "coercer" set-word-prop

"complex?" "math" create t "inline" set-word-prop
"complex" "math" create 6 "complex?" "math" create
{ { 0 { "real" "math" } f } { 1 { "imaginary" "math" } f } } define-builtin
"complex" "math" create 4 "math-priority" set-word-prop

"displaced-alien" "alien" create 7 "displaced-alien?" "alien" create { } define-builtin

"array?" "arrays" create t "inline" set-word-prop
"array" "arrays" create 8 "array?" "arrays" create
{ } define-builtin

"f" "!syntax" create 9 "not" "kernel" create
{ } define-builtin

"hashtable?" "hashtables" create t "inline" set-word-prop
"hashtable" "hashtables" create 10 "hashtable?" "hashtables" create
{
    { 1 { "hash-size" "hashtables" } { "set-hash-size" "kernel-internals" } }
    { 2 { "underlying" "sequences-internals" } { "set-underlying" "sequences-internals" } }
} define-builtin

"vector?" "vectors" create t "inline" set-word-prop
"vector" "vectors" create 11 "vector?" "vectors" create
{
    { 1 { "length" "sequences" } { "set-fill" "sequences-internals" } }
    { 2 { "underlying" "sequences-internals" } { "set-underlying" "sequences-internals" } }
} define-builtin

"string?" "strings" create t "inline" set-word-prop
"string" "strings" create 12 "string?" "strings" create
{
    { 1 { "length" "sequences" } f }
    { 2 { "hashcode" "kernel" } f }
} define-builtin

"sbuf?" "strings" create t "inline" set-word-prop 
"sbuf" "strings" create 13 "sbuf?" "strings" create
{
    { 1 { "length" "sequences" } { "set-fill" "sequences-internals" } }
    { 2 { "underlying" "sequences-internals" } { "set-underlying" "sequences-internals" } }
} define-builtin

"wrapper?" "kernel" create t "inline" set-word-prop
"wrapper" "kernel" create 14 "wrapper?" "kernel" create
{ { 1 { "wrapped" "kernel" } f } } define-builtin

"dll?" "alien" create t "inline" set-word-prop
"dll" "alien" create 15 "dll?" "alien" create
{ { 1 { "dll-path" "alien" } f } } define-builtin

"alien?" "alien" create t "inline" set-word-prop
"alien" "alien" create 16 "alien?" "alien" create { } define-builtin

"word?" "words" create t "inline" set-word-prop
"word" "words" create 17 "word?" "words" create
{
    { 1 { "hashcode" "kernel" } f }
    { 2 { "word-name" "words" } f }
    { 3 { "word-vocabulary" "words" } { "set-word-vocabulary" "words" } }
    { 4 { "word-primitive" "words" } { "set-word-primitive" "words" } }
    { 5 { "word-def" "words" } { "set-word-def" "words" } }
    { 6 { "word-props" "words" } { "set-word-props" "words" } }
} define-builtin

"tuple?" "kernel" create t "inline" set-word-prop
"tuple" "kernel" create 18 "tuple?" "kernel" create
{ } define-builtin

"byte-array?" "arrays" create t "inline" set-word-prop
"byte-array" "arrays" create 19
"byte-array?" "arrays" create
{ } define-builtin

! Define general-t type, which is any object that is not f.
"general-t" "kernel" create dup define-symbol
f "f" "!syntax" lookup builtins get remove [ ] subset
define-union

! Catch-all class for providing a default method.
"object" "generic" create [ drop t ] "predicate" set-word-prop
"object" "generic" create dup define-symbol
f builtins get [ ] subset define-union

! Null class with no instances.
"null" "generic" create [ drop f ] "predicate" set-word-prop
"null" "generic" create dup define-symbol f @{ }@ define-union

FORGET: builtin-predicate
FORGET: register-builtin
FORGET: define-builtin
