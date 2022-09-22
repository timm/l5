Conventions: (1) The help string at top of file is parsed to create	
the settings.  (2) Also, all the `go.x` functions can be run with	
`lua xplor.lua -g x`.  (3) Lastly, this code's function arguments	
have some type hints:	
   	
| What|Notes|                                     	
|:----|:----|	
| 2 blanks            | 2 blanks denote optional arguments |	
| 4 blanks            | 4 blanks denote local arguments |	
| n                   | prefix for numerics |	
| s                   | prefix for strings |	
| is                  | prefix for booleans |	
| fun                 | prefix for functions |                      	
| suffix s            | list of thing (so names is list of strings)|	
| function SYM:new()  | constructor for class e.g. SYM |	
| e.g. sym            | denotes an instance of class constructor |	
   	
## Classes	

| What | Notes |
|:---|:---|
| DATA(t:`tab`)  | constructor |
| NUM(n:`num`, s:`str`)  | constructor for summary of columns |
| SYM(n:`num`, s:`str`)  | summarize stream of symbols |
| XY(n:`num`, s:`str`, nlo:`num`, nhi:`num`, sym:`SYM`)  | Keep the `y` values from `xlo` to `xhi` |
| load(src:`str`,  data:`DATA`)  | if string(src), read file. else, load from list |


## DATA 	

| What | Notes |
|:---|:---|
| DATA:add(t:`tab`)  | add a new row, update column summaries. |
| DATA:sorted()  | sort `self.rows` |
| DATA:bestRest(m, n:`num`) | divide `self.rows` |


## NUM  	
If you are happy	

| What | Notes |
|:---|:---|
| NUM:add(x)  | Update  |
| NUM:norm(n:`num`)  | normalize `n` 0..1 (in the range lo..hi) |
| NUM:discretize(n:`num`) | discretize `Num`s,rounded to (hi-lo)/bins |
| NUM:merge(xys:`[XY]`, nMin:`num`)  | Can we combine any adjacent ranges? |


## SYM  	

| What | Notes |
|:---|:---|
| SYM:add(s:`str`) | `n` times (default=1), update `self` with `s`  |
| SYM:entropy() | entropy |
| SYM:simpler(sym:`SYM`, tiny)  | is `self+sym` simpler than its parts? |


## XY  	

| What | Notes |
|:---|:---|
| XY:__tostring()  | print |
| XY:add(nx:`num`, sy:`str`)  | Extend `xlo`,`xhi` to cover `x`. Add `y` to `self.y` |
| XY:select(row) | Return true if `row` selected by `self` |
| XY:selects(rows)  | Return subset of `rows` selected by `self` |


	
