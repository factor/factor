
USING: kernel continuations namespaces threads match bake concurrency builder ;

IN: builder.server

! : build-server ( -- )
!   receive
!   {
!     {
!       "start"
!       [ [ build ] in-thread ]
!     }

!     {
!       { ?from ?tag "status" }
!       [ `{ ?tag ,[ build-status get ] } ?from send ]
!     }
!   }
!   match-cond
!   build-server ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : build-server ( -- )
!   receive
!   {
!     {
!       "start"
!       [
!         [ [ build ] [ drop ] recover "idle" build-status set-global ] in-thread
!       ]
!     }

!     {
!       { ?from ?tag "status" }
!       [ `{ ?tag ,[ build-status get ] } ?from send ]
!     }
!   }
!   match-cond
!   build-server ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : build-server ( -- )
!   receive
!   {
!     {
!       "start"
!       [
!         build-status get "idle" =
!         build-status get f      =
!         or
!         [
!           [ [ build ] [ drop ] recover "idle" build-status set-global ]
!           in-thread
!         ]
!         when
!       ]
!     }

!     {
!       { ?from ?tag "status" }
!       [ `{ ?tag ,[ build-status get ] } ?from send ]
!     }
!   }
!   match-cond
!   build-server ;

