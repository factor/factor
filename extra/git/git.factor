! Copyright (C) 2015 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs assocs.extras calendar
calendar.format checksums checksums.sha combinators
combinators.smart compression.zlib constructors fry grouping io
io.binary io.directories io.directories.search
io.encodings.binary io.encodings.string io.encodings.utf8
io.files io.files.info io.pathnames io.streams.byte-array
io.streams.peek kernel math math.bitwise math.parser
math.statistics memoize namespaces random sequences
sequences.extras splitting strings ;
IN: git

ERROR: byte-expected offset ;
: read1* ( -- n )
    read1 [ tell-input byte-expected ] unless* ;

ERROR: separator-expected expected-one-of got ;

: read-until* ( separators -- data )
    dup read-until [ nip ] [ separator-expected ] if ;

: find-git-directory ( path -- path' )
    [ ".git" tail? ] find-up-to-root ; inline

ERROR: not-a-git-directory path ;

: current-git-directory ( -- path )
    current-directory get find-git-directory [
        current-directory get not-a-git-directory
    ] unless* ;

: make-git-path ( str -- path )
    current-git-directory prepend-path ;

: make-refs-path ( str -- path )
    [ "refs/" make-git-path ] dip append-path ;

: make-object-path ( str -- path )
    [ "objects/" make-git-path ] dip 2 cut append-path append-path ;

: make-idx-path ( sha -- path )
    "objects/pack/pack-" ".idx" surround make-git-path ;

: make-pack-path ( sha -- path )
    "objects/pack/pack-" ".pack" surround make-git-path ;

: git-binary-contents ( str -- contents )
    make-git-path binary file-contents ;

: git-utf8-contents ( str -- contents )
    make-git-path utf8 file-contents ;

: git-lines ( str -- contents )
    make-git-path utf8 file-lines ;

ERROR: expected-one-line lines ;

: git-line ( str -- contents )
    git-lines dup length 1 =
    [ first ] [ expected-one-line ] if ;

: git-unpacked-object-exists? ( hash -- ? )
    make-object-path exists? ;

TUPLE: index-entry ctime mtime dev ino mode uid gid size sha1 flags name ;
CONSTRUCTOR: <index-entry> index-entry ( ctime mtime dev ino mode uid gid size sha1 flags name -- obj ) ;

: read-index-entry-v2 ( -- seq )
    4 read be> 4 read be> 2array
    4 read be> 4 read be> 2array
    4 read be>
    4 read be>
    4 read be>
    4 read be>
    4 read be>
    4 read be>
    20 read bytes>hex-string
    2 read be> { 0 } read-until drop [ utf8 decode ] [ length ] bi
    7 + 8 mod dup zero? [ 8 swap - ] unless read drop
    <index-entry> ;

TUPLE: git-index magic version entries checksum ;
CONSTRUCTOR: <git-index> git-index ( magic version entries checksum -- obj ) ;

ERROR: unhandled-git-version n ;
ERROR: unhandled-git-index-trailing-bytes bytes ;

: git-index-contents ( -- git-index )
    "index" make-git-path binary [
        4 read utf8 decode
        4 read be>
        4 read be> over {
            { 2 [ [ read-index-entry-v2 ] replicate ] }
            [ unhandled-git-version ]
        } case
        20 read bytes>hex-string
        <git-index>
    ] with-file-reader ;

: make-git-object ( str -- obj )
    [
        [ "blob " ] dip [ length number>string "\0" ] [ ] bi
    ] B{ } append-outputs-as ;

: path>git-object ( path -- bytes )
    binary file-contents make-git-object sha1 checksum-bytes ;

: git-hash-object ( str -- hash )
    make-git-object sha1 checksum-bytes ;

: changed-index-by-sha1 ( -- seq )
    git-index-contents entries>>
    [ [ sha1>> ] [ name>> path>git-object bytes>hex-string ] bi = not ] filter ;

: changed-index-by-mtime ( -- seq )
    git-index-contents entries>>
    [
        [ mtime>> first ]
        [ name>> file-info modified>> timestamp>unix-time >integer ] bi = not
    ] filter ;

TUPLE: commit hash tree parents author committer message ;
CONSTRUCTOR: <commit> commit ( tree parents author committer -- obj ) ;

TUPLE: tree hash tree parents author committer message ;
CONSTRUCTOR: <tree> tree ( -- obj ) ;

: last2 ( seq -- penultimate ultimate ) 2 tail* first2 ;

: gmt-offset>duration ( string -- duration )
    3 cut [ string>number ] bi@
    [ hours ] [ minutes ] bi* time+ ;

: date>string ( seq -- string )
    last2
    [ string>number unix-time>timestamp ]
    [ gmt-offset>duration [ time+ ] [ >>gmt-offset ] bi ] bi*
    timestamp>git-time ;

: commit. ( commit -- )
    {
        [ hash>> "commit " prepend print ]
        [ author>> "Author: " prepend " " split 2 head* " " join print ]
        [ author>> " " split date>string "Date:   " prepend print ]
        [ message>> "\n" split [ "    " prepend ] map "\n" join nl print nl ]
    } cleave ;

ERROR: unknown-commit-line line name ;

ERROR: eof-too-early ;
ERROR: unknown-field field ;

: parse-commit-field ( obj parameter -- obj )
    [ "\r\n" read-until [ eof-too-early ] unless ] dip {
        { "tree" [ >>tree ] }
        { "parent" [ >>parents ] }
        { "author" [ >>author ] }
        { "committer" [ >>committer ] }
        [ unknown-field ]
    } case ;

ERROR: unexpected-text text ;

: parse-commit-lines ( obj -- obj )
    " \n" read-until {
        { CHAR: \s [ parse-commit-field parse-commit-lines ] }
        { CHAR: \n [ drop contents >>message ] }
        [ unexpected-text ]
    } case ;

: parse-commit ( bytes -- commit )
    " " split1 [ "commit" assert= ] [ string>number read ] bi*
    utf8 [
        commit new parse-commit-lines
    ] with-byte-reader ;

: parse-tree-field ( obj parameter -- obj )
    [ "\r\n" read-until* ] dip {
        { "tree" [ >>tree ] }
        { "parent" [ >>parents ] }
        { "author" [ >>author ] }
        { "committer" [ >>committer ] }
        [ unknown-field ]
    } case ;

: parse-tree-lines ( obj -- obj )
    "\s\n" read-until {
        { CHAR: \s [ parse-tree-field parse-tree-lines ] }
        { CHAR: \n [ drop contents >>message ] }
        [ unexpected-text ]
    } case ;


ERROR: key-already-set value key assoc ;
: set-at-once ( value key assoc -- )
    2dup key? [ key-already-set ] [ set-at ] if ;

: parse-object-line>assoc ( hashtable -- hashtable )
    "\s\n" read-until {
        { CHAR: \s [ [ "\r\n" read-until* ] dip pick over "parent" = [ push-at ] [ set-at-once ] if parse-object-line>assoc ] }
        { CHAR: \n [ drop contents "message" pick set-at ] }
    } case ;

: assoc>commit ( assoc -- commit )
    [ commit new ] dip {
        [ "tree" of >>tree ]
        [ "parent" of >>parents ]
        [ "author" of >>author ]
        [ "committer" of >>committer ]
        [ "message" of >>message ]
    } cleave ;

ERROR: unknown-git-object obj ;
: assoc>git-object ( assoc -- git-object )
    {
        { [ "committer" over key? ] [ assoc>commit ] }
        [ unknown-git-object ]
    } cond ;

: parse-object-bytes>assoc ( obj -- hashtable )
    utf8 [
        H{ } clone parse-object-line>assoc assoc>git-object
    ] with-byte-reader ;


: parse-tree ( bytes -- commit )
    [ tree new ] dip
    utf8 [
        parse-tree-lines
    ] with-byte-reader ;

: parse-object ( bytes -- git-obj )
    utf8 [
        { 0 } read-until 0 = drop dup " " split1 drop {
            { "blob" [ "unimplemented blob parsing" throw ] }
            { "commit" [ parse-commit ] }
            { "tree" [ parse-tree ] }
            [ unknown-git-object ]
        } case
    ] with-byte-reader ;

ERROR: idx-v1-unsupported ;

TUPLE: idx version table triples packfile-sha1 idx-sha1 ;
CONSTRUCTOR: <idx> idx ( version table triples packfile-sha1 idx-sha1 -- obj ) ;
! sha1, crc32, offset

: parse-idx-v2 ( -- idx )
    4 read be>
    256 4 * read 4 group [ be> ] map
    dup last
    [ [ 20 read bytes>hex-string ] replicate ]
    [ [ 4 read ] replicate ]
    [ [ 4 read be> ] replicate ] tri 3array flip
    20 read bytes>hex-string
    20 read bytes>hex-string <idx> ;

: parse-idx ( path -- idx )
    binary [
        4 read be> {
            { 0xff744f63 [ parse-idx-v2 ] }
            [ idx-v1-unsupported ]
        } case
    ] with-file-reader ;

SYMBOL: #bits

: read-type-length ( -- pair )
    0 #bits [
        read1*
        [ -4 shift 3 bits ] [ 4 bits ] [ ] tri
        0x80 mask? [
            #bits [ 4 + ] change
            [
                read1* [
                    7 bits #bits get shift bitor
                    #bits [ 7 + ] change
                ] [ 0x80 mask? ] bi
            ] loop
        ] when 2array
    ] with-variable ;

