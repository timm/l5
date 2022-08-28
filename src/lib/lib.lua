local lib={}

for _,file in pairs{"lints", "strings","files","lists","maths",
                    "settings","objects"} do
  for s,fun in pairs(require(file)) do
    lib[s]=fun end end

return lib
