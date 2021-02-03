USING: kernel ;


: hpack-encode ;




:: hpack-decode ( dtable block -- dtable decoded ) ;

: decode-field ( dtable encoded -> dtable block field ) ;
