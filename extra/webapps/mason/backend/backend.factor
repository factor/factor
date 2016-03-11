! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar combinators.short-circuit
db2.connections db2.transactions db2.types io.pathnames kernel
math math.order orm.persistent orm.tuples sequences sqlite.db2 ;
IN: webapps.mason.backend

CONSTANT: +idle+ "idle"
CONSTANT: +starting+ "starting"
CONSTANT: +make-vm+ "make-vm"
CONSTANT: +boot+ "boot"
CONSTANT: +test+ "test"
CONSTANT: +upload+ "upload"
CONSTANT: +finish+ "finish"

CONSTANT: +dirty+ "status-dirty"
CONSTANT: +error+ "status-error"
CONSTANT: +clean+ "status-clean"

TUPLE: builder
host-name os cpu heartbeat-timestamp
clean-git-id clean-timestamp
last-release release-git-id
last-git-id last-timestamp last-report
current-git-id current-timestamp
status ;

PERSISTENT: { builder "BUILDERS" }
    { "host-name" TEXT +user-assigned-key+ }
    { "os" TEXT +user-assigned-key+ }
    { "cpu" TEXT +user-assigned-key+ }
    { "heartbeat-timestamp" TIMESTAMP }

    { "clean-git-id" TEXT } 
    { "clean-timestamp" TIMESTAMP }

    { "last-release" TEXT }
    { "release-git-id" TEXT }
    
    { "last-git-id" TEXT }
    { "last-timestamp" TIMESTAMP }
    { "last-report" TEXT }

    { "current-git-id" TEXT }
    ! TODO FIX THIS OMG
    ! Can't name it CURRENT_TIMESTAMP because of bug in db library
    { { "current-timestamp" "CURR_TIMESTAMP" } TIMESTAMP }
    { "status" TEXT } ;

TUPLE: counter id value ;

PERSISTENT: counter
    { "id" INTEGER +db-assigned-key+ }
    { "value" INTEGER } ;

: counter-tuple ( -- counter )
    counter new select-tuple
    [ counter new dup insert-tuple ] unless* ;

: counter-value ( -- n )
    counter-tuple value>> 0 or ;

: increment-counter-value ( -- n )
    counter-tuple [ 0 or 1 + dup ] change-value update-tuple ;

: all-builders ( -- builders )
    builder new select-tuples ; inline

: crashed? ( builder -- ? )
    heartbeat-timestamp>> 30 minutes ago before? ;

: broken? ( builder -- ? )
    [ clean-git-id>> ] [ last-git-id>> ] bi = not ;

: funny-builders ( -- crashed broken )
    all-builders
    [ [ crashed? ] filter ]
    [ [ broken? ] filter ]
    bi ;

: os/cpu ( builder -- string )
    [ os>> ] [ cpu>> ] bi "/" glue ;

: mason-db ( -- db ) home "mason.db" append-path <sqlite-db> ;

: with-mason-db ( quot -- )
    mason-db [ with-transaction ] with-db ; inline

: init-mason-db ( -- )
    { builder counter } ensure-tables ;
