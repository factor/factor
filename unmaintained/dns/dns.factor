
USING: kernel byte-arrays combinators strings arrays sequences splitting
       grouping
       math math.functions math.parser random
       destructors
       io io.binary io.sockets io.encodings.binary
       accessors
       combinators.smart
       newfx
       ;

IN: dns

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: query name type class ;

TUPLE: rr name type class ttl rdata ;

TUPLE: hinfo cpu os ;

TUPLE: mx preference exchange ;

TUPLE: soa mname rname serial refresh retry expire minimum ;

TUPLE: message
       id qr opcode aa tc rd ra z rcode
       question-section
       answer-section
       authority-section
       additional-section ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: random-id ( -- id ) 2 16 ^ random ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! TYPE
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOLS: A NS MD MF CNAME SOA MB MG MR NULL WKS PTR HINFO MINFO MX TXT AAAA ;

: type-table ( -- table )
  {
    { A     1 }
    { NS    2 }
    { MD    3 }
    { MF    4 }
    { CNAME 5 }
    { SOA   6 }
    { MB    7 }
    { MG    8 }
    { MR    9 }
    { NULL  10 }
    { WKS   11 }
    { PTR   12 }
    { HINFO 13 }
    { MINFO 14 }
    { MX    15 }
    { TXT   16 }
    { AAAA  28 }
  } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! CLASS
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOLS: IN CS CH HS ;

: class-table ( -- table )
  {
    { IN 1 }
    { CS 2 }
    { CH 3 }
    { HS 4 }
  } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! OPCODE
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOLS: QUERY IQUERY STATUS ;

: opcode-table ( -- table )
  {
    { QUERY  0 }
    { IQUERY 1 }
    { STATUS 2 }
  } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! RCODE
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOLS: NO-ERROR FORMAT-ERROR SERVER-FAILURE NAME-ERROR NOT-IMPLEMENTED
         REFUSED ;

: rcode-table ( -- table )
  {
    { NO-ERROR        0 }
    { FORMAT-ERROR    1 }
    { SERVER-FAILURE  2 }
    { NAME-ERROR      3 }
    { NOT-IMPLEMENTED 4 }
    { REFUSED         5 }
  } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: <message> ( -- message )
  message new
    random-id >>id
    0         >>qr
    QUERY     >>opcode
    0         >>aa
    0         >>tc
    1         >>rd
    0         >>ra
    0         >>z
    NO-ERROR  >>rcode
    { }       >>question-section
    { }       >>answer-section
    { }       >>authority-section
    { }       >>additional-section ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: ip->ba ( ip -- ba ) "." split [ string>number ] map >byte-array ;

: ipv6->ba ( ip -- ba ) ":" split [ 16 base> ] map [ 2 >be ] map concat ;

