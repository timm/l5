MAKEFLAGS += --silent
SHELL=/bin/bash
R=$(shell git rev-parse --show-toplevel)
T=/tmp/$(USER)

define xtract
mkdir -p $T
grep '^#$1 ' Makefile | sed 's/#$1 //' > $T/$1
endef

define pdfs
echo "" >> $2
figlet -W -f cybermedium $(basename $1 .lua) >> $2
echo "" >> $2
cat $1  >> $2
endef

README.md : keys.lua keyslib.lua
	grep '^#0' Makefile | sed 's/^#0 //' > $@ 
	(echo ""; echo "\`\`\`css")  >> $@
	lua keysgo.lua -h       >> $@ 
	(echo "\`\`\`"; echo"") >> $@
	grep '^#h' Makefile | sed 's/^#h //' >> $@ 
	lua ../readme.lua $^ >>$@

D=auto2 auto93 nasa93dem china coc1000 healthCloseIsses12mths0011-easy \
   healthCloseIsses12mths0001-hard pom SSN SSM#

best:; echo 1; $(foreach d,$D, lua tiny2.lua -f ../data/$d.csv -g best; )
xys:; echo 1; $(foreach d,$D, lua tiny2.lua -f ../data/$d.csv -g xys; )
rule:; echo 1; $(foreach d,$D, lua tiny2.lua -f ../data/$d.csv -g rule; )
bestLeaf:;   $(foreach d,$D, lua l5.lua -s ${RANDOM} -S 2000 -m 10 -f ../data/$d.csv -e bestLeaf; )

y?=saving
itso: ## save all to Github
	echo "git commit -am '$y'"
	git add *;git commit -am "$y";git push;git status

pdf : 
	(figlet -W -f larry3d keys ; cat keys.lua) > _keys.lua
	$(foreach f,keyslib.lua keysgo.lua, $(call pdfs,$f,_keys.lua);)
	$(MAKE) ~/tmp/_keys.pdf
	rm _keys.lua

~/tmp/%.pdf: %.lua  ## .lua ==> .pdf
	mkdir -p ~/tmp
	$(call xtract,lua.ssh)
	echo "pdf-ing $@ ... "
	a2ps                 \
		-Br                 \
		-L 150               \
		-l 84                 \
		--file-align=fill      \
		--line-numbers=1        \
		--borders=no             \
		--pro=color               \
		--left-title=""            \
		--pretty-print="$T/lua.ssh" \
		--columns 4                  \
		-M letter                     \
		--footer=""                    \
		--right-footer=""               \
	  -o	 $@.ps $<
	ps2pdf $@.ps $@; rm $@.ps
	open $@


#0  
#0 # KEYS: Bayesian multi-objective optimization semi-supervised explanations
#0     
#0 [![DOI](https://zenodo.org/badge/526688243.svg)](https://zenodo.org/badge/latestdoi/526688243)
#0 [![tests](https://github.com/timm/l5/actions/workflows/main.yml/badge.svg)](https://github.com/timm/l5/actions/workflows/main.yml)
#0 ![](https://img.shields.io/badge/language-lua-blue)
#0 ![](https://img.shields.io/badge/purpose-xai-orange)
#0 [![](https://img.shields.io/badge/license-bsd2-lightgrey)](https://github.com/timm/l5/blob/main/LICENSE.md#top)
#0  

