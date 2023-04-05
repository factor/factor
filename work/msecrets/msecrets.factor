! File: msecrets.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Convert Secrets xml file to csv for importing into new password manager
! Copyright (C) 2019 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors csv formatting.private io kernel locals
combinators math.order math.parser namespaces prettyprint regexp sequences
json json.reader json.writer vectors variables assocs math fry io.encodings.utf8 sets sorting urls xml xml.data xml.traversal ;
IN: secrets

SYMBOL: xmldata

FROM: namespaces => set ;
: readfile ( -- xml )
    xmldata get
    [ "/Users/davec/Documents/Secrets-2:24:19.xml" file>xml
      xmldata set
    ] unless
    xmldata get
    ;

: reread ( -- )
    f xmldata set
    readfile drop ;

: credential-tags ( tags -- 'tags )
    [ children-tags
        [ name>> main>> { "identifier" "name" "secrets" "services" } in? ] filter
        [ dup name>> main>> "secrets" = [ "secretValue" deep-tag-named  ] [  ] if  ] { } map-as
        [ dup name>> main>> "services" = [ "address" deep-tag-named  ] [  ] if  ] { } map-as
    ] map
    ;

: credentials ( -- xml )
    readfile  
    "credentials" tag-named
    children-tags 
    credential-tags
    ;

:: reorder-credentials ( tags -- newtags )
    { } :> newtags!
    tags [ name>> main>> "name" = ] find
    dup [ ] [ drop "name" f V{ "" } <tag> ] if
    newtags swap suffix newtags! drop
    tags [ name>> main>> "notes" = ] find
    dup [ ] [ drop "notes" f V{ "" } <tag> ] if
    newtags swap suffix newtags! drop
    tags [ name>> main>> "address" = ] find
    dup [ ] [ drop "address" f V{ "" } <tag> ] if
    newtags swap suffix newtags! drop
    tags [ name>> main>> "identifier" = ] find
    dup [ ] [ drop "identifier" f V{ "" } <tag> ] if
    newtags swap suffix newtags! drop
    tags [ name>> main>> "secretValue" = ] find
    dup [ ] [ drop "secretValue" f V{ "" } <tag> ] if
    newtags swap suffix newtags! drop
    newtags 
    ;

: card-tags ( tags -- 'tags )
    [ children-tags
        [ name>> main>> { "name" "pan" "expirationDate" "securityCode" "cardholder" } in? ] filter
    ] map
    ;

: cards ( -- xml )
    readfile
    "creditCards" tag-named
    children-tags
    card-tags
    ;

: card-tags. ( -- )
    cards first  children-tags
    [ name>> main>> ] map
    printx ;

: find-tag ( tags name -- tag name )
    [ '[ name>> main>> _ = ] find ] keep
    [ drop ] 2dip 
    ; 

SYMBOL: newtags 
: ?istag ( tags tag name -- tags )
    over
    [ drop suffix ]
    [ nip  f V{ "" } <tag>  suffix ]
    if ;

: assemble-url ( protocol host port -- string )
    dup
    [ number>string
      ":" prepend
      append
    ] [ drop ] if
    "://" prepend
    append ; 
    
: mapifurl ( string -- 'string )
    dup >url
    dup protocol>> boolean? not [ 
        [ protocol>> ] keep
        [ host>> ] keep
        port>> assemble-url 
        nip
    ] [ drop ]
    if
    ;

: mapout-parens ( string -- 'string )
    R/ \(.*\)/ "" re-replace ; 

: run-credentials ( -- x )
    { }
    credentials
    [ reorder-credentials
      { "Personal" "Login" } swap
      [ children>>
        [ suffix ] each
      ] each
      suffix
    ] each
    [ [ third ] dip  third <=> ] sort
    [ third R/ [1-9][0-9][0-9].*/ matches? not ] filter
    [ third R/ 10.*/ matches? not ] filter
    [ third R/ 66.*/ matches? not ] filter
    [ [ mapifurl ] map
      [ mapout-parens ] map
    ] map
    ;

: save-credentials ( -- )
    run-credentials "~/Desktop/credentials.csv" utf8 csv>file ;

: reorder-cards ( tags -- newtags )
! Personal,Credit Card,CARD,,111111111111,,1234,Name O Card,4321,Bank,(888) 888-8888,30159 Old Mill Road,
    { }
    over "name" find-tag  ?istag 
    over "dummy" find-tag  ?istag 
    over "pan" find-tag  ?istag 
    over "dummy" find-tag  ?istag 
    over "securityCode" find-tag  ?istag   
    over "cardholder" find-tag  ?istag   
    over "pin" find-tag  ?istag   
    over "expirationDate" find-tag  ?istag   
    over "bank" find-tag  ?istag   
    over "phone" find-tag  ?istag   
    over "billing" find-tag  ?istag   
    nip ;

: run-cards ( -- x )
    { }
    cards
    [ reorder-cards
      { "Personal" "Credit Card" } swap
      [ children>>
        [ suffix ] each
      ] each
      suffix
    ] each
;

: save-cards ( -- )
    run-cards "~/Desktop/cards.csv" utf8 csv>file ;

: account-tags ( tags -- 'tags )
    [ children-tags
      [ name>> main>> { "bankName" "number" "accountHolder" "notes" } in? ] filter
    ] map
    ;

: reorder-accounts ( tags -- newtags )
    { }
    over "bankName" find-tag  ?istag 
    over "number" find-tag  ?istag 
    over "dummy" find-tag  ?istag 
    over "accountHolder" find-tag  ?istag 
    over "dummy" find-tag  ?istag 
    over "dummy" find-tag  ?istag 
    over "dummy" find-tag  ?istag 
    over "notes" find-tag  ?istag 
    nip ;

: accounts ( -- xml )
    readfile
    "bankAccounts" tag-named
    children-tags
    account-tags
    ;

: account-tags. ( -- )
    readfile
    "bankAccount" deep-tags-named
    first
    children-tags
    [ name>> main>> ] map
    printx ;

: run-accounts ( -- x )
    { }
    accounts
    [ reorder-accounts
      { "Personal" "Bank Account" } swap
      [ children>>
        [ suffix ] each
      ] each
      suffix
    ] each
;

: save-accounts ( -- )
    run-accounts "~/Desktop/accounts.csv" utf8 csv>file ;

! SOFTWARE LICENSE
! <softwareLicense>
! 	<creationDate>2019-02-24T12:51:02.814Z</creationDate>
! 	<key>XUXN-WFSR-CQFP</key>
! 	<modificationDate>2019-02-24T12:51:02.814Z</modificationDate>
! 	<name>Instaread</name>
! 	<notes></notes>
! 	<purchaseDate>2018-12-06T12:51:02.833Z</purchaseDate>
! 	<trashed>0</trashed>
! 	<uuid>3CCAFCD0-5E7B-4654-8537-842BF1CD4E68</uuid>
! 	<website>macheist</website>
! </softwareLicense>
! Personal,Software License,SOFTWARE LICENSE,NOTES,KEY,TO,EMAIL,COMPANY,DOWNLOAD,WEBSITE,PRICE,SUPPORT EMAIL,01/01/2011,ORDER NUMBER,

: softwares-tags ( tags -- 'tags )
    [ children-tags
      [ name>> main>> { "creationDate" "key" "name" "notes" "purchaseDate" "website" } in? ] filter
    ] map
    ;

: reorder-softwares ( tags -- newtags )
    { }
    over "name" find-tag  ?istag 
    over "notes" find-tag  ?istag 
    over "key" find-tag  ?istag 
    over "dummy" find-tag  ?istag 
    over "dummy" find-tag  ?istag 
    over "dummy" find-tag  ?istag 
    over "dummy" find-tag  ?istag 
    over "website" find-tag  ?istag 
    over "dummy" find-tag  ?istag 
    over "dummy" find-tag  ?istag 
    over "dummy" find-tag  ?istag 
    over "purchaseDate" find-tag  ?istag 
    over "dummy" find-tag  ?istag 
    nip ;

: softwares ( -- xml )
    readfile
    "softwareLicenses" tag-named
    children-tags
    softwares-tags
    ;

: softwares-tags. ( -- )
    readfile
    "softwareLicenses" tag-named
    children-tags first
    children-tags
    [ name>> main>> ] map
    printx ;

: collect-by-nth ( seq n -- assoc )
    '[ _ swap nth ] collect-by ;

: has-dups? ( values -- values ? )
    dup length 2 >= ; ! More than 1? 

: only-first ( seq -- 'seq )
    first V{ } 1sequence ; ! take only the first 

: special-key? ( key -- ? )
    { "" "\t" "\t\t" } in? ;

SYMBOL: splices

: do-null-case ( key values -- key values )
    2 collect-by-nth
    [ has-dups? [ only-first ] when ] assoc-map
    values
    ;

: do-special-case ( key values -- key values )
    do-null-case 
    ;

: do-special ( key values -- key 'values )
    over {
        { "" [ do-null-case ] }
        { "\t" [ do-special-case ] }
        { "\t\t" [ do-special-case ] }
    } case
    dup splices get  swap append  splices set 
    ;

: prune-dups ( key values -- key values )
    over special-key? [ do-special ] when
    has-dups? [ only-first ] when
    ;

: run-softwares ( -- x )
    { } splices set
    { }
    softwares
    [ reorder-softwares
      { "Personal" "Software License" } swap
      [ children>>
        [ suffix ] each
      ] each
      suffix
    ] each
    ! Lots of dups so…
    4 collect-by-nth ! Create keys
    [ prune-dups ] assoc-map  values
    splices get  append 
    [ first
      dup vector? [ first ] when
      { } swap  [ suffix ] each ] map
;

: save-softwares ( -- )
    run-softwares "~/Desktop/softwares.csv" utf8 csv>file ;

! NOTES

! <note>
! <creationDate>2016-11-06T19:32:13.000Z</creationDate>
! <modificationDate>2016-11-06T19:32:13.000Z</modificationDate>
! <text> Number: 616-78-2496
! Number: 616-78-2496
! </text>
! <title>Tazia Social Security Number</title>
! <trashed>0</trashed>
! <uuid>64CFA8D0-C20E-4D2B-93B3-7F2D177B1009</uuid>
! </note>

: 1pif-file ( -- json )
    "/Users/davec/Documents/1password.1pif/data.1pif" path>json
    ;

: 1pif-dedup ( json -- json )
    [ "contentsHash" swap at ] collect-by
    [ dup length 1 > [ first 1vector ] when ] assoc-map
    values  [ first ] V{ } map-as
    { } swap  [ suffix "***5642bee8-a5ff-11dc-8314-0800200c9a66***" suffix ] each
    ;

: json>file ( path json -- )
    swap utf8 set-file-lines ;

