IN: alien.arrays
USING: help.syntax help.markup byte-arrays alien.c-types ;

ARTICLE: "c-arrays-factor" "Converting C arrays to and from Factor arrays"
"Each primitive C type has a pair of words, " { $snippet ">" { $emphasis "type" } "-array" } " and " { $snippet { $emphasis "type" } "-array>" } ", for converting an array of Factor objects to and from a " { $link byte-array } " of C values. This set of words consists of:"
{ $subsection >c-bool-array      }
{ $subsection >c-char-array      }
{ $subsection >c-double-array    }
{ $subsection >c-float-array     }
{ $subsection >c-int-array       }
{ $subsection >c-long-array      }
{ $subsection >c-longlong-array  }
{ $subsection >c-short-array     }
{ $subsection >c-uchar-array     }
{ $subsection >c-uint-array      }
{ $subsection >c-ulong-array     }
{ $subsection >c-ulonglong-array }
{ $subsection >c-ushort-array    }
{ $subsection >c-void*-array     }
{ $subsection c-bool-array>      }
{ $subsection c-char-array>      }
{ $subsection c-double-array>    }
{ $subsection c-float-array>     }
{ $subsection c-int-array>       }
{ $subsection c-long-array>      }
{ $subsection c-longlong-array>  }
{ $subsection c-short-array>     }
{ $subsection c-uchar-array>     }
{ $subsection c-uint-array>      }
{ $subsection c-ulong-array>     }
{ $subsection c-ulonglong-array> }
{ $subsection c-ushort-array>    }
{ $subsection c-void*-array>     } ;

ARTICLE: "c-arrays-get/set" "Reading and writing elements in C arrays"
"Each C type has a pair of words, " { $snippet { $emphasis "type" } "-nth" } " and " { $snippet "set-" { $emphasis "type" } "-nth" } ", for reading and writing values of this type stored in an array. This set of words includes but is not limited to:"
{ $subsection char-nth }
{ $subsection set-char-nth }
{ $subsection uchar-nth }
{ $subsection set-uchar-nth }
{ $subsection short-nth }
{ $subsection set-short-nth }
{ $subsection ushort-nth }
{ $subsection set-ushort-nth }
{ $subsection int-nth }
{ $subsection set-int-nth }
{ $subsection uint-nth }
{ $subsection set-uint-nth }
{ $subsection long-nth }
{ $subsection set-long-nth }
{ $subsection ulong-nth }
{ $subsection set-ulong-nth }
{ $subsection longlong-nth }
{ $subsection set-longlong-nth }
{ $subsection ulonglong-nth }
{ $subsection set-ulonglong-nth }
{ $subsection float-nth }
{ $subsection set-float-nth }
{ $subsection double-nth }
{ $subsection set-double-nth }
{ $subsection void*-nth }
{ $subsection set-void*-nth } ;

ARTICLE: "c-arrays" "C arrays"
"C arrays are allocated in the same manner as other C data; see " { $link "c-byte-arrays" } " and " { $link "malloc" } "."
$nl
"C type specifiers for array types are documented in " { $link "c-types-specs" } "."
{ $subsection "c-arrays-factor" }
{ $subsection "c-arrays-get/set" } ;
