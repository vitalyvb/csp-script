BOARD=

######################################################################3

TOOLS_PATH=
TOOLS_PREFIX=
TOOLS_VERSION_SUFFIX=

CC = $(TOOLS_PREFIX)gcc$(TOOLS_VERSION_SUFFIX) -m32
AS = $(TOOLS_PREFIX)as
AR = $(TOOLS_PREFIX)ar
SIZE = $(TOOLS_PREFIX)size
OBJDUMP = $(TOOLS_PREFIX)objdump
OBJCOPY = $(TOOLS_PREFIX)objcopy

-include $(TOPDIR)config-local.mk

######################################################################3

ASFLAGS=

CFLAGS=-Os -fno-strict-aliasing -ffunction-sections -fdata-sections
CFLAGS+=-g -Wall
CFLAGS+=-I$(TOPDIR)include

LDFLAGS=

######################################################################3

%.a:
	$(AR) r $@ $^
	$(SIZE) $@
