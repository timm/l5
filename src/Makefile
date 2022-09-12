MAKEFLAGS += --silent
SHELL=/bin/bash
R=$(shell git rev-parse --show-toplevel)

D=auto2 auto93 nasa93dem china coc1000 healthCloseIsses12mths0011-easy \
  healthCloseIsses12mths0001-hard pom SSN SSM#

greedyBest:; $(foreach d,$D, lua l5.lua -f ../data/$d.csv -e greedyBest; )
bestLeaf:;   $(foreach d,$D, lua l5.lua -S 2000 -m 10 -f ../data/$d.csv -e bestLeaf; )


TWOPLUS=cat $@ | awk 'BEGIN {FS="\n";RS=""} NR==1 { print("\n\n"); next} {print $$0 "\n\n"}'

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

../docs/%.pdf: %.lua  ## .lua ==> .pdf
	@mkdir -p $R/docs
	@echo "pdf-ing $@ ... "
	@a2ps               \
		-qBr               \
	  --chars-per-line=80   \
	  --file-align=fill      \
		--line-numbers=1        \
		--borders=no             \
		--pro=color               \
		--columns 3                \
		--pretty-print=$R/etc/lua.ssh \
		--footer=""                    \
		-M letter                       \
		-o $@.ps $<
	@ps2pdf $@.ps $@; rm $@.ps; git add $@
	@open $@
