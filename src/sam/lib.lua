-- lib.lua: misc LUA functions   
-- (c)2022 Tim Menzies <timm@ieee.org> BSD-2 licence
local l={}

---- ---- ---- ---- Meta
-- Find rogue locals.
l.b4={}; for k,v in pairs(_ENV) do l.b4[k]=v end 
function l.rogues()
  for k,v in pairs(_ENV) do if not l.b4[k] then print("?",k,type(v)) end end end

---- ---- ---- ---- Lists
-- Add `x` to a list. Return `x`.
function l.push(t,x) t[1+#t]=x; return x end

-- Sample one item
function l.any(t) return t[math.random(#t)] end

-- Sample many items
function l.many(t,n,  u)  u={}; for i=1,n do u[1+#u]=l.any(t) end; return u end

-- Deepcopy
function l.copy(t)
  if type(t) ~= "table" then return t end
  local u={}; for k,v in pairs(t) do u[k] = l.copy(v) end
  return setmetatable(u,getmetatable(t))  end

-- Round
function l.rnd(n, nPlaces)
  local mult = 10^(nPlaces or 3)
  return math.floor(n * mult + 0.5) / mult end
 
-- Deepcopy
function l.copy(t)
  if type(t) ~= "table" then return t end
  local u={}; for k,v in pairs(t) do u[k] = l.copy(v) end
  return u end

-- Return the `p`-th thing from the sorted list `t`.
function l.per(t,p)
  p=math.floor(((p or .5)*#t)+.5); return t[math.max(1,math.min(#t,p))] end

-- Return the list `t` sorted using `fun`.
function l.sort(t,fun)  table.sort(t,fun); return t end

-- Return a function that sorts on `s` , in ascending order.
function l.lt(s) return function(t1,t2) return t1[s] < t2[s] end end

-- Map `fun` over `t`, returning all not-nil results.
function l.map(t,fun,     t1)
  t1={}; for _,v in pairs(t) do t1[1+#t1] = fun(v) end; return t1 end

---- ---- ---- ---- Strings
-- `o` generates a string from a nested table.
function l.o(t)
  if type(t) ~=  "table" then return tostring(t) end
  local function show(k,v)
    if not tostring(k):find"^_"  then
      v = l.o(v)
      return #t==0 and string.format(":%s %s",k,v) or tostring(v) end end
  local u={}; for k,v in pairs(t) do u[1+#u] = show(k,v) end
  return (t._is or "").."{"..table.concat(#t==0 and l.sort(u) or u," ").."}" end

-- `oo` prints the string from `o`.   
function l.oo(t) print(l.o(t)) return t end
--
-- Convert string to something else.
function l.coerce(s)
  local function coerce1(s1)
    if s1=="true"  then return true end 
    if s1=="false" then return false end
    return s1 end 
  return math.tointeger(s) or tonumber(s) or coerce1(s:match"^%s*(.-)%s*$") end

-- Iterator over csv files. Call `fun` for each record in `fname`.
function l.csv(fname,fun)
  local src = io.input(fname)
  while true do
    local s = io.read()
    if not s then return io.close(src) else 
      local t={}
      for s1 in s:gmatch("([^,]+)") do t[1+#t] = l.coerce(s1) end
      fun(t) end end end 

---- ---- ---- ---- Settings
-- Parse help string looking for slot names and default values
function l.settings(s)
  local t={}
  s:gsub("\n [-][%S]+[%s]+[-][-]([%S]+)[^\n]+= ([%S]+)",
         function(k,x) t[k]=l.coerce(x)end)
  t._help = s
  return t end

-- Update `t` from values after command-line flags. Booleans need no values
-- (we just flip the defeaults).
function l.cli(t)
  for slot,v in pairs(t) do
    v = tostring(v)
    for n,x in ipairs(arg) do
      if x=="-"..(slot:sub(1,1)) or x=="--"..slot then
        v = v=="false" and "true" or v=="true" and "false" or arg[n+1] end end
    t[slot] = l.coerce(v) end
  if t.help then os.exit(print("\n"..t._help.."\n")) end
  return t end

---- ---- ---- ---- Main 
-- In this function:
-- - `k`=`ls`  : list all settings   
-- - `k`=`all` : run all demos   
-- - `k`=x     : run one thing
-- 
-- For each run, beforehand, reset random number seed. Afterwards,
-- discard and settings changes made during that one run. 
-- If any run does not return `true`, increment `fails`.
-- Return fails counter.
function l.runs(k,funs,settings)
  local fails =0
  local function _egs(   t)
    t={}; for k,_ in pairs(funs) do t[1+#t]=k end; table.sort(t); return t end
  if k=="ls" then -- list all
    print("\nExamples -e X):\nX=")
    print(string.format("  %-7s","all"))  
    print(string.format("  %-7s","ls")) 
    for _,k in pairs(_egs()) do print(string.format("  %-7s",k)) end 
  elseif k=="all" then -- run all
    for _,k in pairs(_egs()) do 
      fails=fails + (l.runs(k,funs,settings) and 0 or 1) end
  elseif funs[k] then -- run one
    math.randomseed(settings.seed) -- reset seed
    local b4={}; for k,v in pairs(settings) do b4[k]=v end
    local out=funs[k]()
    for k,v in pairs(b4) do settings[k]=v end -- restore old settings
    print("!!!!!!", k, out and "PASS" or "FAIL") end 
  l.rogues() 
  return fails end

-- -------------------------------------------------
-- That's all folks.
return l
