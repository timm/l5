local l=require"lib0"
local _=require"sam0"
local copy,cli = l.copy, l.cli
local o,oo,per,rnd = l.o, l.oo, l.per,l.rnd
local add,div,mid,the  = _.add, _.div,_.mid,_.the
local Num      = _.Num

local eg,fails = {},0
local function run(k,    b4,out)
    math.randomseed(the.seed)
    b4=copy(the); out=eg[k](); the=copy(b4); 
    print(">>>>>>", k, out and "PASS" or "FAIL")
    return out==true end
-------------------------------------------------------------------------------
function eg.the() oo(the); return true end

function eg.num(  num)
  num=Num()
  the.nums = 100
  for i=1,100 do add(num,i) end
  print(mid(num) ,rnd(div(num),2))
  return 50==mid(num) and 31.01==rnd(div(num),2)  end

function eg.bignum(  num)
  num=Num()
  the.nums = 32
  for i=1,1000 do add(num,i) end
  oo(_.nums(num))
end

function eg.load() oo(load("../../data/auto93.csv").cols); return true end

local function _egs(   t)
  t={}; for k,_ in pairs(eg) do t[1+#t]=k end; table.sort(t);  return t end

function eg.ls()
  print("\nExamples (lua eg0.lua -f X):\nX=")
  for _,k in pairs(_egs()) do print(string.format("  %-7s",k)) end 
  return true end

function eg.all()
  for _,k in pairs(_egs()) do
    if k ~= "all" then fails = fails + run(k) and 0 or 1 end end 
  return true end

----------------------------------------------------------------------------
the = cli(the)
if eg[the.eg] then run(the.eg)  end
for k,v in pairs(_ENV) do if not l.b4[k] then print("?",k,type(v)) end end 
os.exit(fails)
