APP_INC =  -I.
APP_INC += -I..
APP_INC += -Ifatfs/src
APP_INC += -Ifatfs/src/drivers
APP_INC += -IFreeRTOS
APP_INC += -IFreeRTOS/Source/include
APP_INC += -IFreeRTOS/Source/portable/GCC/ARM_CM3
APP_INC += -Iftp
APP_INC += -Ihal
APP_INC += -Ihal/inc
APP_INC += -Imisc
APP_INC += -Imods
APP_INC += -Isimplelink
APP_INC += -Isimplelink/include
APP_INC += -Isimplelink/oslib
APP_INC += -Itelnet
APP_INC += -Iutil
APP_INC += -Ibootmgr
APP_INC += -I$(PY_SRC)
APP_INC += -I$(BUILD)
APP_INC += -I$(BUILD)/genhdr
APP_INC += -I../lib/fatfs
APP_INC += -I../lib/mp-readline
APP_INC += -I../stmhal

APP_CPPDEFINES = -Dgcc -DTARGET_IS_CC3200 -DSL_FULL -DUSE_FREERTOS

APP_FATFS_SRC_C = $(addprefix fatfs/src/,\
	drivers/sflash_diskio.c \
	drivers/sd_diskio.c \
	option/syscall.c \
	diskio.c \
	ffconf.c \
	)

APP_RTOS_SRC_C = $(addprefix FreeRTOS/Source/,\
	croutine.c \
	event_groups.c \
	list.c \
	queue.c \
	tasks.c \
	timers.c \
	portable/GCC/ARM_CM3/port.c \
	portable/MemMang/heap_4.c \
	)

APP_FTP_SRC_C = $(addprefix ftp/,\
	ftp.c \
	updater.c \
	)

APP_HAL_SRC_C = $(addprefix hal/,\
	adc.c \
	aes.c \
	cc3200_hal.c \
	cpu.c \
	crc.c \
	des.c \
	gpio.c \
	i2c.c \
	i2s.c \
	interrupt.c \
	pin.c \
	prcm.c \
	sdhost.c \
	shamd5.c \
	spi.c \
	startup_gcc.c \
	systick.c \
	timer.c \
	uart.c \
	utils.c \
	wdt.c \
	)

APP_MISC_SRC_C = $(addprefix misc/,\
	FreeRTOSHooks.c \
	pin_named_pins.c \
	help.c \
	mperror.c \
	mpexception.c \
	pin_defs_cc3200.c \
	)

APP_MODS_SRC_C = $(addprefix mods/,\
	modnetwork.c \
	modpyb.c \
	moduos.c \
	modusocket.c \
	modutime.c \
	modwlan.c \
	pybextint.c \
	pybi2c.c \
	pybpin.c \
	pybrtc.c \
	pybsystick.c \
	pybuart.c \
	)

APP_SL_SRC_C = $(addprefix simplelink/,\
	source/device.c \
	source/driver.c \
	source/flowcont.c \
	source/fs.c \
	source/netapp.c \
	source/netcfg.c \
	source/socket.c \
	source/wlan.c \
	oslib/osi_freertos.c \
	cc_pal.c \
	) 

APP_TELNET_SRC_C = $(addprefix telnet/,\
	telnet.c \
	)
	
APP_UTIL_SRC_C = $(addprefix util/,\
	fifo.c \
	gccollect.c \
	random.c \
	socketfifo.c \
	)
	
APP_UTIL_SRC_S = $(addprefix util/,\
	gchelper.s \
	)
	
APP_MAIN_SRC_C = \
	main.c \
	mptask.c \
	serverstask.c
	
APP_LIB_SRC_C = $(addprefix lib/,\
	fatfs/ff.c \
	mp-readline/readline.c \
	)
	
APP_STM_SRC_C = $(addprefix stmhal/,\
	bufhelper.c \
	file.c \
	import.c \
	input.c \
	irq.c \
	lexerfatfs.c \
	moduselect.c \
	printf.c \
	pyexec.c \
	pybstdio.c \
	string0.c \
	)

