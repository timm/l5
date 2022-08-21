local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local coerce,csv,o,oo,push
local cols,dist,data,header,isNum,norm,row

-- In this code:
-- - each line is usually 80 chars (or less)
-- - private functions start with "_"
-- - arguments of public functions use type hints
-- - arguments of private functions do anything at all
-- - local variables inside functions do anything at all
-- - prefix is is a boolean
-- - prefix fun is a function
-- - prefix f is a filename
-- - prefix n is a string
-- - prefix s is a string
-- - prefix c is a column index
-- - col denotes Num or Sym
-- - x is anything (table or number of boolean or string
-- - v is a simple value (number or boolean  or  string)
-- - suffix s is a list of things
-- - tables are t or, using the above, a table of numbers would be ns
-- - type names are lower case versions of constuctors. so in this code,
--   cols,data,num,sym are made by the functions Cols Data, Num, Sym

---- Lib
--- Lists
function push(t,x) t[1+#t]=x; return x end

--- Strings
-- `o` generates a string from a nested table.  
-- `oo` prints the string from `oo`.
function oo(t) print(o(t)) return t end
function o(t)
  if type(t) ~=  "table" then return tostring(t) end
  local function show(k,v)
    if not tostring(k):find"^[A-Z]"  then
      v=o(v)
      return #t==0 and string.format(":%s %s",k,v) or tostring(v) end end
  local u={}; for k,v in pairs(t) do u[1+#u] = show(k,v) end
  table.sort(u)
  return (t._is or "").."{"..table.concat(u," ").."}" end

function coerce(s)
  local function coerce1(s)
    if str=="true"  then return true end 
    if str=="false" then return false end
    return s end 
  return tonumber(s) or coerce1(s:match"^%s*(.-)%s*$") end

-- Iterator over csv files. Call `fun` for each record in `fname`.
function csv(fname,fun)
  local src = io.input(fname)
  while true do
    local s = io.read()
    if not s then return io.close(src) else 
      local t={}
      for s1 in s:gmatch("([^,]+)") do t[1+#t]=coerce(s1) end
      fun(t) end end end 

--- Data 
function Data() return {cols=nil,  rows={}} end
function Cols() return {klass=nil, names={}, nums={},
                        x={}, y={}, all={}} end

function Sym(c,s) 
  return {n=0,at=c or 0, name=s or "", _has={}} end

function Num(c,s) 
  return {n0,at=c or 0, name=s or "", _has={},
          isNum=true, lo= math.huge, hi= -math.huge, sorted=true,
          w=(s or ""):find"-$" and -1 or 1} end

function add(col,v)
  if v~="?" then
    col.n = col.n + 1
    if not col.isNum then col._has[v] = 1 + (col._has[v] or 0) else
      push(col._has,v)
      col.sorted = false
      col.hi = math.max(col.hi, v)
      col.lo = math.min(col.lo, v) end end end

-- Processes table of name strings (from row1 of csv file)
function header(sNames)
  local cols = Cols()
  cols.names = namess
  for c,s in pairs(sNames) do
    local col = push(cols.all, (s:find"^[A-Z]*" and Num or Sym)(c,s))
    if not s:find":$" then
      push(s:find"[!+-]" and cols.y or cols.x, col)
      if s:find"!$"    then cols.klass=col end end end 
  return cols end

function row(data,t)
  push(data.rows,t)
  for _,todo in pairs{data.cols.x, data.cols.y} do
    for _,col in pairs(todo) do 
      add(col, t[col.at]) end end end

-- if `src` is a string, read rows from file; else read rows from a `src`  table
function load(src)
  local data=Data()
  local function load1(t)
    if data.cols then row(data,t) else data.cols=header(t) end end
  if type(src)=="string" then csv(src,load1) else
    for _,t in pairs(src or {}) do load1(t) end end 
  return data end


-- function stats(data,cols)
--   for at,col in pairs(cols or data.cols.y) do
--     for _,row in pairs(data.rows) do
--       if 
--
--- Cluster ---------------------------------------------------------
function dist(data,t1,t2)
  local d = 0
  for _,col in pairs(data.cols.x) do 
    if v1=="?" and v2=="?" 
    then d = d + 1
    local v1 = norm(col,t1[col.at])
    local v2 = norm(col,t2[col.at])
    if not col.isNum 
    then d = d + (v1==v2 and 0 or 1) 
    else if v1=="?" then v1=v2<.5 and 1 or 0 end
         if v2=="?" then v2=v1<.5 and 1 or 0 end
         d= d + maths.abs(v1-v2)^2 end end 
  return (d/data.cols.nx)^.5 end

function norm(col,v)
  if v=="?" or not col.isNum then return v else
    local lo = col.lo[c]
    local hi = col.hi[c]
    return (hi - lo) <1E-9 and 0 or (v-lo)/(hi-lo) end end 

--- Cluster ---------------------------------------------------------
local eg={}
function eg.load() oo(load("../../data/auto93.csv").cols); return true end
function eg.dist() oo(load("../../data/auto93.csv").cols); return true end

for k,v in pairs(_ENV) do if not b4[k] then print("?",k,type(v)) end end 
