USING: alien alien.c-types io kernel ldap ldap.libldap
namespaces prettyprint tools.test ;
IN: ldap.tests

"void*" <c-object> "ldap://localhost:389" initialize

get-ldp LDAP_OPT_PROTOCOL_VERSION LDAP_VERSION3 <int> set-option

[ 3 ] [
    get-ldp LDAP_OPT_PROTOCOL_VERSION "int*" <c-object> [ get-option ] keep
    *int
] unit-test

[
    get-ldp "cn=jimbob,dc=example,dc=com" "secret" [

        ! get-ldp "dc=example,dc=com" LDAP_SCOPE_ONELEVEL "(objectclass=*)" f 0
        ! "void*" <c-object> [ search-s ] keep *int .

        [ 2 ] [
            get-ldp "dc=example,dc=com" LDAP_SCOPE_SUBTREE "(objectclass=*)" f 0
            search
        ] unit-test

        ! get-ldp LDAP_RES_ANY 0 f "void*" <c-object> result .

        get-ldp LDAP_RES_ANY LDAP_MSG_ALL f "void*" <c-object> result

        ! get-message *int .

        "Message ID: " write

        get-message msgid .

        get-ldp get-message get-dn .

        "Entries count: " write

        get-ldp get-message count-entries .

        SYMBOL: entry
        SYMBOL: attr

        "Attribute: " write

        get-ldp get-message first-entry entry set get-ldp entry get
        "void*" <c-object> first-attribute dup . attr set

        "Value: " write

        get-ldp entry get attr get get-values *char* .

        get-ldp get-message first-message msgtype result-type

        get-ldp get-message next-message msgtype result-type

    ] with-bind
] drop