: read-be-length ( -- length )
    read1* dup 0x80 mask? [
        7 bits [
            read1*
            [ [ 1 + 7 shift ] [ 7 bits ] bi* bitor ]
            [ 0x80 mask? ] bi
        ] loop
    ] when ;

: read-le-length ( -- length )
    read1* dup 0x80 mask? [
        7 bits [
            read1*
            [ 7 bits 7 shift bitor ]
            [ 0x80 mask? ] bi
        ] loop
    ] when ;

DEFER: git-object-from-pack

TUPLE: insert bytes ;
CONSTRUCTOR: <insert> insert ( bytes -- insert ) ;
TUPLE: copy offset size ;
CONSTRUCTOR: <copy> copy ( offset size -- copy ) ;

: parse-delta ( -- delta/f )
    read1 [
        dup 0x80 mask? not [
            7 bits read <insert>
        ] [
            [ 0 0 ] dip

            dup 0x01 mask? [
                [ read1* bitor ] 2dip
            ] when

            dup 0x02 mask? [
                [ read1* 8 shift bitor ] 2dip
            ] when

            dup 0x04 mask? [
                [ read1* 16 shift bitor ] 2dip
            ] when

            dup 0x08 mask? [
                [ read1* 24 shift bitor ] 2dip
            ] when

            dup 0x10 mask? [
                [ read1* bitor ] dip
            ] when

            dup 0x20 mask? [
                [ read1* 8 shift bitor ] dip
            ] when

            dup 0x40 mask? [
                [ read1* 16 shift bitor ] dip
            ] when

            drop [ 65536 ] when-zero
            <copy>
        ] if
    ] [
        f
    ] if* ;

