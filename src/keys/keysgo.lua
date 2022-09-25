l=require"keyslib"
k=require"keys"

local map,o,obj,oo,push = l.map,l.o,l.obj,l.oo,l.push
local the,SOME,COL,DATA,XY = k.the,k.SOME, k.COL, k.DATA, k.XY

local function cli(the) --- alters contents of `the` from command-line
  for k,v in pairs(the) do
    local v=tostring(v)
    for n,x in ipairs(arg) do
      if x=="-"..(k:sub(1,1)) or x=="--"..k then
         v = v=="false" and "true" or v=="true" and "false" or arg[n+1] end end
    the[k] = l.coerce(v) end  
  if the.help then os.exit(print(the._help)) end  
  return the end

local function run(go,the)
  local fails,defaults = 0,{}
  for k,v in pairs(the) do defaults[k]=v end
  for _,k in pairs(keys(go)) do 
    if the.go == "all" or the.go==k then 
      for k,v in pairs(defaults) do the[k]=v end
      l.srand(the.seed)
      if go[k]() == false then fails=fails+1 end end end 
   l.rogues()
   os.exit(fails) end
-------------------------------------------------------------------------------
local go={}

function go.the() oo(the) end

-------------------------------------------------------------------------------
run(go,cli(the))
