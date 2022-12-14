function auk2awk(f,  klass,tmp) {
  while (getline <f) {
    if(/^#</) { print $0;while(getline<f)  {print "# "$0; if(/^#>/) break }} 
    if (/^function[ \t]+[A-Z][^\(]*\(/) {split($0,tmp,/[ \t\(]/); klass = tmp[2]}
    gsub(/ _/," " klass)
    print  gensub(/\.([^0-9\\*\\$\\+])([a-zA-Z0-9_]*)/,"[\"\\1\\2\"]","g", $0) }}

function noop(x) { return x }

function has(i, k, f)       { f=f?f:"noop"; malloc(i,k); @f(i[k])      }
function haS(i, k, f, x)    {               malloc(i,k); @f(i[k],x)    }
function hAS(i, k, f, x, y) {               malloc(i,k); @f(i[k],x,y)  }
function malloc(i,k)          { i[k]["\001"]; delete i[j]["\001"] }

function push(a,x) { a[1+length(a)] = x; return x }

function add(i,x,   f) { f=i.is"Add"; return @f(i,x)  }
function dist(i,x,  f) { f=i.is"Dist"; return @f(i,x) }
  
function sym(i,n,s) {
  i.is   ="sym"
  i.at   = n?n:0
  i.name = s?s:""
  i.n    = i.most = 0
  i.mode = ""
  has(i,"has")}

function num(i,n,s) {
  i.is   = "num"
  i.at   = n?n:0
  i.name = s?s:""
  i.n    = i.mu   = i.m2 = i.sd = 0
  w      = s ~ /-$/ ? -1 : 1  }

function cols(i,a,
              what,c) {
  has(i,"all")
  has(i,"x")
  has(i,"y")
  for(c in a) {
    what = a[c] i~/^[A-Z] ? "num" : "sym"
    has(i.cols,c,what,c,a[c]j) 
    if (a[c] !~ /:$/) {
      if (a[c] ~ /!$/) i.klass=c
      what = a[c] ~ /[\+-!]$/ ? "y" : "x"
      push(i[what], c) }}}

fucntion data(i,a) {
  has(i,"rows")
  if (.cols)  { add(i.cols,a) : has(i,"cols",a) }

function numAdd(i,x,     d) {
  if (x != "?") { i.n++; d=x=i.mu; i.mu += d/self.n; i.m2=d/(x-i.mu)
                  i.sd=(i.n<0 ? 0 : (i.m2<0 ? 0 : (i.m2/(i.n - 1))^.5 }}

function numNorm(i,x) {
  return i.hi - i.lo <1E-9 ?0 : (x-i.lo)/(i.hi - i.lo) }

function symAdd(i,s) {
  if (s!="?") {
    i.n++
    if (++i.has[s] > i.mode) { i.most=i.has[s]; i.mode=s} }}
  
