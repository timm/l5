function auk2awk(f,  klass,tmp) {
  while (getline <f) {
    if(/^#</) { print $0;while(getline<f)  {print "# "$0; if(/^#>/) break }} 
    if (/^function[ \t]+[A-Z][^\(]*\(/) {split($0,tmp,/[ \t\(]/); klass = tmp[2]}
    gsub(/ _/," " klass)
    print  gensub(/\.([^0-9\\*\\$\\+])([a-zA-Z0-9_]*)/,"[\"\\1\\2\"]","g", $0) }}

function add(i,x,   f)  { f=i.is"Add"; return @f(i,x)  }
function dist(i,x,   f) { f=i.is"Dist"; return @f(i,x) }
  
function num(i,n,s) {
  if(n ~= "?") {
    i.n++
    i.is   ="num"
    i.at   = n?n:0
    i.name = s?s:""
    i.mu   = i.m2 = i.sd = 0
    w      = s ~ /-$/ ? -1 : 1  }

function numAdd(i,x,     d) {
  if (x != "?") { i.n++; d=x=i.mu; i.mu += d/self.n; i.m2=d/(x-i.mu)
                  i.sd=(i.n<0 ? 0 : (i.m2<0 ? 0 : (i.m2/(i.n - 1))^.5 }}

function numNorm(i,x) {
  return i.hi - i.lo <1E-9 ?0 : (x-i.lo)/(i.hi - i.lo) }

function symAdd(i,s)
  if (s!="?") {
    i.n++
  
