
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
| DATA:new(t:`tab`) |  constructor |
| ROW:new(t:`tab`) |  constructor |
| NUM:new(n:`num`, s:`str`) |  constructor for summary of columns |
| SYM:new(n:`num`, s:`str`) |  summarize stream of symbols |
| XY:new(n:`num`, s:`str`, nlo:`num`, nhi:`num`, sym:`SYM`) |  Keep the `y` values from `xlo` to `xhi` |


## COLS 	

| What | Notes |
|:---|:---|
| load(from,   data:`DATA`?) |  if string(from), read file. else, load from list |


## DATA 	

| What | Notes |
|:---|:---|
| DATA:add(t:`tab`) |  add a new row, update column summaries. |
| DATA:sorted() |  sort `self.rows` |
| DATA:bestRest(m,  n:`num`) |  divide `self.rows` |


## NUM  	
If you are happy	

| What | Notes |
|:---|:---|
| NUM:add(x) |  Update  |
| NUM:norm(n:`num`) |  normalize `n` 0..1 (in the range lo..hi) |
| NUM:discretize(n:`num`) |  discretize `Num`s,rounded to (hi-lo)/bins |
| NUM:merge(xys:`[XY]`,  nMin:`num`) |  Can we combine any adjacent ranges? |


## SYM  	

| What | Notes |
|:---|:---|
| SYM:add(s:`str`,   n:`num`?) |  `n` times (default=1), update `self` with `s`  |
| SYM:entropy() |  entropy |
| SYM:simpler(sym:`SYM`,  tiny) |  is `self+sym` simpler than its parts? |


## XY  	

| What | Notes |
|:---|:---|
| XY:__tostring() |  print |
| XY:add(nx:`num`,  sy:`str`) |  Extend `xlo`,`xhi` to cover `x`. Add `y` to `self.y` |
| XY:select(row:`ROW`) |  Return true if `row` selected by `self` |
| XY:selects(rows:`[ROW]`) |  Return subset of `rows` selected by `self` |



#	xplorlib.lua	

some xxs not working	
need to do the 2 space thing	
	
## Linting	
## Objects	
## Maths	

| What | Notes |
|:---|:---|
| l.per(t:`tab`,  p) |  return the pth (0..1) item of `t`. |


## Lists	

| What | Notes |
|:---|:---|
| l.copy(t:`tab`,  isDeep:`bool`) |  copy a list (deep copy if `isDep`) |
| l.push(t:`tab`,  x) |  push `x` onto `t`, return `x` |


### Sorting	

| What | Notes |
|:---|:---|
| l.sort(t:`tab`,  fun:`fun`) |  return `t`, sorted using function `fun` |
| l.lt(x) |  return function that sorts ascending on key `x` |


## Coercion	
### String to thing	

| What | Notes |
|:---|:---|
| l.coerce(s:`str`) |  Parse `the` config settings from `help` |
| l.csv(sFilename:`str`,  fun:`fun`) |  call `fun` on csv rows |


### Thing to String	

| What | Notes |
|:---|:---|
| l.fmt(str:`str`,  ...) |  emulate printf |
| l.oo(t:`tab`) |  Print a table `t` (non-recursive) |
| l.o(t:`tab`) |   Generate a print string for `t` (non-recursive) |


## Meta	

| What | Notes |
|:---|:---|
| l.map(t:`tab`,  fun:`fun`) |  Return `t`, filter through `fun(value)` (skip nils) |
| l.kap(t:`tab`,  fun:`fun`) |  Return `t` and its size, filtered via `fun(key,value)` |
| l.keys(t:`tab`) |  Return keys of `t`, sorted (skip any with prefix  `_`) |


## Settings	

| What | Notes |
|:---|:---|
| l.settings(s:`str`) |  parse help string to extract settings |
| l.cli(t:`tab`) |  update table slots via command-line flags |


## Runtime	

| What | Notes |
|:---|:---|
| l.on(configs:`tab`,  funs:`[fun]`) |  reset cofnig before running a demo |


