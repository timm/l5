SHELL=/bin/bash
R=$(shell git rev-parse --show-toplevel)

../../docs/%.html: %.lua  ## .lua ==> .html
	@mkdir -p $R/docs
	@docco -o $R/docs $<
	@open $@
			
../../docs/%.pdf: %.lua  ## .lua ==> .pdf
	@mkdir -p $R/docs
	@echo "pdf-ing $@ ... "
	@a2ps               \
		-qBr                \
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
	@open $@
	@ps2pdf $@.ps $@; rm $@.ps; git add $@
