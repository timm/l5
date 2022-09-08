local l=require"lib"
local the           = require"about"
local obj           = l.obj
local Num,Sym       = obj"Num",  obj"Sym"
local Data,Cols,Row = obj"Data", obj"Cols", obj"Row"

return {the=the, Data=Data, Cols=Cols, Row=Row, Num=Num, Sym=Sym}
