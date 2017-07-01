USING: help.markup help.syntax ;
IN: openssl

HELP: maybe-init-ssl
{ $description "Word that initializes openssl if it isn't already initialized." }
{ $see-also ssl-initialized? } ;

HELP: ssl-initialized?
{ $var-description "Boolean that is " { $link t } " after ssl has been initialized." } ;

HELP: ssl-new-api?
{ $var-description "Boolean that is " { $link t } " if the detected libssl version is 1.1.0 or greater." } ;

ARTICLE: "openssl" "OpenSSL Binding"
"The " { $vocab-link "openssl" } " vocab and its subvocabs implements bindings for the libssl and libcrypto SSL libraries. Variables:"
{ $subsections ssl-initialized? ssl-new-api? } ;

ABOUT: "openssl"
