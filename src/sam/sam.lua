-- For a list of coding conventions in this file, see 
-- [eg.lua](https://github.com/timm/lua/blob/main/src/sam/eg.lua).
local l=require"lib"
local the=l.settings([[   
SAM : Semi-supervised And Multi-objective explainations
(c) 2022 Tim Menzies <timm@ieee.org> BSD-2 license

USAGE: lua eg.lua [OPTIONS]

OPTIONS:
 -e  --eg     start-up example         = nothing
 -c  --cohen  small effect             = .35
 -h  --help   show help                = false
 -m  --min    min size = n^(the.min)   = .5
 -n  --nums   how many numbers to keep = 256
 -p  --p      distance coeffecient     = 2
 -s  --seed   random number seed       = 10019]])
-- Commonly used lib functions.
local o,oo,per,push = l.o,l.oo,l.per, l.push

---- ---- ---- ---- Classes 
local Data,Cols,Sym,Num,Row
-- Holder of `rows` and their sumamries (in `cols`).
function Data() return {cols=nil,  -- summaries of data
                        rows={}    -- kept data
                       } end

-- Holds of summaries of columns. 
-- Columns are created once, then may appear in  multiple slots.
function Cols() return {
  names={},  -- all column names
  all={},    -- all the columns (including the skipped ones)
  klass=nil, -- the single dependent klass column (if it exists)
  x={},      -- independent columns (that are not skipped)
  y={}       -- depedent columns (that are not skipped)
  } end

-- Summarizers a stream of symbols.
function Sym(c,s) 
  return {n=0,          -- items seen
          at=c or 0,    -- column position
          name=s or "", -- column name
          _has={}       -- kept data
         } end

-- Summarizes a stream of numbers.
function Num(c,s) 
  return {n=0,at=c or 0, name=s or "", _has={}, -- as per Sym
          isNum=true,      -- mark that this is a number
          lo= math.huge,   -- lowest seen
          hi= -math.huge,  -- highest seen
          sorted=true,    -- no updates since last sort of data
          w=(s or ""):find"-$" and -1 or 1 -- minimizing if w=-1
         } end

-- Holds one record
function Row(t) return {cells=t,         -- one record
                        cooked=i.copy(t) -- used if we discretize data
                       } end

---- ---- ---- ---- Data Functions
local add,adds,clone,div,mid,norm,nums,record,records,stats
---- ---- ---- Create
-- Generate rows from some `src`.  If `src` is a string, read rows from file; 
-- else read rows from a `src`  table. When reading, use row1 to define columns.
function records(src,      data,head,body)
  function head(sNames)
    local cols = Cols()
    cols.names = namess
    for c,s in pairs(sNames) do
      local col = push(cols.all, -- Numerics start with Uppercase. 
                       (s:find"^[A-Z]*" and Num or Sym)(c,s))
      if not s:find":$" then -- some columns are skipped
        push(s:find"[!+-]" and cols.y or cols.x, col) -- some cols are goal cols
        if s:find"!$"    then cols.klass=col end end end 
    return cols 
  end ------------
  function body(t) -- treat first row differently (defines the columns)
    if data.cols then record(data,t) else data.cols=head(t) end 
  end ----------
  data =  Data()
  if type(src)=="string" then l.csv(src, body) else 
    for _,t in pairs(src or {}) do body(t) end end 
  return data end

-- Return a new data with same structure as `data1`. Optionally, oad in `rows`.
function clone(data1,  rows)
  data2=Data()
  data2.cols = _head(data1.cols.names)
  for _,row in pairs(rows or {}) do record(data2,row) end
  return data2 end

---- ---- ---- Update
-- Add one thing to `col`. For Num, keep at most `nums` items.
function add(col,v)
  if v~="?" then
    col.n = col.n + 1
    if not col.isNum then col._has[v] = 1 + (col._has[v] or 0) else 
       col.lo = math.min(v, col.lo)
       col.hi = math.max(v, col.hi)
       local pos
       if     #col._has < the.nums           then pos = 1 + (#col._has) 
       elseif math.random() < the.nums/col.n then pos = math.random(#col._has) end
       if pos then col.sorted = false 
                   col._has[pos] = tonumber(v) end end end end

-- Add many things to col
function adds(col,t) for _,v in pairs(t) do add(col,v) end; return col end

-- Add a `row` to `data`. Calls `add()` to  updatie the `cols` with new values.
function record(data,xs)
  local row= push(data.rows, xs.cells and xs or Row(xs)) -- ensure xs is a Row
  for _,todo in pairs{data.cols.x, data.cols.y} do
    for _,col in pairs(todo) do 
      add(col, row.cells[col.at]) end end end

-- Unsupervised discretization.
function unsuper(data)
  local function sorter(col) 
    return function (row1,row2)
             local x,y = row1.cells[col.at], row2.cells[cols.at]
             x = x=="?" and math.huge or x
             y = y=="?" and math.huge or y
             return x < y end end
  for _,col in pairs(data.cols.x) do
    if col.isNum then
      local enough  = (#data.rows)^the.min
      local epsilon = div(col)    *the.cohen
      table.sort(data.rows,sorter(col))
      n,lo,hi = 0, data.rows[1].cells[col.at], data.rows[1].cells[col.at]
      for i,row in pairs(data.rows) do 
        v = row.cells[col.at]
        if v ~= "?" then
          if i < #data.rows - enough then
            w = data.rows[i+1].cells[col.at]
            if v~=w and (hi-lo)>epsilon and n>enough then n,lo,hi = 0,v,v end end 
          n  = n+1
          hi = v
          row.cooked[col.at] = lo end end end end end

---- ---- ---- Query
-- Return kept numbers, sorted. 
function nums(num)
  if not num.sorted then table.sort(num._has); num.sorted=true end
  return num._has end

-- Normalized numbers 0..1. Everything else normalizes to itself.
function norm(col,n) 
  return x=="?" or not col.isNum and x or  (n-col.lo)/(col.hi-col.lo + 1E-32) end

-- Diversity (standard deviation for Nums, entropy for Syms)
function div(col)
  if  col.isNum then local a=nums(col); return (per(a,.9)-per(a,.1))/2.58 else
    local function fun(p) return p*math.log(p,2) end
    local e=0
    for _,n in pairs(col._has) do if n>0 then e=e-fun(n/col.n) end end
    return e end end

-- Central tendancy (median for Nums, mode for Syms)
function mid(col)
  if col.isNum then return per(nums(col),.5) else 
    local most,mode = -1
    for k,v in pairs(col._has) do if v>most then mode,most=k,v end end
    return mode end end

-- For `showCols` (default=`data.cols.x`) in `data`, report `fun` (default=`mid`).
function stats(data,  showCols,fun,    t)
  showCols, fun = showCols or data.cols.y, fun or mid
  t={}; for _,col in pairs(showCols) do t[col.name]=fun(col) end; return t end

---- ---- ---- ---- Distance functions
local dist
-- Distance between rows (returns 0..1). For unknown values, assume max distance.
function dist(data,t1,t2)
  local function fun(col,  v1,v2)
    if   v1=="?" and v2=="?" then return 1 end
    if not col.isNum then return v1==v2 and 0 or 1 end 
    v1,v2 = norm(col,v1), norm(col,v2)
    if v1=="?" then v1 = v2<.5 and 1 or 0 end 
    if v2=="?" then v2 = v1<.5 and 1 or 0 end
    return math.abs(v1-v2) 
  end -------
  local d = 0
  for _,col in pairs(data.cols.x) do 
    d = d + fun(col, t1.cells[col.at], t2.cells[col.at])^the.p end
  return (d/#data.cols.x)^(1/the.p) end

-- ----------------------------------------------------------------------------
-- That's all folks.
return {the=the, 
        Data=Data, Cols=Cols, Sym=Sym, Num=Num, Row=Row, 
        add=add, adds=adds, clone=clone, dist=dist,  div=div,
        mid=mid, nums=nums, records=records, record=record, stats=stats}
