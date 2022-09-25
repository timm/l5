fmt=sting.format

function last(t)    return t[#t] end
function push(t, x) table.insert(t,x); return x end
function sort(t, f) table.sort(t,f); return t end
function map(t, f)  local u={};for _,v in pairs(t)do u[1+#u]=f(v)end;return u end
function kap(t, f)  local u={};for k,v in pairs(t)do u[k]=f(k,v)end; return u end
function keys(t) 
  local function want(k,_) if tostring(k):sub(1,1) ~= "_" then return k end end
  return sort(kap(t,want)) end

function oo(t)      print(o(t)) end
function o(t) 
  if type(t) ~= "table" then return tostring(t) end
  local function filter(v) return fmt(":%s %s",v,o(t[v])) end
  t = #t>0 and map(t,tostring) or map(keys(t),filter)
  return "{".. table.concat(t," ") .."}" end

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

local is={}
function is.skip(s)   return s:find":$"     end
function is.num(s)    return s:find"^[A-Z]" end
function is.goal(s)   return s:find"[!+-]$" end
function is.klass(s)  return s:find"!$"     end
function is.weight(s) return s:find"-$" and -1 or 1 end

function DATA() return {cols=nil,rows={}} end

function COL(n,s)
  return {has={}, at=n, name=s,
          is=kap(is,function(_,fun) return fun(n) end)} end 

function COLS(names)
  local cols={all={},x={},y={}}
  for n,s in pairs(names) do
    col = push(cols.all, COL(n,s))
    if not is.skip(s) then
      if is.klass(s) then cols.klass=col end
      push(is.goal(s)  and cols.y or cols.x, cols) end end
  return cols end

function norm(col,n,      lo,hi)
  lo,hi=col.has[1], last(col.has) 
  return hi - lo < 1E-9 and 0 or (x-lo)/(hi-lo) end 

function dists(cols, row1,row2)
  local function dist(col,x,y)
    if x=="?" and y=="?" then return 1 end
    if not col.is.num then return x==y and 0 or 1 else
      x,y = self:norm(x), self:norm(y)
      if x=="?" then x = y<.5 and 1 or 0 end
      if y=="?" then y = x<.5 and 1 or 0 end
      return math.abs(x-y) end 
  end 
  local d,n=0,0
  for _,col in pairs(cols.x) do
    n = n + 1
    d = d + dist(col,row1[col.at],row2[col.at])^2 end 
  return (d/n)^.5 end

function read(row,data)
  if not data.cols then data.cols=COLS(row) else
    push(data.rows, row)
    for n,x in pairs(row)do if x ~="?" then push(cols[n],x) end end end end

function main(file)
  local rows,cols = {},{}
  csv(file, read)
  map(cols,function(col) table.sort(col.has) end)
  

