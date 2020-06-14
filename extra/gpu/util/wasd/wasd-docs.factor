USING: help.markup help.syntax math gpu.util.wasd ;
IN: gpu.util.wasd+docs

HELP: wasd-world
{ $class-description "A wasd-world is a 3d world in which the camera can move using the keybindings 'w', 'a', 's' and 'd' and the view can rotate using the camera." } ;

HELP: wasd-near-plane
{ $values
  { "world" wasd-world }
  { "near-plane" float }
} { $description "Near plane of the 3d world." } ;