: label->ba ( label -- ba ) [ >byte-array ] [ length ] bi prefix ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: uint8->ba  ( n -- ba ) 1 >be ;
: uint16->ba ( n -- ba ) 2 >be ;
: uint32->ba ( n -- ba ) 4 >be ;
: uint64->ba ( n -- ba ) 8 >be ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: dn->ba ( dn -- ba ) "." split [ label->ba ] map concat ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: query->ba ( query -- ba )
  [
    {
      [ name>>                 dn->ba ]
      [ type>>  type-table  of uint16->ba ]
      [ class>> class-table of uint16->ba ]
    } cleave
  ] output>array concat ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: hinfo->ba ( rdata -- ba )
    [ cpu>> label->ba ]
    [ os>>  label->ba ]
  bi append ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: mx->ba ( rdata -- ba )
    [ preference>> uint16->ba ]
    [ exchange>>   dn->ba ]
  bi append ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: soa->ba ( rdata -- ba )
  [
    {
      [ mname>>   dn->ba ]
      [ rname>>   dn->ba ]
      [ serial>>  uint32->ba ]
      [ refresh>> uint32->ba ]
      [ retry>>   uint32->ba ]
      [ expire>>  uint32->ba ]
      [ minimum>> uint32->ba ]
    } cleave
  ] output>array concat ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: rdata->ba ( type rdata -- ba )
  swap
    {
      { CNAME [ dn->ba ] }
      { HINFO [ hinfo->ba ] }
      { MX    [ mx->ba ] }
      { NS    [ dn->ba ] }
      { PTR   [ dn->ba ] }
      { SOA   [ soa->ba ] }
      { A     [ ip->ba ] }
    }
  case ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: rr->ba ( rr -- ba )
  [
    {
      [ name>>                 dn->ba     ]
      [ type>>  type-table  of uint16->ba ]
      [ class>> class-table of uint16->ba ]
      [ ttl>>   uint32->ba ]
      [
        [ type>>            ] [ rdata>> ] bi rdata->ba
        [ length uint16->ba ] [         ] bi append
      ]
    } cleave
  ] output>array concat ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: header-bits-ba ( message -- ba )
  [
    {
      [ qr>>                     15 shift ]
      [ opcode>> opcode-table of 11 shift ]
      [ aa>>                     10 shift ]
      [ tc>>                      9 shift ]
      [ rd>>                      8 shift ]
      [ ra>>                      7 shift ]
      [ z>>                       4 shift ]
      [ rcode>>  rcode-table of   0 shift ]
    } cleave
  ] sum-outputs uint16->ba ;

: message->ba ( message -- ba )
  [
    {
      [ id>> uint16->ba ]
      [ header-bits-ba ]
      [ question-section>>   length uint16->ba ]
      [ answer-section>>     length uint16->ba ]
      [ authority-section>>  length uint16->ba ]
      [ additional-section>> length uint16->ba ]
      [ question-section>>   [ query->ba ] map concat ]
      [ answer-section>>     [ rr->ba    ] map concat ]
      [ authority-section>>  [ rr->ba    ] map concat ]
      [ additional-section>> [ rr->ba    ] map concat ]
    } cleave
  ] output>array concat ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: get-single ( ba i -- n ) at ;
: get-double ( ba i -- n ) dup 2 + subseq be> ;
: get-quad   ( ba i -- n ) dup 4 + subseq be> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: label-length ( ba i -- length ) get-single ;

: skip-label ( ba i -- ba i ) 2dup label-length + 1 + ;

: null-label? ( ba i -- ? ) get-single 0 = ;

: get-label ( ba i -- label ) [ 1 + ] [ skip-label nip ] 2bi subseq >string ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bit-test ( a b -- ? ) bitand 0 = not ;

: pointer? ( ba i -- ? ) get-single BIN: 11000000 bit-test ;

: pointer ( ba i -- val ) get-double BIN: 0011111111111111 bitand ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: skip-name ( ba i -- ba i )
    {
      { [ 2dup null-label? ] [ 1 + ] }
      { [ 2dup pointer?    ] [ 2 + ] }
      { [ t ] [ skip-label skip-name ] }
    }
  cond ;

: get-name ( ba i -- name )
    {
      { [ 2dup null-label? ] [ 2drop "" ] }
      { [ 2dup pointer?    ] [ dupd pointer get-name ] }
      {
        [ t ]
        [
          [ get-label ]
          [ skip-label get-name ]
          2bi
          "." glue 
        ]
      }
    }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: get-query ( ba i -- query )
    [ get-name ]
    [
      skip-name
      [ 0 + get-double type-table  key-of ]
      [ 2 + get-double class-table key-of ]
      2bi
    ]
  2bi query boa ;

