! Copyright (C) 2008, 2009 Daniel Ehrenberg, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math splitting make fry ;
IN: regexp.matchers

! For now, a matcher is just something with a method to do the
! equivalent of match.

! matcher protocol:
GENERIC: match-index ( string matcher -- index/f )

: match ( string matcher -- slice/f )
    dupd match-index [ head-slice ] [ drop f ] if* ;

: matches? ( string matcher -- ? )
    dupd match-index
    [ swap length = ] [ drop f ] if* ;

: match-head ( string matcher -- end/f ) match [ length ] [ f ] if* ;

: match-at ( string m matcher -- n/f finished? )
    [
        2dup swap length > [ 2drop f f ] [ tail-slice t ] if
    ] dip swap [ match-head f ] [ 2drop f t ] if ;

: match-range ( string m matcher -- a/f b/f )
    3dup match-at over [
        drop nip rot drop dupd +
    ] [
        [ 3drop drop f f ] [ drop [ 1+ ] dip match-range ] if
    ] if ;

: first-match ( string matcher -- slice/f )
    dupd 0 swap match-range rot over [ <slice> ] [ 3drop f ] if ;

: re-cut ( string matcher -- end/f start )
    dupd first-match
    [ split1-slice swap ] [ "" like f swap ] if* ;

<PRIVATE

: (re-split) ( string matcher -- )
    over [ [ re-cut , ] keep (re-split) ] [ 2drop ] if ;

PRIVATE>

: re-split ( string matcher -- seq )
    [ (re-split) ] { } make ;

: re-replace ( string matcher replacement -- result )
    [ re-split ] dip join ;

: next-match ( string matcher -- end/f match/f )
    dupd first-match dup
    [ [ split1-slice nip ] keep ] [ 2drop f f ] if ;

: all-matches ( string matcher -- seq )
    [ dup ] swap '[ _ next-match ] [ ] produce nip harvest ;

: count-matches ( string matcher -- n )
    all-matches length ;
