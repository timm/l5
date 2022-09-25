local l={}
-- ## Maths
function l.R(n) --- shortcut to math.random
  return math.random(n) end

-- ## Lists
function l.ent(t) --- entropy
  local function calc(p) return p*math.log(p) end
  local n=0; for _,n1 in pairs(t) do n=n+n1 end
  local e=0; for _,n1 in pairs(t) do e=e - calc(n1/n) end 
  return e end

function l.kap(t, fun) --- map function `fun`(k,v) over list (skip nil results) 
  local u={};for k,v in pairs(t)do u[k]=fun(k,v)end; return u end

function l.keys(t) --- sort+return `t`'s keys (ignore things with leading `_`)
  local function want(k,x) if tostring(k):sub(1,1) ~= "_" then return k end end
  return l.sort(l.kap(t,want)) end

function l.last(t) -- return list item in a list
  return t[#t] end

function l.map(t, fun)  --- map function `fun`(v) over list (skip nil results) 
  local u={};for i,v in pairs(t)do u[1+#u]=fun(v)end;return u end

function l.push(t, x) --- push `x` to end of list; return `x` 
  table.insert(t,x); return x end

function l.sd(t) --- sorted list standard deviation= (90-10)th percentile/2.58
  return i(t[(.9*#t)//1] - t[(.1*#t)//1])/ 2.58 end

function l.sort(t, fun) --- return `t`,  sorted by `fun` (default= `<`)
  table.sort(t,fun); return t end

-- ## Strings
fmt = string.format
function oo(t)      print(o(t)) end
function o(t) 
  if type(t) ~= "table" then return tostring(t) end
  local function filter(v) return fmt(":%s %s",v,o(t[v])) end
  t = #t>0 and map(t,tostring) or map(keys(t),filter)
  return (t._is or "").."{".. table.concat(t," ") .."}" end

-- strings to things
function coerce(s,    fun) --- Parse `the` config settings from `help`
  function fun(s1)
    if s1=="true"  then return true  end
    if s1=="false" then return false end
    return s1 end
  return math.tointeger(s) or tonumber(s) or fun(s:match"^%s*(.-)%s*$") end

function csv(sFilename, fun,      src,s,t) --- call `fun` on csv rows
  src  = io.input(sFilename)
  while true do
    s = io.read()
    if   s
    then t={}; for s1 in s:gmatch("([^,]+)") do t[1+#t]=coerce(s1) end; fun(t)
    else return io.close(src) end end end

-- objects
function l.obj(s,    t,i,new) --- Create a klass and a constructor + print method
  local isa=setmetatable
  function new(k,...) i=isa({},k); return isa(t.new(i,...) or i,k) end
  t={__tostring = function(x) return l.o(x) end}
  t.__index = t;return isa(t,{_is=s,__call=new}) end

-- options
function l.options(s,    t) --- parse help string to extract settings
  t={}; s:gsub("\n [-][%S]+[%s]+[-][-]([%S]+)[^\n]+= ([%S]+)",
                 function(k,v) t[k]=l.coerce(v) end)
  t._help = s
  return t end

-- That's all folks.
return l
-
