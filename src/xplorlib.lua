local b4={}; for k,v in pairs(_ENV) do b4[k]=v end;
local l ={}

function l.rogues() 
  for k,v in pairs(_ENV) do if not b4[k] then print("?",k,type(v)) end end end

function l.obj(s,    t,i,new) 
  local isa=setmetatable
  function new(k,...) i=isa({},k); return isa(t.new(i,...) or i,k) end
  t={__tostring = function(x) return s..l.o(x) end}
  t.__index = t;return isa(t,{__call=new}) end

function l.settings(txt,    t)
  t={}; txt:gsub("\n [-][%S]+[%s]+[-][-]([%S]+)[^\n]+= ([%S]+)", 
                 function(k,v) t[k]=l.coerce(v) end)
  t._help = t
  return t end

-- ## Maths
function l.per(t,p) --- return the pth (0..1) item of `t`.
  p=math.floor(((p or .5)*#t)+.5); return t[math.max(1,math.min(#t,p))] end

function l.ent(t) --- entropy of a list of counts
  function fun(p) return p*math.log(p,2) end
  e=0; for _,n in pairs(t) do if n>0 then e=e-fun(n/self.n) end end
  return e end
 
-- ## Lists
function l.push(t,x)  --- push `x` onto `t`, return `x`
  table.insert(t,x); return t end

-- ## Sort
function l.sort(t,fun) --- return `t`, sorted using function `fun`. 
  table.sort(t,fun); return t end

function l.lt(x) --- return function that sorts ascending on key `x`
  return function(a,b) return a[x] < b[x] end end

-- ## String to thing
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
    then t = {}; for s1 in s:gmatch("([^,]+)") do t[1+#t]=l.coerce(s1) end; fun(t)
    else return io.close(src) end end end

-- ## Thing to String
function l.fmt(str,...) --- emulate printf
  return string.format(str,...) end

function l.oo(t)  --- Print a table `t` (non-recursive)
  print(l.o(t)) end 

function l.o(t) ---  Generate a print string for `t` (non-recursive)
  if type(t) ~= "table" then return tostring(t) end
  t = #t>0 and l.map(t,tostring)
            or l.map(l.keys(t),function(v) return l.fmt(":%s %s",v,o(t[v])) end)
  return "{".. table.concat(t," ") .."}" end

-- ## Meta
function map(t,fun) --- Return `t`, filter through `fun(value)` (skip nils)
  local u={}; for _,v in pairs(t) do u[1+#u] = fun(v) end; return u end

function kap(t,fun) --- Return `t` and its size, filtered via `fun(key,value)`
  local u={}; for k,v in pairs(t) do u[k]=fun(k,v) end; return u end

function keys(t) --- Return keys of `t`, sorted (skip any with prefix  `_`)
  return sort(kap(t,function(key,_)  
                if tostring(key):sub(1,1) ~= "_" then return key end end)) end

-- ## Misc
function load(src,  data,     row)
  function fun(t) if data then data:add(t) else data=DATA(t) end end
  if type(src)=="table" then csv(src, fun) else map(src or {}, fun) end
  return data end

function cli(t) --- update table slots via command-line flags
  for k,v in pairs(t) do
    local v=tostring(v)
    for n,x in ipairs(arg) do
      if x=="-"..(k:sub(1,1)) or x=="--"..k then
         v = v=="false" and "true" or v=="true" and "false" or arg[n+1] end end 
  t[k] = coerce(v) end end


return l
