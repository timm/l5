
<pre>

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
</pre>

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
| DATA:new(<i>t</i>:`tab`) |  constructor |
| ROW:new(<i>t</i>:`tab`) |  constructor |
| NUM:new(<i>n</i>:`num`, <i>s</i>:`str`) |  constructor for summary of columns |
| SYM:new(<i>n</i>:`num`, <i>s</i>:`str`) |  summarize stream of symbols |
| XY:new(<i>n</i>:`num`, <i>s</i>:`str`, <i>nlo</i>:`num`, <i>nhi</i>:`num`, <i>sym</i>:`SYM`) |  Keep the `y` values from `xlo` to `xhi` |


## COLS	

| What | Notes |
|:---|:---|
| load(<i>from</i>,   <i>data</i>:`DATA`?) |  if string(from), read file. else, load from list |


## DATA	

| What | Notes |
|:---|:---|
| DATA:add(<i>t</i>:`tab`) |  add a new row, update column summaries. |
| DATA:sorted() |  sort `self.rows` |
| DATA:bestRest(<i>m</i>,  <i>n</i>:`num`) |  divide `self.rows` |


## NUM 	
If you are happy	

| What | Notes |
|:---|:---|
| NUM:add(<i>x</i>) |  Update  |
| NUM:norm(<i>n</i>:`num`) |  normalize `n` 0..1 (in the range lo..hi) |
| NUM:discretize(<i>n</i>:`num`) |  discretize `Num`s,rounded to (hi-lo)/bins |
| NUM:merge(<i>xys</i>:`[XY]`,  <i>nMin</i>:`num`) |  Can we combine any adjacent ranges? |


## SYM 	

| What | Notes |
|:---|:---|
| SYM:add(<i>s</i>:`str`,   <i>n</i>:`num`?) |  `n` times (default=1), update `self` with `s`  |
| SYM:entropy() |  entropy |
| SYM:simpler(<i>sym</i>:`SYM`,  <i>tiny</i>) |  is `self+sym` simpler than its parts? |


## XY 	

| What | Notes |
|:---|:---|
| XY:__tostring() |  print |
| XY:add(<i>nx</i>:`num`,  <i>sy</i>:`str`) |  Extend `xlo`,`xhi` to cover `x`. Add `y` to `self.y` |
| XY:select(<i>row</i>:`ROW`) |  Return true if `row` selected by `self` |
| XY:selects(<i>rows</i>:`[ROW]`) |  Return subset of `rows` selected by `self` |



#	xplorlib.lua	

some xxs not working	
need to do the 2 space thing	
----------------------------------------------------------------------------	
## Linting	
## Objects	
## Maths	

| What | Notes |
|:---|:---|
| l.per(<i>t</i>:`tab`,  <i>p</i>) |  return the pth (0..1) item of `t`. |


## Lists	

| What | Notes |
|:---|:---|
| l.copy(<i>t</i>:`tab`,  <i>isDeep</i>:`bool`) |  copy a list (deep copy if `isDep`) |
| l.push(<i>t</i>:`tab`,  <i>x</i>) |  push `x` onto `t`, return `x` |


### Sorting	

| What | Notes |
|:---|:---|
| l.sort(<i>t</i>:`tab`,  <i>fun</i>:`fun`) |  return `t`, sorted using function `fun` |
| l.lt(<i>x</i>) |  return function that sorts ascending on key `x` |


## Coercion	
### String to thing	

| What | Notes |
|:---|:---|
| l.coerce(<i>s</i>:`str`) |  Parse `the` config settings from `help` |
| l.csv(<i>sFilename</i>:`str`,  <i>fun</i>:`fun`) |  call `fun` on csv rows |


### Thing to String	

| What | Notes |
|:---|:---|
| l.fmt(<i>str</i>:`str`,  <i>...</i>) |  emulate printf |
| l.oo(<i>t</i>:`tab`) |  Print a table `t` (non-recursive) |
| l.o(<i>t</i>:`tab`) |   Generate a print string for `t` (non-recursive) |


## Meta	

| What | Notes |
|:---|:---|
| l.map(<i>t</i>:`tab`,  <i>fun</i>:`fun`) |  Return `t`, filter through `fun(value)` (skip nils) |
| l.kap(<i>t</i>:`tab`,  <i>fun</i>:`fun`) |  Return `t` and its size, filtered via `fun(key,value)` |
| l.keys(<i>t</i>:`tab`) |  Return keys of `t`, sorted (skip any with prefix  `_`) |


## Settings	

| What | Notes |
|:---|:---|
| l.settings(<i>s</i>:`str`) |  parse help string to extract settings |
| l.cli(<i>t</i>:`tab`) |  update table slots via command-line flags |


## Runtime	

| What | Notes |
|:---|:---|
| l.on(<i>configs</i>:`tab`,  <i>funs</i>:`[fun]`) |  reset cofnig before running a demo |


