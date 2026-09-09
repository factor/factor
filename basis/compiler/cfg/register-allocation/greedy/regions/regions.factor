! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs kernel locals math math.order sequences vectors ;
IN: compiler.cfg.register-allocation.greedy.regions

! A binary residency network. Nodes carry { memory-use-cost forced-memory? };
! edges carry { from to transition-cost }. The source side is register-resident.
! Unlike a layout boundary heuristic, the objective counts actual CFG edges.
! An exact minimum cut gives a deterministic solution, including transparent
! blocks and cycles. Register constraints have capacity greater than any finite
! placement, so the solver cannot choose an interfering register assignment.
TUPLE: residency-network capacities neighbors source sink ;
TUPLE: residency-plan resident cost ;

:: add-capacity ( amount from to network -- )
    from to 2array :> key
    amount key network capacities>> at 0 or + key network capacities>> set-at
    to from network neighbors>> push-at
    from to network neighbors>> push-at ;

:: <residency-network> ( nodes edges -- network )
    H{ } clone H{ } clone nodes length dup 1 + residency-network boa :> network
    nodes [ first ] map-sum edges [ third ] map-sum + 1 + :> infinity
    nodes [| node i |
        node first network source>> i network add-capacity
        node second [ infinity i network sink>> network add-capacity ] when
    ] each-index
    edges [| edge |
        edge first edge second = [ ] [
            edge third edge first edge second network add-capacity
            edge third edge second edge first network add-capacity
        ] if
    ] each network ;

:: residual-search ( network -- predecessors )
    H{ } clone :> seen
    network source>> dup seen set-at
    network source>> 1vector :> queue
    0 :> cursor!
    [ cursor queue length < ] [
        cursor queue nth :> from
        from network neighbors>> at [| to |
            to seen key? [ ] [
                from to 2array network capacities>> at 0 or 0 > [
                    from to seen set-at to queue push
                ] when
            ] if
        ] each
        cursor 1 + cursor!
    ] while seen ;

:: augment-residual ( predecessors network -- amount )
    network sink>> :> node!
    1/0. :> amount!
    [ node network source>> = ] [
        node predecessors at :> from
        from node 2array network capacities>> at amount min amount!
        from node!
    ] until
    network sink>> node!
    [ node network source>> = ] [
        node predecessors at :> from
        from node 2array :> forward
        node from 2array :> reverse
        forward network capacities>> at amount - forward network capacities>> set-at
        reverse network capacities>> at 0 or amount + reverse network capacities>> set-at
        from node!
    ] until amount ;

:: solve-residency ( nodes edges -- plan )
    nodes edges <residency-network> :> network
    0 :> cost!
    network residual-search :> reached!
    [ network sink>> reached key? ] [
        reached network augment-residual cost + cost!
        network residual-search reached!
    ] while
    nodes length <iota> [ reached key? ] map cost residency-plan boa ;
