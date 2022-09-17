local b4={}; for k,v in pairs(_ENV) do b4[k]=v end;
local help=[[
TINY2: a lean little learning library, in LUA
(c) 2022 Tim Menzies <timm@ieee.org> BSD-2 license

USAGE: lua l5.lua [OPTIONS]

OPTIONS:
 -b  --bins  max number of bins                     = 16
 -d  --dump  on test failure, exit with stack dump  = false
 -f  --file  file with csv data                     = ../data/auto93.csv
 -g  --go    start-up example                       = nothing
 -h  --help  show help                              = false
 -k  --k     low frequency attribute hack           = 2
 -m  --m     low frequency class hack               = 1
 -p  --p     distance calculation coefficient       = 2
 -s  --seed  random number seed                     = 10019]]

local o,map,coerce,csv,settings,cli
local isa=setmetatable
function obj(s,    t,i,new) 
  function new(k,...) i=isa({},k); return isa(t.new(i,...) or i,k) end
  t={__tostring = function(x) return s..o(x) end}
  t.__index = t;return isa(t,{__call=new}) end

local Data,NB,Num,Row,Sym =obj"Data",obj"Num",obj"Row",obj"Sym",obj"NB"

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
  self.rows = {}
  self.cols = {names={},all={},x={},y={}}
  load(self,src) end

function NB:new(src)
  self.all, self.nh, self.datas = Data(), 0, {}
  load(self,src) end

function NB:add(row)
  local function new() self.nh = self.nh+1; return self.all:clone() end
  self.all:add(row)
  self.datas[row.klass()] = self.datas[row.klass()] or new()
  self.datas[row.klass()].add(row) end 

--              ,   .           .     
-- ._ _    _   -+-  |_    _    _|   __
-- [ | )  (/,   |   [ )  (_)  (_]  _) 
-- ## Num     ----- ----- -----------------------------------------------------
function Num:add(x)
  if x ~= "?" then
    self.n  = self.n + 1
    self.mu = self.mu + d/self.n
    self.m2 = self.m2 + d*(x - self.mu)
    self.sd = self.n<0 and 0 or (self.m2<0 and 0 or (self.m2/(i.n-1))^.5)
    if x > self.hi then self.hi = x end
    if x < self.lo then self.lo = x end end end

-- ## Sym     ----- ----- -----------------------------------------------------
function Sym:add(s,  n) --- Update.
  if s~="?" then 
    self.n  = self.n + 1
    self.has[s] = n+(self.has[s] or 0) 
    if self.has[s] > self.most then
      self.most,self.mode = self.has[s], s end end end

-- ## Data     ----- ----- -----------------------------------------------------
-- ### Create
function Data:clone(src) return load(Data({self.cols.names}),src) end

-- ### Update
function Data:add(row) --- the new row is either a header, or a data row  
  if #self.cols.all==0 then self._head(row) else self._body(row) end  end

function Data:_head(row)--- Create `Num`s and `Sym`s for the column headers
  self.cols.names = row
  for n,s in pairs(row) do
    local col = push(self.cols.all, (s:find"^[A-Z]" and Num or Sym)(n,s))
    if not s:find":$" then
      push(s:find"[!+-]" and self.cols.y or self.cols.x, col) end end end
 
function Data:_body(row) --- Crete new row. Store in `rows`. Update cols.
  row = row.cells and row or Row(row) -- Ensure `row` is a `Row`.
  push(self.rows, row)
  for _,cols in pairs{self.cols.x, self.cols.y} do
    for _,col in pairs(cols) do
      col:add(row.cells[col.at]) end end end

-- .     .  
-- |  *  |_ 
-- |  |  [_)

fmt=string.format

function load(data,src)
  if   type(src)=="string"
  then csv(src,       function(row) data:add(row) end)
  else map(src or {}, function(row) data:add(row) end) end  end

function push(t,x) t[1+#t]=x; return x end --- at `x` to `t`, return `x`

function map(t1,fun,    t2)  --- apply `fun` to all of `t1` (skip nil results)
  t2={}; for _,v in pairs(t1) do t2[1+#t2] = fun(v) end; return t2 end

function copy(t,  shallow, u) --- copy list
  if type(t) ~= "table" then return t end
  u={}; for k,v in pairs(t) do u[k] = shallow and v or copy(v,shallow) end
  return setmetatable(u,getmetatable(t))  end

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

-- ## Demo  ----- ----- -------------------------------------------------------
--   .                      
--  _|   _   ._ _    _    __
-- (_]  (/,  [ | )  (_)  _) 

local go={}
function go.the() oo(the); return 1 end

-- ## Start  ----- ----- -------------------------------------------------------
local function on(settings,funs,   fails,old)
  fails=0
  old = copy(settings)
  for k,fun in pairs(funs) do
    if settings.go == "all" or settings.go == k then
      for k,v in pairs(old) do settings[k]=v end
      math.randomseed(settings.seed or 10019)
      print("#>>>>>",k)
      if fun()==false then fails = fails+1;print("F#AIL!!!!!",k); end end end
  for k,v in pairs(_ENV) do if not b4[k] then print("#?",k,type(v)) end end 
  os.exit(fails) end

the = cli(settings(help))
on(the,go)

