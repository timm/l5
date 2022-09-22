MAKEFLAGS += --silent
SHELL=/bin/bash
R=$(shell git rev-parse --show-toplevel)

D=auto2 auto93 nasa93dem china coc1000 healthCloseIsses12mths0011-easy \
   healthCloseIsses12mths0001-hard pom SSN SSM#

best:; echo 1; $(foreach d,$D, lua tiny2.lua -f ../data/$d.csv -g best; )
xys:; echo 1; $(foreach d,$D, lua tiny2.lua -f ../data/$d.csv -g xys; )
rule:; echo 1; $(foreach d,$D, lua tiny2.lua -f ../data/$d.csv -g rule; )
bestLeaf:;   $(foreach d,$D, lua l5.lua -s ${RANDOM} -S 2000 -m 10 -f ../data/$d.csv -e bestLeaf; )

TWOPLUS=cat $@ | awk 'BEGIN {FS="\n";RS=""} NR==1 { print("\n\n"); next} {print $$0 "\n\n"}'

README.md : xplor.lua xplorlib.lua
	(echo "[xplor](#xplor) | [xplorlib](#xplorlib) <hr>"; echo ""; echo "<pre>") > $@
	lua xplorgo.lua -h    >> $@ 
	(echo "</pre>"; echo "") >> $@
	lua readme.lua  $^    >> $@

pub: ## save all to Github
	git add *;git commit -am save;git push;git status

../docs/%.html: %.lua 
	@mkdir -p $R/docs
	@cat $R/etc/header > /tmp/$<
	@cat $< | gawk '/^-- ##/{print $0; print"\n"; next} 1' >> /tmp/$<
	@cd /tmp; docco -l classic -o $R/docs $<
	@cp $R/etc/docco.css $R/docs

htmls:
	@$(foreach f,$(shell ls *.lua), $(MAKE)  -s ../docs/$(basename $f).html;)

g=about.lua  num.lua sym.lua row.lua cols.lua data.lua eg.lua
pdfs:
	a2ps -o ~/tmp/all.ps -qBr -f 5 -M letter --borders=no --pro=color --line-numbers=1 --borders=no -A virtual --pretty-print=$R/etc/lua.ssh --columns 3 $g
	@a2ps -o ~/tmp/all.ps -qBr -f 5 --columns 3-M letter --pro=color --line-numbers=1 --pretty-print=$R/etc/lua.ssh  -A virtual$g
	ps2pdf ~/tmp/all.ps ~/tmp/all.pdf

txts : 
	@figlet -W -f larry3d xplor > _xplor.lua; cat xplor.lua >> _xplor.lua
	#$(foreach f,xplorlib.lua xplorgo.lua, (figlet -W -f contessa $f >> _xplor.lua ; cat $f >> _xplor.lua);)
	$(foreach f,xplorlib.lua xplorgo.lua, (figlet -W -f contessa $f ; cat $f;) >> _xplor.lua;)
	$(MAKE) ~/tmp/_xplor.pdf
	rm _xplor.lua

~/tmp/%.txt: %.lua
	@bash  ../etc/comments.sh $<  > $@
	@cat $@

~/tmp/%.pdf: %.lua  ## .lua ==> .pdf
	@echo 1
	@mkdir -p $R/docs
	@echo "pdf-ing $@ ... "
	@a2ps                   \
		-Br                    \
		-L 150                  \
		-l 84                   \
		--file-align=fill        \
		--line-numbers=1          \
		--borders=no               \
		--pro=color                 \
		--left-title="" \
		--columns 4                  \
		--pretty-print=$R/etc/lua.ssh \
		-M letter                      \
		--footer="" \
		--right-footer="" \
	  -o	 $@.ps $<
	ps2pdf $@.ps $@; rm $@.ps
	@open $@


#		--footer='Page %p. or #p.'  \
