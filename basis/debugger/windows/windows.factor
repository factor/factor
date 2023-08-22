! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs debugger io kernel literals math.parser
namespaces prettyprint sequences system windows.kernel32
windows.ole32 windows.errors math ;
IN: debugger.windows

CONSTANT: seh-names
    H{
        { $ STATUS_GUARD_PAGE_VIOLATION       "STATUS_GUARD_PAGE_VIOLATION"     }
        { $ STATUS_DATATYPE_MISALIGNMENT      "STATUS_DATATYPE_MISALIGNMENT"    }
        { $ STATUS_BREAKPOINT                 "STATUS_BREAKPOINT"               }
        { $ STATUS_SINGLE_STEP                "STATUS_SINGLE_STEP"              }
        { $ STATUS_ACCESS_VIOLATION           "STATUS_ACCESS_VIOLATION"         }
        { $ STATUS_IN_PAGE_ERROR              "STATUS_IN_PAGE_ERROR"            }
        { $ STATUS_INVALID_HANDLE             "STATUS_INVALID_HANDLE"           }
        { $ STATUS_NO_MEMORY                  "STATUS_NO_MEMORY"                }
        { $ STATUS_ILLEGAL_INSTRUCTION        "STATUS_ILLEGAL_INSTRUCTION"      }
        { $ STATUS_NONCONTINUABLE_EXCEPTION   "STATUS_NONCONTINUABLE_EXCEPTION" }
        { $ STATUS_INVALID_DISPOSITION        "STATUS_INVALID_DISPOSITION"      }
        { $ STATUS_ARRAY_BOUNDS_EXCEEDED      "STATUS_ARRAY_BOUNDS_EXCEEDED"    }
        { $ STATUS_FLOAT_DENORMAL_OPERAND     "STATUS_FLOAT_DENORMAL_OPERAND"   }
        { $ STATUS_FLOAT_DIVIDE_BY_ZERO       "STATUS_FLOAT_DIVIDE_BY_ZERO"     }
        { $ STATUS_FLOAT_INEXACT_RESULT       "STATUS_FLOAT_INEXACT_RESULT"     }
        { $ STATUS_FLOAT_INVALID_OPERATION    "STATUS_FLOAT_INVALID_OPERATION"  }
        { $ STATUS_FLOAT_OVERFLOW             "STATUS_FLOAT_OVERFLOW"           }
        { $ STATUS_FLOAT_STACK_CHECK          "STATUS_FLOAT_STACK_CHECK"        }
        { $ STATUS_FLOAT_UNDERFLOW            "STATUS_FLOAT_UNDERFLOW"          }
        { $ STATUS_INTEGER_DIVIDE_BY_ZERO     "STATUS_INTEGER_DIVIDE_BY_ZERO"   }
        { $ STATUS_INTEGER_OVERFLOW           "STATUS_INTEGER_OVERFLOW"         }
        { $ STATUS_PRIVILEGED_INSTRUCTION     "STATUS_PRIVILEGED_INSTRUCTION"   }
        { $ STATUS_STACK_OVERFLOW             "STATUS_STACK_OVERFLOW"           }
        { $ STATUS_CONTROL_C_EXIT             "STATUS_CONTROL_C_EXIT"           }
        { $ STATUS_FLOAT_MULTIPLE_FAULTS      "STATUS_FLOAT_MULTIPLE_FAULTS"    }
        { $ STATUS_FLOAT_MULTIPLE_TRAPS       "STATUS_FLOAT_MULTIPLE_TRAPS"     }
        { 0xe06d7363 "Visual C++ exception" }
    }

: seh-name. ( n -- )
    seh-names at [ " (" ")" surround write ] when* ;

M: windows signal-error.
    "Windows exception 0x" write
    third [ >hex write ] [ seh-name. ] bi nl ;

M: ole32-error error.
    "COM error 0x" write
    dup code>> 0xffff,ffff bitand >hex write ": " write
    message>> write ;

M: windows-error error.
    "Win32 error 0x" write
    dup n>> 0xffff,ffff bitand >hex write ": " write
    string>> write ;
