
USING: sets meta.util obj ;

IN: obj.papers

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: title    properties adjoin
SYM: abstract properties adjoin
SYM: authors  properties adjoin
SYM: file     properties adjoin
SYM: date     properties adjoin

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: paper  types adjoin
SYM: person types adjoin

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: randall-b-smith { type person } define-object
SYM: david-ungar     { type person } define-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: programming-as-an-experience
  {
    type     paper
    title    "Programming as an Experience: The Inspiration for Self"
    abstract "The Self system attempts to integrate intellectual and non-intellectual aspects of programming to create an overall experience. The language semantics, user interface, and implementation each help create this integrated experience. The language semantics embed the programmer in a uniform world of simple ob jects that can be modified without appealing to definitions of abstractions. In a similar way, the graphical interface puts the user into a uniform world of tangible objects that can be directly manipulated and changed without switching modes. The implementation strives to support the world-of-objects illusion by minimiz ing perceptible pauses and by providing true source-level semantics without sac rificing performance. As a side benefit, it encourages factoring. Although we see areas that fall short of the vision, on the whole, the language, interface, and im plementation conspire so that the Self programmer lives and acts in a consistent and malleable world of objects."
    authors  { randall-b-smith david-ungar }
    file     "/storage/papers/programming-as-experience.ps"
    date     1995
  }
define-object
