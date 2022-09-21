local b4={}; for k,v in pairs(_ENV) do b4[k]=v end;

function aaaa(x) return x+1 end

print(aaaa(100))

_ENV = b4

--print(a(100))

for k,v in pairs(_G) do print(k,v) end
