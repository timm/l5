BEGIN {FS=" --- "}
NF> 1 && $1 !~ /:_/ {
       gsub(/^function[ \t]+/,"")
       gsub(/[,]?    [^)]*/,"",$1)
       gsub(/:new\(/,"(",$1)
       gsub(/[ \t]+$/,"",$1)
       gsub(/[ \t]+$/,"",$2)
       what[++n]=$1
       wmax = length($1)>wmax ? length($1):wmax
       notes[n]=$2 
       nmax = length($2)>nmax ? length($2):nmax}

END {
  for(i=1;i<=n;i++) 
    printf("| %-"wmax"s| %-"nmax"s|\n",what[i],notes[i]) }

