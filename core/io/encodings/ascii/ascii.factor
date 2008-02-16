USING: io io.encodings strings kernel ;
IN: io.encodings.ascii

: encode-check>= ( string max -- byte-array )
    dupd [ >= ] curry all? [ >byte-array ] [ encoding-error ] if ;

TUPLE: ascii ;

M: ascii encode-string
    drop 127 encode-check>= ;

M: ascii decode-step
    3drop over push f f ;
