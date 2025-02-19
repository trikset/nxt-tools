# Tool-chain specific items

#===============================================================================
# GNUARM_ROOT and NEXTTOOL_ROOT need to adapt your PC environment
#===============================================================================

# specify GNU-ARM root directory
#ifndef GNUARM_ROOT
#endif

# specify NeXTTool root directory
ifndef NEXTTOOL_ROOT
NEXTTOOL_ROOT = /cygdrive/C/cygwin/nexttool
endif


#===============================================================================
$(VERBOSE).SILENT:

TARGET_PREFIX :=arm-none-eabi-

MKDIR = mkdir -p
TOUCH = touch

CROSS = $(GNUARM_ROOT)/bin/$(TARGET_PREFIX)

CURRENT_DIR = $(pwd)

CC       = "$(CROSS)gcc" --sysroot=$(GNUARM_ROOT)
CXX	 = "$(CROSS)g++"
AS       = "$(CROSS)as"
AR       = "$(CROSS)ar"
LD       = "$(CROSS)gcc" -nostartfiles --sysroot=$(GNUARM_ROOT)
OBJCOPY  = "$(CROSS)objcopy"

BIOSFLASH = biosflash.exe
APPFLASH  = appflash.exe
RAMBOOT   = ramboot.exe
NEXTTOOL  = NeXTTool.exe

OUTPUT_OPTION = -MD -o $@

# GCC optimisation level
ifndef C_OPTIMISATION_FLAGS
C_OPTIMISATION_FLAGS = -Os
endif

# -I$(LIBS_ROOT)/include -L$(LIBS_ROOT)/lib

# for .c
CFLAGS = -c -ffreestanding -fsigned-char \
	$(C_OPTIMISATION_FLAGS) \
	-Winline -Wall -Werror-implicit-function-declaration --param max-inline-insns-single=1000 -nostdlib\
	-mcpu=arm7tdmi \
	-mthumb -mthumb-interwork -ffunction-sections -fdata-sections \
	$(addprefix -iquote ,$(INC_PATH)) -I. $(addprefix -I,$(TOPPERS_INC_PATH)) \
	$(addprefix -D,$(ECROBOT_DEF)) $(addprefix -D,$(USER_DEF)) $(addprefix -D,$(TOPPERS_KERNEL)) -std=gnu99 $(USER_C_OPT) -Wno-inline \

#
## for C++ (.cc and .cpp)
## Note that C++ RTTI is disabled by -fno-rtti option-I/usr/local/target/include myinit.c -L/usr/local/target/lib
#

ifdef ECROBOT_CPP_ROOT
# for .cpp
CXX_PATH = $(addprefix -I ,$(ECROBOT_CPP_ROOT)/device) $(addprefix -I ,$(ECROBOT_CPP_ROOT)/util)
else
# for .cc
CXX_PATH = $(addprefix -I ,$(CXX_ROOT)) $(addprefix -I ,$(CXX_ROOT)/boost) $(addprefix -I ,$(CXX_ROOT)/util)
endif


CXXFLAGS = -c -fsigned-char -mcpu=arm7tdmi -fno-exceptions \
	$(C_OPTIMISATION_FLAGS) \
	-Wall --param max-inline-insns-single=1000 \
	-fno-common -fno-rtti \
	-mthumb -mthumb-interwork -ffunction-sections -fdata-sections \
	$(CXX_PATH) \
	$(addprefix -iquote ,$(INC_PATH)) -I. $(addprefix -I,$(TOPPERS_INC_PATH)) \
	$(addprefix -D,$(ECROBOT_DEF)) $(addprefix -D,$(USER_DEF)) $(addprefix -D,$(TOPPERS_KERNEL)) $(USER_CXX_OPT) -Wno-inline

#
## for C/C++ (.c, .cc and .cpp)
#

ifdef ECROBOT_CPP_ROOT
# for .cpp
CXX_LIB = $(LIBECROBOT_CPP)
else
# for .cc
CXX_LIB = $(LIBLEJOSOSEK)
endif

LDFLAGS = -mthumb -mthumb-interwork -Wl,--allow-multiple-definition -Wl,-Map,$(basename $@).map -Wl,--cref -Wl,--gc-sections \
	-L$(LIBPREFIX) $(addprefix -L,$(INC_PATH)) \
	$(addprefix -L,$(CXX_ROOT)) -L$(O_PATH) -L$(O_PATH)/$(LEJOS_PLATFORM_SOURCES_PATH) -lm $(CXX_LIB) $(LIBECROBOT) \
	$(addprefix -l,$(USER_LIB))


