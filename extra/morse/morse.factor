! Copyright (C) 2007, 2008, 2009 Alex Chapman, 2009 Diego Martinelli
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ascii assocs biassocs combinators hashtables
kernel lists literals math namespaces make multiline openal
openal.alut parser sequences splitting strings synth
synth.buffers ;
IN: morse

ERROR: no-morse-ch ch ;

<PRIVATE

CONSTANT: dot-char char: .
CONSTANT: dash-char char: -
CONSTANT: char-gap-char char: \s
CONSTANT: word-gap-char char: /
CONSTANT: unknown-char char: ?

PRIVATE>

CONSTANT: morse-code-table $[
    H{
        { char: a ".-"    }
        { char: b "-..."  }
        { char: c "-.-."  }
        { char: d "-.."   }
        { char: e "."     }
        { char: f "..-."  }
        { char: g "--."   }
        { char: h "...."  }
        { char: i ".."    }
        { char: j ".---"  }
        { char: k "-.-"   }
        { char: l ".-.."  }
        { char: m "--"    }
        { char: n "-."    }
        { char: o "---"   }
        { char: p ".--."  }
        { char: q "--.-"  }
        { char: r ".-."   }
        { char: s "..."   }
        { char: t "-"     }
        { char: u "..-"   }
        { char: v "...-"  }
        { char: w ".--"   }
        { char: x "-..-"  }
        { char: y "-.--"  }
        { char: z "--.."  }
        { char: 1 ".----" }
        { char: 2 "..---" }
        { char: 3 "...--" }
        { char: 4 "....-" }
        { char: 5 "....." }
        { char: 6 "-...." }
        { char: 7 "--..." }
        { char: 8 "---.." }
        { char: 9 "----." }
        { char: 0 "-----" }
        { char: . ".-.-.-" }
        { char: , "--..--" }
        { char: ? "..--.." }
        { char: \' ".----." }
        { char: \! "-.-.--" }
        { char: / "-..-."  }
        { char: \( "-.--."  }
        { char: \) "-.--.-" }
        { char: & ".-..."  }
        { char: \: "---..." }
        { char: \; "-.-.-." }
        { char: = "-...- " }
        { char: + ".-.-."  }
        { char: - "-....-" }
        { char: _ "..--.-" }
        { char: \" ".-..-." }
        { char: $ "...-..-" }
        { char: @ ".--.-." }
        { char: \s "/" }
    } >biassoc
]

: ch>morse ( ch -- morse )
    ch>lower morse-code-table at unknown-char 1string or ;

: morse>ch ( str -- ch )
    morse-code-table value-at char-gap-char or ;

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
    [ dup char: _ = [ drop char: - ] when ] map ;

PRIVATE>

: >morse ( str -- newstr )
    trim-blanks sentence>morse ;

: morse> ( morse -- plain )
    replace-underscores morse>sentence ;

SYNTAX: \MORSE[[ "]]" parse-multiline-string morse> suffix! ;

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

: play-char ( string -- )
    [ intra-char-gap ] [
        {
            { dot-char [ dot ] }
            { dash-char [ dash ] }
            { word-gap-char [ intra-char-gap ] }
            { unknown-char [ intra-char-gap ] }
            [ no-morse-ch ]
        } case
    ] interleave ;

PRIVATE>

: play-as-morse* ( str unit-length -- )
    [
        [ letter-gap ] [ ch>morse play-char ] interleave
    ] swap playing-morse ; inline

: play-as-morse ( str -- )
    0.05 play-as-morse* ; inline
