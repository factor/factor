! File: hosts.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2014 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors hash-sets ip-parser kernel locals make math
math.order math.parser namespaces regexp sequences sequences.strings
sets sorting splitting strings ;

IN: tools.dns.hosts

TUPLE: dns-record name domain type ip active? ;
C: <dns-record> dns-record

:: <dns> ( fqdns t address -- dns-record )
    fqdns "." split  dup length 2-  cut
    "." join :> domain
    "." join :> host
    host domain t address f dns-record boa
    ;

: <ptr> ( ptr -- dnsrecord )
    dup ".r.ptr" append  t rot  <dns>
    ;

: name+domain ( name domain -- fqdn )
    swap "." append
    swap append
    ;

: fqdn ( record -- fqdn )  [ name>> ] keep  domain>>  name+domain ;

SYMBOL: origin
SYMBOL: lastname
SYMBOL: lastname-seq
CONSTANT: dnsTypes { "A" "AAAA" }

M:: dns-record equal? ( obj1 obj2 -- ? )
    obj1 obj2 2dup
    [ name>> ] bi@ =
    [ [ ip>> ] bi@  = ] dip
    or
    ;

M: dns-record hashcode*   name>> hashcode* ;

M: dns-record ?adjoin
    2dup swap name>>  in? [ 2drop f ] [ adjoin t ] if ;
    
FROM: namespaces => set ;
: has-A ( s -- )
    dup length 1 >
    [
        "A" over second =
        [ first lastname set
          1 lastname-seq set
        ]
        [ drop ] if
    ]
    [  drop ] if
    ;
    
: has-soa ( s -- )
    dup length 2 > 
    [
        "SOA" over third =
        [ first chop origin set ]
        [ has-A ] if
    ] [ drop ] if ;

: has-origin ( s -- )
    dup length 1 >
    [
        "$ORIGIN" over first =
        [ second chop origin set ]
        [ has-soa ] if
    ]
    [  drop ] if
    ;

:: (prepend-type) ( lineseq type -- lineseq )
    origin get  type  lineseq last  { } 3sequence ;  

:: is-new-name ( lineseq newname -- lineseq )
    newname  lineseq first  lineseq last  { } 3sequence ;

:: (has-no-name) ( lineseq -- line-seq )
    lineseq first :> type
    type  dnsTypes member?
    [ lineseq type (prepend-type) ]
    [ lineseq ]
    if
    ;

:: has-no-name ( lineseq -- lineseq )
    lineseq length 2 =
    [ lineseq  first "A" =
      [ lineseq  lastname get
        lastname-seq get 0 >
        [ lastname-seq get number>string append ] when
        lastname-seq get 1+ lastname-seq set 
        is-new-name ]
      [ lineseq ]
      if
    ]
    [ lineseq ]
    if
    (has-no-name)
    ;

:: (append) ( lineseq -- lineseq )
    lineseq first
    "." append
    origin get append
    lineseq  second
    lineseq third
    { } 3sequence
    ;

:: append-origin ( lineseq -- s )
    lineseq length 1 >
    [
        lineseq second :> type
        type dnsTypes member?
        [ lineseq (append) ]
        [ lineseq ]
        if
    ]
    [ lineseq ]
    if
  ;

: prepend-origin ( records -- seq )
    "NONE" origin set
    { } swap
    [ " " split
      dup has-origin
      has-no-name
      append-origin
      " " join  suffix
    ] each
    ;

: sort-by-ip ( records -- records )   [ ip>> ipv4-aton  swap  ip>> ipv4-aton  >=<  ] sort ;
: sort-by-name ( records -- records )   [ name>>  swap  name>>  >=<  ] sort ;

M:: dns-record members ( records -- seq )
    V{ } :> collection!
    V{ } :> uniques!
B    records [ :> item
        item ip>> :> ip
        ip uniques member?
          [ uniques ip suffix! uniques!
            collection item suffix! collection!
          ] unless
    ] each
    collection
    ;

: strip-TTL-lines ( seq -- seq )   R/ ^\$TTL.*/ remove-regexp ;
: strip-host-comment-lines ( seq -- seq )   R/ ^;.*/ remove-regexp ;

: A-records ( records -- records )
    [ type>> "A" = ] filter ;

: AAAA-records ( records -- records )
    [ type>> "AAAA" = ] filter ;

:: within-cidr? ( ip cidr -- ? )
    cidr "/" split
    dup  first ipv4-aton :> start 
    last string>number  1 32 rot -  shift  start +  :> last
    ip ipv4-aton start last between?
    ;

:: cidr-range ( cidr -- seq )
    cidr "/" split
    dup  first ipv4-aton :> start
    last string>number  32 swap -
    1 swap shift  iota
    [ start +  ipv4-ntoa ] map
    ;
    
:: networks-only ( records networks -- seq )
    records [ 
        f :> result!
        ip>> 
        networks [
            over swap  within-cidr?  result or  result!
        ] each
        drop
        result           
    ] filter
    ;