OBJ = $(PY_O) $(addprefix $(BUILD)/, $(APP_FATFS_SRC_C:.c=.o) $(APP_RTOS_SRC_C:.c=.o) $(APP_FTP_SRC_C:.c=.o) $(APP_HAL_SRC_C:.c=.o) $(APP_MISC_SRC_C:.c=.o))
OBJ += $(addprefix $(BUILD)/, $(APP_MODS_SRC_C:.c=.o) $(APP_SL_SRC_C:.c=.o) $(APP_TELNET_SRC_C:.c=.o) $(APP_UTIL_SRC_C:.c=.o) $(APP_UTIL_SRC_S:.s=.o))
OBJ += $(addprefix $(BUILD)/, $(APP_MAIN_SRC_C:.c=.o) $(APP_LIB_SRC_C:.c=.o) $(APP_STM_SRC_C:.c=.o))
OBJ += $(BUILD)/pins.o

# Add the linker script
LINKER_SCRIPT = application.lds
LDFLAGS += -T $(LINKER_SCRIPT)

# Add the application specific CFLAGS
CFLAGS += $(APP_CPPDEFINES) $(APP_INC)

# Disable strict aliasing for the simplelink driver
$(BUILD)/simplelink/source/driver.o: CFLAGS += -fno-strict-aliasing

# Check if we would like to debug the port code
ifeq ($(BTYPE), release)
# Optimize everything and define the NDEBUG flag
CFLAGS += -Os -DNDEBUG
else
ifeq ($(BTYPE), debug)
# Define the DEBUG flag
CFLAGS += -DDEBUG=DEBUG
# Optimize the stable sources only
$(BUILD)/extmod/%.o: CFLAGS += -Os
$(BUILD)/lib/%.o: CFLAGS += -Os
$(BUILD)/fatfs/src/%.o: CFLAGS += -Os
$(BUILD)/FreeRTOS/Source/%.o: CFLAGS += -Os
$(BUILD)/ftp/%.o: CFLAGS += -Os
$(BUILD)/hal/%.o: CFLAGS += -Os
$(BUILD)/misc/%.o: CFLAGS += -Os
$(BUILD)/py/%.o: CFLAGS += -Os
$(BUILD)/simplelink/%.o: CFLAGS += -Os
$(BUILD)/stmhal/%.o: CFLAGS += -Os
$(BUILD)/telnet/%.o: CFLAGS += -Os
$(BUILD)/util/%.o: CFLAGS += -Os
$(BUILD)/pins.o: CFLAGS += -Os
else
$(error Invalid BTYPE specified)
endif
endif

SHELL = bash
APP_SIGN = appsign.sh

all: $(BUILD)/MCUIMG.BIN

$(BUILD)/application.axf: $(OBJ) $(LINKER_SCRIPT)
	$(ECHO) "LINK $@"
	$(Q)$(CC) -o $@ $(LDFLAGS) $(OBJ) $(LIBS)
	$(Q)$(SIZE) $@

$(BUILD)/application.bin: $(BUILD)/application.axf
	$(ECHO) "Create $@"
	$(Q)$(OBJCOPY) -O binary $< $@

$(BUILD)/MCUIMG.BIN: $(BUILD)/application.bin
	$(ECHO) "Create $@"
	$(Q)$(SHELL) $(APP_SIGN) $(BOARD)

MAKE_PINS = boards/make-pins.py
BOARD_PINS = boards/$(BOARD)/pins.csv
AF_FILE = boards/cc3200_af.csv
PREFIX_FILE = boards/cc3200_prefix.c
GEN_PINS_SRC = $(BUILD)/pins.c
GEN_PINS_HDR = $(HEADER_BUILD)/pins.h
GEN_PINS_QSTR = $(BUILD)/pins_qstr.h
    
# Making OBJ use an order-only dependency on the generated pins.h file
# has the side effect of making the pins.h file before we actually compile
# any of the objects. The normal dependency generation will deal with the
# case when pins.h is modified. But when it doesn't exist, we don't know
# which source files might need it.
$(OBJ): | $(GEN_PINS_HDR)

# Call make-pins.py to generate both pins_gen.c and pins.h
$(GEN_PINS_SRC) $(GEN_PINS_HDR) $(GEN_PINS_QSTR): $(BOARD_PINS) $(MAKE_PINS) $(AF_FILE) $(PREFIX_FILE) | $(HEADER_BUILD)
	$(ECHO) "Create $@"
	$(Q)$(PYTHON) $(MAKE_PINS) --board $(BOARD_PINS) --af $(AF_FILE) --prefix $(PREFIX_FILE) --hdr $(GEN_PINS_HDR) --qstr $(GEN_PINS_QSTR) > $(GEN_PINS_SRC)

$(BUILD)/pins.o: $(BUILD)/pins.c
	$(call compile_c)
