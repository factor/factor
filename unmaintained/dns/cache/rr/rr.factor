
USING: kernel sequences assocs sets locals combinators
       accessors system math math.functions unicode.case prettyprint
       combinators.smart dns ;

IN: dns.cache.rr

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <entry> time data ;

: now ( -- seconds ) millis 1000.0 / round >integer ;

: expired? ( <entry> -- ? ) time>> now <= ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make-cache-key ( obj -- key )
  [ [ name>> >lower ] [ type>> ] [ class>> ] tri ] output>array ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: cache ( -- table ) H{ } ;

: cache-at     (     obj -- ent ) make-cache-key cache at ;
: cache-delete (     obj --     ) make-cache-key cache delete-at ;
: cache-set-at ( ent obj --     ) make-cache-key cache set-at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: cache-get ( OBJ -- rrs/f )
   [let | ENT [ OBJ cache-at ] |
     {
       { [ ENT f =      ] [                  f ] }
       { [ ENT expired? ] [ OBJ cache-delete f ] }
       {
         [ t ]
         [
           [let | NAME  [ OBJ name>>       ]
                  TYPE  [ OBJ type>>       ]
                  CLASS [ OBJ class>>      ]
                  TTL   [ ENT time>> now - ] |
             ENT data>>
               [| RDATA | T{ rr f NAME TYPE CLASS TTL RDATA } ]
             map
           ]
         ]
       }
     }
     cond
   ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: cache-add ( RR -- )
   [let | ENT   [ RR cache-at    ]
          TIME  [ RR ttl>> now + ]
          RDATA [ RR rdata>>     ] |
     {
       { [ ENT f =      ] [ T{ <entry> f TIME V{ RDATA } } RR cache-set-at ] }
       { [ ENT expired? ] [ RR cache-delete RR cache-add                   ] }
       { [ t            ] [ TIME ENT (>>time) RDATA ENT data>> adjoin      ] }
     }
     cond
   ] ;