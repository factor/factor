PROVIDE: demos/nehe
{ 
  +files+ { 
    "nehe-utils.factor" 
    "nehe2.factor" 
    "nehe3.factor" 
    "nehe4.factor" 
  }
} ;

USING: kernel gadgets nehe sequences gadgets-buttons ;

MAIN: demos/nehe
  { 
    { "Nehe 2" [ drop run2 ] } 
    { "Nehe 3" [ drop run3 ] } 
    { "Nehe 4" [ drop run4 ] } 
  } [ first2 <bevel-button> ] map make-pile 
  "Nehe examples" open-titled-window ;