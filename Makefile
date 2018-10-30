# weaves
# GNUMakefile

export D_NAME ?= run

# services
# ticker rdb tq hlcv last show feed
# export D_Ss ?= ticker rdb last show feed

# VWAP is broken at ticker but fixed by its client
export D_Ss ?= ticker rdb last hlcv vwap tq show feed

check: $(D_NAME).log

$(D_NAME).log: 
	run.sh $$D_Ss 2>&1 | tee $@

clean:
	m_ -f ticker screen x-kill-all

distclean: clean
	$(RM) $(wildcard *.log)


