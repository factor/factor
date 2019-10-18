class TreeNode extends Object [
    |left right item|

    method binarytrees: n to: output [
        | minDepth maxDepth stretchDepth check longLivedTree iterations |
        minDepth := 4.
        maxDepth := minDepth + 2 max: n.
        stretchDepth := maxDepth + 1.

        check := (TreeNode bottomUpTree: 0 depth: stretchDepth) itemCheck.
        output
            nextPutAll: 'stretch tree of depth '; print: stretchDepth; tab;
            nextPutAll: ' check: '; print: check; nl.

        longLivedTree := TreeNode bottomUpTree: 0 depth: maxDepth.
        minDepth to: maxDepth by: 2 do: [:depth|
            iterations := 1 bitShift: maxDepth - depth + minDepth.

            check := 0.
            1 to: iterations do: [:i|
                check := check + (TreeNode bottomUpTree: i depth: depth) itemCheck.
                check := check + (TreeNode bottomUpTree: -1*i depth: depth) itemCheck
            ].
            output
                print:  (2*iterations); tab;
                nextPutAll: ' trees of depth '; print: depth; tab;
                nextPutAll: ' check: '; print: check; nl
            ].

        output
            nextPutAll: 'long lived tree of depth '; print: maxDepth; tab;
            nextPutAll: ' check: '; print: longLivedTree itemCheck; nl
    ].
    
    method binarytrees: arg [
        self binarytrees: arg to: self stdout.
        ^''
    ].

    method left: leftChild right: rightChild item: anItem [
        left := leftChild.
        right := rightChild.
        item := anItem
    ].

    method itemCheck [
        ^left isNil
            ifTrue: [item] ifFalse: [item + (left itemCheck - right itemCheck)]
    ].

    method bottomUpTree: anItem depth: anInteger [
        ^(anInteger > 0)
            ifTrue: [
                self
                    left: (self bottomUpTree: 2*anItem - 1 depth: anInteger - 1)
                    right: (self bottomUpTree: 2*anItem depth: anInteger - 1)
                    item: anItem
            ] ifFalse: [self left: nil right: nil item: anItem]
    ].

    method left: leftChild right: rightChild item: anItem [
        ^(super new) left: leftChild right: rightChild item: anItem
    ]
].

