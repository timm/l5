local b4={}; for k,v in pairs(_ENV) do b4[k]=v end;
local help=[[
XPLOR: Bayesian active learning
(c) 2022 Tim Menzies <timm@ieee.org> BSD-2 license

USAGE: lua XPLOR.lua [OPTIONS]

OPTIONS:
 -f  --file  file with csv data                     = ../data/auto93.csv
 -g  --go    start-up example                       = nothing
 -h  --help  show help                              = false
 -k  --k     Bayes hack: low attribute frequency    =  2
 -m  --m     Bayes hack: low class frequency        =  1
 -s  --seed  random number seed                     = 10019]]

local adds,cdf,cli,coerce,copy,csv,fmt,o,obj,oo,map,pdf,push,rnd,run,settings,the
function obj(s,    isa,new,t)
  isa=setmetatable
  function new(k,...) local i=isa({},k); return isa(t.new(i,...) or i,k) end
  t={__tostring = function(x) return s..o(x) end}
  t.__index = t;return isa(t,{__call=new}) end

local Data,NB,Num,Row,Sym=obj"Data",obj"Num",obj"Row",obj"Sym",obj"NB"

function Row:new(t) --- Hold one record
  return {cells =t} end

function Sym:new(n,s) --- Summarize stream of symbols.
    return {at=n or 0,
            txt=s or "",
            n=0, mode=nil,most=-1,
            has={}} end

function Num:new(c,x) --- Summarize stream of numbers
  return {at=c or 0,txt=x or "",n=0,
          lo= 1E32,  hi= -1E32, mu=0, m2=0, sd=0,
          w=(x or ""):find"-$" and -1 or 1} end

function Data:new(src) --- Store rows of data. Summarize rows in `self.cols`.
  self.rows, self.cols = {}, {names={},all={},x={},y={}}
  adds(self,src) end

function NB:new(src)
  self.all, self.nh, self.datas = Data(), 0, {}
  adds(self,src) end

-- The help string at top of file is parsed to create the settings.
-- Also, my `go.x` functions can be run with `lua xplor.lua -g x`.
-- Further, this code's function arguments have some type hints:
--   
-- | What         | Notes                                       |
-- |:------------:|---------------------------------------------|
-- | 2 blanks     | 2 blanks denote optional arguments          |
-- | 4 blanks     | 4 blanks denote local arguments             |
-- | n            | prefix for numerics                         |
-- | s            | prefix for strings                          |
-- | is           | prefix for booleans                         |
-- | fun          | prefix for functions                        |
-- | suffix s     | list of thing (so names is list of strings) |
--              ,   .           .     
-- ._ _    _   -+-  |_    _    _|   __
-- [ | )  (/,   |   [ )  (_)  (_]  _) 

-- ## Num     ----- ----- -----------------------------------------------------
function Num:add(x)
  if x ~= "?" then
    self.n  = self.n + 1
    local d = x - self.mu
    self.mu = self.mu + d/self.n
    self.m2 = self.m2 + d*(x - self.mu)
    self.sd = self.n<0 and 0 or (self.m2<0 and 0 or (self.m2/(self.n-1))^.5)
    if x > self.hi then self.hi = x end
    if x < self.lo then self.lo = x end end end

function Num:like(x,...)
  return self.sd>0 and pdf(x,self.mu,self.sd) or (x==self.mu and 1 or 1/big) end

function Num:mid() return self.mu end
function Num:div() return self.sd end

-- ## Sym     ----- ----- ------------------------------------------------------
function Sym:add(s,  n) --- Update.
  if s~="?" then 
    self.n  = self.n + 1
    self.has[s] = 1 + (self.has[s] or 0) 
    if self.has[s] > self.most then
      self.most,self.mode = self.has[s], s end end end

function Sym:like(x,prior)
  return ((self.kept[x] or 0)+the.m*prior) / (self.n+the.m) end

function Sym:mid() return self.mode end

function Sym:div(     e)
  local function fun(p) return -p*math.log(p,2) end
  e=0; for x,n in pairs(self.has) do if n>0 then e = e - fun(n/self.n) end end
  return e end

