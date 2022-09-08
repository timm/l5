SHELL=/bin/bash
R=$(shell git rev-parse --show-toplevel)

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


