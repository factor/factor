PROVIDE: demos/nehe
{ 
  +files+ { 
    "nehe2.factor" 
    "nehe3.factor" 
    "nehe4.factor" 
    "nehe5.factor" 
    ! "nehe6.factor" 
  }
} ;

USING: kernel gadgets nehe sequences gadgets-buttons ;

MAIN: demos/nehe
[
    "Nehe 2" [ drop run2 ] <bevel-button> gadget,
    "Nehe 3" [ drop run3 ] <bevel-button> gadget,
    "Nehe 4" [ drop run4 ] <bevel-button> gadget,
    "Nehe 5" [ drop run5 ] <bevel-button> gadget,
    ! "Nehe 6" [ drop run6 ] <bevel-button> gadget,
] make-filled-pile "Nehe examples" open-window ;
