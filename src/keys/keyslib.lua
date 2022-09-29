-- keyslib.lua: misc lua routines
-- (c)2022, Tim Menzies BSD-2 clause
local l={}

-- ## Linting
local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
function l.rogues() --- report rogue locals
  for k,v in pairs(_ENV) do
    if not b4[k] then print( l.fmt("#W ?%s %s",k,type(v)) ) end end end

-- ## Maths
function l.balance(t,x,y,xgoal,ygoal)
  local xlo,ylo =  1E32,  1E32
  local xhi,yhi = -1E32, -1E32
  for _,z in pairs(t) do
    xlo = math.min(xlo, z[x]); xhi = math.max(xhi,z[x])
    ylo = math.min(ylo, z[y]); yhi = math.max(yhi,z[y]) end
  l.oo(t[1])
  for _,z in pairs(t) do
    print(x,y,l.o(z))
    local x1  = (z[x] - xlo) / (xhi - xlo + 1E-31) -- normalize
    local y1  = (z[y] - ylo) / (yhi - ylo + 1E-31) -- normalize
    t.balance = ((xgoal - x1)^2 + (ygoal - y1)^2)^.5 end 
  return sort(t,gt"balance") end
    
-- ### Random number generator
-- The LUA doco says its random number generator is not stable across platforms.
-- Hence, we use our own (using Park-Miller).

local Seed=937162211
function l.srand(n)  --- reset random number seed (defaults to 937162211) 
  Seed = n or 937162211 end

function l.rand(nlo,nhi) --- return float from `nlo`..`nhi` (default 0..1)
  nlo, nhi = nlo or 0, nhi or 1
  Seed = (16807 * Seed) % 2147483647
  return nlo + (nhi-nlo) * Seed / 2147483647 end

function l.rint(nlo,nhi)  --- returns integer from `nlo`..`nhi` (default 0..1)
  return math.floor(0.5 + l.rand(nlo,nhi)) end

-- ## Lists
function l.ent(t) --- entropy
  local function calc(p) return p*math.log(p) end
  local n=0; for _,n1 in pairs(t) do n=n+n1 end
  local e=0; for _,n1 in pairs(t) do e=e - calc(n1/n) end 
  return e end

function l.kap(t, fun) --- map function `fun`(k,v) over list (skip nil results) 
  local u={}; for k,v in pairs(t)do u[k]=fun(k,v) end; return u end

function l.keys(t) --- sort+return `t`'s keys (ignore things with leading `_`)
  local function want(k,x) if tostring(k):sub(1,1) ~= "_" then return k end end
  local u={}; for k,v in pairs(t) do if want(k) then u[1+#u] = k end end
  return l.sort(u) end

function l.last(t) -- return list item in a list
  return t[#t] end

function l.map(t, fun)  --- map function `fun`(v) over list (skip nil results) 
  local u={}; for i,v in pairs(t)do u[1+#u]=fun(v) end;return u end

function l.powerset(s)
  local t = {{}}
  for i = 1, #s do
    for j = 1, #t do
      t[#t+1] = {s[i],table.unpack(t[j])} end end
 return l.sort(t,function(a,b) return #a < #b end)  end

function l.push(t, x) --- push `x` to end of list; return `x` 
  table.insert(t,x); return x end

function l.sd(t) --- sorted list standard deviation= (90-10)th percentile/2.58
  return (t[(.9*#t)//1] - t[(.1*#t)//1]) / 2.58 end

function l.top(n,t) --- return first `n` items from `t`.
  local u={}; for i=1,#t do u[1+#u] = t[i]; if i>= n then break end end
  return u end

-- ### Sorting Lists
function l.gt(s)
  return function(a,b) return a[s] > b[s] end end

function l.lt(s)
  return function(a,b) return a[s] < b[s] end end

function l.sort(t, fun) --- return `t`,  sorted by `fun` (default= `<`)
  table.sort(t,fun); return t end

-- ## Coercion
-- ### Strings to Things
function l.coerce(s) --- return int or float or bool or string from `s`
  local function fun(s1)
    if s1=="true"  then return true  end
    if s1=="false" then return false end
    return s1 end
  return math.tointeger(s) or tonumber(s) or fun(s:match"^%s*(.-)%s*$") end

function l.options(s,    t) --- parse help string to extract a table of options
  t={}; s:gsub("\n [-][%S]+[%s]+[-][-]([%S]+)[^\n]+= ([%S]+)",
                 function(k,v) t[k]=l.coerce(v) end)
  t._help = s
  return t end

function l.csv(sFilename,fun) --- call `fun` on rows (after coercing cell text)
  local src,s,t  = io.input(sFilename)
  while true do
    s = io.read()
    if   s
    then t={}; for s1 in s:gmatch("([^,]+)") do t[1+#t]=l.coerce(s1) end; fun(t)
    else return io.close(src) end end end

-- ### Things to Strings
function l.fmt(sControl,...) --- emulate printf
  return string.format(sControl,...) end

function l.oo(t)  --- print `t`'s string (the one generated by `o`)
  print(l.o(t)) end

function l.o(t,  seen) --- table to string (recursive)
  if type(t) ~= "table" then return tostring(t) end
  local pre = t._is and l.fmt("%s%s",t._is,t._id or "") or ""
  seen=seen or {}
  if seen[t] then return l.fmt("<%s>",pre) end
  seen[t]=t
  local function filter(k) return l.fmt(":%s %s",k,l.o(t[k],seen)) end
  local u   = #t>0 and l.map(t,tostring) or l.map(l.keys(t),filter)
  return pre.."{".. table.concat(u," ").."}" end

-- ## Objects
local _id=0
local function id() _id=_id+1; return _id end

function l.obj(s,    t,new) --- Create a klass and a constructor + print method
  local function new(k,...) 
     local i=setmetatable({_id=id()},k); t.new(i,...); return i end
  t={_is=s, __tostring = l.o}
  t.__index = t;return setmetatable(t,{__call=new}) end

-- That's all folks.
return l
