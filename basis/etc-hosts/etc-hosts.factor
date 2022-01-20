USING: assocs environment io.encodings.utf8 io.files
io.pathnames kernel sequences splitting system unicode ;

IN: etc-hosts

HOOK: hosts-path os ( -- path )

M: windows hosts-path
    "SystemRoot" os-env "System32/drivers/etc/hosts" append-path ;

M: unix hosts-path "/etc/hosts" ;

: parse-hosts ( path -- hosts )
    utf8 file-lines
    [ [ unicode:blank? ] trim ] map harvest
    [ "#" head? ] reject
    [
        [ unicode:blank? ] split1-when
        [ unicode:blank? ] split-when harvest
    ] H{ } map>assoc ;

MEMO: system-hosts ( -- hosts ) hosts-path parse-hosts ;

: host>ips ( host -- ips )
    system-hosts [ member? nip ] with assoc-filter keys ;

: ip>hosts ( ip -- hosts )
    system-hosts at ;
