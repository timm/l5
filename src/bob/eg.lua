local l=require"lua"
local the=require"about"
local Sym,Num,Data = obj"Sym", obj"Num",obj"data"

local eg = {}

-- Test that the test  happes when something crashes?
function eg.BAD() print(eg.dont.have.this.field) end

-- Settings come from big string top of "sam.lua" 
-- (maybe updated from comamnd line)
function eg.the() oo(the); return true end

-- The middle and diversity of a set of symbols is called "mode" 
-- and "entropy" (and the latter is zero when all the symbols 
-- are the same).
function eg.sym(  sym,entropy,mode)
  sym= Sym()
  for _,x in pairs{"a","a","a","a","b","b","c"} do sym:add(x) end
  mode, entropy = sym:mid(), sym:div()
  entropy = (1000*entropy)//1/1000
  oo({mid=mode, div=entropy})
  return mode=="a" and 1.37 <= entropy and entropy <=1.38 end

-- The middle and diversity of a set of numbers is called "median" 
-- and "standard deviation" (and the latter is zero when all the nums 
-- are the same).
function eg.num(  num,mid,div)
  num=Num()
  for i=1,100 do num:add(i) end
  mid,div = num:mid(), num:div()
  print(mid ,div)
  return 50<= mid and mid<= 52 and 30.5 <div and div<32 end 

-- Nums store only a sample of the numbers added to it (and that storage 
-- is done such that the kept numbers span the range of inputs).
function eg.bignum(  num)
  num=Num()
  the.nums = 32
  for i=1,1000 do num:add(i) end
  oo(num:nums())
  return 32==#num._has; end

-- Show we can read csv files.
function eg.csv(   n) 
  n=0
  csv("../data/auto93.csv",function(row)
    n=n+1; if n> 10 then return else oo(row) end end); return true end

-- Can I load a csv file into a Data?.
function eg.data(   d)
  d = Data("../data/auto93.csv")
  for _,col in pairs(d.cols.y) do oo(col) end
  return true
end

-- Print some stats on columns.
function eg.stats(   data,mid,div)
  data = Data("../data/auto93.csv")
  div=function(col) return col:div() end
  mid=function(col) return col:mid() end
  print("xmid", o( data:stats(2,data.cols.x, mid)))
  print("xdiv", o( data:stats(3,data.cols.x, div)))
  print("ymid", o( data:stats(2,data.cols.y, mid)))
  print("ydiv", o( data:stats(3,data.cols.y, div)))
  return true
end
  
-- ---------------------------------
l.runs(the.eg, the, eg)
