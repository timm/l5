#= [keys](#keyslua) | [keyslib](#keysliblus)
#=  
#= <img width="350" 
#=      align=right 
#=      src="http://division14robots.weebly.com/uploads/2/6/1/9/26190497/3183350_orig.png">
#=    
#= ## Code Conventions
#=    
#=  1. Indent = 2 spaces
#=  2. Line width = 80 chars (soft limit)
#=  3. The help string at top of file is parsed to create the settings.  
#=  4. `function DATA:new()` is a  constructor for class e.g. DATA 
#=  5. x.lua is the main code. `xlib.lua` are general utils. `xgo.lua
#=     holds demos/tests of the system.
#=  5. All the `go.xx` functions in `xgo.lua` can be run with `lua xgo.lua -g x`.  
#=  6. Public functions are denoted with a  trailing "---", followed by comment text. 
#=  7. Public function arguments have the following type hints:
#=    
#=  | What        | Notes |                                     
#=  |:------------|:-----------------------------------|
#=  | 2 blanks    | 2 blanks denote optional arguments |
#=  | 4 blanks    | 4 blanks denote local arguments |
#=  | n           | prefix for numerics |
#=  | s           | prefix for strings |
#=  | is          | prefix for booleans |
#=  | suffix fun  | suffix for functions |                      
#=  | suffix s    | list of thing (so `names` is list of strings) |
#=     
#= Other conventions:
#=     
#=  - In the code, any upper case name (e.g. `DATA` defines a class type)
#=  - In public function arguments,
#=    lower case versions of class type (e.g. `data`) are instances of that type (e.g. 
#=    `data` isa `DATA` so `datas` is a list of `DATA` instances).
#=  - Polymorphism yes, inheritance no. Why? Well...
#=    http://www.cs.kent.edu/~jmaletic/cs69995-PC/papers/Hatton98.pdf     
#=    https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.467.5571&rep=rep1&type=pdf

MAKEFLAGS += --silent
SHELL=/bin/bash
R=$(shell git rev-parse --show-toplevel)

README.md : keys.lua keyslib.lua
	(echo ""; echo "\`\`\`css")  > $@
	lua keysgo.lua -h       >> $@ 
	(echo "\`\`\`"; echo"") >> $@
	grep '^#=' Makefile | sed 's/^#= //' >> $@ 
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

../docs/%.html: %.lua 
	mkdir -p $R/docs
	cat $R/etc/header > /tmp/$<
	cat $< | gawk '/^-- ##/{print $0; print"\n"; next} 1' >> /tmp/$<
	cd /tmp; docco -l classic -o $R/docs $<
	cp $R/etc/docco.css $R/docs

htmls:
	$(foreach f,$(shell ls *.lua), $(MAKE)  -s ../docs/$(basename $f).html;)

pdf : 
	figlet -W -f larry3d keys > _keys.lua; cat keys.lua >> _keys.lua
	$(foreach f,keyslib.lua keysgo.lua, (echo ""; figlet -W -f cybermedium $(basename $f .lua) ; echo ""; cat $f;) >> _keys.lua;)
	$(MAKE) ~/tmp/_keys.pdf
	rm _keys.lua

~/tmp/%.pdf: %.lua  ## .lua ==> .pdf
	mkdir -p ~/tmp
	echo "pdf-ing $@ ... "
	a2ps                   \
		-Br                   \
		-L 150                 \
		-l 84                   \
		--file-align=fill        \
		--line-numbers=1          \
		--borders=no               \
		--pro=color                 \
		--left-title=""              \
		--columns 4                   \
		--pretty-print=$R/etc/lua.ssh  \
		-M letter                       \
		--footer=""                      \
		--right-footer=""                 \
	  -o	 $@.ps $<
	ps2pdf $@.ps $@; rm $@.ps
	open $@
