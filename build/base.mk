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


#COMPILER:=arm-none-eabi-
A_CC := $(COMPILER)gcc
A_CPP := $(COMPILER)g++
LD := $(COMPILER)g++
LC := $(COMPILER)g++ -g -shared

ifneq ($(SPLINTDIR),)
//PARSER := $(SPLINTDIR)/splint
endif

STD_LIB := c m gcc   #

#COMPILER_HEADER:=$(TOOLCHAINS_PATH)/arm-none-eabi/include
#COMPILER_GCC:=$(TOOLCHAINS_PATH)/lib/gcc/arm-none-eabi/4.8.4
#COMPILER_LIB:=$(TOOLCHAINS_PATH)/arm-none-eabi/lib
COMPILER_HEADER:=/usr/lib/include
COMPILER_LIB:=/usr/lib/i386-linux-gnu
COMPILER_GCC:=/usr/lib/gcc/i686-linux-gnu/4.8
MODULE := $(notdir $(CURDIR))
SRCDIR := src
INCDIR := inc inc/private $(DEP_INCS)
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

LD_CRTBEGIN:=$(COMPILER_GCC)/crtbegin.o
LD_CRT1:=$(COMPILER_LIB)/crt1.o
LD_CRT0:=$(COMPILER_LIB)/crt0.o
LD_CRTI:=$(COMPILER_LIB)/crti.o
LD_CRTN:=$(COMPILER_LIB)/crtn.o
LD_CRTEND:=$(COMPILER_GCC)/crtend.o

LD_OPTS +=  -nostdlib \
			$(LOCAL_GLOBAL_DEFINATION) \
			-Wl,-rpath-link=$(COMPILER_LIB) \
			-Wl,-rpath-link=$(COMPILER_GCC) \
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
	@$(A_CC) $(CFLAGS) $(LOCAL_GLOBAL_DEFINATION) $< -o $(OBJDIR)/$@

%$O :  %$(CPP)
	@$(A_CPP) $(CFLAGS) $(LOCAL_GLOBAL_DEFINATION) $< -o $(OBJDIR)/$@

%$O :  %$S
	@$(A_CC) $(CFLAGS) $(LOCAL_GLOBAL_DEFINATION) $< -o $(OBJDIR)/$@

%$D : %$C
	@$(A_CC) $(CFLAGS) $(LOCAL_GLOBAL_DEFINATION) $< -M -MF $(TMPDIR)/$@


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
	$(LD) -o $(basename $@) \
	$(LD_CRT1) \
	$(LD_CRTI) \
	$(LD_CRTBEGIN) \
	$(LD_OPTS) $(addprefix $(OBJDIR)/, $(OBJS))  \
	$(addprefix -L,$(OUTLIBDIR)) \
	$(addprefix -l,$(basename $(DEP_LIBS:lib%=%))) \
	$(addprefix -l,$(STD_LIB)) \
	$(LD_CRTN) \
	$(LD_CRTEND)
	@cp $(basename $@) $(INSTALLDIR)
	@chmod 777 -R $(INSTALLDIR)

else ifeq ($(TARGET_SUFFIX),.so)
$(TARGET) : $(OBJS)
	$(LC) -Wl,-soname,$@ $(LD_OPTS) -o  $@ $(addprefix $(OBJDIR)/, $(OBJS))
	@-cp -f $@ $(OUTLIBDIR)
	@-cp -f $@ $(INSTALLDIR)
else ifeq ($(TARGET_SUFFIX),.a)
$(TARGET) : $(OBJS)
	@$(AR) -r $@ $(addprefix $(OBJDIR)/, $(OBJS))
	@-cp -f $@ $(OUTLIBDIR)
	@-cp -f $@ $(INSTALLDIR)
endif

$(STDDIRS)   :
	mkdir -p $@

dir : $(STDDIRS)





#-MMD -MF $(TMPDIR)/$(@:%.o=%.d)
-include $(TMPDIR)/$(OBJS:.o=.d)

