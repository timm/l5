-- lib.lua : some of my favorite lua tricks.
-- (c)2022 Tim Menzies <timm@ieee.org> BSD 2 clause license
local l={}

-- Cache names -----------------------------------------------------------------
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
function l.rogues()
  for k,v in pairs(_ENV) do if not b4[k] then print("?",k,type(v)) end end end

-- Print table -----------------------------------------------------------------
function l.chat(t) print(l.cat(t)); return t end

function l.cat(t)
  if type(t)~="table" then return tostring(t) end
  local function show(k,v)
    if not tostring(k):find"^[A-Z]"  then
      v=l.cat(v)
      return #t==0 and string.format(":%s %s",k,v) or tostring(v) end end
  local u={}; for k,v in pairs(t) do u[1+#u] = show(k,v) end
  table.sort(u)
  return (t._is or "").."{"..table.concat(u," ").."}" end

-- Maths ----------------------------------------------------------------------
function l.rnd(num, places)
  local mult = 10^(places or 3)
  return math.floor(num * mult + 0.5) / mult end
 
-- Lists -----------------------------------------------------------------------
function l.any(t) return t[math.random(#t)] end

function l.copy(t)
  if type(t) ~= "table" then return t end
  local u={}; for k,v in pairs(t) do u[k] = l.copy(v) end
  return setmetatable(u,getmetatable(t))  end

function l.least(t,x,   y)
  for _,n in pairs(t) do y=n; if x <= y then break end end
  return y end

function l.many(t,n,  u)  u={}; for i=1,n do u[1+#u]=l.any(t) end; return u end

function l.per(t,p)
  p=p or .5
  p=math.floor((p*#t)+.5); return t[math.max(1,math.min(#t,p))] end

function l.push(t,x) t[1+#t]=x; return x end

-- Return items in `t` filtered through `f`. If `f` ever returns nil
-- then the returned list will be shorter.
function l.map(t,fun)
  local t1={}; for _,v in pairs(t) do t1[1+#t1]=fun(v) end; return t1 end

-- Return a function that sorts on slot `x`
function l.lt(x) return function(a,b) return a[x] < b[x] end end

-- In-place sort, returns sorted list
function l.sort(t,fun) table.sort(t,fun); return t end

-- Update slots in `t` from command line ---------------------------------------
function l.cli(t)
  for slot,v in pairs(t) do
    v = tostring(v)
    for n,x in ipairs(arg) do
      if x=="-"..(slot:sub(1,1)) or x=="--"..slot then
        v = v=="false" and "true" or v=="true" and "false" or arg[n+1] end end
    t[slot] =  l.coerce(v) end
  return t end

-- Define classes --------------------------------------------------------------
function l.obj(name)
  local function new(k,...)
    local self = setmetatable({},k)
    return setmetatable(k.new(self,...) or self,k) end
  local t={_is = name, __tostring = l.cat}
  t.__index = t
  return setmetatable(t,{__call=new}) end

-- Coerce ----------------------------------------------------------------------
function l.coerce(str)
  local function coerce1(str)
    if str=="true"  then return true end 
    if str=="false" then return false end
    return str end 
  return tonumber(str) or coerce1(str:match"^%s*(.-)%s*$") end

-- Coerce lines from csv file (fiterling result through `fun`).
function l.csv(filename, fun)
  l.lines(filename, function(t) fun(l.words(t,",",l.coerce)) end) end

--- Call `fun  on all lines from `filename`.
function l.lines(filename, fun)
  local src = io.input(filename)
  while true do
    local str = io.read()
    if not str then return io.close(src) else fun(str) end end end

-- Split  `str` on `sep`, filtering parts through `fun`.
function l.words(str,sep,fun,      t)
  fun = fun or function(z) return z end
  sep = l.string.format("([^%s]+)",sep)
  t={};for x in str:gmatch(sep) do t[1+#t]=fun(x) end;return t end

return l
