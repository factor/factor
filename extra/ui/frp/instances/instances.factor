USING: accessors kernel models monads ui.frp.signals ui.frp.layout ui.gadgets ;
IN: ui.frp.instances

M: model >>= [ swap <action> ] curry ;
M: model fmap <mapped> ;

SINGLETON: gadget-monad
INSTANCE: gadget-monad monad
INSTANCE: gadget monad
M: gadget monad-of drop gadget-monad ;
M: gadget-monad return drop <gadget> swap >>model ;
M: gadget >>= output-model [ swap call( x -- y ) ] curry ; 
