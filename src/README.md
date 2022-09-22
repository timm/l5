

## Linting


## Objects


## Maths

| What | Notes |
|:---:|----|
| l.per(t,p)  | return the pth (0..1) item of `t`. |
| l.ent(t)  | entropy of a list of counts |


## Lists

| What | Notes |
|:---:|----|
| l.copy(t, deep,    u)  | copy a list (shallow copy if `deep` is false) |
| l.push(t,x)   | push `x` onto `t`, return `x` |


### Sorting

| What | Notes |
|:---:|----|
| l.sort(t,fun)  | return `t`, sorted using function `fun`.  |
| l.lt(x)  | return function that sorts ascending on key `x` |


## Coercion


### String to thing

| What | Notes |
|:---:|----|
| l.coerce(s,    fun)  | Parse `the` config settings from `help`. |
| l.csv(sFilename, fun,      src,s,t)  | call `fun` on csv rows. |


### Thing to String

| What | Notes |
|:---:|----|
| l.fmt(str,...)  | emulate printf |
| l.oo(t)   | Print a table `t` (non-recursive) |
| l.o(t)  |  Generate a print string for `t` (non-recursive) |


## Meta

| What | Notes |
|:---:|----|
| l.map(t,fun)  | Return `t`, filter through `fun(value)` (skip nils) |
| l.kap(t,fun)  | Return `t` and its size, filtered via `fun(key,value)` |
| l.keys(t)  | Return keys of `t`, sorted (skip any with prefix  `_`) |


## Settings

| What | Notes |
|:---:|----|
| l.settings(txt,    t)  | parse help string to extract settings |
| l.cli(t)  | update table slots via command-line flags |


## Runtime


  