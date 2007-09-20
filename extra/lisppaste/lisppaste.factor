USING: arrays kernel xml-rpc ;
IN: lisppaste

: url "http://www.common-lisp.net:8185/RPC2" ;

: channels ( -- seq )
    { } "listchannels" url invoke-method ;

: lisppaste ( seq -- response )
    ! seq is { channel user title contents }
    ! or { channel user title contents annotation-number }
    "newpaste" url invoke-method ;
