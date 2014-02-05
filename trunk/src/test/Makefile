TOPDIR=../
include $(TOPDIR)config.mk

CFLAGS+=-D_GNU_SOURCE
LDLIBS=-lparser -lvm
LDFLAGS+=-L$(TOPDIR)parser -L$(TOPDIR)vm

test: test.o $(TOPDIR)parser/libparser.a  $(TOPDIR)vm/libvm.a

$(TOPDIR)parser/libparser.a:
	make -C $(TOPDIR)parser

$(TOPDIR)vm/libvm.a:
	make -C $(TOPDIR)vm

clean:
	rm -f test test.o

