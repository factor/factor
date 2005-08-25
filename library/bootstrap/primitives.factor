! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: image
USING: alien generic hashtables io kernel kernel-internals lists
math namespaces sequences strings vectors words ;

! Some very tricky code creating a bootstrap embryo in the
! host image.

"Creating primitives and basic runtime structures..." print

! These symbols need the same hashcode in the target as in the
! host.
{ vocabularies object null typemap builtins }

! Bring up a bare cross-compiling vocabulary.
"syntax" vocab

{{ }} clone vocabularies set
f crossref set

vocabularies get [ "syntax" set [ reveal ] each ] bind

: make-primitive ( { vocab word } n -- )
    >r 2unseq create r> f define ;

{
    { "execute" "words"                     }
    { "call" "kernel"                       }
    { "ifte" "kernel"                       }
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
    { "str>float" "parser"                  }
    { "(unparse-float)" "parser"            }
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
    { "dup" "kernel"                        }
    { "swap" "kernel"                       }
    { "over" "kernel"                       }
    { "pick" "kernel"                       }
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
    { "<byte-array>" "kernel-internals"     }
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
    { "resize-array" "kernel-internals"     }
    { "resize-string" "strings"             }
    { "<hashtable>" "hashtables"            }
    { "<array>" "kernel-internals"          }
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
} dup length 3 swap [ + ] map-with [ make-primitive ] 2each

: set-stack-effect ( { vocab word effect } -- )
    3unseq >r lookup r> "stack-effect" set-word-prop ;

{
    { "drop" "kernel" " x -- " }
    { "dup" "kernel"  " x -- x x " }
    { "swap" "kernel" " x y -- y x " }
    { "over" "kernel" " x y -- x y x " }
    { "pick" "kernel" " x y z -- x y z x " }
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
    [ \ type , over types first , \ eq? , ] [ ] make
    define-predicate ;

: register-builtin ( class -- )
    dup types first builtins get set-nth ;

: define-builtin ( symbol type# predicate slotspec -- )
    >r >r >r
    dup intern-symbol
    dup r> 1vector "types" set-word-prop
    dup builtin define-class
    dup r> builtin-predicate
    dup r> intern-slots 2dup "slots" set-word-prop
    define-slots
    register-builtin ;

{{ }} clone typemap set
num-types empty-vector builtins set

! Catch-all metaclass for providing a default method.
object num-types >vector "types" set-word-prop
object [ drop t ] "predicate" set-word-prop
object object define-class

! Null metaclass with no instances.
null { } "types" set-word-prop
null [ drop f ] "predicate" set-word-prop
null null define-class

"fixnum" "math" create 0 "fixnum?" "math" create { } define-builtin
"fixnum" "math" create 0 "math-priority" set-word-prop
"fixnum" "math" create ">fixnum" [ "math" ] search unit "coercer" set-word-prop

"bignum" "math" create 1 "bignum?" "math" create { } define-builtin
"bignum" "math" create 1 "math-priority" set-word-prop
"bignum" "math" create ">bignum" [ "math" ] search unit "coercer" set-word-prop

"cons" "lists" create 2 "cons?" "lists" create
{ { 0 { "car" "lists" } f } { 1 { "cdr" "lists" } f } } define-builtin

"ratio" "math" create 4 "ratio?" "math" create
{ { 0 { "numerator" "math" } f } { 1 { "denominator" "math" } f } } define-builtin
"ratio" "math" create 2 "math-priority" set-word-prop

"float" "math" create 5 "float?" "math" create { } define-builtin
"float" "math" create 3 "math-priority" set-word-prop
"float" "math" create ">float" [ "math" ] search unit "coercer" set-word-prop

"complex" "math" create 6 "complex?" "math" create
{ { 0 { "real" "math" } f } { 1 { "imaginary" "math" } f } } define-builtin
"complex" "math" create 4 "math-priority" set-word-prop

"t" "!syntax" create 7 "t?" "kernel" create
{ } define-builtin

"array" "kernel-internals" create 8 "array?" "kernel-internals" create
{ } define-builtin

"f" "!syntax" create 9 "not" "kernel" create
{ } define-builtin

"hashtable" "hashtables" create 10 "hashtable?" "hashtables" create {
    { 1 { "hash-size" "hashtables" } { "set-hash-size" "kernel-internals" } }
    { 2 { "hash-array" "kernel-internals" } { "set-hash-array" "kernel-internals" } }
} define-builtin

"vector" "vectors" create 11 "vector?" "vectors" create {
    { 1 { "length" "sequences" } { "set-capacity" "kernel-internals" } }
    { 2 { "underlying" "kernel-internals" } { "set-underlying" "kernel-internals" } }
} define-builtin

"string" "strings" create 12 "string?" "strings" create {
    { 1 { "length" "sequences" } f }
    { 2 { "hashcode" "kernel" } f }
} define-builtin

"sbuf" "strings" create 13 "sbuf?" "strings" create {
    { 1 { "length" "sequences" } { "set-capacity" "kernel-internals" } }
    { 2 { "underlying" "kernel-internals" } { "set-underlying" "kernel-internals" } }
} define-builtin

"wrapper" "kernel" create 14 "wrapper?" "kernel" create
{ { 1 { "wrapped" "kernel" } f } } define-builtin

"dll" "alien" create 15 "dll?" "alien" create
{ { 1 { "dll-path" "alien" } f } } define-builtin

"alien" "alien" create 16 "alien?" "alien" create { } define-builtin

"word" "words" create 17 "word?" "words" create {
    { 1 { "hashcode" "kernel" } f }
    { 4 { "word-def" "words" } { "set-word-def" "words" } }
    { 5 { "word-props" "words" } { "set-word-props" "words" } }
} define-builtin

"tuple" "kernel" create 18 "tuple?" "kernel" create { } define-builtin

"byte-array" "kernel-internals" create 19 "byte-array?" "kernel-internals" create { } define-builtin

"displaced-alien" "alien" create 20 "displaced-alien?" "alien" create { } define-builtin

FORGET: builtin-predicate
FORGET: register-builtin
FORGET: define-builtin
