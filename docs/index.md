 
# KEYS: Bayesian multi-objective optimization semi-supervised explanations
    
[![tests](https://github.com/timm/l5/actions/workflows/main.yml/badge.svg)](https://github.com/timm/l5/actions/workflows/main.yml)
![](https://img.shields.io/badge/language-lua-blue)
![](https://img.shields.io/badge/purpose-xai-orange)
[![](https://img.shields.io/badge/license-bsd2-lightgrey)](https://github.com/timm/l5/blob/main/LICENSE.md#top)
 

```css
KEYS: Bayesian multi-objective semi-supervised explanations
(c)2022 Tim Menzies <timm@ieee.org> BSD-2 license

  .-------.                dispute: where bad==better
  | Ba    | Bad <----.     plan   : better - bad
  |    56 |          |     watch  : bad - better
  .-------.------.   |     explore: where bad and better is scarce
          | Be   |   v  
          |    4 | Better
          .------.

Usage: lua keysgo.lua [Options]

Options:
 -a  --aim   aim: plan,watch,explore or dispute  = plan
 -b  --bins  minimum bin width                   = 16
 -B  --beam  beam size                           = 10
 -f  --file  file with csv data                  = ../../data/auto93.csv
 -g  --go    start-up example                    = nothing
 -h  --help  show help                           = false
 -K  --K     Bayes hack: low attribute frequency = 1
 -M  --M     Bayes hack: low class frequency     = 2
 -m  --min   stop at n^Min                       = .5
 -r  --rest  expansion best to rest              = 5
 -S  --Some  How many items to keep per row      = 256
 -s  --seed  random number seed                  = 10019
```

  
[keys](keyslua) | [keyslib](keysliblua)
  
<img width="350" 
     align=right 
     src="http://division14robots.weebly.com/uploads/2/6/1/9/26190497/3183350_orig.png">
   
## Code Conventions
   
 1. x.lua is the main code. `xlib.lua` are some general utils. `xgo.lua1
    holds demos/tests of the system.
 2. All the `go.xx` functions in `xgo.lua` can be run via `lua xgo.lua -g x`.  
 3. Indent = 2 spaces
 4. Line width = 80 chars (soft limit)
 5. The help string at top of file is parsed to create a table of global
    settings, store in the `the` variable.
 6. Slots of `the` are updated by command-line flags. 
    - Flags update the first
       slot they match to E.g.   `lua xgo.lua -s 1234` resets `the.seed` 
       (since   `seed` starts with `s`. 
     - If a boolean slot appears on the command line, it
       does not need a following value (we just flip the default value). e.g.
       `lua xgo.lua -h` flips `the.help` from `false` to `true
 7. Any word starting with two upper case leading letters is a class; e.g. DATA
 8. `function DATA:new()` is a  constructor for class e.g. DATA . Constructors 
    are based in `self` so should not use a return statement.
 9. Public functions are denoted with a  trailing "---", followed by comment text. 
 10. Public function arguments have the following type hints:
   
 | What        | Notes |                                     
 |:------------|:-----------------------------------|
 | 2 blanks    | 2 blanks denote optional arguments |
 | 4 blanks    | 4 blanks denote local arguments |
 | n           | prefix for numerics |
 | s           | prefix for strings |
 | is          | prefix for booleans |
 | suffix fun  | suffix for functions |                      
 | suffix s    | list of thing (so `names` is list of strings) |
    
Other conventions:
    
 - In public function arguments,
   lower case versions of class type (e.g. `data`) are instances of that type (e.g. 
   `data` isa `DATA` so `datas` is a list of `DATA` instances).
 - Polymorphism yes, inheritance no. Why? Well...
   http://www.cs.kent.edu/~jmaletic/cs69995-PC/papers/Hatton98.pdf     
   https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.467.5571&rep=rep1&type=pdf
 

#	keys.lua	


| What | Notes |
|:---|:---|
| <b>XY:new(s:`str`, n:`num`, nlo:`num`, nhi:`num`)</b> |  Count the `y` values from `xlo` to `xhi` |
| <b>XY:__tostring()</b> |  print |
| <b>XY:add(nx:`num`, sy:`str`,   n:`num`?)</b> |  `n`[=1] times,count `sy`. Expand to cover `nx`  |
| <b>XY:merge(xy:`XY`)</b> |  combine two items (assumes both from same column) |
| <b>XY:score(want, B, R)</b> |  how well does `self` select for `want`? |
| <b>XY:select(row)</b> |  return true if `row` selected by `self` |
| <b>XY:selects(rows:`tab`)</b> |  return subset of `rows` selected by `self` |
| <b>XY:simpler(xy:`XY`, nMin:`num`)</b> |  if whole simpler than parts, return merged self+xy |


### Class methods 	
For lists of `xy`s.	

| What | Notes |
|:---|:---|
| <b>XY.like(xys:`[XY]`, sWant:`str`, nB:`num`, nR:`num`)</b> |  likelihood we do/dont `sWant` `xys` |
| <b>XY.canonical(xys:`[XY]`)</b> |  simplify a list of `xy` ranges |
| <b>COL:merge(xys:`[XY]`,  nMin:`num`)</b> |  Can we combine any adjacent ranges? |
| <b>DATA:sorted()</b> |  sort `self.rows` |


That's all folks	

#	keyslib.lua	

keyslib.lua: misc lua routines	
(c)2022, Tim Menzies BSD-2 clause	
## Linting	

| What | Notes |
|:---|:---|
| <b>l.rogues()</b> |  report rogue locals |


## Maths	
### Random number generator	
The LUA doco says its random number generator is not stable across platforms.	
Hence, we use our own (using Park-Miller).	

| What | Notes |
|:---|:---|
| <b>l.srand(n:`num`)</b> |  reset random number seed (defaults to 937162211)  |
| <b>l.rand(nlo:`num`, nhi:`num`)</b> |  return float from `nlo`..`nhi` (default 0..1) |
| <b>l.rint(nlo:`num`, nhi:`num`)</b> |  returns integer from `nlo`..`nhi` (default 0..1) |


## Lists	

| What | Notes |
|:---|:---|
| <b>l.ent(t:`tab`)</b> |  entropy |
| <b>l.kap(t:`tab`,  fun:`fun`)</b> |  map function `fun`(k,v) over list (skip nil results)  |
| <b>l.keys(t:`tab`)</b> |  sort+return `t`'s keys (ignore things with leading `_`) |
| <b>l.map(t:`tab`,  fun:`fun`)</b> |  map function `fun`(v) over list (skip nil results)  |
| <b>l.push(t:`tab`,  x)</b> |  push `x` to end of list; return `x`  |
| <b>l.sd(t:`tab`)</b> |  sorted list standard deviation= (90-10)th percentile/2.58 |
| <b>l.top(n:`num`, t:`tab`)</b> |  return first `n` items from `t`. |


### Sorting Lists	

| What | Notes |
|:---|:---|
| <b>l.sort(t:`tab`,  fun:`fun`)</b> |  return `t`,  sorted by `fun` (default= `<`) |


## Coercion	
### Strings to Things	

| What | Notes |
|:---|:---|
| <b>l.coerce(s:`str`)</b> |  return int or float or bool or string from `s` |
| <b>l.options(s:`str`)</b> |  parse help string to extract a table of options |
| <b>l.csv(sFilename:`str`, fun:`fun`)</b> |  call `fun` on rows (after coercing cell text) |


### Things to Strings	

| What | Notes |
|:---|:---|
| <b>l.fmt(sControl:`str`, ...)</b> |  emulate printf |
| <b>l.oo(t:`tab`)</b> |  print `t`'s string (the one generated by `o`) |
| <b>l.o(t:`tab`,   seen:`str`?)</b> |  table to string (recursive) |


## Objects	

| What | Notes |
|:---|:---|
| <b>l.obj(s:`str`)</b> |  Create a klass and a constructor + print method |


That's all folks.	
