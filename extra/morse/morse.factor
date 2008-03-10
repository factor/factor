! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables kernel lazy-lists namespaces openal
parser-combinators promises sequences strings unicode.case ;
IN: morse

<PRIVATE
: morse-codes ( -- array )
    {
        { CHAR: a ".-"    }
        { CHAR: b "-..."  }
        { CHAR: c "-.-."  }
        { CHAR: d "-.."   }
        { CHAR: e "."     }
        { CHAR: f "..-."  }
        { CHAR: g "--."   }
        { CHAR: h "...."  }
        { CHAR: i ".."    }
        { CHAR: j ".---"  }
        { CHAR: k "-.-"   }
        { CHAR: l ".-.."  }
        { CHAR: m "--"    }
        { CHAR: n "-."    }
        { CHAR: o "---"   }
        { CHAR: p ".--."  }
        { CHAR: q "--.-"  }
        { CHAR: r ".-."   }
        { CHAR: s "..."   }
        { CHAR: t "-"     }
        { CHAR: u "..-"   }
        { CHAR: v "...-"  }
        { CHAR: w ".--"   }
        { CHAR: x "-..-"  }
        { CHAR: y "-.--"  }
        { CHAR: z "--.."  }
        { CHAR: 1 ".----" }
        { CHAR: 2 "..---" }
        { CHAR: 3 "...--" }
        { CHAR: 4 "....-" }
        { CHAR: 5 "....." }
        { CHAR: 6 "-...." }
        { CHAR: 7 "--..." }
        { CHAR: 8 "---.." }
        { CHAR: 9 "----." }
        { CHAR: 0 "-----" }
        { CHAR: . ".-.-.-" }
        { CHAR: , "--..--" }
        { CHAR: ? "..--.." }
        { CHAR: ' ".----." }
        { CHAR: ! "-.-.--" }
        { CHAR: / "-..-."  }
        { CHAR: ( "-.--."  }
        { CHAR: ) "-.--.-" }
        { CHAR: & ".-..."  }
        { CHAR: : "---..." }
        { CHAR: ; "-.-.-." }
        { CHAR: = "-...- " }
        { CHAR: + ".-.-."  }
        { CHAR: - "-....-" }
        { CHAR: _ "..--.-" }
        { CHAR: " ".-..-." }
        { CHAR: $ "...-..-" }
        { CHAR: @ ".--.-." }
        { CHAR: \s "/" }
    } ;

: ch>morse-assoc ( -- assoc )
    morse-codes >hashtable ;

: morse>ch-assoc ( -- assoc )
    morse-codes [ reverse ] map >hashtable ;

PRIVATE>

: ch>morse ( ch -- str )
    ch>lower ch>morse-assoc at* swap "" ? ;

: morse>ch ( str -- ch )
    morse>ch-assoc at* swap f ? ;

: >morse ( str -- str )
    [
        [ CHAR: \s , ] [ ch>morse % ] interleave
    ] "" make ;

<PRIVATE

: dot ( -- ch ) CHAR: . ;
: dash ( -- ch ) CHAR: - ;
: char-gap ( -- ch ) CHAR: \s ;
: word-gap ( -- ch ) CHAR: / ;

: =parser ( obj -- parser )
    [ = ] curry satisfy ;

LAZY: 'dot' ( -- parser )
    dot =parser ;

LAZY: 'dash' ( -- parser )
    dash =parser ;

LAZY: 'char-gap' ( -- parser )
    char-gap =parser ;

LAZY: 'word-gap' ( -- parser )
    word-gap =parser ;

LAZY: 'morse-char' ( -- parser )
    'dot' 'dash' <|> <+> ;

LAZY: 'morse-word' ( -- parser )
    'morse-char' 'char-gap' list-of ;

LAZY: 'morse-words' ( -- parser )
    'morse-word' 'word-gap' list-of ;

PRIVATE>

: morse> ( str -- str )
    'morse-words' parse car parse-result-parsed [
        [ 
            >string morse>ch
        ] map >string
    ] map [ [ CHAR: \s , ] [ % ] interleave ] "" make ;

