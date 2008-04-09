USING: accessors calendar kernel math money sequences ;
IN: bank

TUPLE: account name interest-rate interest-payment-day opening-date transactions unpaid-interest interest-last-paid ;

: <account> ( name interest-rate interest-payment-day opening-date -- account )
    V{ } clone 0 pick account construct-boa ;

TUPLE: transaction date amount description ;
C: <transaction> transaction

: >>transaction ( account transaction -- account )
    over transactions>> push ;

: total ( transactions -- balance )
    0 [ amount>> + ] reduce ;

: balance>> ( account -- balance ) transactions>> total ;

: open-account ( name interest-rate interest-payment-day opening-date opening-balance -- account )
    >r [ <account> ] keep r> "Account Opened" <transaction> >>transaction ;

: daily-rate ( yearly-rate day -- daily-rate )
    days-in-year / ;

: daily-rate>> ( account date -- rate )
    [ interest-rate>> ] dip daily-rate ;

: before? ( date date -- ? ) <=> 0 < ;

: transactions-on-date ( account date -- transactions )
    [ before? ] curry subset ;

: balance-on-date ( account date -- balance )
    transactions-on-date total ;

: pay-interest ( account date -- )
    over unpaid-interest>> "Interest Credit" <transaction>
    >>transaction 0 >>unpaid-interest drop ;

: interest-payment-day? ( account date -- ? )
    day>> swap interest-payment-day>> = ;

: ?pay-interest ( account date -- )
    2dup interest-payment-day? [ pay-interest ] [ 2drop ] if ;

: unpaid-interest+ ( account amount -- account )
    over unpaid-interest>> + >>unpaid-interest ;

: accumulate-interest ( account date -- )
    [ dupd daily-rate>> over balance>> * unpaid-interest+ ] keep
    >>interest-last-paid drop ;

: process-day ( account date -- )
    2dup accumulate-interest ?pay-interest ;

: each-day ( quot start end -- )
    2dup before? [
        >r dup >r over >r swap call r> r> 1 days time+ r> each-day
    ] [
        3drop
    ] if ;

: process-to-date ( account date -- account )
    over interest-last-paid>> 1 days time+
    [ dupd process-day ] spin each-day ;

: inserting-transactions ( account transactions -- account )
    [ [ date>> process-to-date ] keep >>transaction ] each ;
