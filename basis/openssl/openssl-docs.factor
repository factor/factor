USING: help.markup help.syntax ;
IN: openssl

HELP: maybe-init-ssl
{ $description "Word that initializes openssl if it isn't already initialized." }
{ $see-also ssl-initialized? } ;

HELP: ssl-initialized?
{ $var-description "Boolean that is " { $link t } " after ssl has been initialized." } ;

HELP: ssl-new-api?
{ $var-description "Boolean that is " { $link t } " when the SSL library provides the OpenSSL 1.1.0 stack API. Initialization is detected separately because LibreSSL provides the modern initializer with the legacy stack API." } ;

HELP: ssl-native-identity-checks?
{ $var-description "Boolean that is " { $link t } " when the initialized SSL library provides both native certificate hostname and IP address checks." } ;

ARTICLE: "openssl" "OpenSSL Binding"
"The " { $vocab-link "openssl" } " vocab and its subvocabs implements bindings for the libssl and libcrypto SSL libraries. Variables:"
{ $subsections ssl-initialized? ssl-new-api? ssl-native-identity-checks? }
"On Linux, the bindings use OpenSSL 1.1 on 32-bit systems and OpenSSL 3 otherwise." ;

ABOUT: "openssl"
