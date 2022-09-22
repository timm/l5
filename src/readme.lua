function lines(fun)
  while true do
    s=io.read()
    if s then fun(s) else return io.close() end end  end

toc={}
function dump()
  if #toc>0 then
    print("\n| What | Notes |\n|:---:|:----|")
    for _,two in pairs(toc) do print("| "..two[1].." | ".. two[2] .." |") end end
  print"\n"
  toc={} end 

function pretty(s)
  return s:gsub("[,]?    .*",")")
          :gsub(":new()","")
          :gsub(",(%S)",function(w) return ", "..w end) end

lines(function(line)
  line:gsub("[A-Z][A-Z]+",      function(x) print("==>",x); return x end )
  line:gsub("^[-][-] ([^\n]+)", function(x) dump(); print(x:gsub("-----.*",""),"") end) 
  line:gsub("^function[%s]+([^-]+)[-][-][-] ([^\n]+)",
            function(what,notes) toc[1+#toc] = {pretty(what),notes} end) end)
dump()
