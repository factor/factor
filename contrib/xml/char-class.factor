IN: char-classes
USING: kernel sequences math ;

: in-range-seq? ( number seq -- ? )
    #! seq: { { min max } { min max }* }
    [ first2 between? ] contains-with? ;

PREDICATE: integer name-start-char
    {
        { CHAR: _    CHAR: _    }
        { CHAR: A    CHAR: Z    }
        { CHAR: a    CHAR: z    }
        { HEX: C0    HEX: D6    }
        { HEX: D8    HEX: F6    }
        { HEX: F8    HEX: 2FF   }
        { HEX: 370   HEX: 37D   }
        { HEX: 37F   HEX: 1FFF  }
        { HEX: 200C  HEX: 200D  }
        { HEX: 2070  HEX: 218F  }
        { HEX: 2C00  HEX: 2FEF  }
        { HEX: 3001  HEX: D7FF  }
        { HEX: F900  HEX: FDCF  }
        { HEX: FDF0  HEX: FFFD  }
        { HEX: 10000 HEX: EFFFF }
    } in-range-seq? ;

PREDICATE: integer name-char
    dup name-start-char? swap {
        { CHAR: -   CHAR: -   }
        { CHAR: .   CHAR: .   }
        { CHAR: 0   CHAR: 9   }
        { HEX: b7   HEX: b7   }
        { HEX: 300  HEX: 36F  }
        { HEX: 203F HEX: 2040 }
    } in-range-seq? or ;
