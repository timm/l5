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

function eg.dist(  data)
  data=read("../../data/auto93.csv")
  for i=2,#data.rows do
    print(dist(data,data.rows[1], data.rows[i])) end 
  return true end

-- -------------------------------------------------------------------------
the = l.cli(the)
os.exit( l.run(the.eg, eg, the))
