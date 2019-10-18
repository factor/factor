USING: help.markup help.syntax ;
IN: checksums.ripemd

HELP: ripemd-160
{ $class-description "RIPEMD-160 checksum algorithm." } ;

ARTICLE: "checksums.ripemd" "RIPEMD checksum"
"The RIPEMD checksum algorithm family implements one-way hash functions. RIPEMD-160 is believed to be secure and patent-free. Unlike the SHA-1 and SHA-2 family of hash functions, it was not designed in USA by the NSA. Instead, RIPEMD-160 was designed in the open academic community in Europe by the RIPE consortium. Although it may have been less scrutinized than SHA-1 and SHA-2, it is relied on in widely used standards such as OpenPGP or Bitcoin."
{ $subsections ripemd-160 } ;

ABOUT: "checksums.ripemd"
