cat $1 |
gawk '
    BEGIN {FS=" --- "}
                        { gsub(/----- .*/,"") }
    gsub(/^-- ## /,"")  { H2= trim($0); H3="" }
    gsub(/^-- ### /,"") { H3= trim($0)        } 
    NF> 1 && $1 !~ /:_/ {
           $0 = trim($0)
           gsub(/^function[ \t]+/,"")
           gsub(/[,]?    [^)]*/,"",$1)
           gsub(/:new\(/,"(",$1)
           $1 = trim($1)
           $2 = trim($2)
           printf("%s|%s|%s|%s\n",H2,H3,$1,$2) }
    
    function trim(s) {
      gsub(/^[ \t]*/,"",s)
      gsub(/[ \t]*$/,"",s)
      return s } 
' | gawk '
    BEGIN { FS="|" }
          { for(i=1;i<=NF;i++) {
              d[NR][i]=$i
              w[i] = length($i)>w[i] ? length($i) : w[i] } }
END {
  s="| %-"w[3]"s | %-"w[4]"s |\n" 
  for(i=1;i<=NR;i++) {
     if (d[i][1] && (d[i][1] != d[i-1][1]))  {
         print "\n## "  d[i][1] ;
         #printf(s,"What","Notes")
         #printf("| %s | %s |\n",nch(w[3],"-"), nch(w[4],"-"))
      }
     if (d[i][2] && (d[i][2] != d[i-1][2]))  {
         print "\n### " d[i][2] ;
         #printf(s,"What","Notes")
         #printf("| %s | %s |\n",nch(w[3],"-"), nch(w[4],"-"))
     }
     printf(s,d[i][3],d[i][4]) } }

function nch(n,ch,    s) {
  while(--n>=0) s = s ch
  return s } '
     
          
