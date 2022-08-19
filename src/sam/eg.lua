l=require"lib"
_=require"sam"
local cat,cli,copy,rogues = l.cat, l.cli,l.copy,l.rogues
local the = _.the

local eg={}
local fails=0

local function run(k)
  math.randomseed(the.seed)
  math.random(the.seed)
  local b4 = copy(the)
  local ok = eg[k] and eg[k]() == t  
  the = copy(b4) 
  return ok end

function eg.ls()
  local t={}; for k,v in pairs(eg) do t[1+#t]=t end; table.sort(t) 
  for _,k in pairs(t) do print(string.format("lua eg.lua -e ~a",k)) end end

function eg.all()
  local t={}; for k,v in pairs(eg) do t[1+#t]=t end; table.sort(t) 
  for _,k in pairs(t) do
    if k ~= "all" then 
      if not run(k) then fails = fails + 1; print("FAIL!",k) end end end end

the = cli(the)
eg[the.example]()
rogues()
os.exit(fails) 
