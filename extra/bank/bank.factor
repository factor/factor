USING: accessors calendar kernel money new-slots sequences ;
IN: bank

MIXIN: policy
TUPLE: simple-policy interest-rate ;
INSTANCE: simple-policy policy
C: <simple-policy> simple-policy

GENERIC: interest-rate ( date account policy -- rate )
M: simple-policy interest-rate 2nip interest-rate>> ;

: daily-interest-rate ( date account policy -- rate )
    pick days-in-year >r interest-rate r> / ;

TUPLE: account name balance transactions ;

: <account> ( name -- account )
    0 V{ } clone account construct-boa ;

TUPLE: transaction date amount description ;

C: <transaction> transaction

: >>transaction ( account transaction -- account )
    over transactions>> push ;

: open-account ( date opening-balance name -- account )
    <account> >r "Account Opened" <transaction> >>transaction ;

: open-account-now ( opening-balance name -- account )
    now -rot open-account ;


