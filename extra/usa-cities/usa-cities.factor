! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files io.encodings.ascii sequences generalizations
math.parser combinators kernel memoize csv summary
words accessors math.order binary-search combinators.smart ;
IN: usa-cities

SINGLETONS: AK AL AR AS AZ CA CO CT DC DE FL GA HI IA ID IL IN
KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK
OR PA PR RI SC SD TN TX UT VA VI VT WA WI WV WY ;

: states ( -- seq )
    {
        AK AL AR AS AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY
        LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK
        OR PA PR RI SC SD TN TX UT VA VI VT WA WI WV WY
    } ; inline

ERROR: no-such-state name ;

M: no-such-state summary drop "No such state" ;

MEMO: string>state ( string -- state )
    dup states [ name>> = ] with find nip
    [ ] [ no-such-state ] ?if ;

TUPLE: city
first-zip name state latitude longitude gmt-offset dst-offset ;

MEMO: cities ( -- seq )
    "resource:extra/usa-cities/zipcode.csv" ascii file>csv
    rest-slice [
        [
            {
                [ string>number ]
                [ ]
                [ string>state ]
                [ string>number ]
                [ string>number ]
                [ string>number ]
                [ string>number ]
            } spread
        ] input<sequence city boa
    ] map ;

MEMO: cities-named ( name -- cities )
    cities [ name>> = ] with filter ;

MEMO: cities-named-in ( name state -- cities )
    cities [
        [ name>> = ] [ state>> = ] bi-curry bi* and
    ] 2with filter ;

: find-zip-code ( code -- city )
    cities [ first-zip>> <=> ] with search nip ;
