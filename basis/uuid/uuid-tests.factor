! Copyright (C) 2008 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: kernel uuid tools.test ;

{ t } [ NAMESPACE_DNS  [ uuid-parse uuid-unparse ] keep = ] unit-test
{ t } [ NAMESPACE_URL  [ uuid-parse uuid-unparse ] keep = ] unit-test
{ t } [ NAMESPACE_OID  [ uuid-parse uuid-unparse ] keep = ] unit-test
{ t } [ NAMESPACE_X500 [ uuid-parse uuid-unparse ] keep = ] unit-test

{ t } [ NAMESPACE_URL "ABCD" uuid3
        "2e10e403-d7fa-3ffb-808f-ab834a46890e" = ] unit-test

{ t } [ NAMESPACE_URL "ABCD" uuid5
        "0aa883d6-7953-57e7-a8f0-66db29ce5a91" = ] unit-test
