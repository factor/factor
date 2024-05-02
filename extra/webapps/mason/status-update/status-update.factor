! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar combinators db.tuples furnace.actions
furnace.redirection html.forms http.server.responses io kernel
namespaces sequences validators webapps.mason.utils webapps.mason.backend ;
IN: webapps.mason.status-update

: find-builder ( host-name os cpu -- builder )
    builder new
        swap >>cpu
        swap >>os
        swap >>host-name
    [ select-tuple ] [ dup insert-tuple ] ?unless ;

: update-runs ( builder -- run-id )
  [ run new ] dip
  { [ host-name>> >>host-name ]
    [ os>> >>os ]
    [ cpu>> >>cpu ]
    [ current-timestamp>> >>timestamp ]
    [ current-git-id>> >>git-id ] } cleave
  dup insert-tuple run-id>>
;

: parse-report ( report -- assoc )
  drop { { "test1" 1500 } { "test2" 2000 } }
;

: update-benchmarks ( run-id builder -- )
  [ benchmark new swap >>run-id ] dip last-report>> parse-report
  [ first2 [ >>name ] dip >>duration insert-tuple ] with each
;

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
        [ [ update-runs ] [ update-benchmarks ] bi ] keep
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
