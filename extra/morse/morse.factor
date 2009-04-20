! Copyright (C) 2007, 2008, 2009 Alex Chapman, 2009 Diego Martinelli
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ascii assocs biassocs combinators hashtables kernel lists literals math namespaces make multiline openal parser sequences splitting strings synth synth.buffers ;
IN: morse

<PRIVATE

CONSTANT: dot-char CHAR: .
CONSTANT: dash-char CHAR: -
CONSTANT: char-gap-char CHAR: \s
CONSTANT: word-gap-char CHAR: /
CONSTANT: unknown-char CHAR: ?

PRIVATE>

CONSTANT: morse-code-table $[
    H{
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
    } >biassoc
]

: ch>morse ( ch -- morse )
    ch>lower morse-code-table at [ unknown-char ] unless* ;

: morse>ch ( str -- ch )
    morse-code-table value-at [ char-gap-char ] unless* ;
    
<PRIVATE
    
: word>morse ( str -- morse )
    [ ch>morse ] { } map-as " " join ;

: sentence>morse ( str -- morse )
    " " split [ word>morse ] map " / " join ;
    
: trim-blanks ( str -- newstr )
    [ blank? ] trim ; inline

: morse>word ( morse -- str )
    " " split [ morse>ch ] "" map-as ;

: morse>sentence ( morse -- sentence )
    "/" split [ trim-blanks morse>word ] map " " join ;

: replace-underscores ( str -- str' )
    [ dup CHAR: _ = [ drop CHAR: - ] when ] map ;

PRIVATE>
    
: >morse ( str -- newstr )
    trim-blanks sentence>morse ;
    
: morse> ( morse -- plain )
    replace-underscores morse>sentence ;

SYNTAX: [MORSE "MORSE]" parse-multiline-string morse> parsed ; 
    
<PRIVATE
    
SYMBOLS: source dot-buffer dash-buffer intra-char-gap-buffer letter-gap-buffer ;

: queue ( symbol -- )
    get source get swap queue-buffer ;

: dot ( -- ) dot-buffer queue ;
: dash ( -- ) dash-buffer queue ;
: intra-char-gap ( -- ) intra-char-gap-buffer queue ;
: letter-gap ( -- ) letter-gap-buffer queue ;

CONSTANT: beep-freq 880

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
