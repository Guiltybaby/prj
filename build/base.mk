#test by jeff
include ./currdir.mk

.SUFFIXES                              :

O := .o
C := .c
S := .S
CPP := .cpp
H := .h
D := .d

% : RCS/%,v
% : RCS/%
% : %,v
% : s.%
% : RCCS/s.%


COMPILER:=arm-none-eabi
A_CC := arm-none-eabi-gcc
A_CPP := arm-none-eabi-g++
LD := arm-none-eabi-ld
LC := arm-none-eabi-ld -g -shared

ifneq ($(SPLINTDIR),)
//PARSER := $(SPLINTDIR)/splint
endif

STD_LIB := c m gcc

COMPILER_HEADER:=$(TOOLCHAINS_PATH)/arm-none-eabi/include
COMPILER_LIB:=$(TOOLCHAINS_PATH)/arm-none-eabi/lib
COMPILER_GCC:=$(TOOLCHAINS_PATH)/lib/gcc/arm-none-eabi/4.8.4
MODULE := $(notdir $(CURDIR))
SRCDIR := src
INCDIR := inc $(DEP_INCS)
OUTDIR := $(PROJECTDIR)/out/obj/$(MODULE)
OBJDIR := $(PROJECTDIR)/out/obj/$(MODULE)/intermediates
TMPDIR := $(PROJECTDIR)/out/obj/$(MODULE)/intermediates
OUTLIBDIR := $(PROJECTDIR)/out/obj/lib
LINKEDDIR := $(PROJECTDIR)/out/obj/$(MODULE)/intermediates/linked
INSTALLDIR := $(PROJECTDIR)/out/install
STDDIRS := $(OUTDIR) $(LINKEDDIR) $(TMPDIR) $(INSTALLDIR) $(OUTLIBDIR) #$(OBJDIR)

vpath %$C  		./$(SRCDIR)/
vpath %$(CPP)  	./$(SRCDIR)/
vpath %$O  		$(OBJDIR)/
vpath %$D  		$(TMPDIR)/

LD_OPTS += -nostdlib \
			$(LOCAL_GLOBAL_DEFINATION) \
			-rpath-link=$(COMPILER_LIB) \
			-rpath-link=$(COMPILER_GCC) \
			$(addprefix -L,$(COMPILER_LIB)) \
			$(addprefix -L,$(COMPILER_GCC))
LD_OPTS+= $(addprefix --wrap , $(WRAP_FUN))

SYSINCDIR:=#$(COMPILER_HEADER)

PFLAGS += -weak -warnposix -maintype -preproc -nestcomment $(addprefix -I, $(INCDIR)) 

CFLAGS += -c -fPIC
CFLAGS += -Wall -Werror -g -Wno-unused 
CFLAGS += $(addprefix -isystem , $(SYSINCDIR)) \
			 $(addprefix -I, $(INCDIR))
SFLAGS := -S


SRCNAMES 	:= $(basename $(C_SRCS) $(CPP_SRCS) $(S_SRCS))
OBJS 		:= $(addsuffix $O, $(SRCNAMES))
DEPS 		:= $(addsuffix $D, $(SRCNAMES))
ifeq ($(TARGET_SUFFIX),.so)
TARGET		:=$(addprefix $(LINKEDDIR)/,$(addprefix lib,$(addsuffix $(TARGET_SUFFIX),$(MODULE))))
else ifeq ($(TARGET_SUFFIX),.a)
TARGET		:=$(addprefix $(LINKEDDIR)/,$(addprefix lib,$(addsuffix $(TARGET_SUFFIX),$(MODULE))))
else ifeq ($(TARGET_SUFFIX),.exe)
TARGET		:=$(addprefix $(LINKEDDIR)/,$(MODULE))
endif


%$O :  %$C
	$(A_CC) $(CFLAGS) $(LOCAL_GLOBAL_DEFINATION) $< -o $(OBJDIR)/$@

%$O :  %$(CPP)
	$(A_CPP) $(CFLAGS) $(LOCAL_GLOBAL_DEFINATION) $< -o $(OBJDIR)/$@

%$O :  %$S
	$(A_CC) $(CFLAGS) $(LOCAL_GLOBAL_DEFINATION) $< -o $(OBJDIR)/$@

%$D : %$C
	$(A_CC) $(CFLAGS) $(LOCAL_GLOBAL_DEFINATION) $< -M -MF $(TMPDIR)/$@


.PHONY : default clean_all clean all depends obj parse

default: dir depends obj $(TARGET) parse

obj : $(OBJS)

depends: $(DEPS)

$(DEPS):

parse:
ifneq ($(PARSER),)
		for i in $(addprefix $(SRCDIR)/,$(C_SRCS)); \
        do \
        $(PARSER) $(PFLAGS) $$i ; \
        done

		for i in $(addprefix $(SRCDIR)/,$(CPP_SRCS)); \
        do \
        $(PARSER) $(PFLAGS) -fileextensions $$i ; \
        done
endif
	

all : clean_all
	$(MAKE) 

clean_all : clean cleandepends

clean : 
	@-rm -rf $(addprefix $(OBJDIR)/,$(OBJS)) $(addprefix $(LINKEDDIR)/,$(TARGET))
cleandepends :
	@-rm -rf $(addprefix $(TMPDIR)/,$(DEPS))

test :

ifeq ($(TARGET_SUFFIX),.exe)
$(TARGET) : $(OBJS) #$(basename $(DEP_LIBS:lib%=%))
	$(LD) -o $(basename $@) $(LD_OPTS) $(addprefix $(OBJDIR)/, $(OBJS))  \
	$(addprefix -L,$(OUTLIBDIR)) \
	$(addprefix -l,$(basename $(DEP_LIBS:lib%=%))) \
	$(addprefix -l,$(STD_LIB)) 
	@-cp -f $(basename $@) $(INSTALLDIR)

else ifeq ($(TARGET_SUFFIX),.so)
$(TARGET) : $(OBJS)
	$(LC) -Wl,-soname,$@ $(LD_OPTS) -o  $@ $(addprefix $(OBJDIR)/, $(OBJS))
	@-cp -f $@ $(OUTLIBDIR)
	@-cp -f $@ $(INSTALLDIR)
else ifeq ($(TARGET_SUFFIX),.a)
$(TARGET) : $(OBJS)
	$(AR) -r $@ $(addprefix $(OBJDIR)/, $(OBJS))
	@-cp -f $@ $(OUTLIBDIR)
	@-cp -f $@ $(INSTALLDIR)
endif

$(STDDIRS)   :
	mkdir -p $@

dir : $(STDDIRS)





#-MMD -MF $(TMPDIR)/$(@:%.o=%.d)
-include $(TMPDIR)/$(OBJS:.o=.d)

