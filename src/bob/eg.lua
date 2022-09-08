local l=require"lib"
local Bob = require"Bob"
local o,oo = l.o,l.oo
local the = Bob.the
local eg,fails = {},0

-- 1. reset random number seed before running something.
-- 2. Cache the detaults settings, and...
-- 3. ... restore them after the test
-- 4. Print error messages or stack dumps as required.
-- 5. Return true if this all went well.
local function runs(k,     old,status,out,msg)
  if not eg[k] then return end
  math.randomseed(the.seed) -- reset seed [1]
  old={}; for k,v in pairs(the) do old[k]=v end --  [2]
  if the.dump then -- [4]
    status,out=true, eg[k]() 
  else
    status,out=pcall(eg[k]) -- pcall means we do not crash and dump on errror
  end
  for k,v in pairs(old) do the[k]=v end -- restore old settings [3]
  msg = status and ((out==true and "PASS") or "FAIL") or "CRASH" -- [4]
  print("!!!!!!", msg, k, status)
  return out or err end

-- Test that the test  happens when something crashes?
function eg.BAD() print(eg.dont.have.this.field) end

-- Sort all test names.
function eg.LIST(   t)
  t={}; for k,_ in pairs(eg) do t[1+#t]=k end; table.sort(t); return t end

-- List test names.
function eg.LS()
  print("\nExamples lua csv -e ...")
  for _,k in pairs(eg.LIST()) do print(string.format("\t%s",k)) end 
  return true end

-- Run all tests
function eg.ALL()
  for _,k in pairs(eg.LIST()) do 
    if k ~= "ALL" then
      print"\n-----------------------------------"
      if not runs(k) then fails=fails+ 1 end end end 
  return true end
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
  div  = function(col) return col:div() end
  mid  = function(col) return col:mid() end
  print("xmid", o( data:stats(2, data.cols.x, mid)))
  print("xdiv", o( data:stats(3, data.cols.x, div)))
  print("ymid", o( data:stats(2, data.cols.y, mid)))
  print("ydiv", o( data:stats(3, data.cols.y, div)))
  return true
end

-- distance functions
function eg.around(    data,around)
  data = Data("../data/auto93.csv")
  around = data:around(data.rows[1] )
  for i=1,380,40 do print(around[i].dist, o(around[i].row.cells)) end
  return true end

-- ---------------------------------
--  Start up
the = l.cli(the)  
runs(the.eg)
l.rogues() 
os.exit(fails) 
