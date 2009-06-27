USING: help.markup help.syntax ui.frp.signals ;
IN: ui.frp.functors

ARTICLE: { "ui.frp.functors" "signal-collection" } "Signal Collection"
"While " { $vocab-link "models.arrow.smart" } " use arrows and products to apply a quotation to the values of more than one signal, frp has more than one kind of arrow, as well as more than one kind of product" $nl
"A simple pattern is used to generate the requisite 'smart mapping' functions: "
"if 'word' maps a function on a model, then '2word; would map on two models. "
"The product is specified on the end: '2word-product'. " { $link | } " updates when any of the model it collects updates, while " { $link & } " updates when all dependencies have new values. "
"Examples of collection functions are 2fmap-| and 2$>-&" ;
ABOUT: { "ui.frp.functors" "signal-collection" }