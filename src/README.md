
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

 <img width='280' 
     align=right 
     src='https://fcit.usf.edu/matrix/wp-content/uploads/2016/12/Robot-11-C.png'>
    
[xplor](#xplorlua) | [xplorlib](#xplorliblua)

## Code Conventions

(1) The help string at top of file is parsed to create
the settings.  (2) Also, all the `go.x` functions can be run with
`lua xplor.lua -g x`.  (3) Lastly, this code's function arguments
have some type hints:

| _What_                | Notes |                                     
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
| <b>DATA:new</b>(t:`tab`) |  constructor |
| <b>ROW:new</b>(t:`tab`) |  constructor |
| <b>NUM:new</b>(n:`num`, s:`str`) |  constructor for summary of columns |
| <b>SYM:new</b>(n:`num`, s:`str`) |  summarize stream of symbols |
| <b>XY:new</b>(n:`num`, s:`str`, nlo:`num`, nhi:`num`, sym:`SYM`) |  Keep the `y` values from `xlo` to `xhi` |


## COLS	

| What | Notes |
|:---|:---|
| <b>load</b>(from,   data:`DATA`?) |  if string(from), read file. else, load from list |


## DATA	

| What | Notes |
|:---|:---|
| <b>DATA:add</b>(t:`tab`) |  add a new row, update column summaries. |
| <b>DATA:sorted</b>() |  sort `self.rows` |
| <b>DATA:bestRest</b>(m,  n:`num`) |  divide `self.rows` |


## NUM 	
If you are happy	

| What | Notes |
|:---|:---|
| <b>NUM:add</b>(x) |  Update  |
| <b>NUM:norm</b>(n:`num`) |  normalize `n` 0..1 (in the range lo..hi) |
| <b>NUM:discretize</b>(n:`num`) |  discretize `Num`s,rounded to (hi-lo)/bins |
| <b>NUM:merge</b>(xys:`[XY]`,  nMin:`num`) |  Can we combine any adjacent ranges? |


## SYM 	

| What | Notes |
|:---|:---|
| <b>SYM:add</b>(s:`str`,   n:`num`?) |  `n` times (default=1), update `self` with `s`  |
| <b>SYM:entropy</b>() |  entropy |
| <b>SYM:simpler</b>(sym:`SYM`,  tiny) |  is `self+sym` simpler than its parts? |


## XY 	

| What | Notes |
|:---|:---|
| <b>XY:__tostring</b>() |  print |
| <b>XY:add</b>(nx:`num`,  sy:`str`) |  Extend `xlo`,`xhi` to cover `x`. Add `y` to `self.y` |
| <b>XY:select</b>(row:`ROW`) |  Return true if `row` selected by `self` |
| <b>XY:selects</b>(rows:`[ROW]`) |  Return subset of `rows` selected by `self` |



#	xplorlib.lua	

some xxs not working	
need to do the 2 space thing	
----------------------------------------------------------------------------	
## Linting	
## Objects	
## Maths	

| What | Notes |
|:---|:---|
| <b>l.per</b>(t:`tab`,  p) |  return the pth (0..1) item of `t`. |


## Lists	

| What | Notes |
|:---|:---|
| <b>l.copy</b>(t:`tab`,  isDeep:`bool`) |  copy a list (deep copy if `isDep`) |
| <b>l.push</b>(t:`tab`,  x) |  push `x` onto `t`, return `x` |


### Sorting	

| What | Notes |
|:---|:---|
| <b>l.sort</b>(t:`tab`,  fun:`fun`) |  return `t`, sorted using function `fun` |
| <b>l.lt</b>(x) |  return function that sorts ascending on key `x` |


## Coercion	
### String to thing	

| What | Notes |
|:---|:---|
| <b>l.coerce</b>(s:`str`) |  Parse `the` config settings from `help` |
| <b>l.csv</b>(sFilename:`str`,  fun:`fun`) |  call `fun` on csv rows |


### Thing to String	

| What | Notes |
|:---|:---|
| <b>l.fmt</b>(str:`str`,  ...) |  emulate printf |
| <b>l.oo</b>(t:`tab`) |  Print a table `t` (non-recursive) |
| <b>l.o</b>(t:`tab`) |   Generate a print string for `t` (non-recursive) |


## Meta	

| What | Notes |
|:---|:---|
| <b>l.map</b>(t:`tab`,  fun:`fun`) |  Return `t`, filter through `fun(value)` (skip nils) |
| <b>l.kap</b>(t:`tab`,  fun:`fun`) |  Return `t` and its size, filtered via `fun(key,value)` |
| <b>l.keys</b>(t:`tab`) |  Return keys of `t`, sorted (skip any with prefix  `_`) |


## Settings	

| What | Notes |
|:---|:---|
| <b>l.settings</b>(s:`str`) |  parse help string to extract settings |
| <b>l.cli</b>(t:`tab`) |  update table slots via command-line flags |


## Runtime	

| What | Notes |
|:---|:---|
| <b>l.on</b>(configs:`tab`,  funs:`[fun]`) |  reset cofnig before running a demo |


