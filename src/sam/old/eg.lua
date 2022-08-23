-- eg.lua : demo code for sam.lua
-- (c)2022 Tim Menzies <timm@ieee.org> BSD 2 clause license
local l=require"lib"
local _=require"sam"
local cat,chat,cli,copy,per = l.cat,l.chat,l.cli,l.copy,l.per
local rogues = l.rnd,l.rogues
local Num = _.Num
local the,eg,fails = _.the,{},0

local function run(k,    b4,out)
  math.randomseed(the.seed)
  b4=copy(the); out=eg[k].fun(); the=copy(b4); return out==true end

local function egs(   t)
  t={}; for k,v in pairs(eg) do t[1+#t]=k end; table.sort(t);  return t end

eg.the = {doc="show config", fun=function () 
  chat(the); return true end}

eg.ls = {doc="list examples", fun=function ()
  print("\nExamples (lua eg.lua -f X):\nX=")
  for _,k in pairs(egs()) do print(string.format("%7s : %s",k,eg[k].doc)) end 
  return true end}

eg.all = {doc="run all examples", fun=function()
  for _,k in pairs(egs()) do
    if k ~= "all" then 
      if not run(k) then fails = fails + 1; print("FAIL!",k) end end end end}

eg.nums = {doc="numbers", fun=function(   n)
  n=Num()
  the.keep = 64
  for i=1,100 do n:add(i) end
  return 52==n:mid(r) and 32.56==rnd(n:div(),2)  end}

the = cli(the)
if eg[the.example] then eg[the.example].fun() end
rogues()
os.exit(fails) 
