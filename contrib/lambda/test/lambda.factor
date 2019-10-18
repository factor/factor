USING: lambda test hashtables sequences kernel ;

#! test simple parsing
[ "(A. A)" ] [ "(b.b)" lambda-parse second bound-vars swap expr>string ] unit-test

#! test name replacement
[ "(A. A)" ] [ 
                "(b.b)" lambda-parse second "OK" H{ } clone [ set-hash ] keep
                "OK" lambda-parse second replace-names bound-vars
                swap expr>string 
             ] unit-test