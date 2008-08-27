
USING: sets obj.util obj ;

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

SYM: bay-wei-chang   { type person } define-object
SYM: craig-chambers  { type person } define-object
SYM: david-ungar     { type person } define-object
SYM: randall-b-smith { type person } define-object
SYM: urs-holzle      { type person } define-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: programming-as-an-experience
  {
    type     paper
    title    "Programming as an Experience: The Inspiration for Self"
    abstract "The Self system attempts to integrate intellectual and non-intellectual aspects of programming to create an overall experience. The language semantics, user interface, and implementation each help create this integrated experience. The language semantics embed the programmer in a uniform world of simple ob jects that can be modified without appealing to definitions of abstractions. In a similar way, the graphical interface puts the user into a uniform world of tangible objects that can be directly manipulated and changed without switching modes. The implementation strives to support the world-of-objects illusion by minimiz ing perceptible pauses and by providing true source-level semantics without sac rificing performance. As a side benefit, it encourages factoring. Although we see areas that fall short of the vision, on the whole, the language, interface, and im plementation conspire so that the Self programmer lives and acts in a consistent and malleable world of objects."
    authors  { randall-b-smith david-ungar }
    date     1995
  }
define-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: self-the-power-of-simplicity
  {
    type paper
    title "Self: The Power of Simplicity"
    abstract "Self is an object-oriented language for exploratory programming based on a small number of simple and concrete ideas: prototypes, slots, and behavior. Prototypes combine inheritance and instantiation to provide a framework that is simpler and more flexible than most object-oriented languages. Slots unite variables and procedures into a single construct. This permits the inheritance hierarchy to take over the function of lexical scoping in conventional languages. Finally, because Self does not distinguish state from behavior, it narrows the gaps between ordinary objects, procedures, and closures. Self's simplicity and expressiveness offer new insights into object-oriented computation."
    authors { randall-b-smith david-ungar }
    date 1987
  }
define-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: parents-are-shared-parts
  {
    type paper
    title "Parents are Shared Parts: Inheritance and Encapsulation in Self"
    abstract "The design of inheritance and encapsulation in Self, an object-oriented language based on prototypes, results from understanding that inheritance allows parents to be shared parts of their children. The programmer resolves ambiguities arising from multiple inheritance by prioritizing an object's parents. Unifying unordered and ordered multiple inheritance supports differential programming of abstractions and methods, combination of unrelated abstractions, unequal combination of abstractions, and mixins. In Self, a private slot may be accessed if the sending method is a shared part of the receiver, allowing privileged communication between related objects. Thus, classless Self enjoys the benefits of class-based encapsulation."
    authors { craig-chambers david-ungar bay-wei-chang urs-holzle }
    date 1991
  }
define-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: organizing-programs-without-classes
  {
    type paper
    title "Organizing Programs Without Classes"
    abstract "All organizational functions carried out by classes can be accomplished in a simple and natural way by object inheritance in classless languages, with no need for special mechanisms. A single model--dividing types into prototypes and traits--supports sharing of behavior and extending or replacing representations. A natural extension, dynamic object inheritance, can model behavioral modes. Object inheritance can also be used to provide structured name spaces for well-known objects. Classless languages can even express 'class-based' encapsulation. These stylized uses of object inheritance become instantly recognizable idioms, and extend the repertory of organizing principles to cover a wider range of programs."
    authors { david-ungar craig-chambers bay-wei-chang urs-holzle }
    date 1991
  }
define-object
