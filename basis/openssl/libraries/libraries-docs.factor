USING: help.markup help.syntax strings ;
IN: openssl.libraries

HELP: linux-openssl-library
{ $values { "name" string } { "path" string } }
{ $description "Appends the suffix of the first loadable Linux OpenSSL library pair to a library name. Both libssl and libcrypto must be available with the same suffix. OpenSSL 3 is preferred, followed by 1.1 and the unversioned libraries. If no pair can be loaded, the OpenSSL 3 soname is returned so library loading reports the missing dependency." } ;

ARTICLE: "openssl.libraries" "OpenSSL library selection"
"Linux bindings select a matching pair of libssl and libcrypto libraries using the dynamic loader. Versioned runtime libraries are sufficient; development symlinks are only needed when using the unversioned fallback."
{ $subsections linux-openssl-library } ;

ABOUT: "openssl.libraries"
