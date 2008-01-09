USING: io.backend kernel system vocabs.loader ;
IN: io.sniffer

SYMBOL: sniffer-type

TUPLE: sniffer ;

HOOK: <sniffer> io-backend ( obj -- sniffer )

bsd? [ "io.sniffer.bsd" require ] when
