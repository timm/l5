
```css
KEYS: multi-objective semi-supervised explainations
(c)2022 Tim Menzies <timm@ieee.org> BSD-2 license

Usage: lua keysgo.lua [Options]

Options:
 -a  --aim   aim; One of {plan,watch,explore}    = plan
 -b  --bins  minimum bin width                   = 16
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

[keys](\#keys) | [keyslib](\#keyslib)
 
  <img width="280" 
      align=right 
      src="https://fcit.usf.edu/matrix/wp-content/uploads/2016/12/Robot-11-C.png">
   
 ## Code Conventions
   
 1. `function DATA:new()` is a  constructor for class e.g. DATA 
 2. The help string at top of file is parsed to create the settings.  
 3. Also, all the `go.xx` functions can be run with `lua xplor.lua -g x`.  
 4. Indent = 2 spaces
 5. Line width = 80 chars
 6. Public functions are denoted with a  "---", followed by comment text." 
 7. Public function arguments have the following type hints:
   
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
 - In the code, any upper case name (e.g. `DATA` defines a class type)
 - In public function arguments,
   lower case versions of class type (e.g. `data`) are instances of that type (e.g. 
   `data` isa `DATA`).
    
