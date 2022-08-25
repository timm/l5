-- In this code:
-- - Line strive to be 80 chars (or less)
-- - Two spaces before function argumnets denote optionals.
-- - Four spaces before function argumnets denote local variables.
-- - Private functions start with `_`
-- - Arguments of private functions do anything at all
-- - Local variables inside functions do anything at all
-- - Arguments of public functions use type hints
--   - Variable  `x` is is anything
--   - Prefix `is` is a boolean
--   - Prefix `fun` is a function
--   - Prefix `f` is a filename
--   - Prefix `n` is a string
--   - Prefix `s` is a string
--   - Prefix `c` is a column index
--   - `col` denotes `num` or `sym`
--   - `x` is anything (table or number of boolean or string
--   - `v` is a simple value (number or boolean  or  string)
--   - Suffix `s` is a list of things
--   - Tables are `t` or, using the above, a table of numbers would be `ns`
--   - Type names are lower case versions of constuctors; e.g `col` isa `Cols`.
--      
--  All demo functions `eg.fun1` can be called via  `lua eg.lua -e fun1`.
local eg= {}

local l=require"lib"
local _=require"sam"
local o,oo,per,push,rnd = l.o,l.oo,l.per,l.push,l.rnd
local add,adds,dist,div = _.add,_.adds,_.dist,_.div
local mid, records, the = _.mid,_.records,_.the
local Num,Sym      = _.Num, _.Sym

-- Settings come from big string top of "sam.lua" 
-- (maybe updated from comamnd line)
function eg.the() oo(the); return true end

-- The middle and diversity of a set of symbols is called "mode" 
-- and "entropy" (and the latter is zero when all the symbols 
-- are the same).
function eg.ent(  sym,ent)
  sym= adds(Sym(), {"a","a","a","a","b","b","c"})
  ent= div(sym)
  print(ent,mid(sym))
  return 1.37 <= ent and ent <=1.38 end

-- The middle and diversity of a set of numbers is called "median" 
-- and "standard deviation" (and the latter is zero when all the nums 
-- are the same).
function eg.num(  num)
  num=Num()
  for i=1,100 do add(num,i) end
  local med,ent = mid(num), rnd(div(num),2)
  print(mid(num) ,rnd(div(num),2))
  return 50<= med and med<= 52 and 30.5 <ent and ent <32 end 

-- Nums store only a sample of the numbers added to it (and that storage 
-- is done such that the kept numbers span the range of inputs).
function eg.bignum(  num)
  num=Num()
  the.nums = 32
  for i=1,1000 do add(num,i) end
  oo(_.nums(num))
  return 32==#num._has end

-- We can read data from disk-based csv files, where row1 lists a
-- set of columns names. These names are used to work out what are Nums, or
-- ro Syms, or goals to minimize/maximize, or (indeed) what columns to ignre.
function eg.records() 
 oo(records("../../data/auto93.csv").cols.y); return true end

-- Any two rows have a distance 0..1 that satisfies equality, symmetry
-- and the triangle inequality.
function eg.dist(  data,t)
  data=records("../../data/auto93.csv")
  t={}
  for i=1,100 do 
     local A,B,C = l.any(data.rows), l.any(data.rows), l.any(data.rows)
     local a,b,c = dist(data,B,C), dist(data,A,C), dist(data,A,B)
     assert(a<=1 and b<=1 and c<=1)
     assert(a>=0 and b>=0 and c>=0)
     assert( dist(data,A,A) == 0)              -- equality
     assert( dist(data,A,B) == dist(data,B,A)) -- symmetry
     assert(a+b>=c)                            -- triangle inequality
     for _,x in pairs{a} do push(t,rnd(x,2)) end  end
  table.sort(t)
  oo(t)
  return true end

function eg.far(  data)
  data = records("../../data/auto93.csv")
  oo(data.rows[1].cells)
  for i,t in pairs(_.around(data,data.rows[1])) do 
    if i>390 or i< 10 then print(o(t.row.cells),t.dist) end end 
  oo(_.far(data, data.rows[1]).cells) 
  return true end

function eg.half(   data)
  data = records("../../data/auto93.csv")
  _.halves(data)
  --tree(_.halves(data),function(t) tostring(10) end)
  return true end

-- -------------------------------------------------------------------------
the = l.cli(the)
os.exit( l.runs(the.eg, eg, the))
