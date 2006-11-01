! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: prettyprint-internals
USING: alien arrays generic hashtables io kernel math
namespaces parser sequences strings styles vectors words
prettyprint ;

! Sections
TUPLE: section start end style ;

C: section ( style length -- section )
    >r position [ dup rot + dup ] change r>
    [ set-section-end ] keep
    [ set-section-start ] keep
    [ set-section-style ] keep ;

GENERIC: section-fits? ( section -- ? )

M: section section-fits? ( section -- ? )
    section-end last-newline get - text-fits? ;

GENERIC: short-section ( section -- )

GENERIC: long-section ( section -- )

GENERIC: block-empty? ( section -- ? )

: pprint-section ( section -- )
    {
        { [ margin get zero? ] [ short-section ] }
        { [ dup section-fits? ] [ short-section ] }
        { [ t ] [ long-section ] }
    } cond ;

! Block sections
TUPLE: block sections ;

C: block ( style -- block )
    swap 0 <section> over set-delegate
    V{ } clone over set-block-sections ;

: pprinter-block ( -- block ) pprinter-stack get peek ;

: add-section ( section -- )
    dup block-empty?
    [ drop ] [ pprinter-block block-sections push ] if ;

M: block block-empty? block-sections empty? ;

M: block section-fits? ( section -- ? )
    line-limit? [
        drop t
    ] [
        delegate section-fits?
    ] if ;

: (<block) pprinter-stack get push ;

: <style section-style stdio [ <nested-style-stream> ] change ;

: style> stdio [ delegate ] change ;

: change-indent ( n -- )
    tab-size get * indent [ + ] change ;

: <indent ( -- ) 1 change-indent ;

: indent> ( -- ) -1 change-indent ;

! Text section
TUPLE: text string ;

C: text ( string style -- text )
    [ >r over length 1+ <section> r> set-delegate ] keep
    [ set-text-string ] keep ;

M: text block-empty? drop f ;

M: text short-section
    dup text-string swap section-style format ;

M: text long-section
    dup section-start fresh-line short-section ;

: styled-text ( string style -- ) <text> add-section ;

: text ( string -- ) H{ } styled-text ;

! Newline section
TUPLE: newline ;

C: newline ( -- section )
    H{ } 0 <section> over set-delegate ;

M: newline block-empty? drop f ;

M: newline section-fits? drop t ;

M: newline short-section section-start fresh-line ;

: newline ( -- ) <newline> add-section ;

! Inset section
TUPLE: inset ;

C: inset ( style -- block )
    swap <block> over set-delegate ;

M: inset section-fits? ( section -- ? )
    line-limit? [
        drop t
    ] [
        section-end last-newline get - 2 + text-fits?
    ] if ;

: advance ( section -- )
    dup newline? [
        drop
    ] [
        section-start last-newline get = [ bl ] unless
    ] if ;

M: block short-section ( block -- )
    dup <style
    block-sections unclip pprint-section
    [ dup advance pprint-section ] each
    style> ;

M: inset long-section
    <indent
    dup section-start fresh-line dup short-section
    indent>
    section-end fresh-line ;

: <inset ( style -- ) <inset> (<block) ;

! Flow section
TUPLE: flow ;

C: flow ( style -- block )
    swap <block> over set-delegate ;

M: flow section-fits? ( section -- ? )
    dup delegate section-fits? [
        drop t
    ] [
        dup section-end swap section-start - text-fits? not
    ] if ;

M: flow long-section
    dup section-start fresh-line short-section ;

: <flow ( style -- ) <flow> (<block) ;

! Narrow section
TUPLE: narrow ;

C: narrow ( style -- block )
    swap <block> over set-delegate ;

M: narrow section-fits? ( section -- ? )
    line-limit? [
        drop t
    ] [
        section-end last-newline get - 2 + text-fits?
    ] if ;

: narrow-block ( block -- )
    dup <style
    block-sections unclip pprint-section
    [ dup section-start fresh-line pprint-section ] each
    style> ;

M: narrow long-section 
    <indent
    dup section-start fresh-line dup narrow-block
    indent>
    section-end fresh-line ;

: <narrow ( style -- ) <narrow> (<block) ;

! Defblock section
TUPLE: defblock ;

C: defblock ( style -- block )
    swap <block> over set-delegate ;

M: defblock long-section
    <indent
    dup section-start fresh-line short-section
    indent> ;

: <defblock ( style -- ) <defblock> (<block) ;

: end-block ( block -- ) position get swap set-section-end ;

: (block>) ( -- )
    pprinter-stack get pop dup end-block add-section ;

: last-block? ( -- ? ) pprinter-stack get length 1 = ;

: block> ( -- ) last-block? [ (block>) ] unless ;

: end-blocks ( -- ) last-block? [ (block>) end-blocks ] unless ;

: do-pprint ( -- )
    [
        end-printing set pprinter-block
        dup block-empty? [ drop ] [ pprint-section ] if
    ] callcc0 ;
