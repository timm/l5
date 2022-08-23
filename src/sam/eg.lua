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
local l=require"lib"
local _=require"sam"

local o,oo,per,push,rnd = l.o,l.oo,l.per,l.push,l.rnd
local add,adds,dist,div = _.add,_.adds,_.dist,_.div
local mid, read, the = _.mid,_.read,_.the
local Num,Sym      = _.Num, _.Sym

local eg= {}
function eg.the() oo(the); return true end

function eg.ent(  sym,ent)
  sym= adds(Sym(), {"a","a","a","a","b","b","c"})
  ent= div(sym)
  print(ent,mid(sym))
  return 1.37 <= ent and ent <=1.38 end

function eg.num(  num)
  num=Num()
  for i=1,100 do add(num,i) end
  local med,ent = mid(num), rnd(div(num),2)
  print(mid(num) ,rnd(div(num),2))
  return 50<= med and med<= 52 and 30.5 <ent and ent <32 end 

function eg.bignum(  num)
  num=Num()
  the.nums = 32
  for i=1,1000 do add(num,i) end
  oo(_.nums(num))
  return 32==#num._has end

function eg.read() 
 oo(read("../../data/auto93.csv").cols.y); return true end

function eg.dist(  data,t)
  data=read("../../data/auto93.csv")
  t={}
  for i=1,20 do push(t,rnd(dist(data,l.any(data.rows), l.any(data.rows)),2)) end 
  table.sort(t)
  oo(t)
  return true end

-- -------------------------------------------------------------------------
the = l.cli(the)
os.exit( l.run(the.eg, eg, the))
