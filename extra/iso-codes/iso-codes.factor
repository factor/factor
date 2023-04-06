! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs assocs.extras cli.git io.files.temp io.pathnames
json kernel ;
IN: iso-codes

: iso-codes-directory ( -- directory ) temp-directory "iso-codes" append-path ;

MEMO: sync-iso-codes ( -- )
    "https://salsa.debian.org/iso-codes-team/iso-codes.git"
    iso-codes-directory sync-repository-as drop ;

: iso-code-json ( path -- json )
    [ sync-iso-codes iso-codes-directory ] dip append-path path>json ;

: iso-15924-json ( -- json ) "data/iso_15924.json" iso-code-json ;
: iso-3166-1-json ( -- json ) "data/iso_3166-1.json" iso-code-json ;
: iso-3166-2-json ( -- json ) "data/iso_3166-2.json" iso-code-json ;
: iso-3166-3-json ( -- json ) "data/iso_3166-3.json" iso-code-json ;
: iso-4217-json ( -- json ) "data/iso_4217.json" iso-code-json ;
: iso-639-2-json ( -- json ) "data/iso_639-2.json" iso-code-json ;
: iso-639-3-json ( -- json ) "data/iso_639-3.json" iso-code-json ;
: iso-639-5-json ( -- json ) "data/iso_639-5.json" iso-code-json ;

: schema-15924-json ( -- json ) "data/schema-15924.json" iso-code-json ;
: schema-3166-1-json ( -- json ) "data/schema-3166-1.json" iso-code-json ;
: schema-3166-2-json ( -- json ) "data/schema-3166-2.json" iso-code-json ;
: schema-3166-3-json ( -- json ) "data/schema-3166-3.json" iso-code-json ;
: schema-4217-json ( -- json ) "data/schema-4217.json" iso-code-json ;
: schema-639-2-json ( -- json ) "data/schema-639-2.json" iso-code-json ;
: schema-639-3-json ( -- json ) "data/schema-639-3.json" iso-code-json ;
: schema-639-5-json ( -- json ) "data/schema-639-5.json" iso-code-json ;


: iso-15924-hash4 ( -- hash ) iso-15924-json "15924" of [ "alpha_4" of ] zip-with assoc-invert ;
: iso-15924-hash-name ( -- hash ) iso-15924-json "15924" of [ "name" of ] zip-with assoc-invert ;
: iso-15924-hash-numeric ( -- hash ) iso-15924-json "15924" of [ "numeric" of ] zip-with assoc-invert ;

: iso-3166-1-hash2 ( -- hash ) iso-3166-1-json "3166-1" of [ "alpha_2" of ] zip-with assoc-invert ;
: iso-3166-1-hash3 ( -- hash ) iso-3166-1-json "3166-1" of [ "alpha_3" of ] zip-with assoc-invert ;
: iso-3166-1-hash-name ( -- hash ) iso-3166-1-json "3166-1" of [ "name" of ] zip-with assoc-invert ;
: iso-3166-1-hash-numeric ( -- hash ) iso-3166-1-json "3166-1" of [ "numeric" of ] zip-with assoc-invert ;

: iso-3166-2-hash-code ( -- hash ) iso-3166-2-json "3166-2" of [ "code" of ] zip-with assoc-invert ;

: iso-3166-3-hash2 ( -- hash ) iso-3166-3-json "3166-3" of [ "alpha_2" of ] zip-with assoc-invert ;
: iso-3166-3-hash3 ( -- hash ) iso-3166-3-json "3166-3" of [ "alpha_3" of ] zip-with assoc-invert ;
: iso-3166-3-hash4 ( -- hash ) iso-3166-3-json "3166-3" of [ "alpha_4" of ] zip-with assoc-invert ;
: iso-3166-3-numeric ( -- hash ) iso-3166-3-json "3166-3" of [ "numeric" of ] zip-with assoc-invert ;

: iso-4217-hash-alpha3 ( -- hash ) iso-4217-json "4217" of [ "alpha_3" of ] zip-with assoc-invert ;
: iso-4217-hash-numeric ( -- hash ) iso-4217-json "4217" of [ "numeric" of ] zip-with assoc-invert ;

: iso-639-2-hash2 ( -- hash ) iso-639-2-json "639-2" of [ "alpha_2" of ] zip-with assoc-invert ;
: iso-639-2-hash3 ( -- hash ) iso-639-2-json "639-2" of [ "alpha_3" of ] zip-with assoc-invert ;

: iso-639-3-hash ( -- hash ) iso-639-3-json "639-3" of [ "alpha_3" of ] zip-with assoc-invert ;

: iso-639-5-hash ( -- hash ) iso-639-5-json "639-5" of [ "alpha_3" of ] zip-with assoc-invert ;