#h   
#h [keys](keyslua) | [keyslib](keysliblua)
#h   
#h <img width="350" 
#h      align=right 
#h      src="http://division14robots.weebly.com/uploads/2/6/1/9/26190497/3183350_orig.png">
#h    
#h ## Code Conventions
#h    
#h  1. x.lua is the main code. `xlib.lua` are some general utils. `xgo.lua1
#h     holds demos/tests of the system.
#h  2. All the `go.xx` functions in `xgo.lua` can be run via `lua xgo.lua -g x`.  
#h  3. Indent = 2 spaces
#h  4. Line width = 80 chars (soft limit)
#h  5. The help string at top of file is parsed to create a table of global
#h     settings, store in the `the` variable.
#h  6. Slots of `the` are updated by command-line flags. 
#h     - Flags update the first
#h        slot they match to E.g.   `lua xgo.lua -s 1234` resets `the.seed` 
#h        (since   `seed` starts with `s`. 
#h      - If a boolean slot appears on the command line, it
#h        does not need a following value (we just flip the default value). e.g.
#h        `lua xgo.lua -h` flips `the.help` from `false` to `true
#h  7. Any word starting with two upper case leading letters is a class; e.g. DATA
#h  8. `function DATA:new()` is a  constructor for class e.g. DATA . Constructors 
#h     are based in `self` so should not use a return statement.
#h  9. Public functions are denoted with a  trailing "-->", followed by return type and comment text. 
#h  10. Public function arguments have the following type hints:
#h    
#h  | What        | Notes |                                     
#h  |:------------|:-----------------------------------|
#h  | 2 blanks    | 2 blanks denote optional arguments |
#h  | 4 blanks    | 4 blanks denote local arguments |
#h  | n           | prefix for numerics |
#h  | s           | prefix for strings |
#h  | is          | prefix for booleans |
#h  | suffix fun  | suffix for functions |                      
#h  | suffix s    | list of thing (so `names` is list of strings) |
#h     
#h Other conventions:
#h     
#h  - In public function arguments,
#h    lower case versions of class type (e.g. `data`) are instances of that type (e.g. 
#h    `data` isa `DATA` so `datas` is a list of `DATA` instances).
#h  - Polymorphism yes, inheritance no. Why? Well...
#h    http://www.cs.kent.edu/~jmaletic/cs69995-PC/papers/Hatton98.pdf     
#h    https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.467.5571&rep=rep1&type=pdf
#h  

#lua.ssh # Lua.ssh --- Sheet definitions for Lua source code
#lua.ssh # Copyright (c) 2014 Kenji Rikitake
#lua.ssh # Copyright (c) 1999 Edward Arthur, Akim Demaille, Miguel Santana
#lua.ssh 
#lua.ssh ## This style is derived from Edward Arthur's AWK Style Sheet
#lua.ssh 
#lua.ssh style Lua is
#lua.ssh 
#lua.ssh written by "Kenji Rikitake <kenji.rikitake@acm.org>"
#lua.ssh version is 0.1
#lua.ssh requires a2ps version 4.9.7
#lua.ssh 
#lua.ssh documentation is
#lua.ssh     "This style file is intended to support Lua ."
#lua.ssh end documentation
#lua.ssh 
#lua.ssh alphabets are
#lua.ssh    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0"
#lua.ssh case sensitive
#lua.ssh 
#lua.ssh keywords in Keyword are
#lua.ssh     and, false, ipairs, nil, not, or, pairs, rawequal, rawget, 
#lua.ssh     rawlen, rawset, select, tonumber, tostring, true, type
#lua.ssh end keywords
#lua.ssh 
#lua.ssh #keywords in Keyword_strong are
#lua.ssh keywords in Keyword_strong are
#lua.ssh     assert, break, collectgarbage, do, dofile, else, elseif, "end", 
#lua.ssh     error, for, function, getmetatable, goto, if, "in", local, 
#lua.ssh     load, loadfile, next, pcall, print, repeat, require, return, 
#lua.ssh     setmetatable, then, until, while, xpcall, _G, _VERSION
#lua.ssh end keywords
#lua.ssh 
#lua.ssh keywords in Label_strong are
#lua.ssh     "^" function
#lua.ssh end keywords
#lua.ssh 
#lua.ssh keywords in Comment are
#lua.ssh     self
#lua.ssh end keywords
#lua.ssh 
#lua.ssh sequences are
#lua.ssh     "[[" Comment "]]",
#lua.ssh     "--" Comment,
#lua.ssh     C-string
#lua.ssh end sequences
#lua.ssh end style
