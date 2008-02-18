USING: io io.encodings strings kernel ;
IN: io.encodings.latin1

TUPLE: latin1 ;

M: latin1 stream-read delegate stream-read >string ;

M: latin1 stream-read-until delegate stream-read-until >string ;

M: latin1 stream-read-partial delegate stream-read-partial >string ;
