
MAKECMDGOALS                    :=      $(filter-out default all $(SUBMODULES), $(MAKECMDGOALS))
.PHONY : default all $(SUBMODULES) $(MAKECMDGOALS)
include ./currdir.mk

default:
	for i in $(SUBMODULES); \
        do \
        $(MAKE) -C $$i ; \
        done


all :
	for i in $(SUBMODULES); \
	do \
	$(MAKE) -C $$i all || exit 1; \
	done
$(SUBMODULES) :
	$(MAKE) -C $@

$(MAKECMDGOALS) :
	for i in $(SUBMODULES); \
        do \
        $(MAKE) -C $$i -d all || exit 1; \
        done




