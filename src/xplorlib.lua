-- some xxs not working
-- need to do the 2 space thing
local b4={}; for k,v in pairs(_ENV) do b4[k]=v end;
local l ={}
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
function l.per(t, p) --- return the pth (0..1) item of `t`.
  p=math.floor(((p or .5)*#t)+.5); return t[math.max(1,math.min(#t,p))] end

function l.rnd(x, places) 
  local mult=10^(places or 2); return math.floor(x * mult + 0.5)/mult end

-- ## Lists
function l.copy(t, isDeep,    u) --- copy a list (deep copy if `isDep`)
  if type(t) ~= "table" then return t end
  u={};for k,v in pairs(t) do u[k]=isDeep and l.copy(v,isDeep) or v end;return u end

function l.push(t, x)  --- push `x` onto `t`, return `x`
  table.insert(t,x); return x end

-- ### Sorting
function l.sort(t, fun) --- return `t`, sorted using function `fun`
  table.sort(t,fun); return t end

function l.lt(x) --- return function that sorts ascending on key `x`
  return function(a,b) return a[x] < b[x] end end

function l.gt(x) --- return function that sorts descending on key `x`
  return function(a,b) return a[x] > b[x] end end

-- ## Coercion
-- ### String to thing
function l.coerce(s,    fun) --- Parse `the` config settings from `help`
  function fun(s1)
    if s1=="true"  then return true  end
    if s1=="false" then return false end
    return s1 end
  return math.tointeger(s) or tonumber(s) or fun(s:match"^%s*(.-)%s*$") end

function l.csv(sFilename, fun,      src,s,t) --- call `fun` on csv rows
  src  = io.input(sFilename)
  while true do
    s = io.read()
    if   s
    then t={}; for s1 in s:gmatch("([^,]+)") do t[1+#t]=l.coerce(s1) end; fun(t)
    else return io.close(src) end end end

-- ### Thing to String
function l.fmt(str, ...) --- emulate printf
  return string.format(str,...) end

function l.cat(t) 
  return table.concat(t,", ") end

function l.oo(t)  --- Print a table `t` (non-recursive)
  print(l.o(t)) end

function l.o(t) ---  Generate a print string for `t` (non-recursive)
  if type(t) ~= "table" then return tostring(t) end
  local function fun(v) return l.fmt(":%s %s",v,l.o(t[v])) end
  t = #t>0 and l.map(t,tostring) or l.map(l.keys(t),fun)
  return "{".. table.concat(t," ") .."}" end

-- ## Meta
function l.map(t, fun) --- Return `t`, filter through `fun(value)` (skip nils)
  local u={}; for _,v in pairs(t) do u[1+#u] = fun(v) end; return u end

function l.kap(t, fun) --- Return `t` and its size, filtered via `fun(key,value)`
  local u={}; for k,v in pairs(t) do u[k]=fun(k,v) end; return u end

function l.keys(t) --- Return keys of `t`, sorted (skip any with prefix  `_`)
  local function want(k,_) if tostring(k):sub(1,1) ~= "_" then return k end end
  return l.sort(l.kap(t,want)) end

-- ## Settings
function l.settings(s,    t) --- parse help string to extract settings
  t={}; s:gsub("\n [-][%S]+[%s]+[-][-]([%S]+)[^\n]+= ([%S]+)",
                 function(k,v) t[k]=l.coerce(v) end)
  t._help = s
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
function l.on(configs, funs) --- reset cofnig before running a demo
  local fails=0
  local old = l.copy(configs)
  for _,k in pairs(l.keys(funs)) do
    if configs.go == "all" or configs.go == k then
      for k,v in pairs(old) do configs[k]=v end
      math.randomseed(configs.seed or 10019)
      print("#>>>>>",k)
      if funs[k]()==false then fails=fails+1;print("# FAIL!!!!!",k); end end end
  l.rogues()
  os.exit(fails) end

return l
