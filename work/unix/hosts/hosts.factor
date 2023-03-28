! Copyright (C) 2013 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io io.backend io.encodings.utf8 io.files kernel
locals make math math.parser regexp sequences splitting
splitting.extras tools.continuations ;

IN: unix.hosts

CONSTANT: hostsFile "/etc/hosts"

TUPLE: host ip names access description ;
: <host> ( -- host )   host new ; 

: get-hosts-file ( -- seq )
    hostsFile normalize-path  utf8  file-lines ;

: remove-comment-lines ( lines -- lines )
  [ "#" swap start 0 = not ] filter ;

: remove-blank-lines ( lines -- lines )
  [ R/ ( |\t)+/ matches? not ] filter 
  [ length 0 = not ] filter ;

: to-tsv ( seq -- seq )
  [ "\t" split-harvest ] map ;

: trim-whitespace ( x -- x )
  [ dup 32 =  swap 09 = or ] trim ;

: host-set-ip ( line host -- seq host )
  over first trim-whitespace >>ip ; 

: host-set-names ( line host -- seq host )
  over second trim-whitespace >>names ;

: host-set-access ( line host -- seq host )
  over 3 swap ?nth 
  [ over  3 swap nth ] [ "" ] if 
  trim-whitespace >>access ; 

: host-set-description ( line host -- seq host )
  over 4 swap ?nth 
  [ over  4 swap nth ] [ "" ] if 
  trim-whitespace >>description ;

: line->host ( line -- host )
  <host> host-set-ip  host-set-names
  over 2 swap ?nth [ ! look for #, if found we may have more fields
  host-set-access  host-set-description 
  ] when                    
  nip ;

: make-hosts ( seq -- seq )
  [ line->host ] map ; 

: hosts ( -- hosts )
    get-hosts-file 
    remove-comment-lines
    remove-blank-lines
    to-tsv make-hosts ;

: (.hosts) ( hosts -- )
  [ 
    [  
      dup ip>> % 
      "\t" % dup names>> % 
      "\t" % access>> % 
    ] "" make print 
  ] each ;

: .hosts ( -- )
  hosts (.hosts) ; 

:: lookup-by-name ( name -- hosts )
    hosts [ names>> name swap start ] filter ;

: lookup-by-ip ( octets -- hosts )
    hosts [ ip>> over swap start ] filter  nip ;

:: lookup ( value -- hosts )
  value number? [ value number>string ] [ value ] if
  :> value!  value "." split  :> octets
  octets first string>number [ t ] [ f ] if  
  [ value lookup-by-ip ] [ value lookup-by-name ] if  
;

