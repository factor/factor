USING: io kernel math namespaces parser.notes sequences ;

IN: core.parser
SYMBOL: parsing-file-level
parsing-file-level [ 0 ] initialize

: (parsing-file-level) ( -- string )
    parsing-file-level get dup
    [ "" swap <iota> [ drop "." append ] each ]
    [ drop "" ] if
    ;

FROM: namespaces => set ; 
: parsing-file-level++ ( -- )
    parsing-file-level get  1 +  parsing-file-level set ;
 
: parsing-file-level-- ( -- )
      parsing-file-level get  1 -  parsing-file-level set ;
      
: parsing-file ( file -- )
    parser-quiet? get [ drop ]
    [ (parsing-file-level) "Loading " append write print flush ] if ;
