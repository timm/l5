                  ___                     
                 /\_ \                    
 __  _   _____   \//\ \      ___    _ __  
/\ \/'\ /\ '__`\   \ \ \    / __`\ /\`'__\
\/>  </ \ \ \L\ \   \_\ \_ /\ \L\ \\ \ \/ 
 /\_/\_\ \ \ ,__/   /\____\\ \____/ \ \_\ 
 \//\/_/  \ \ \/    \/____/ \/___/   \/_/ 
           \ \_\                          
            \/_/                          
--
local l=require"xplorlib"
local the= l.settings[[

XPLOR: Bayesian active learning
(c) 2022 Tim Menzies <timm@ieee.org> BSD-2 license

USAGE: lua xplorgo.lua [OPTIONS]

OPTIONS:
 -f  --file  file with csv data                  = ../data/auto93.csv
 -g  --go    start-up example                    = nothing
 -h  --help  show help                           = false
 -k  --k     Bayes hack: low attribute frequency = 1
 -m  --m     Bayes hack: low class frequency     = 2
 -M  --Min   stop at n^Min                       = .5
 -r  --rest  expansion best to rest              = 5
 -S  --Some  How many items to keep per row      = 256
 -s  --seed  random number seed                  = 10019]]

--[[
## Classes
| DATA(t)               | constructor                                              |
| NUM(n,s)              | constructor for summary of columns                       |
| SYM(n,s)              | summarize stream of symbols                              |
| XY(n,s,nlo,nhi,sym)   | Keep the `y` values from `xlo` to `xhi`                  |

## DATA
| DATA:add(t)           | add a new row, update column summaries.                  |
| DATA:sorted()         | sort `self.rows`                                         |
| DATA:bestRest(m,n)    | divide `self.rows`                                       |

## NUM
| NUM:add(x)            | Update                                                   |
| NUM:norm(n)           | normalize `n` 0..1 (in the range lo..hi)                 |
| NUM:discretize(n)     | discretize `Num`s,rounded to (hi-lo)/bins                |
| NUM:merge(xys,nMin)   | Can we combine any adjacent ranges?                      |

## SYM
| SYM:add(s)            | `n` times (default=1), update `self` with `s`            |
| SYM:entropy()         | entropy                                                  |
| SYM:simpler(sym,tiny) | is `self+sym` simpler than its parts?                    |

## XY
| XY:add(x,y)           | Update `xlo`,`xhi` to cover `x`. And add `y` to `self.y` |
| XY:select(row)        | Return true if `row` selected by `self`                  |
| XY:selects(rows)      | Return subset of `rows` selected by `self`               |

CONVENTIONS: (1) The help string at top of file is parsed to create
the settings.  (2) Also, all the `go.x` functions can be run with
`lua xplor.lua -g x`.  (3) Lastly, this code's function arguments
have some type hints:

| What               | Notes                                       |
|:------------------:|---------------------------------------------|
| 2 blanks           | 2 blanks denote optional arguments          |
| 4 blanks           | 4 blanks denote local arguments             |
| n                  | prefix for numerics                         |
| s                  | prefix for strings                          |
| is                 | prefix for booleans                         |
| fun                | prefix for functions                        |
| suffix s           | list of thing (so names is list of strings) |
| function SYM:new() | constructor for class e.g. SYM              |
| e.g. sym           | denotes an instance of class constructor    |
--]]
local betters,coerce,csv           = l.betters, l.coerce, l.csv
local fmt,kap,keys,lt,map,o        = l.fmt,l.kap,l.keys,l.lt,l.map,l.o
local obj,oo,ordered,per,push,sort = l.obj,l.oo,l.ordered,l.per,l.push,l.sort 
local is = {}

-- ## Classes
local COLS,DATA,NUM,SYM,XY = obj"COLS", obj"DATA", obj"NUM", obj"SYM", obj"XY"

function DATA:new(t) --- constructor
   return  {names=t, 
           rows={}, 
           cols=COLS(t) } end

function COLS:new(t)
  return self:columns({names=t, 
                       klass=nil,
                       all={}, 
                       x={}, 
                       y={}}) end 

function NUM:new(n,s) --- constructor for summary of columns
  n,s = n or 0, s or ""
  return {n=0, 
          at=n, 
          name=s, 
          mu=0, m2=0, 
          lo=1E32, hi=-1E32, 
          w=is.weight(s)} end

function SYM:new(n,s) --- summarize stream of symbols
  return {n=0, at=n, name=s, 
          mode=nil, 
          most=-1, 
          has={}} end

function XY:new(n,s,nlo,nhi,sym) --- Keep the `y` values from `xlo` to `xhi`
  return {txt= s,                    -- name of this column
          at  = n,                   -- offset for this column
          xlo = nlo,                 -- min x seen so far
          xhi = nhi or nlo,          -- max x seen so far
          y   = sym or SYM(n,s)} end -- y symbols see so far

-- ## COLS ----- ----- ---------------------------------------------------------
function is.skip(s)   return s:find":$"     end
function is.num(s)    return s:find"^[A-Z]" end
function is.goal(s)   return s:find"[!+-]$" end
function is.klass(s)  return s:find"!$"     end
function is.weight(s) return s:find"-$" and -1 or 1 end

function COLS:columns(cols,    col) 
  for n,s in pairs(cols.names) do
    col = (is.num(s) and NUM or SYM)(n,s)
    push(cols.all, col)
    if not is.skip(s) then
      if is.klass(s) then cols.klass= col end
      push(is.goal(s) and cols.y or cols.x, col) end end 
  return cols end

function COLS:add(t)
  for _,cols in pairs({self.x, self.y}) do
    for _,col in pairs(cols) do
       col:add(t[col.at]) end end end

function load(src,  data,    fun)
  function fun(t) if data then data:add(t) else data=DATA(t) end end
  if type(src)=="string" then csv(src, fun) else map(src or {}, fun) end
  return data end

-- ## DATA ----- ----- ---------------------------------------------------------
function DATA:add(t) --- add a new row, update column summaries.
  push(self.rows,t)
  self.cols:add(t) end

function DATA:sorted() --- sort `self.rows`
    return sort(self.rows, 
                function(row1,row2,    s1,s2,x,y)
                  s1,s2,x,y=0,0
                  for _,col in pairs(self.cols.y) do
                    x = col:norm(row1[col.at])
                    y = col:norm(row2[col.at])
                    s1= s1 - math.exp(col.w * (x-y)/#self.cols.y)
                    s2= s2 - math.exp(col.w * (y-x)/#self.cols.y) end
                  return s1/#self.cols.y < s2/#self.cols.y end) end
                     
function DATA:bestRest(m,n,     best,rest,rows) --- divide `self.rows`
  best, rest, rows = {}, {}, self:sorted()
  for i = 1,m do push(best, rows[i]) end 
  for i = m+1,#rows, (#rows - m+1)/(n*m)//1 do push(rest, rows[i]) end
  return best, rest end 
 
local function xys(col,datas)
  local n,all,xys = 0,{},{}
  for y,data in pairs(datas) do
    for _,row in pairs(data.rows) do
      local x = row[col.at]
      if x=="?" then
        n = n+1
        local bin = col:discretize(x) 
        xys[bin] = xys[bin] or push(all, XY(col.at,col.txt,x)) 
        xys[bin]:add(x,y) end end end
  return col:merge(sort(all,lt"xlo"), n^the.Min) end

-- ## NUM  ----- ----- ---------------------------------------------------------
function NUM:add(x) --- Update 
  if x ~= "?" then
    self.n  = self.n + 1
    local d = x - self.mu
    self.mu = self.mu + d/self.n
    self.m2 = self.m2 + d*(x - self.mu)
    self.sd = self.n<0 and 0 or (self.m2<0 and 0 or (self.m2/(self.n-1))^.5)
    if x > self.hi then self.hi = x end
    if x < self.lo then self.lo = x end end end

function NUM:norm(n) --- normalize `n` 0..1 (in the range lo..hi)
  local lo,hi = self.lo,self.hi
  return (hi - lo) < 1E-9 and 0 or (n - lo)/(hi - lo) end

function NUM:discretize(n,    tmp) --- discretize `Num`s,rounded to (hi-lo)/bins
  tmp = (self.hi - self.lo)/(the.bins - 1)
  return self.hi == self.lo and 1 or math.floor(n/tmp+.5)*tmp end 

function NUM:merge(xys,nMin,    try2Merge) --- Can we combine any adjacent ranges?
  function try2Merge(t,    n,u,merged)
    while n <= #t do
      local a,b = t[n], t[n+1]
      local ab  = n < #t and a.y:simpler(b.y, nMin)
      u[1+#u]   = ab or XY(col.at, col.name, a.xlo, b.xhi, ab)
      n         = ab and n+2 or n+1 end
    return #t == #u and t or try2Merge(u) 
  end --------------------
  xys = try2Merge(xys,1,{})
  for n = 2,#xys do xys[n].xlo = xys[n-1].xhi end   -- fill in any gaps
  xys[1].xlo, xys[#xys].xhi = -math.huge, math.huge -- extend to +/- infinity
  return xys end

-- ## SYM  ----- ----- ---------------------------------------------------------
function SYM:add(s,     inc) --- `n` times (default=1), update `self` with `s` 
  if s~="?" then 
    inc = inc or 1
    self.n  = self.n + inc
    self.has[s] = inc + (self.has[s] or 0) 
    if self.has[s] > self.most then
      self.most,self.mode = self.has[s], s end end end

function SYM:discretize(x) return x end 
function SYM:merge(t)      return t end 

function SYM:entropy(     e,fun) --- entropy
  function fun(p) return p*math.log(p,2) end
  e=0; for _,n in pairs(self.has) do if n>0 then e=e-fun(n/self.n) end end
  return e end

function SYM:simpler(sym,tiny) --- is `self+sym` simpler than its parts?
  local whole = SYM(self.at, self.txt)
  for x,n in pairs(self.has) do whole:add(x,n) end
  for x,n in pairs(sym.has)  do whole:add(x,n) end
  local e1, e2, e12 = self:entropy(), sym:entropy(), whole:entropy()
  if self.n < tiny or sym.n < tiny or e12 <= (self.n*e1 + sym.n*e2)/whole.n then 
    return whole end end

-- ## XY  ----- ----- ----------------------------------------------------------
function XY:__tostring() --- print
  local x,lo,hi,big = self.txt, self.xlo, self.xhi, math.huge
  if     lo ==  hi  then return fmt("%s == %s", x, lo)
  elseif hi ==  big then return fmt("%s >  %s", x, lo)
  elseif lo == -big then return fmt("%s <= %s", x, hi)
  else                   return fmt("%s <  %s <= %s", lo,x,hi) end end

function XY:add(x,y) --- Update `xlo`,`xhi` to cover `x`. And add `y` to `self.y`
  if x~="?" then
    if x < self.xlo then self.xlo=x end
    if x > self.xhi then self.xhi=x end
    self.y:add(y) end end

function XY:select(row,     x) --- Return true if `row` selected by `self`
  x = row[self.at]
  if x =="?" then return true end ------------------ assume yes for unknowns
  if self.xlo==self.xhi and v==self.xlo then return true end     -- for symbols
  if self.xlo < x and x <= self.xhi     then return true end end -- for numerics

function XY:selects(rows) --- Return subset of `rows` selected by `self`
  return map(rows,function(row) if self:select(row) then return row end end) end

-- ------------------------------------------------------------
return {the=the, COLS=COLS, DATA=DATA, NUM=NUM, SYM=SYM, XY=XY}
      .      . .     .      
\./._ | _ ._.|*|_    |. . _.
/'\[_)|(_)[  ||[_) * |(_|(_]
   |                        
-- ----------------------------------------------------------------------------
local b4={}; for k,v in pairs(_ENV) do b4[k]=v end;
local l ={}
--[[
## Maths
| l.per(t,p)            | return the pth (0..1) item of `t`.                     |
| l.ent(t)              | entropy of a list of counts                            |

## Lists
| l.copy(t, deep)       | copy a list (shallow copy if `deep` is false)          |
| l.push(t,x)           | push `x` onto `t`, return `x`                          |

### Sorting
| l.sort(t,fun)         | return `t`, sorted using function `fun`.               |
| l.lt(x)               | return function that sorts ascending on key `x`        |

### String to thing
| l.coerce(s)           | Parse `the` config settings from `help`.               |
| l.csv(sFilename, fun) | call `fun` on csv rows.                                |

### Thing to String
| l.fmt(str,...)        | emulate printf                                         |
| l.oo(t)               | Print a table `t` (non-recursive)                      |
| l.o(t)                | Generate a print string for `t` (non-recursive)        |

## Meta
| l.map(t,fun)          | Return `t`, filter through `fun(value)` (skip nils)    |
| l.kap(t,fun)          | Return `t` and its size, filtered via `fun(key,value)` |
| l.keys(t)             | Return keys of `t`, sorted (skip any with prefix  `_`) |

## Settings
| l.settings(txt)       | parse help string to extract settings                  |
| l.cli(t)              | update table slots via command-line flags              |
--]]

-- ## Linting
function l.rogues() 
  for k,v in pairs(_ENV) do if not b4[k] then print("?",k,type(v)) end end end

-- ## Objects
function l.obj(s,    t,i,new) 
  local isa=setmetatable
  function new(k,...) i=isa({},k); return isa(t.new(i,...) or i,k) end
  t={__tostring = function(x) return s..l.o(x) end}
  t.__index = t;return isa(t,{__call=new}) end

-- ## Maths
function l.per(t,p) --- return the pth (0..1) item of `t`.
  p=math.floor(((p or .5)*#t)+.5); return t[math.max(1,math.min(#t,p))] end

function l.ent(t) --- entropy of a list of counts
  function fun(p) return p*math.log(p,2) end
  e=0; for _,n in pairs(t) do if n>0 then e=e-fun(n/self.n) end end
  return e end
 
-- ## Lists
function l.copy(t, deep,    u) --- copy a list (shallow copy if `deep` is false)
  if type(t) ~= "table" then return t end
  u={};for k,v in pairs(t) do u[k]=deep and l.copy(v,deep) or v end;return u end

function l.push(t,x)  --- push `x` onto `t`, return `x`
  table.insert(t,x); return x end

-- ### Sorting
function l.sort(t,fun) --- return `t`, sorted using function `fun`. 
  table.sort(t,fun); return t end

function l.lt(x) --- return function that sorts ascending on key `x`
  return function(a,b) return a[x] < b[x] end end

-- ## Coercion
-- ### String to thing
function l.coerce(s,    fun) --- Parse `the` config settings from `help`.
  function fun(s1)
    if s1=="true"  then return true  end
    if s1=="false" then return false end
    return s1 end
  return math.tointeger(s) or tonumber(s) or fun(s:match"^%s*(.-)%s*$") end

function l.csv(sFilename, fun,      src,s,t) --- call `fun` on csv rows.
  src  = io.input(sFilename)
  while true do
    s = io.read()
    if   s 
    then t={}; for s1 in s:gmatch("([^,]+)") do t[1+#t]=l.coerce(s1) end; fun(t)
    else return io.close(src) end end end

-- ### Thing to String
function l.fmt(str,...) --- emulate printf
  return string.format(str,...) end

function l.oo(t)  --- Print a table `t` (non-recursive)
  print(l.o(t)) end 

function l.o(t) ---  Generate a print string for `t` (non-recursive)
  if type(t) ~= "table" then return tostring(t) end
  t = #t>0 and l.map(t,tostring)
            or l.map(l.keys(t),
                     function(v) return l.fmt(":%s %s",v,l.o(t[v])) end)
  return "{".. table.concat(t," ") .."}" end

-- ## Meta
function l.map(t,fun) --- Return `t`, filter through `fun(value)` (skip nils)
  local u={}; for _,v in pairs(t) do u[1+#u] = fun(v) end; return u end

function l.kap(t,fun) --- Return `t` and its size, filtered via `fun(key,value)`
  local u={}; for k,v in pairs(t) do u[k]=fun(k,v) end; return u end

function l.keys(t) --- Return keys of `t`, sorted (skip any with prefix  `_`)
  return l.sort(l.kap(t,function(key,_)  
                if tostring(key):sub(1,1) ~= "_" then return key end end)) end

-- ## Settings
function l.settings(txt,    t) --- parse help string to extract settings
  t={}; txt:gsub("\n [-][%S]+[%s]+[-][-]([%S]+)[^\n]+= ([%S]+)", 
                 function(k,v) t[k]=l.coerce(v) end)
  t._help = txt
  return t end

function l.cli(t) --- update table slots via command-line flags
  for k,v in pairs(t) do
    local v=tostring(v)
    for n,x in ipairs(arg) do
      if x=="-"..(k:sub(1,1)) or x=="--"..k then
         v = v=="false" and "true" or v=="true" and "false" or arg[n+1] end end 
  t[k] = l.coerce(v) end 
  if t.help then os.exit(print("\n"..t._help)) end
  return t end 

-- ## Runtime
function l.on(settings,funs,   fails,old)
  fails=0
  old = l.copy(settings)
  for k,fun in pairs(funs) do
    if settings.go == "all" or settings.go == k then
      for k,v in pairs(old) do settings[k]=v end
      math.randomseed(settings.seed or 10019)
      print("#>>>>>",k)
      if fun()==false then fails = fails+1;print("F#AIL!!!!!",k); end end end
  l.rogues()
  os.exit(fails) end

return l
      .               .      
\./._ | _ ._. _  _    |. . _.
/'\[_)|(_)[  (_](_) * |(_|(_]
   |         ._|             
local l=require"xplorlib"
local X=require"xplor"

local the,DATA,NUM,SYM = X.the,X.DATA,X.NUM,X.SYM
local o,on,oo,csv,map  = l.o,l.on,l.oo,l.csv,l.map

-- -----------------------------------------------------------------------------
local go={}
function go.the() oo(the)  end

function go.num(     num)
  num = NUM()
  for i=1,100 do num:add(i) end
  print(num.mu, num.sd) end

function go.sym(     sym)
  sym = SYM()
  for _,s in pairs{"a","a","a","a","b","b","c"} do sym:add(s) end
  print(sym.mode, sym:entropy()) end

function go.csv(      data)
  data = load(the.file)
  map(data.cols.x, oo) end

function go.sorted(      data,rows)
  data = load(the.file)
  rows= data:sorted() 
  for i=1,#rows,30 do print(i,o(rows[i])) end end

function go.bestRest(      data,best,rest)
  data = load(the.file)
  best,rest = data:bestRest(20,3) 
  print(#best, #rest) end

-- -----------------------------------------------------------------------------
the = l.cli(the)                  
on(the,go)
