local l = {}

-- ### Find rogue locals

local b4 = {}; -- a cache of old globals. used to find rogue globals.
for k,v in pairs(_ENV) do b4[k]=v end 
function l.rogues()
  for k,v in pairs(_ENV) do if not b4[k] then print("?",k,type(v)) end end end

-- ### Settings
-- Create a `the` variables
function l.settings(s,     t)
  t = {_help=s}
  s:gsub("\n [-][%S]+[%s]+[-][-]([%S]+)[^\n]+= ([%S]+)",
         function(k,x) t[k] = l.coerce(x) end)
  return t end

-- Parse `the` config settings from `help`.
function l.coerce(s,    fun)
  function fun(s1)
    if s1=="true"  then return true end 
    if s1=="false" then return false end
    return s1 end 
  return math.tointeger(s) or tonumber(s) or fun(s:match"^%s*(.-)%s*$") end

-- Updates from command-line flags. Booleans need no values (just flip default).
function l.cli(t)
  for slot,v in pairs(t) do
    v = tostring(v)
    for n,x in ipairs(arg) do
      if x=="-"..(slot:sub(1,1)) or x=="--"..slot then
        v = v=="false" and "true" or v=="true" and "false" or arg[n+1] end end
    t[slot] = l.coerce(v) end
  if t.help then os.exit(print("\n"..t._help.."\n")) end
  return t end

-- ### Sampling
-- Select any one.
function l.any(t) return t[math.random(#t)] end

-- Select any `n`.
function l.many(t1,n,  t2)
  if n >= #t1 then return l.shuffle(t1) end
  t2={}; for i=1,n do l.push(t2, l.any(t1)) end; return t2 end

-- Randomly shuffle, in place, the list `t`.
function l.shuffle(t,   j)
  for i=#t,2,-1 do j=math.random(i); t[i],t[j]=t[j],t[i] end; return t end

-- ### Strings
l.fmt = string.format

-- ### Lists
-- Deepcopy
function l.copy(t,    u)
  if type(t) ~= "table" then return t end
  u={}; for k,v in pairs(t) do u[k] = l.copy(v) end
  return setmetatable(u,getmetatable(t))  end

-- Return the `p`-th thing from the sorted list `t`.
function l.per(t,p)
  p=math.floor(((p or .5)*#t)+.5); return t[math.max(1,math.min(#t,p))] end

-- Add to `t`, return `x`.
function l.push(t,x) t[1+#t]=x; return x end

-- Function, return a sorted list.
function l.sort(t,f) table.sort(t,f); return t end

-- Sorting functions
function l.lt(x) return function(t1,t2) return t1[x] < t2[x] end end
function l.gt(x) return function(t1,t2) return t1[x] > t2[x] end end

-- Map a function over a list
function l.map(t1,fun,    t2) 
  t2={}; for _,v in pairs(t1) do t2[1+#t2] = fun(v) end; return t2 end

-- Return `t` from `nGo` to `nStop` by `nStep` (defaults=1,#t,1)     
function l.slice(t,  nGo,nStop,nStep,    u)
  u={}
  for j=(nGo or 1)//1,(nStop or #t)//1,(nStep or 1)//1 do u[1+#u]=t[j] end
  return u end

-- Call `fun` on each row. Row cells are divided on `,`.
function l.csv(sFilename, fun,      src,s,t)
  src = io.input(sFilename)
  while true do
    s = io.read()
    if not s then return io.close(src) else 
      t={}
      for s1 in s:gmatch("([^,]+)") do t[1+#t] = l.coerce(s1) end
      fun(t) end end end

-- ### Strings
-- `o` is a telescope and `oo` are some binoculars we use to exam stucts.
-- `o`:  generates a string from a nested table.
function l.o(t,   seen,show,u)
  if type(t) ~=  "table" then return tostring(t) end
  seen=seen or {}
  if seen[t] then return "..." end
  seen[t] = t
  function show(k,v)
    if not tostring(k):find"^_"  then
      v = l.o(v,seen)
      return #t==0 and l.fmt(":%s %s",k,v) or l.o(v,seen) end end
  u={}; for k,v in pairs(t) do u[1+#u] = show(k,v) end
  if #t==0 then table.sort(u) end
  return "{"..table.concat(u," ").."}" end

-- `oo`: prints the string from `o`.   
function l.oo(t) print(l.o(t)) return t end

-- ### Maths
function l.rnd(x, places) 
  local mult = 10^(places or 2)
  return math.floor(x * mult + 0.5) / mult end

-- obj("Thing") enables a constructor Thing:new() ... and a pretty-printer
function l.obj(s,    t,i,new) 
  t={__tostring = function(x) return s..l.o(x) end}
  function new(k,...) i=setmetatable({},k);
                      return setmetatable(t.new(i,...) or i,k) end
  t.__index = t;return setmetatable(t,{__call=new}) end

-- That's all folks.
return l