: parse-deltas ( bytes -- deltas )
    binary [
        read-le-length
        read-le-length
        [ parse-delta ] loop>array 3array
    ] with-byte-reader ;

ERROR: unknown-delta-operation op ;

: apply-delta ( delta -- )
    {
        { [ dup insert? ] [ bytes>> write ] }
        { [ dup copy? ] [ [ offset>> seek-absolute seek-input ] [ size>> read write ] bi ] }
        [ unknown-delta-operation ]
    } cond ;

: do-deltas ( bytes delta-bytes -- bytes' )
    [ binary ] 2dip '[
        _ binary [
            _ parse-deltas third [ apply-delta ] each
        ] with-byte-reader
    ] with-byte-writer ;


ERROR: unsupported-packed-raw-type type ;

: read-packed-raw ( -- string )
    read-type-length first2 swap {
        { 1 [ 256 + read uncompress ] }
        [ unsupported-packed-raw-type ]
    } case ;

SYMBOL: initial-offset

: read-offset-delta ( size -- obj )
    [ read-be-length neg initial-offset get + ] dip 256 + read uncompress
    [ seek-absolute seek-input read-packed-raw ] dip 2array ;

: read-sha1-delta ( size -- obj )
    [ 20 read bytes>hex-string git-object-from-pack ] dip read uncompress 2array ;

