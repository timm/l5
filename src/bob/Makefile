SHELL=/bin/bash
R=$(shell git rev-parse --show-toplevel)

ONE=cat README.md | awk 'BEGIN {FS="\n";RS=""} {print $$0 "\n"; exit}' | awk '{print "  " $$0} END{print("\n\n")}'
TWOPLUS=cat $@ | awk 'BEGIN {FS="\n";RS=""} NR==1 { print("\n\n"); next} {print $$0 "\n\n"}'

pub: ## save all to Github
	$(MAKE) all
	git add *;git commit -am save;git push;git status

htmls:
	@$(foreach f,$(shell ls *.lua), $(MAKE) $R/docs/$(basename $f).html;)

$R/docs/?.html: ?lua $R/etc/header Makefile 
	@mkdir -p $R/docs
	echo "$@ ... "
	@(cat $R/etc/header;  $(TWOPLUS)) > /tmp/$<
	@docco -l classic -o $R/docs $<
	@cp $R/etc/docco.css $R/docs

g=about.lua  num.lua sym.lua row.lua cols.lua data.lua eg.lua
pdfs:
	a2ps -o ~/tmp/all.ps -qBr -f 5 -M letter --borders=no --pro=color --line-numbers=1 --borders=no -A virtual --pretty-print=$R/etc/lua.ssh --columns 3 $g
	@a2ps -o ~/tmp/all.ps -qBr -f 5 --columns 3-M letter --pro=color --line-numbers=1 --pretty-print=$R/etc/lua.ssh  -A virtual$g
	ps2pdf ~/tmp/all.ps ~/tmp/all.pdf

../../docs/%.pdf: %.lua  ## .lua ==> .pdf
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
