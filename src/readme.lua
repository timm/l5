toc={}
obj={}

function lines(sFilename, fun,      src,s) --- call `fun` on csv rows.
  src  = io.input(sFilename)
  while true do
    s = io.read()
    if s then fun(s) else return io.close(src) end end end

function dump()
  if #toc>0 then
    print("\n| What | Notes |\n|:---|:---|")
    for _,two in pairs(toc) do print("| "..two[1].." | ".. two[2] .." |") end 
    print"\n" end
  toc={} end 

function trim(s) return s:match"^%s*(.-)%s*$" end 

local is={}
function is.str(s) if s:sub(1,1)=="s" then return "str"  end end
function is.num(s) if s:sub(1,1)=="n" then return "num" end end
function is.tbl1(s) if s=="t"          then return "tab" end end

function of(s) return obj[s] or is.str(s) or is.num(s) or is.tbl1(s) end

function pretty(s)
  local function annotate(s1,type) 
    return type and s1..":`"..type .. "`" or s1 end
  return s:gsub("[,]?    .*", ")")
          :gsub(":new()",    "")
          :gsub("([^, ()]+)", function(s1) 
                               s1=trim(s1); return annotate(s1,of(s1)) end) end

for i,file in ipairs(arg) do
    print("\n#",file,"\n")
    lines(file,function(line)
      line:gsub("[A-Z][A-Z]+",      
                function(x) obj[x:lower()]=x 
                            obj[x:lower().."s"]="["..x.."]" end)
      if line:find"^[-][-] " then
        line:gsub("^[-][-] ([^\n]+)", 
                  function(x) dump(); print(x:gsub("[-][-][-][-][-].*",""),"") end) 
      else  
        line:gsub("^function[%s]+([^-]+)[-][-][-] ([^\n]+)",
                  function(what,notes) toc[1+#toc] = {pretty(what),notes} end) end end) 
    dump() end 