-- ## Data     ----- ----- -----------------------------------------------------
-- ### Create
function Data:clone(src) return adds(Data({self.cols.names}),src) end

-- ### Update
function Data:add(row) --- the new row is either a header, or a data row  
  if #self.cols.all==0 then self:_head(row) else self:_body(row) end  end

function Data:_head(row)--- Create `Num`s and `Sym`s for the column headers
  self.cols.names = row
  for n,s in pairs(row) do
    local col = push(self.cols.all, (s:find"^[A-Z]" and Num or Sym)(n,s))
    if not s:find":$" then
      if s:find"!$" then self.cols.klass= col end
      push(s:find"[!+-]" and self.cols.y or self.cols.x, col) end end end
 
function Data:_body(row) --- Crete new row. Store in `rows`. Update cols.
  row = row.cells and row or Row(row) -- Ensure `row` is a `Row`.
  push(self.rows, row)
  for _,cols in pairs{self.cols.x, self.cols.y} do
    for _,col in pairs(cols) do
      col:add(row.cells[col.at]) end end end

function Data:like(row, nklasses, nrows)
  local prior,like,inc,x
  prior = (#self.rows + the.k) / (nrows + the.k * nklasses)
  like  = math.log(prior)
  row = row.cells and row.cells or row
  for _,col in pairs(self.cols.x) do
    x = row[col.at]
    if x ~= nil and x ~= "?" then
      inc  = col:like(x,prior)
      like = like + math.log(inc) end end
  return like end

function Data:klass(row) 
 return row.cells[self.cols.klass.at] end

function Data:stats(  places,showCols,todo,    t,v)
    showCols, todo = showCols or self.cols.y, todo or "mid"
    t={}; for _,col in pairs(showCols) do 
            v=getmetatable(col)[todo](col)
            print("v",v)
            v=type(v)=="number" and rnd(v,places) or v
            t[col.txt]=v end; return t end

-- ## NB     ----- ----- -----------------------------------------------------
-- ### Update
function NB:add(row,   k)
  local function new() self.nh = self.nh+1; return self.all:clone() end
  self.all:add(row)
  k = self.all:klass(row)
  self.datas[k] = self.datas[k] or new()
  self.datas[k].add(row) end 

function NB:classify(row) --- which klass likes `row` the most?
  local most,klass = -math.huge
  for k,data in pairs(self.datas) do
    like = data:like(row,self.nh, #self.all.rows)
    if like > most then most,klass=like,k end end
  return klass end
-- .     .  
-- |  *  |_ 
-- |  |  [_)

-- ## Math     ----- ----- -----------------------------------------------------
function rnd(x, places) 
  local mult = 10^(places or 2)
  return math.floor(x * mult + 0.5) / mult end

function pdf(x,mu,sd)
  return math.exp(-.5*((x - mu)/sd)^2) / (sd*((2*math.pi)^0.5)) end  

function cdf (x,    _cdf) 
  function _cdf(x,    p,t) --- Abramowitz and Stegun cdf approximation
    p = pdf(x,0,1)         -- Handbook Mathematical Functions, 1988
    t = 1 / (1+0.2316419*x)
    return (1 - p*(0.319381530*t - 0.356563782*t^2 + 1.781477937*t^3 
                   - 1.821255978*t^4 + 1.330274429*t^5)) end
  return (x==0 and .5) or (x>0 and _cdf(x)) or 1-_cdf(-x) end

-- ## Lists     ----- ----- ----------------------------------------------------
function push(t,x) t[1+#t]=x; return x end --- at `x` to `t`, return `x`

function map(t1,fun,    t2)  --- apply `fun` to all of `t1` (skip nil results)
  t2={}; for _,v in pairs(t1) do t2[1+#t2] = fun(v) end; return t2 end

function copy(t,  shallow, u) --- copy list
  if type(t) ~= "table" then return t end
  u={}; for k,v in pairs(t) do u[k] = shallow and v or copy(v,shallow) end
  return setmetatable(u,getmetatable(t))  end

-- ## Strings to Things    ----- ----- -----------------------------------------
function coerce(s,    fun) --- Parse `the` config settings from `help`.
  function fun(s1)
    if s1=="true"  then return true end 
    if s1=="false" then return false end
    return s1 end 
  return math.tointeger(s) or tonumber(s) or fun(s:match"^%s*(.-)%s*$") end

function csv(sFilename, fun,      src,s,t) --- call `fun` cells in each CSV line
  src  = io.input(sFilename)
  while true do
    s = io.read()
    if   s 
    then t = {}; for s1 in s:gmatch("([^,]+)") do t[1+#t] = coerce(s1) end
         fun(t) 
    else return io.close(src) end end end

function adds(data,src)
  if   type(src)=="string"
  then csv(src,       function(row) data:add(row) end)
  else map(src or {}, function(row) data:add(row) end) end  end

-- ## Thing to string   ----- ----- -------------------------------------------
fmt=string.format

function oo(t) print(o(t)) return t end --- print nested lists
function o(t,   seen,show,u) ---  coerce to string (skip loops, sort slots)
  if type(t) ~=  "table" then return tostring(t) end
  seen=seen or {}
  if seen[t] then return "..." end
  seen[t] = t
  function show(k,v)
    if not tostring(k):find"^_"  then
      v = o(v,seen)
      return #t==0 and fmt(":%s %s",k,v) or o(v,seen) end end
  u={}; for k,v in pairs(t) do u[1+#u] = show(k,v) end
  if #t==0 then table.sort(u) end
  return "{"..table.concat(u," ").."}" end

-- ## Settings     ----- ----- -------------------------------------------------
function settings(s) --- create a `the` variable
  local t,pat = {_help=s}, "\n [-][%S]+[%s]+[-][-]([%S]+)[^\n]+= ([%S]+)"
  s:gsub(pat, function(k,x) t[k]=coerce(x) end)
  return t end

function cli(t) -- Updates from command-line. Bool need no values (just flip)
  for slot,v in pairs(t) do
    v = tostring(v)
    for n,x in ipairs(arg) do
      if x=="-"..(slot:sub(1,1)) or x=="--"..slot then
        v = v=="false" and "true" or v=="true" and "false" or arg[n+1] end end
    t[slot] = coerce(v) end
  if t.help then os.exit(print("\n"..t._help.."\n")) end
  return t end

-- ## Start up     ----- ----- -------------------------------------------------
function run(settings,funs,   fails,old)
  fails=0
  old = copy(settings)
  for k,fun in pairs(funs) do
    if settings.go == "all" or settings.go == k then
      for k,v in pairs(old) do settings[k]=v end
      math.randomseed(settings.seed or 10019)
      print("# >>>>>",k)
      if fun()==false then fails = fails+1;print("# FAIL!!!!!",k); end end end
  for k,v in pairs(_ENV)do if not b4[k] then print("# rogue?",k,type(v)) end end 
  os.exit(fails) end
--   .                      
--  _|   _   ._ _    _    __
-- (_]  (/,  [ | )  (_)  _) 

local go={}
function go.the() oo(the); return  1 end

function go.cdf()
  for x=-2,2.5,.3 do print(rnd(cdf(x),4), ("-"):rep(cdf(x)*50//1)..".") end end

function go.sym(  sym) 
  sym = Sym()
  for _,x in pairs{"a","a","a","a","b","b","c"} do sym:add(x) end
  return sym.mode =="a" and sym.most==4 end

function go.num(  num) 
  num = Num()
  for x=1,100 do num:add(x) end
  return 51==rnd(num.mu,0) and 29== rnd(num.sd,0) end

function go.csv()
  csv(the.file, oo); return 1 end

function go.data(   d)
  d=Data(the.file) 
  map(d.cols.x,oo); print""
  map(d.cols.y,oo) end 

function go.data(    d)
  d=Data(the.file) 
  oo(d:stats(2, d.cols.x,"mid"))
  map(d.cols.x,oo); print""
  map(d.cols.y,oo) end 

function go.nb(   d)
  d=NB("../data/diabetes.csv") 
  for _,data in pairs(d.all.cols.x) do 
    oo(data.cols.x) 
    oo(data:stats(2, data.cols.x,"mid")) end  end

-- ## Start  ----- ----- -------------------------------------------------------
the = cli(settings(help))
run(the,go)

