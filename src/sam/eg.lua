-- eg.lua : demo code for sam.lua
-- (c)2022 Tim Menzies <timm@ieee.org> BSD 2 clause license
local l=require"lib"
local _=require"sam"
local cat,chat,cli,copy,rogues = l.cat,l.chat,l.cli,l.copy,l.rogues
local the = _.the

local eg={}
local fails=0

local function run(k)
  math.randomseed(the.seed)
  local b4 = copy(the)
  local ok = eg[k]() == true  
  the = copy(b4) 
  return ok end

function eg.the() chat(the); return true end 

function eg.ls()
  print("")
  local t={}; for k,v in pairs(eg) do t[1+#t]=k end; table.sort(t) 
  for _,k in pairs(t) do print(string.format("lua eg.lua -e %s",k)) end 
  return true end

function eg.all()
  local t={}; for k,v in pairs(eg) do t[1+#t]=k end; table.sort(t) 
  for _,k in pairs(t) do
    if k ~= "all" then 
      if not run(k) then fails = fails + 1; print("FAIL!",k) end end end end

the = cli(the)
if eg[the.example] then eg[the.example]() end
rogues()
os.exit(fails) 
