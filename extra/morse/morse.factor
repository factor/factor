! Copyright (C) 2007, 2008, 2009 Alex Chapman, 2009 Diego Martinelli
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ascii assocs biassocs combinators hashtables
kernel lists literals math namespaces make multiline openal
openal.alut parser sequences splitting strings synth
synth.buffers ;
IN: morse

ERROR: no-morse-ch ch ;

<PRIVATE

CONSTANT: dot-char ch'.
CONSTANT: dash-char ch'-
CONSTANT: char-gap-char ch'\s
CONSTANT: word-gap-char ch'/
CONSTANT: unknown-char ch'?

PRIVATE>

CONSTANT: morse-code-table $[
    H{
        { ch'a ".-"    }
        { ch'b "-..."  }
        { ch'c "-.-."  }
        { ch'd "-.."   }
        { ch'e "."     }
        { ch'f "..-."  }
        { ch'g "--."   }
        { ch'h "...."  }
        { ch'i ".."    }
        { ch'j ".---"  }
        { ch'k "-.-"   }
        { ch'l ".-.."  }
        { ch'm "--"    }
        { ch'n "-."    }
        { ch'o "---"   }
        { ch'p ".--."  }
        { ch'q "--.-"  }
        { ch'r ".-."   }
        { ch's "..."   }
        { ch't "-"     }
        { ch'u "..-"   }
        { ch'v "...-"  }
        { ch'w ".--"   }
        { ch'x "-..-"  }
        { ch'y "-.--"  }
        { ch'z "--.."  }
        { ch'1 ".----" }
        { ch'2 "..---" }
        { ch'3 "...--" }
        { ch'4 "....-" }
        { ch'5 "....." }
        { ch'6 "-...." }
        { ch'7 "--..." }
        { ch'8 "---.." }
        { ch'9 "----." }
        { ch'0 "-----" }
        { ch'. ".-.-.-" }
        { ch', "--..--" }
        { ch'? "..--.." }
        { ch'\' ".----." }
        { ch'\! "-.-.--" }
        { ch'/ "-..-."  }
        { ch'\( "-.--."  }
        { ch'\) "-.--.-" }
        { ch'& ".-..."  }
        { ch'\: "---..." }
        { ch'\; "-.-.-." }
        { ch'= "-...- " }
        { ch'+ ".-.-."  }
        { ch'- "-....-" }
        { ch'_ "..--.-" }
        { ch'\" ".-..-." }
        { ch'$ "...-..-" }
        { ch'@ ".--.-." }
        { ch'\s "/" }
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
    [ dup ch'_ = [ drop ch'- ] when ] map ;

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
