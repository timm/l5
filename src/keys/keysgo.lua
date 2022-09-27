local l=require"keyslib"
local k=require"keys"

local fmt,map,o,obj,oo     = l.fmt,l.map,l.o,l.obj,l.oo
local powerset, push,top   = l.powerset, l.push,l.top
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
  for _,k in pairs(l.keys(go)) do 
    if the.go == "all" or the.go==k then 
      for k,v in pairs(defaults) do the[k]=v end
      l.srand(the.seed)
      if go[k]() == false then fails=fails+1 end end end 
   l.rogues()
   os.exit(fails) end
-------------------------------------------------------------------------------
local go={}

function go.the() oo(the) end

function go.some(    some)
  some=SOME(32)
  for i=1,10000 do some:add(i) end
  oo(some:nums()) end

function go.col(     col)
  col=COL("N")
  for i=1,10^6 do col:add(i) end 
  print(col)
  oo(col.has:nums()) end 

function go.data(      data)
  data=load(the.file) 
  oo(data.cols.all[4].has:nums()) end

function go.clone(     data1,data2)
  data1=load(the.file) 
  data2=data1:clone(data1.rows)
  oo(data1.cols.all[4].has:nums()) 
  print""
  oo(data2.cols.all[4].has:nums()) end

function go.sorted(      data,rows)
  data = load(the.file) 
  rows = data:sorted() 
  oo(data.cols.names)
  for i=1,#rows,20 do print(i,o(rows[i])) end
end

function go.xys(     data)
  data = load(the.file) 
  map(data:xys(),oo)
end

function go.learn(     data)
  data = load(the.file) 
  xyss,B,R= data:xys()
  local function fun(xys) return {score=XY.like(xys,"best",B,R),xys=xys} end 
  top(the.beam, sort(map(powerset(top(the.beam,xyss)), fun),gt"score"))
end

-------------------------------------------------------------------------------
run(go,cli(the))
