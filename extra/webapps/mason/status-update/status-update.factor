! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar combinators db.tuples furnace.actions
furnace.redirection html.forms http.server.responses io kernel
namespaces validators webapps.mason.utils webapps.mason.backend ;
IN: webapps.mason.status-update

: find-builder ( host-name os cpu -- builder )
    builder new
        swap >>cpu
        swap >>os
        swap >>host-name
    dup select-tuple [ ] [ dup insert-tuple ] ?if ;

: heartbeat ( builder -- )
    now >>heartbeat-timestamp
    drop ;

: status ( builder status -- )
    >>status
    now >>current-timestamp
    drop ;

: idle ( builder -- ) +idle+ status ;

: git-id ( builder id -- ) >>current-git-id +starting+ status ;

: make-vm ( builder -- ) +make-vm+ status ;

: boot ( builder -- ) +boot+ status ;

: test ( builder -- ) +test+ status ;

: report ( builder content status -- )
    [
        >>last-report
        now >>current-timestamp
    ] dip
    +clean+ = [
        dup current-git-id>> >>clean-git-id
        dup current-timestamp>> >>clean-timestamp
    ] when
    dup current-git-id>> >>last-git-id
    dup current-timestamp>> >>last-timestamp
    drop ;

: upload ( builder -- ) +upload+ status ;

: finish ( builder -- ) +finish+ status ;

: release ( builder name -- )
    >>last-release
    dup clean-git-id>> >>release-git-id
    drop ;

: update-builder ( builder -- )
    "message" value {
        { "heartbeat" [ heartbeat ] }
        { "idle" [ idle ] }
        { "git-id" [ "arg" value git-id ] }
        { "make-vm" [ make-vm ] }
        { "boot" [ boot ] }
        { "test" [ test ] }
        { "report" [ "report" value "arg" value report ] }
        { "upload" [ upload ] }
        { "finish" [ finish ] }
        { "release" [ "arg" value release ] }
    } case ;

: <status-update-action> ( -- action )
    <action>
    [
        {
            { "host-name" [ v-one-line ] }
            { "target-cpu" [ v-one-line ] }
            { "target-os" [ v-one-line ] }
            { "message" [ v-one-line ] }
            { "arg" [ [ v-one-line ] v-optional ] }
            { "report" [ ] }
        } validate-params

        validate-secret
    ] >>validate

    [
        [
            "host-name" value
            "target-os" value
            "target-cpu" value
            find-builder
            [ update-builder ] [ update-tuple ] bi
        ] with-mason-db
        "OK" <text-content>
    ] >>submit ;
