help:
	@grep -E '^[^ ]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {print ""; FS = ":.*?## "}; \
	             {printf "make \033[36m%-20s\033[0m : %s\n", $$1, $$2}'

R=$(shell git rev-parse --show-toplevel)

want = eg.lua sam.lua lib.lua 

bye: ## commit to github
	git add *;git commit -am save;git push;git status

../../docs/%.html: %.lua  ## make html
	@gawk -f $R/etc/lua2doc.awk $< > tmp.lua
	@echo "docco: $< -> $@"
	@docco -l classic -o $R/docs tmp.lua > /dev/null
	@gawk 'sub(/>tmp.lua</,">$(basename $<)<") 1 ' $R/docs/tmp.html > $@
	@cp $R/etc/docco.css $R/docs/docco.css

all: $(want) ## all code => .pdf
	@figlet -W -f larry3d sam>_all.lua
	echo "SAM : Semi-supervised And Multi-objective explainations">>_all.lua
	echo "(c) 2022 Tim Menzies <timm@ieee.org> BSD-2 license">>_all.lua
	@$(foreach f,$^, $(MAKE) ../../docs/$(shell basename $f .lua).html;)
	@$(foreach f,$^,(figlet -W -f small $f>>_all.lua;cat $f>>_all.lua;);)
	@$(MAKE) ../../docs/_all.pdf
	@rm _all.lua
	@open   ../../docs/_all.pdf
		
# ../../docs/%.pdf: %.lua  ## .lua ==> .pdf
# 	@mkdir -p $R/docs
# 	@echo "pdf-ing $@ ... "
# 	@a2ps -B              \
# 		-q                   \
# 	  --chars-per-line=82   \
# 	  --file-align=fill      \
# 		--line-numbers=1        \
# 		--borders=no             \
# 		--pro=color               \
# 		--columns 3                \
# 		--right-footer="%Q"         \
# 		--left-footer="%W"           \
# 		--pretty-print=$R/etc/lua.ssh \
# 		--footer=""                    \
# 		-M letter                       \
# 		-o $@.ps $<
# 	@ps2pdf $@.ps $@; rm $@.ps; git add $@
# 	@open $@
#

$R/docs/%.md : %.lua
		gawk -f $R/etc/lua2md.awk -v name="$<" $< > $@

$R/docs/%.pdf : $R/docs/%.md  ## make pdf
	@mkdir -p $R/docs
	@echo "pdf-ing $@ ... "
	pandoc "$<"  -o "$@" --from markdown --template "$R/etc/eis.tex" --listings

	@open $@

