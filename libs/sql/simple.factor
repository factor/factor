USING: errors generic kernel namespaces prettyprint
sequences sql:utils ;
IN: sql

G: create-sql* ( db tuple -- string ) 1 standard-combination ;
G: drop-sql* ( db tuple -- string ) 1 standard-combination ;
G: insert-sql* ( db tuple -- string ) 1 standard-combination ;
G: delete-sql* ( db tuple -- string ) 1 standard-combination ;
G: update-sql* ( db tuple -- string ) 1 standard-combination ;
G: select-sql* ( db tuple -- string ) 1 standard-combination ;

: create-sql ( tuple -- string ) >r db get r> create-sql* ;
: drop-sql ( tuple -- string ) >r db get r> drop-sql* ;
: insert-sql ( tuple -- string ) >r db get r> insert-sql* ;
: delete-sql ( tuple -- string ) >r db get r> delete-sql* ;
: update-sql ( tuple -- string ) >r db get r> update-sql* ;
: select-sql ( tuple -- string ) >r db get r> select-sql* ;

! M: connection create-sql* ( db tuple -- string )
    ! nip [
        ! "create table " %
        ! dup class unparse % "(" %
        ! tuple>mapping%
        ! ");" %
    ! ] "" make ;

! M: connection drop-sql* ( db tuple -- string )
    ! nip [ "drop table " % tuple>sql-name % ";" % ] "" make ;
! 
! M: connection insert-sql* ( db tuple -- string )
    ! nip [
        ! "insert into " %
        ! dup tuple>sql-name %
        ! ! " (" % fulltuple>insert-all-parts dup first ", " join %
        ! ") values(" %
        ! second [ escape-sql enquote ] map ", " join %
        ! ");" %
    ! ] "" make ;
! 
! M: connection delete-sql* ( db tuples -- string )
    ! nip [
        ! ! "delete from table " % unparse % ";" %
    ! ] "" make ;
! 
! M: connection update-sql* ( db tuples -- string )
    ! nip [
    ! ] "" make ;
! 
! M: connection select-sql* ( db tuples -- string )
    ! nip [
    ! ] "" make ;


