PROJ_PATH = /home/bekzat/chip_bootcamp
STA_PATH = $(PROJ_PATH)/yosys-sta
SHELL := /bin/bash

O ?= $(STA_PATH)/result
DESIGN ?= cpu
SDC_FILE ?= $(STA_PATH)/scripts/default.sdc
RTL_FILES ?= $(shell find $(PROJ_PATH)/soc/ \( -name "*.sv" -o -name "*.hv" \))
export CLK_FREQ_MHZ ?= 100
export CLK_PORT_NAME ?= clock
PDK = icsprout55

RESULT_DIR = $(O)/$(DESIGN)-$(CLK_FREQ_MHZ)MHz
SCRIPT_DIR = $(STA_PATH)/scripts
NETLIST_SYN_V   = $(RESULT_DIR)/$(DESIGN).netlist.v
TIMING_RPT = $(RESULT_DIR)/$(DESIGN).rpt

init:
	bash -c "$$(wget -O - https://ysyx.oscc.cc/slides/resources/scripts/init-yosys-sta.sh)"
	mkdir -p pdk
	cd pdk && git clone -b ysyx --depth 1 https://github.com/openecos-projects/icsprout55-pdk.git icsprout55

syn: $(NETLIST_SYN_V)
$(NETLIST_SYN_V): $(RTL_FILES) $(SCRIPT_DIR)/yosys.tcl
	echo $(RTL_FILES)
	mkdir -p $(@D)
	echo tcl $(SCRIPT_DIR)/yosys.tcl $(DESIGN) $(PDK) \"$(RTL_FILES)\" $@ | yosys -g -l $(@D)/yosys.log -s -

sta: $(TIMING_RPT)
$(TIMING_RPT): $(SCRIPT_DIR)/sta.tcl $(SDC_FILE) $(NETLIST_SYN_V)
	set -o pipefail && ./bin/iEDA -script $^ $(DESIGN) $(PDK) 2>&1 | tee $(RESULT_DIR)/sta.log

clean:
	-rm -rf result/

.PHONY: init syn sta clean