ASFLAGS = -mcpu=arm7tdmi -mthumb-interwork $(addprefix -I,$(TOPPERS_INC_PATH))

LINK_ELF = $(LD) -o $@ -Wl,-T,$(filter-out %.o %.oram %owav %.obmp %ospr, $^) $(filter %.o %.oram %owav %.obmp %ospr,$^) $(LDFLAGS) $(EXTRALIBS)

ifdef O_PATH
%.bin : %.elf
	@echo "Generating binary file $@"
	$(OBJCOPY) -O binary $< $@

.SECONDEXPANSION:

$(O_PATH)/%.o : %.c $$(@D)/.f
	@echo "Compiling $< to $(notdir $@)"
	$(COMPILE.c) $(OUTPUT_OPTION) $<

$(O_PATH)/%.o : %.cc $$(@D)/.f
	@echo "Compiling $< to $(notdir $@)"
	$(COMPILE.cc) $(OUTPUT_OPTION) $<

$(O_PATH)/%.o : %.cpp $$(@D)/.f
	@echo "Compiling $< to $(notdir $@)"
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(O_PATH)/%.oram : %.c $$(@D)/.f
	@echo "Compiling $< to $(notdir $@)"
	$(COMPILE.c) $(OUTPUT_OPTION) $<

$(O_PATH)/%.oram : %.cc $$(@D)/.f
	@echo "Compiling $< to $(notdir $@)"
	$(COMPILE.cc) $(OUTPUT_OPTION) $<

$(O_PATH)/%.oram : %.cpp $$(@D)/.f
	@echo "Compiling $< to $(notdir $@)"
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(O_PATH)/%.oram: %.S $$(@D)/.f
	@echo "Assembling $< to $(notdir $@)"
	$(COMPILE.S) -o $@ $<

$(O_PATH)/%.o: %.S $$(@D)/.f
	@echo "Assembling $< to $(notdir $@)"
	$(COMPILE.S) -o $@ $<

$(O_PATH)/%.oram: %.s $$(@D)/.f
	@echo "Assembling $< to $(notdir $@)"
	$(COMPILE.S) -o $@ $<

$(O_PATH)/%.o: %.s $$(@D)/.f
	@echo "Assembling $< to $(notdir $@)"
	$(COMPILE.s) -o $@ $<

$(O_PATH)/%.owav : %.wav $$(@D)/.f
	@echo "Converting $< to $(notdir $@)"
	$(OBJCOPY) -I binary -O elf32-littlearm -B arm \
	--redefine-sym _binary_$(subst .,,$(subst /,_,$(basename $<)))_wav_start=$(basename $(notdir $<))_wav_start \
	--redefine-sym _binary_$(subst .,,$(subst /,_,$(basename $<)))_wav_end=$(basename $(notdir $<))_wav_end \
	--redefine-sym _binary_$(subst .,,$(subst /,_,$(basename $<)))_wav_size=$(basename $(notdir $<))_wav_size \
	$< $@

$(O_PATH)/%.obmp : %.bmp $$(@D)/.f
	@echo "Converting $< to $(notdir $@)"
	$(OBJCOPY) -I binary -O elf32-littlearm -B arm \
	--redefine-sym _binary_$(subst .,,$(subst /,_,$(basename $<)))_bmp_start=$(basename $(notdir $<))_bmp_start \
	--redefine-sym _binary_$(subst .,,$(subst /,_,$(basename $<)))_bmp_end=$(basename $(notdir $<))_bmp_end \
	--redefine-sym _binary_$(subst .,,$(subst /,_,$(basename $<)))_bmp_size=$(basename $(notdir $<))_bmp_size \
	$< $@

$(O_PATH)/%.ospr : %.spr $$(@D)/.f
	@echo "Converting $< to $(notdir $@)"
	$(OBJCOPY) -I binary -O elf32-littlearm -B arm \
	--redefine-sym _binary_$(subst .,,$(subst /,_,$(basename $<)))_spr_start=$(basename $(notdir $<))_spr_start \
	--redefine-sym _binary_$(subst .,,$(subst /,_,$(basename $<)))_spr_end=$(basename $(notdir $<))_spr_end \
	--redefine-sym _binary_$(subst .,,$(subst /,_,$(basename $<)))_spr_size=$(basename $(notdir $<))_spr_size \
	$< $@

.PRECIOUS: %/.f
%/.f:
	$(MKDIR) $(dir $@)
	$(TOUCH) $@
endif
