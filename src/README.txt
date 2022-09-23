 <img width='280' 
     align=right 
     src='https://fcit.usf.edu/matrix/wp-content/uploads/2016/12/Robot-11-C.png'>
    
[xplor](#xplorlua) | [xplorlib](#xplorliblua) <hr>

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