: skip-query ( ba i -- ba i ) skip-name 4 + ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: get-mx ( ba i -- mx ) [ get-double ] [ 2 + get-double ] 2bi mx boa ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: get-soa ( ba i -- soa )
    {
      [           get-name ]
      [ skip-name get-name ]
      [
        skip-name
        skip-name
        {
          [  0 + get-quad ]
          [  4 + get-quad ]
          [  8 + get-quad ]
          [ 12 + get-quad ]
          [ 16 + get-quad ]
        }
          2cleave
      ]
    }
  2cleave soa boa ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: get-ip ( ba i -- ip ) dup 4 + subseq >array [ number>string ] map "." join ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: get-ipv6 ( ba i -- ip )
  dup 16 + subseq 2 group [ be> 16 >base ] map ":" join ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: get-rdata ( ba i type -- rdata )
    {
      { CNAME [ get-name ] }
      { NS    [ get-name ] }
      { PTR   [ get-name ] }
      { MX    [ get-mx   ] }
      { SOA   [ get-soa  ] }
      { A     [ get-ip   ] }
      { AAAA  [ get-ipv6 ] }
    }
  case ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: get-rr ( ba i -- rr )
  [ get-name ]
  [
    skip-name
      {
        [ 0 + get-double type-table  key-of ]
        [ 2 + get-double class-table key-of ]
        [ 4 + get-quad   ]
        [ [ 10 + ] [ get-double type-table key-of ] 2bi get-rdata ]
      }
    2cleave
  ]
    2bi rr boa ;

: skip-rr ( ba i -- ba i ) skip-name 8 + 2dup get-double + 2 + ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: get-question-section ( ba i count -- seq ba i )
  [ drop [ skip-query ] [ get-query ] 2bi ] map -rot ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: get-rr-section ( ba i count -- seq ba i )
  [ drop [ skip-rr ] [ get-rr ] 2bi ] map -rot ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: >> ( x n -- y ) neg shift ;

: get-header-bits ( ba i -- qr opcode aa tc rd ra z rcode )
    get-double
    {
      [ 15 >> BIN:    1 bitand ]
      [ 11 >> BIN:  111 bitand opcode-table key-of ]
      [ 10 >> BIN:    1 bitand ]
      [  9 >> BIN:    1 bitand ]
      [  8 >> BIN:    1 bitand ]
      [  7 >> BIN:    1 bitand ]
      [  4 >> BIN:  111 bitand ]
      [       BIN: 1111 bitand rcode-table key-of ]
    }
  cleave ;

: parse-message ( ba -- message )
  0
  {
    [ get-double ]
    [ 2 + get-header-bits ]
    [
      4 +
      {
        [ 8 +            ]
        [ 0 + get-double ]
        [ 2 + get-double ]
        [ 4 + get-double ]
        [ 6 + get-double ]
      }
        2cleave
      {
        [ get-question-section ]
        [ get-rr-section ]
        [ get-rr-section ]
        [ get-rr-section ]
      } spread
      2drop
    ]
  }
    2cleave message boa ;

: ba->message ( ba -- message ) parse-message ;

: with-message-bytes ( ba quot -- ) [ ba->message ] dip call message->ba ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: send-receive-udp ( ba server -- ba )
  f 0 <inet4> <datagram>
    [
      [ send ] [ receive drop ] bi
    ]
  with-disposal ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: send-receive-tcp ( ba server -- ba )
  [ dup length 2 >be prepend ] [ ] bi*
  binary
    [
      write flush
      2 read be> read
    ]
  with-client ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: >dns-inet4 ( obj -- inet4 )
  dup string?
    [ 53 <inet4> ]
    [            ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: ask-server ( message server -- message )
  [ message->ba ] [ >dns-inet4 ] bi*
  2dup
  send-receive-udp parse-message
  dup tc>> 1 =
    [ drop send-receive-tcp parse-message ]
    [ nip nip                             ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: dns-servers ( -- seq ) V{ } ;

: dns-server ( -- server ) dns-servers random ;

: ask ( message -- message ) dns-server ask-server ;

: query->message ( query -- message ) <message> swap 1array >>question-section ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: message-query ( message -- query ) question-section>> 1st ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ERROR: name-error name ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: fully-qualified ( name -- name )
    {
      { [ dup empty?         ] [ "." append ] }
      { [ dup peek CHAR: . = ] [            ] }
      { [ t                  ] [ "." append ] }
    }
  cond ;
