local b4={}; for k,v in pairs(_ENV) do b4[k]=v end;
local l ={}
-- ----------------------------------------------------------------------------
-- ## Maths
-- l.per(t,p)            : return the pth (0..1) item of `t`.
-- l.ent(t)              : entropy of a list of counts
--
-- ## Lists
-- l.copy(t, deep)       : copy a list (shallow copy if `deep` is false)
-- l.push(t,x)           : push `x` onto `t`, return `x`
--
-- ### Sorting
-- l.sort(t,fun)         : return `t`, sorted using function `fun`.
-- l.lt(x)               : return function that sorts ascending on key `x`
--
-- ### String to thing
-- l.coerce(s)           : Parse `the` config settings from `help`.
-- l.csv(sFilename, fun) : call `fun` on csv rows.
--
-- ### Thing to String
-- l.fmt(str,...)        : emulate printf
-- l.oo(t)               : Print a table `t` (non-recursive)
-- l.o(t)                : Generate a print string for `t` (non-recursive)
--
-- ## Meta
-- l.map(t,fun)          : Return `t`, filter through `fun(value)` (skip nils)
-- l.kap(t,fun)          : Return `t` and its size,filtered via `fun(key,value)`
-- l.keys(t)             : Return keys of `t`, sorted (skip any with prefix `_`)
--
-- ## Settings
-- l.settings(txt)       : parse help string to extract settings
-- l.cli(t)              : update table slots via command-line flags
-- ----------------------------------------------------------------------------
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
  local function fun(v) return l.fmt(":%s %s",v,l.o(t[v])) end
  t = #t>0 and l.map(t,tostring) or l.map(l.keys(t),fun)
  return "{".. table.concat(t," ") .."}" end

-- ## Meta
function l.map(t,fun) --- Return `t`, filter through `fun(value)` (skip nils)
  local u={}; for _,v in pairs(t) do u[1+#u] = fun(v) end; return u end

function l.kap(t,fun) --- Return `t` and its size, filtered via `fun(key,value)`
  local u={}; for k,v in pairs(t) do u[k]=fun(k,v) end; return u end

function l.keys(t) --- Return keys of `t`, sorted (skip any with prefix  `_`)
  local function want(k,_) if tostring(k):sub(1,1) ~= "_" then return k end end
  return l.sort(l.kap(t,want)) end

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
function l.on(settings,funs) --- reset settings before running a demo
  local fails=0
  local old = l.copy(settings)
  for _,k in pairs(_,keys(funs)) do
    if settings.go == "all" or settings.go == k then
      for k,v in pairs(old) do settings[k]=v end
      math.randomseed(settings.seed or 10019)
      print("#>>>>>",k)
      if funs[k]()==false then fails=fails+1;print("# FAIL!!!!!",k); end end end
  l.rogues()
  os.exit(fails) end

return l
