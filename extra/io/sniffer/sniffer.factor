USING: io.backend kernel system ;
IN: io.sniffer

SYMBOL: sniffer-type

TUPLE: sniffer ;

HOOK: <sniffer> io-backend ( obj -- sniffer )

USE-IF: bsd? io.sniffer.bsd
