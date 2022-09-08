SHELL=/bin/bash
R=$(shell git rev-parse --show-toplevel)

g=about.lua  num.lua sym.lua row.lua cols.lua data.lua eg.lua
docs:
	a2ps -o ~/tmp/all.ps -qBr -f 5 -M letter --borders=no --pro=color --line-numbers=1 --borders=no -A virtual --pretty-print=$R/etc/lua.ssh --columns 3 $g
	ps2pdf ~/tmp/all.ps ~/tmp/all.pdf

htmls:
	@$(foreach f,$(shell ls *.lua), $(MAKE) ../../docs/$(basename $f).html;)

../../docs/%.html: %.lua  ## .lua ==> .html
	@mkdir -p $R/docs
	@docco -l classic -o $R/docs $<
			
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


