TOPLEVEL_LANG = vhdl
SIM = ghdl
SIM_ARGS = --vcd=sim.vcd

include $(shell cocotb-config --makefiles)/Makefile.sim

rom:
	$(MAKE) TOPLEVEL=mips_rom \
	        MODULE=test_mips_rom \
	        VHDL_SOURCES=../src/mips_rom.vhd

ram:
	$(MAKE) TOPLEVEL=mips_ram \
	        MODULE=test_mips_ram \
	        VHDL_SOURCES=../src/mips_ram.vhd

toplevel:
	$(MAKE) TOPLEVEL=mips_word_toplevel \
	        MODULE=test_mips_word_toplevel \
	        VHDL_SOURCES="../src/ula.vhd ../src/reg_file.vhd ../src/sign_extender.vhd ../src/pc_register.vhd ../src/mips_decoder.vhd ../src/mips_rom.vhd ../src/mips_ram.vhd ../src/mips_word_toplevel.vhd"
