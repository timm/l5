[about](about.html)  | [cols](cols.html) | [data](data.html) |
[eg](eg.html) | [lib](lib.html) | [num](num.html) | [row](row.html) |
[sample](sample.html) | [sym](sym.html)<hr>

# Coding Conventions

Every file should start with `require"lib"`.

Function argument conventions: 
- 1. two blanks denote optionas, four blanls denote locals:
- 2. prefix n,s,is,fun denotes number,string,bool,function; 
- 3. suffix s means list of thing (so names is list of strings)
- 4. c is a column index (usually)

Code starts with a help string, from which we extract settings to the `the`
variable.

Code ends with `eg`s, containing demo code. The command line

    lua eg.lua -e x

runs example `x`.
