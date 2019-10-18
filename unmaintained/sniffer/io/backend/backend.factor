USING: io.backend kernel system vocabs.loader ;
IN: io.sniffer.backend

SYMBOL: sniffer-type
TUPLE: sniffer ;
HOOK: <sniffer> io-backend ( obj -- sniffer )
