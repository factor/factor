! Copyright (C) 2011 Alex Vondrak.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: graphviz.attributes

TUPLE: graph-attributes
Damping
K
URL
aspect
bb
bgcolor
center
charset
clusterrank
color
colorscheme
comment
compound
concentrate
defaultdist
dim
dimen
diredgeconstraints
dpi
epsilon
esep
fillcolor
fontcolor
fontname
fontnames
fontpath
fontsize
id
label
labeljust
labelloc
landscape
layers
layersep
layout
levels
levelsgap
lheight
lp
lwidth
margin
maxiter
mclimit
mindist
mode
model
mosek
nodesep
nojustify
normalize
nslimit
nslimit1
ordering
orientation
outputorder
overlap
overlap_scaling
pack
packmode
pad
page
pagedir
pencolor
penwidth
peripheries
quadtree
quantum
rank
rankdir
ranksep
ratio
remincross
repulsiveforce
resolution
root
rotate
searchsize
sep
showboxes
size
smoothing
sortv
splines
start
style
stylesheet
target
tooltip
truecolor
viewport
voro_margin ;

TUPLE: node-attributes
URL
color
colorscheme
comment
distortion
fillcolor
fixedsize
fontcolor
fontname
fontsize
group
height
id
image
imagescale
label
labelloc
layer
margin
nojustify
orientation
penwidth
peripheries
pin
pos
rects
regular
root
samplepoints
shape
shapefile
showboxes
sides
skew
sortv
style
target
tooltip
vertices
width
z ;

TUPLE: edge-attributes
URL
arrowhead
arrowsize
arrowtail
color
colorscheme
comment
constraint
decorate
dir
edgeURL
edgehref
edgetarget
edgetooltip
fontcolor
fontname
fontsize
headURL
headclip
headhref
headlabel
headport
headtarget
headtooltip
href
id
label
labelURL
labelangle
labeldistance
labelfloat
labelfontcolor
labelfontname
labelfontsize
labelhref
labeltarget
labeltooltip
layer
len
lhead
lp
ltail
minlen
nojustify
penwidth
pos
samehead
sametail
showboxes
style
tailURL
tailclip
tailhref
taillabel
tailport
tailtarget
tailtooltip
target
tooltip
weight ;

: <graph-attributes> ( -- attrs )
    graph-attributes new ;

: <edge-attributes> ( -- attrs )
    edge-attributes new ;

: <node-attributes> ( -- attrs )
    node-attributes new ;
