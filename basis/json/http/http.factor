! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: http.client json kernel ;
IN: json.http

: json-get* ( endpoint -- res json ) http-get* ?json> ;
: json-post* ( post-data endpoint -- res json ) http-post* ?json> ;
: json-put* ( post-data endpoint -- res json ) http-put* ?json> ;
: json-patch* ( patch-data endpoint -- res json ) http-patch* ?json> ;
: json-delete* ( endpoint -- res json ) http-delete* ?json> ;

: json-get ( endpoint -- json ) http-get nip ?json> ;
: json-post ( post-data endpoint -- json ) http-post nip ?json> ;
: json-put ( post-data endpoint -- json ) http-put nip ?json> ;
: json-patch ( patch-data endpoint -- json ) http-patch nip ?json> ;
: json-delete ( endpoint -- json ) http-delete nip ?json> ;
