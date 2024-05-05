! Copyright (C) 2015 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs assocs.extras calendar
calendar.format checksums checksums.sha combinators
combinators.short-circuit combinators.smart compression.zlib
constructors endian formatting grouping hashtables hex-strings
ini-file io io.directories io.encodings.binary
io.encodings.string io.encodings.utf8 io.files io.files.info
io.pathnames io.streams.byte-array io.streams.peek kernel math
math.bitwise math.parser namespaces random sequences
sequences.extras splitting splitting.monotonic strings ;
IN: git

ERROR: byte-expected offset ;
: read1* ( -- n )
    read1 [ tell-input byte-expected ] unless* ;

ERROR: separator-expected expected-one-of got ;

: read-until* ( separators -- data )
    dup read-until [ nip ] [ separator-expected ] if ;

ERROR: unknown-dot-git path ;

: parse-dot-git-file ( path -- path' )
    dup utf8 file-lines ?first "gitdir: " ?head [
        nip
    ] [
        drop unknown-dot-git
    ] if ;

: find-git-directory ( path -- path'/f )
    [ ".git" tail? ] find-up-to-root
    dup ?file-info regular-file? [ parse-dot-git-file ] when ; inline

: find-base-git-directory ( path -- path'/f )
    find-git-directory dup ".git" tail? [ find-base-git-directory ] unless ;

ERROR: not-a-git-directory path ;

: current-git-directory ( -- path )
    current-directory get find-git-directory [
        current-directory get not-a-git-directory
    ] unless* ;

: current-git-base-directory ( -- path )
    current-git-directory find-base-git-directory ;

: make-git-path ( str -- path )
    current-git-directory prepend-path ;

: make-git-base-path ( str -- path )
    current-git-base-directory prepend-path ;

: get-git-file-contents ( path -- contents )
    make-git-base-path utf8 file-contents ;

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
    make-object-path file-exists? ;

TUPLE: index-entry ctime mtime dev ino mode uid gid size sha1 flags name ;
CONSTRUCTOR: <index-entry> index-entry ( ctime mtime dev ino mode uid gid size sha1 flags name -- obj ) ;

: read-index-entry-v2 ( -- seq )
    4 read be> 4 read be> 2array
    4 read be> 4 read be> 2array
    4 read be> 4 read be> 4 read be>
    4 read be> 4 read be> 4 read be>
    20 read bytes>hex-string
    2 read be> { 0 } read-until drop [ utf8 decode ] [ length ] bi
    7 + 8 mod dup zero? [ 8 swap - ] unless read drop
    <index-entry> ;

TUPLE: git-index magic version entries checksum ;
CONSTRUCTOR: <git-index> git-index ( magic version entries checksum -- obj ) ;

ERROR: unhandled-git-version n ;

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
    [ [ sha1>> ] [ name>> path>git-object bytes>hex-string ] bi = ] reject ;

: changed-index-by-mtime ( -- seq )
    git-index-contents entries>>
    [
        [ mtime>> first ]
        [ name>> file-info modified>> timestamp>unix-time >integer ] bi = not
    ] filter ;

TUPLE: commit hash tree parents author committer gpgsig message ;
CONSTRUCTOR: <commit> commit ( tree parents author committer -- obj ) ;

TUPLE: tree hash tree parents author committer gpgsig message ;
CONSTRUCTOR: <tree> tree ( -- obj ) ;

: gmt-offset>duration ( string -- duration )
    3 cut [ string>number ] bi@
    [ hours ] [ minutes ] bi* time+ ;

: git-date>string ( seq -- string )
    last2
    [ string>number unix-time>timestamp ]
    [ gmt-offset>duration [ time+ ] [ >>gmt-offset ] bi ] bi*
    timestamp>git-string ;

: commit. ( commit -- )
    {
        [ hash>> "commit " prepend print ]
        [ author>> "Author: " prepend split-words 2 head* join-words print ]
        [ author>> split-words git-date>string "Date:   " prepend print ]
        [ message>> split-lines [ "    " prepend ] map join-lines nl print nl ]
    } cleave ;

ERROR: unknown-field name parameter ;

: set-git-object-field ( obj name parameter -- obj )
    swap {
        { "tree" [ >>tree ] }
        { "parent" [ >>parents ] }
        { "author" [ >>author ] }
        { "committer" [ >>committer ] }
        { "gpgsig" [ >>gpgsig ] }
        { "message" [ >>message ] }
        [ unknown-field ]
    } case ; inline

: git-string>assoc ( string -- assoc )
    "\n\n" split1 [
        split-lines [ nip first CHAR: \s = ] monotonic-split
        [
            dup length 1 = [
                first " " split1 2array
            ] [
                [ first " " split1 ]
                [ rest [ rest ] map ] bi
                swap prefix join-lines 2array
            ] if
        ] map
    ] [
        "message" swap 2array
    ] bi* suffix ;

: parse-new-git-object ( string class -- commit )
    new swap git-string>assoc [ first2 set-git-object-field ] each ; inline

ERROR: unknown-git-object obj ;

: parse-object ( bytes -- git-obj )
    utf8 [
        { 0 } read-until 0 = drop dup " " split1 drop {
            { "blob" [ "unimplemented blob parsing" throw ] }
            { "commit" [
                " " split1
                [ "commit" assert= ] [ string>number read ] bi*
                commit parse-new-git-object
            ] }
            { "tree" [ tree parse-new-git-object ] }
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
            dup 0x01 mask? [ [ read1* bitor ] 2dip ] when
            dup 0x02 mask? [ [ read1* 8 shift bitor ] 2dip ] when
            dup 0x04 mask? [ [ read1* 16 shift bitor ] 2dip ] when
            dup 0x08 mask? [ [ read1* 24 shift bitor ] 2dip ] when
            dup 0x10 mask? [ [ read1* bitor ] dip ] when
            dup 0x20 mask? [ [ read1* 8 shift bitor ] dip ] when
            dup 0x40 mask? [ [ read1* 16 shift bitor ] dip ] when
            drop [ 65536 ] when-zero <copy>
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
            { 6 [ read-offset-delta first2 do-deltas parse-object ] }
            ! { 7 [ B read-sha1-delta ] }
            [ number>string "unknown packed type: " prepend throw ]
        } case
    ] with-variable ;

: parse-packed-object ( sha1 offset -- obj )
    [ make-pack-path binary ] dip '[
        input-stream [ <peek-stream> ] change
        _ seek-absolute seek-input read-packed
    ] with-file-reader ;

! https://stackoverflow.com/questions/18010820/git-the-meaning-of-object-size-returned-by-git-verify-pack
TUPLE: pack magic version count objects sha1 ;
: parse-pack ( path -- pack )
    binary [
        input-stream [ <peek-stream> ] change
        4 read >string
        4 read be>
        4 read be> 3array
        [ peek1 ] [ read-packed ] produce 2array
    ] with-file-reader ;

: git-read-idx ( sha -- obj ) make-idx-path parse-idx ;

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

: git-hash? ( str -- ? ) sha1-string? ;

: parse-ref-line ( string -- string' )
    "ref: " ?head [ expected-ref ] unless
    get-git-file-contents ;

: parse-ref ( string -- string' )
    dup git-hash? [ parse-ref-line ] unless ;

: list-refs-for ( path -- seq )
    "refs/" append-path recursive-directory-files ;

: list-refs ( -- seq )
    current-git-base-directory list-refs-for ;

: remote-refs-dirs ( -- seq )
    "remotes" make-refs-path directory-files ;

: ref-contents ( str -- line ) make-refs-path git-line ;
: git-stash-ref-sha1 ( -- contents ) "stash" ref-contents ;
: git-ref ( ref -- sha1 ) git-line parse-ref ;
: git-head-ref ( -- sha1 ) "HEAD" git-ref ;
: git-log-for-ref ( ref -- log ) git-line git-read-object ;
: git-head-object ( -- commit ) git-head-ref git-log-for-ref ;
: git-config ( -- config ) "config" make-git-path ;

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

: filter-git-remotes ( seq -- seq' )
    [ "remote" head? ] filter-keys ;

: github-git-remote? ( hash -- ? )
    "url" of [ CHAR: / = ] trim-tail "git@github.com:" head? ;

: github-https-remote? ( hash -- ? )
    "url" of [ CHAR: / = ] trim-tail "https://github.com/" head? ;

: github-git-remote-matches? ( hash owner repo -- ? )
    [ "url" of [ CHAR: / = ] trim-tail ] 2dip "git@github.com:%s/%s" sprintf = ;

: github-https-remote-matches? ( hash owner repo -- ? )
    [ "url" of [ CHAR: / = ] trim-tail ] 2dip "https://github.com/%s/%s" sprintf = ;

: git-remote? ( hash -- ? )
    { [ github-git-remote? ] [ github-https-remote? ] } 1|| ;

: git-remote-matches? ( hash owner repo -- ? )
    { [ github-git-remote-matches? ] [ github-https-remote-matches? ] } 3|| ;

: git-config-path ( -- path )
    current-directory get find-git-directory "config" append-path ;

: parse-git-config ( -- seq )
    git-config-path utf8 file-contents string>ini >alist ;

: has-any-git-at-urls? ( git-ini -- ? )
    [ github-git-remote? ] any-value? ;

: has-remote-repo? ( git-ini owner repo -- ? )
    '[ _ _ git-remote-matches? ] filter-values f like ;

: write-git-config ( seq -- )
    ini>string git-config-path utf8 set-file-contents ;

: ensure-git-remote ( owner repo -- )
    [ parse-git-config ] 2dip
    3dup has-remote-repo? [
        3drop
    ] [
        [
            pick has-any-git-at-urls? [
                [ "git@github.com:%s/%s" sprintf ]
                [ drop "+refs/heads/*:refs/remotes/%s/*" sprintf ] 2bi
                '{ { "url" _ } { "fetch" _ } } >hashtable
            ] [
                [ "https://github.com/%s/%s" sprintf ]
                [ drop "+refs/heads/*:refs/remotes/%s/*" sprintf ] 2bi
                '{ { "url" _ } { "fetch" _ } } >hashtable
            ] if
        ] 2keep "_" glue "\"" dup surround "remote " prepend swap 2array
        suffix write-git-config
    ] if ;

: ensure-pr-remote ( pr-json -- )
    "head" of "repo" of "full_name" of "/" split first2 ensure-git-remote ;
