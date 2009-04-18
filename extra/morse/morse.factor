! Copyright (C) 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ascii assocs combinators hashtables kernel lists math
namespaces make openal parser-combinators promises sequences
strings synth synth.buffers unicode.case ;
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

: dot-char ( -- ch ) CHAR: . ;
: dash-char ( -- ch ) CHAR: - ;
: char-gap-char ( -- ch ) CHAR: \s ;
: word-gap-char ( -- ch ) CHAR: / ;

: =parser ( obj -- parser )
    [ = ] curry satisfy ;

LAZY: 'dot' ( -- parser )
    dot-char =parser ;

LAZY: 'dash' ( -- parser )
    dash-char =parser ;

LAZY: 'char-gap' ( -- parser )
    char-gap-char =parser ;

LAZY: 'word-gap' ( -- parser )
    word-gap-char =parser ;

LAZY: 'morse-char' ( -- parser )
    'dot' 'dash' <|> <+> ;

LAZY: 'morse-word' ( -- parser )
    'morse-char' 'char-gap' list-of ;

LAZY: 'morse-words' ( -- parser )
    'morse-word' 'word-gap' list-of ;

PRIVATE>

: morse> ( str -- str )
    'morse-words' parse car parsed>> [
        [ 
            >string morse>ch
        ] map >string
    ] map [ [ CHAR: \s , ] [ % ] interleave ] "" make ;

<PRIVATE
SYMBOLS: source dot-buffer dash-buffer intra-char-gap-buffer letter-gap-buffer ;

: queue ( symbol -- )
    get source get swap queue-buffer ;

: dot ( -- ) dot-buffer queue ;
: dash ( -- ) dash-buffer queue ;
: intra-char-gap ( -- ) intra-char-gap-buffer queue ;
: letter-gap ( -- ) letter-gap-buffer queue ;

: beep-freq ( -- n ) 880 ;

: <morse-buffer> ( -- buffer )
    half-sample-freq <8bit-mono-buffer> ;

: sine-buffer ( seconds -- id )
    beep-freq swap <morse-buffer> >sine-wave-buffer
    send-buffer id>> ;

: silent-buffer ( seconds -- id )
    <morse-buffer> >silent-buffer send-buffer id>> ;

: make-buffers ( unit-length -- )
    {
        [ sine-buffer dot-buffer set ]
        [ 3 * sine-buffer dash-buffer set ]
        [ silent-buffer intra-char-gap-buffer set ]
        [ 3 * silent-buffer letter-gap-buffer set ]
    } cleave ;

: playing-morse ( quot unit-length -- )
    [
        init-openal 1 gen-sources first source set make-buffers
        call
        source get source-play
    ] with-scope ; inline

: play-char ( ch -- )
    [ intra-char-gap ] [
        {
            { dot-char [ dot ] }
            { dash-char [ dash ] }
            { word-gap-char [ intra-char-gap ] }
        } case
    ] interleave ;

PRIVATE>

: play-as-morse* ( str unit-length -- )
    [
        [ letter-gap ] [ ch>morse play-char ] interleave
    ] swap playing-morse ; inline

: play-as-morse ( str -- )
    0.05 play-as-morse* ; inline
