
```css
Xplor: Bayesian active learning
(c) 2022 Tim Menzies <timm@ieee.org> Bsd-2 license

Usage: lua xplorgo.lua [Options]

Options:
 -f  --file  file with csv data                  = ../data/auto93.csv
 -g  --go    start-up example                    = nothing
 -h  --help  show help                           = false
 -k  --k     Bayes hack: low attribute frequency = 1
 -m  --m     Bayes hack: low class frequency     = 2
 -M  --Min   stop at n^Min                       = .5
 -r  --rest  expansion best to rest              = 5
 -S  --Some  How many items to keep per row      = 256
 -s  --seed  random number seed                  = 10019
```

[xplor](#xplorlua) | [xplorlib](#xplorliblua)

 <img width='280' 
     align=right 
     src='https://fcit.usf.edu/matrix/wp-content/uploads/2016/12/Robot-11-C.png'>

## Code Conventions

(1) The help string at top of file is parsed to create
the settings.  (2) Also, all the `go.x` functions can be run with
`lua xplor.lua -g x`.  (3) Lastly, this code's function arguments
have some type hints:

| What                | Notes |                                     
|:--------------------|:-----------------------------------|
| 2 blanks            | 2 blanks denote optional arguments |
| 4 blanks            | 4 blanks denote local arguments |
| n                   | prefix for numerics |
| s                   | prefix for strings |
| is                  | prefix for booleans |
| suffix fun          | suffix for functions |                      
| suffix s            | list of thing (so names is list of strings)|
| function SYM:new()  | constructor for class e.g. SYM |
| e.g. sym            | denotes an instance of class constructor |


#	xplor.lua	

## Classes	

| What | Notes |
|:---|:---|
| DATA:new( <b>t</b>:`tab`) |  constructor |
| ROW:new( <b>t</b>:`tab`) |  constructor |
| NUM:new( <b>n</b>:`num`,  <b>s</b>:`str`) |  constructor for summary of columns |
| SYM:new( <b>n</b>:`num`,  <b>s</b>:`str`) |  summarize stream of symbols |
| XY:new( <b>n</b>:`num`,  <b>s</b>:`str`,  <b>nlo</b>:`num`,  <b>nhi</b>:`num`,  <b>sym</b>:`SYM`) |  Keep the `y` values from `xlo` to `xhi` |


## COLS	

| What | Notes |
|:---|:---|
| load( <b>from</b>,    <b>data</b>:`DATA`?) |  if string(from), read file. else, load from list |


## DATA	

| What | Notes |
|:---|:---|
| DATA:add( <b>t</b>:`tab`) |  add a new row, update column summaries. |
| DATA:sorted() |  sort `self.rows` |
| DATA:bestRest( <b>m</b>,   <b>n</b>:`num`?) |  divide `self.rows` |


## NUM 	
If you are happy	

| What | Notes |
|:---|:---|
| NUM:add( <b>x</b>) |  Update  |
| NUM:norm( <b>n</b>:`num`) |  normalize `n` 0..1 (in the range lo..hi) |
| NUM:discretize( <b>n</b>:`num`) |  discretize `Num`s,rounded to (hi-lo)/bins |
| NUM:merge( <b>xys</b>:`[XY]`,   <b>nMin</b>:`num`?) |  Can we combine any adjacent ranges? |


## SYM 	

| What | Notes |
|:---|:---|
| SYM:add( <b>s</b>:`str`,    <b>n</b>:`num`?) |  `n` times (default=1), update `self` with `s`  |
| SYM:entropy() |  entropy |
| SYM:simpler( <b>sym</b>:`SYM`,   <b>tiny</b>?) |  is `self+sym` simpler than its parts? |


## XY 	

| What | Notes |
|:---|:---|
| XY:__tostring() |  print |
| XY:add( <b>nx</b>:`num`,   <b>sy</b>:`str`?) |  Extend `xlo`,`xhi` to cover `x`. Add `y` to `self.y` |
| XY:select( <b>row</b>:`ROW`) |  Return true if `row` selected by `self` |
| XY:selects( <b>rows</b>:`[ROW]`) |  Return subset of `rows` selected by `self` |



#	xplorlib.lua	

some xxs not working	
need to do the 2 space thing	
----------------------------------------------------------------------------	
## Linting	
## Objects	
## Maths	

| What | Notes |
|:---|:---|
| l.per( <b>t</b>:`tab`,   <b>p</b>?) |  return the pth (0..1) item of `t`. |


## Lists	

| What | Notes |
|:---|:---|
| l.copy( <b>t</b>:`tab`,   <b>isDeep</b>:`bool`?) |  copy a list (deep copy if `isDep`) |
| l.push( <b>t</b>:`tab`,   <b>x</b>?) |  push `x` onto `t`, return `x` |


### Sorting	

| What | Notes |
|:---|:---|
| l.sort( <b>t</b>:`tab`,   <b>fun</b>:`fun`?) |  return `t`, sorted using function `fun` |
| l.lt( <b>x</b>) |  return function that sorts ascending on key `x` |


## Coercion	
### String to thing	

| What | Notes |
|:---|:---|
| l.coerce( <b>s</b>:`str`) |  Parse `the` config settings from `help` |
| l.csv( <b>sFilename</b>:`str`,   <b>fun</b>:`fun`?) |  call `fun` on csv rows |


### Thing to String	

| What | Notes |
|:---|:---|
| l.fmt( <b>str</b>:`str`,   <b>...</b>?) |  emulate printf |
| l.oo( <b>t</b>:`tab`) |  Print a table `t` (non-recursive) |
| l.o( <b>t</b>:`tab`) |   Generate a print string for `t` (non-recursive) |


## Meta	

| What | Notes |
|:---|:---|
| l.map( <b>t</b>:`tab`,   <b>fun</b>:`fun`?) |  Return `t`, filter through `fun(value)` (skip nils) |
| l.kap( <b>t</b>:`tab`,   <b>fun</b>:`fun`?) |  Return `t` and its size, filtered via `fun(key,value)` |
| l.keys( <b>t</b>:`tab`) |  Return keys of `t`, sorted (skip any with prefix  `_`) |


## Settings	

| What | Notes |
|:---|:---|
| l.settings( <b>s</b>:`str`) |  parse help string to extract settings |
| l.cli( <b>t</b>:`tab`) |  update table slots via command-line flags |


## Runtime	

| What | Notes |
|:---|:---|
| l.on( <b>configs</b>:`tab`,   <b>funs</b>:`[fun]`?) |  reset cofnig before running a demo |


