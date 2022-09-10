BEGIN { FS=","   }
NR==1 { header() }
NR>1  { data()   }

function header(   c) {
  for(c=1;c<=NF;c++) {
    Names[c] = $c;
    Hi[c]    = -1E31;
    Lo[c]    =  1E31;
    ($c ~ /[!+-]$/) ? Y[c] : X[c] }}

function data(  c) {
  for(c=1;c<=NF;c++) {
    D[NR-1][c] = $c
    D[NR-1][c] = $c
  }
  for(c in Lo)  {
    if ($c < Lo[c]) Lo[c]=$c + 0
    if ($c > Hi[c]) Hi[c]=$c + 0 }}

function dist(i,j,    c,d) {
  for(c in X) d = d + dist1(c, i, j)^2 
  return (d/length(X))^.5 }

function dist1(c,  i,j) {
  if (i=="?" && j=="?") return 1
  if (Lo[c]) {
    if      (i=="?") { j=norm(c, D[i][c]); i = j<.5 ? 1 : 0 }
    else if (j=="?") { i=norm(c, D[j][c]); j = i<.5 ? 1 : 0 }
    else    {i= norm(c, D[i][c]);  j= norm(c, D[j][c])}
    return  abs(i-j) 
  } else return i==j ? 0 : 1 }

function norm(c,z) {
  if (z=="?") return "?";
  return (Hi[c] - Lo[c]) < 1E-9 ? 0 : (z - Lo[c]) / (Hi[c] - Lo[c]) }

function around(row,rows,out,     r) {
  for(r in rows) {
    out[r]["d"] = dist(row, r)
    out[r]["r"] = r }
  keysort(out,"d") }

function far(row,rows,   out) {
  around(row,rows,out)
  return out[int(length(out)*.95)]["r"] }

#----------------------------------------------
function abs(x)      { return x>0 ? x : -1*x }
function array(x)    { split("",x,"") }
function malloc(x,k) { x[k][0]=0; delete x[k][0] }

function cat(a,  s,sep,k) {
  if (!isarray(a)) return a;
  s="{"; for(k in a)  {s=s sep (isarray(a[k]) ? cat(a[k]) : a[k]); sep=", "}
  return s"}" }

function slots(a,  s,k) {
  if (!isarray(a)) return a;
  s="{"; for(k in a) {s=s " :"k" " (isarray(a[k]) ? slots(a[k]) : a[k])}
  return s"}" }

function rogues(    s) {
  for(s in SYMTAB) if (s ~ /^[a-z]/    ) print "#W: Rogue: " s>"/dev/stderr"}

function keysort(a,k) {
  _keysorter = k
  return asort(a,a,"__keysort")
}
function __keysort(i1,x,i2,y) {
  return kompare(x[ _keysorter ] + 0, y[ _keysorter ] + 0) }

function kompare(x,y) { return  (x < y) ? -1: ((x == y) ?  0 : 1) }

END { 
print cat(Lo)
print cat(Hi)
for(r in D) if (r<50) print(r, dist(1,r))
#print cat(D[1])
#print cat(D[far(D[1],D)])
rogues() }
