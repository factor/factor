#! An interpreter for lambda expressions, by Matthew Willis
REQUIRES: lazy-lists ;
USING: lazy-lists io strings hashtables sequences namespaces kernel ;
IN: lambda

: bound-vars ( -- lazy-list ) 65 lfrom [ ch>string ] lmap ;

: lambda>string ( expr -- string )
    bound-vars swap expr>string ;

: matching-names ( names string -- string )
    #! this inefficiently finds all names matching the
    #! canonical representation of string
    [ \ evaluate , \ lambda>string , , \ = , \ nip , ] [ ] make 
    hash-subset hash-keys ", " join "=> " swap append ": " append ;

: lambda-print ( names expr -- names )
    lambda>string [ matching-names ] 2keep rot swap append print flush ;

: lambda-eval ( names input -- names expr )
    lambda-parse [ first ] keep second 
    pick swap replace-names 
    [ swap rot set-hash ] 3keep evaluate nip ;

: lambda-boot ( -- names )
    #! load the core lambda library
    H{ } clone ;

: (lambda) ( names -- names )
     readln dup "." = [ drop ] [ lambda-eval lambda-print (lambda) ] if ;

: lambda ( -- names )
    lambda-boot (lambda) ;