! XXX: actual length is stored in the gzip header
! We add 256 instead of using it for now.
: read-packed ( -- obj/f )
    tell-input initial-offset [
        read-type-length first2 swap {
            { 1 [ 256 + read uncompress parse-object ] }
            { 6 [ read-offset-delta first2 do-deltas parse-object-bytes>assoc ] }
            ! { 7 [ B read-sha1-delta ] }
            [ number>string "unknown packed type: " prepend throw ]
        } case
    ] with-variable ;

: parse-packed-object ( sha1 offset -- obj )
    [ make-pack-path binary ] dip '[
        input-stream [ <peek-stream> ] change
        _ seek-absolute seek-input read-packed
    ] with-file-reader ;

! http://stackoverflow.com/questions/18010820/git-the-meaning-of-object-size-returned-by-git-verify-pack
TUPLE: pack magic version count objects sha1 ;
: parse-pack ( path -- pack )
    binary [
        input-stream [ <peek-stream> ] change
        4 read >string
        4 read be>
        4 read be> 3array
        [ peek1 ] [ read-packed ] produce 2array
    ] with-file-reader ;

: git-read-idx ( sha -- obj )
    make-idx-path parse-idx ;

! Broken for now
! : git-read-pack ( sha -- obj ) make-pack-path parse-pack ;

: parsed-idx>hash ( seq -- hash )
    H{ } clone [
        '[
            [ packfile-sha1>> ]
            [ triples>> ] bi
            [ first3 rot [ 3array ] dip _ set-at ] with each
        ] each
    ] keep ;

MEMO: git-parse-all-idx ( -- seq )
    "objects/pack/" make-git-path qualified-directory-files
    [ ".idx" tail? ] filter
    [ parse-idx ] map
    parsed-idx>hash ;

ERROR: no-pack-for sha1 ;

: find-pack-for ( sha1 -- triple )
    git-parse-all-idx ?at [ no-pack-for ] unless ;

: git-object-from-pack ( sha1 -- pack )
    [ find-pack-for [ first ] [ third ] bi parse-packed-object ] keep >>hash ;

: git-object-contents ( hash -- contents )
    make-object-path binary file-contents uncompress ;

: git-read-object ( sha -- obj )
    dup git-unpacked-object-exists? [
        [ git-object-contents parse-object ] keep >>hash
    ] [
        git-object-from-pack
    ] if ;

! !: git-object-contents ( hash -- contents )
    ! make-object-path ! binary file-contents uncompress ;
    ! [ git-read-object ] [ git-object-from-pack ] if ;

: parsed-idx>hash2 ( seq -- hash )
    [
        [ triples>> [ [ drop f ] [ first ] bi ] [ set-at ] sequence>hashtable ]
        [ packfile-sha1>> ] bi
    ] [ set-at ] sequence>hashtable ; inline

ERROR: expected-ref got ;

: parse-ref-line ( string -- string' )
    " " split1 [
        dup "ref:" = [ drop ] [ expected-ref ] if
    ] dip ;

: list-refs ( -- seq )
    current-git-directory "refs/" append-path recursive-directory-files ;

: remote-refs-dirs ( -- seq )
    "remotes" make-refs-path directory-files ;

: ref-contents ( str -- line ) make-refs-path git-line ;
: git-stash-ref-sha1 ( -- contents ) "stash" ref-contents ;
: git-ref ( ref -- sha1 ) git-line parse-ref-line ;
: git-head-ref ( -- sha1 ) "HEAD" git-ref ;
: git-log-for-ref ( ref -- log ) git-line git-read-object ;
: git-head-object ( -- commit ) git-head-ref git-log-for-ref ;
: git-config ( -- config )
    "config" make-git-path ;


SYMBOL: parents
ERROR: repeated-parent-hash hash ;

: git-log ( -- log )
    H{ } clone parents [
        git-head-object [
            parents>> dup string? [ random ] unless [
                dup git-unpacked-object-exists?
                [ git-read-object ] [ git-object-from-pack ] if
            ] [ f ] if*
        ] follow
    ] with-variable ;
