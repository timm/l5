local l=require"lib0"
local _=require"sam0"
local copy,cli = l.copy,l.cli
local o,oo     = l.o, l.oo
local the      = _.the

eg,fails = {},0

function eg.the() oo(the); return true end

function eg.num()
  n=Num()
  the.keep = 64
  for i=1,100 do add(n,i) end
  return 52==n:mid(r) and 32.56==rnd(n:div(),2)  end

function eg.load() oo(load("../../data/auto93.csv").cols); return true end

local function _egs(   t)
  t={}; for k,_ in pairs(eg) do t[1+#t]=k end; table.sort(t);  return t end

function eg.ls()
  print("\nExamples (lua eg.lua -f X):\nX=")
  for _,k in pairs(_egs()) do print(string.format("  %-7s",k)) end 
  return true end

function eg.all()
  for _,k in pairs(_egs()) do
    if k ~= "all" then 
      if not run(k) then fails = fails + 1; print("FAIL!",k) end end end end

function run(k,    b4,out)
  math.randomseed(the.seed)
  b4=copy(the); out=eg[k](); the=copy(b4); return out==true end

----------------------------------------------------------------------------
print(the.help)

the = cli(the)
if eg[the.example] then eg[the.example]() end
for k,v in pairs(_ENV) do if not l.b4[k] then print("?",k,type(v)) end end 
os.exit(fails)
