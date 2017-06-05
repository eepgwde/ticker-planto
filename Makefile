# weaves
# GNUMakefile

export D_NAME ?= run
export D_Ss ?= ticker rdb show feed

check: $(D_NAME).log

$(D_NAME).log: 
	run.sh $$D_Ss 2>&1 | tee $@

clean:
	m_ -f ticker screen x-kill-all

dist-clean: clean
	$(RM) $(wildcard *.log)


