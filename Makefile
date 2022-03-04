# :dbolli:20220226 19:18:45 Based on ~/dev/unix-src/z88dk/libsrc/sprites/software/sp1/Makefile

Z88DKROOT=$(HOME)/dev/unix-src/z88dk

include $(Z88DKROOT)/libsrc/Make.config

Z80EXECNAME=asm-lib-test

ORGADDRESS=0x6100

default: $(Z80EXECNAME)-all

$(Z80EXECNAME)-all:
	@echo
	@echo --- make build $(Z80EXECNAME)---
	z80asm +zx -v -s -l -m -g -r$(ORGADDRESS) \
		-L../asmtest/asm-lib-z88dk/ -lasm-lib \
		-L../../Ticker-zasm/ticker-lib-z88dk/ -lticker-lib \
		$(Z80EXECNAME).asm
	tr '[:lower:]' '[:upper:]' < $(Z80EXECNAME).lis > $(Z80EXECNAME).out.lis
	z88dk-dis -o $(ORGADDRESS) -x $(Z80EXECNAME).map $(Z80EXECNAME).bin > $(Z80EXECNAME)-asm.tmp
	tr '[:lower:]' '[:upper:]' < $(Z80EXECNAME)-asm.tmp > $(Z80EXECNAME)-asm.lis
	echo "Deleting "; rm -fv $(Z80EXECNAME)-asm.tmp

clean:
	$(RM) *.o
	$(RM) *.bin
	$(RM) *.lis
	$(RM) *.sym
	$(RM) *.map
	$(RM) *.def
	$(RM) $(Z80EXECNAME).tap
