#*****************************************************************************
# This is the makefile to control the whole verification environment
#
# Author: Qiu Chao 
# Date  : 2018/11/20
#
#*****************************************************************************
SHELL=/bin/bash
########Define the export PATH  
export VVD_ROOT
export VVD_BIN
export VVD_DATA
export VVD1604_ROOT
export VVD1604_BIN
export VVD1604_DATA
export PRJ_ROOT
export RTL_ROOT 
export VF_ROOT
export TB_ROOT 
export BTC_ROOT 
export UTC_ROOT 
export SCRIPTLIN_ROOT
export MAKEFILE_SCRIPT 
export PERL_SCRIPT 
export VVD_SCRIPT
export FLIST_SCRIPT 
export RUNSIM_ROOT 
export LIBPLI_ROOT
export PAR_TC
export PAR_SIM_TYPE
export PAR_WAVE_TYPE
export PAR_UVM_TYPE
export PAR_IP_TYPE
export PAR_OTHER_TYPE
export PAR_SUB_MAKEFILE
export MACRO_RTL_FILE
#export UVM_HOME
export VCS_HOME
export NOVAS_HOME
export NOVAS_RC
export NOVAS_ROOT
#export PLATFORM
#export LD_LIBRARY_PATH
export SIM_LIBRARY_PATH
export VVD1602_LIBRARY_PATH
export VVD1703_LIBRARY_PATH
export Verdi
export IP_PRJ
export MAKEFILE_CMPL
export WEB_ROOT

#VVD_ROOT		= /opt/tool/xilinx/vivado2016_02/Vivado/2016.2
#VVD_ROOT		= /opt/tool/xilinx/vivado2014_02/Vivado/2014.2
##VVD_ROOT		= /opt/tool/xilinx/vivado2017_03/Vivado/2017.3
VVD_ROOT		= /opt/tool/xilinx/vivado2018_03/Vivado/2018.3
VVD_BIN			= $(VVD_ROOT)/bin
VVD_DATA		= $(VVD_ROOT)/data
VVD1604_ROOT	= /opt/tool/xilinx/vivado2016_04/Vivado/2016.4
VVD1604_BIN		= $(VVD1604_ROOT)/bin
VVD1604_DATA	= $(VVD1604_ROOT)/data
PRJ_ROOT		= $(shell cd ../;pwd)
SRC_ROOT        = $(PRJ_ROOT)/src
RTL_ROOT		= $(PRJ_ROOT)/rtl
VF_ROOT			= $(PRJ_ROOT)/vf
TB_ROOT			= $(PRJ_ROOT)/tb
BTC_ROOT		= $(TB_ROOT)/btc
UTC_ROOT		= $(TB_ROOT)/utc
SCRIPTLIN_ROOT  = $(VF_ROOT)/scriptlin
LIBPLI_ROOT		= $(VF_ROOT)/libpli
MAKEFILE_SCRIPT = $(SCRIPTLIN_ROOT)/makefile_script
PERL_SCRIPT     = $(SCRIPTLIN_ROOT)/perl_script
VVD_SCRIPT		= $(SCRIPTLIN_ROOT)/vivado_script
FLIST_SCRIPT	= $(SCRIPTLIN_ROOT)/flist_script
RUNSIM_ROOT		= $(shell cd ./;pwd)
MACRO_RTL_FILE  = $(RTL_ROOT)/macro_rtl
#UVM_HOME		= /opt/tool/mentor/questasim10_4c/questasim/verilog_src/uvm-1.1d
VCS_HOME        = /opt/tool/synopsys/vcs_mx_vl201606
#NOVAS_HOME 		= /opt/tool/novas/verdi3_201403
NOVAS_HOME 		= /opt/tool/synopsys/verdi_vL_2016_06_1
NOVAS_ROOT		= $(VF_ROOT)/novas
NOVAS_RC		= $(NOVAR_ROOT)/novas.rc


# PLATFORM   		= LINUXAMD64
# LD_LIBRARY_PATH = $(NOVAS_HOME)/share/PLI/MODELSIM/$(PLATFORM)

#PLATFORM   		= LINUX64
#LD_LIBRARY_PATH = $(NOVAS_HOME)/share/PLI/VCS/$(PLATFORM)

SIM_LIBRARY_PATH = /home/logic/verification/library
# VVD1602_LIBRARY_PATH = $(SIM_LIBRARY_PATH)/vivado2016_02
# VVD1703_LIBRARY_PATH = $(SIM_LIBRARY_PATH)/vivado2017_03
# VVD1803_LIBRARY_PATH = $(SIM_LIBRARY_PATH)/vivado2018_03
IP_PRJ			= ip_prj
MAKEFILE_CMPL	= Makefile.cmpl.vvd
WEB_ROOT		= $(VF_ROOT)/gui/tornadoWeb

########Set the mode keywords
QuestaSim		= qst
Verdi			= vrd 

########Get the SubMakefile from the config file.(such as TC_NAME=qst_xxx,return qst_xxx)
define getDataFromFileFunc
	$(patsubst $(1)=%,%,$(filter $(1)=%,$(shell cat $(2))))
endef
TC_LIST				=$(call getDataFromFileFunc,TC_NAME,tc.cfg)

####Get the first word of the TC_LIST
PAR_TC 				=$(word 1, $(TC_LIST))

####Name Rule:PAR_XXX means the variable is a parmeter. it is changed by the function call.
####Get the value from PAR_TC(such as PAR_TC=qst_nvrd_nuvm_nip_nhls_tc3)
####					  so PAR_SIM_TYPE=qst
####					  so PAR_WAVE_TYPE=nvrd
####					  so PAR_UVM_TYPE=nuvm
####					  so PAR_IP_TYPE=nip
####					  so PAR_OTHER_TYPE=nhls
####					  so PAR_SUB_MAKEFILE=Makefile.qst.nvrd.nuvm.nip.nhls
PAR_SIM_TYPE		=$(word 1,$(subst _, ,$(PAR_TC)))
PAR_WAVE_TYPE		=$(word 2,$(subst _, ,$(PAR_TC)))
PAR_UVM_TYPE		=$(word 3,$(subst _, ,$(PAR_TC)))
PAR_IP_TYPE			=$(word 4,$(subst _, ,$(PAR_TC)))
PAR_OTHER_TYPE		=$(word 5,$(subst _, ,$(PAR_TC)))
PAR_SUB_MAKEFILE	=Makefile.$(PAR_SIM_TYPE).$(PAR_WAVE_TYPE).$(PAR_UVM_TYPE).$(PAR_IP_TYPE).$(PAR_OTHER_TYPE)

####Get the TC_LIST words,(such as "tc1_xx tc2_xx",return 2)
TC_WORDS :=$(words $(TC_LIST))

####Display the help commond 
.PHONY:default
default:
	@echo -e "\033[40;32m *****************************************************************************  \033[0m"
	@echo -e "\033[40;32m Build Library ***************************************************************  \033[0m"
	@echo -e "\033[40;32m make build_vvd1602***********************************************************  \033[0m"
	@echo -e "\033[40;32m make build_vvd1703***********************************************************  \033[0m"
	@echo -e "\033[40;32m make build_vvd1803***********************************************************  \033[0m"
	@echo -e "\033[40;32m Most common commands*********************************************************  \033[0m"
	@echo -e "\033[40;32m make crtvvd******************************************************************  \033[0m"
	@echo -e "\033[40;32m make openwebserver***********************************************************  \033[0m"
	@echo -e "\033[40;32m make checkwebserver**********************************************************  \033[0m"
	@echo -e "\033[40;32m make closewebserver**********************************************************  \033[0m"
	@echo -e "\033[40;32m make resetwebserver**********************************************************  \033[0m"
	@echo -e "\033[40;32m make codereport**************************************************************  \033[0m"
	@echo -e "\033[40;32m make codehtml****************************************************************  \033[0m"
	@echo -e "\033[40;32m make mvhtml******************************************************************  \033[0m"
	@echo -e "\033[40;32m make gui*********************************************************************  \033[0m"
	@echo -e "\033[40;32m make run*********************************************************************  \033[0m"
	@echo -e "\033[40;32m make verdi*******************************************************************  \033[0m"
	@echo -e "\033[40;32m make clean*******************************************************************  \033[0m"
	@echo -e "\033[40;32m Info:: verdi wave cfg file tb/btc/xxx/rc/cm.rc**or tb/utc/xxx/rc/cm.rc*******  \033[0m"

################################Most common commands Beign #########################################
####Run all testcase from the tc.cfg file 
.PHONY:run
run:
	$(foreach tc_name,$(TC_LIST),$(call runTestCase,$(tc_name)))

####Run the testcase (such as tc=tc1_org, run testcase is tc1_org) 
define runTestCase
	make checktc PAR_TC=$(1) ; 
endef

####Check the PAR_TC format is ok or not.
####The PAR_TC format must be xx_xx_xx_xx_xx_xx 
.PHONY:checktc
checktc:
	@if [[ $(words $(subst _, ,$(PAR_TC))) < 6 ]] ; then \
		echo -e "\033[0;31m The TC_NAME=xxx format is wrong!!!   \033[0m" ; \
		echo -e "\033[0;31m The format must be x_x_x_x_x_x       \033[0m" ; \
		echo -e "\033[0;31m You can write it like this           \033[0m" ; \
		echo -e "\033[0;31m TC_NAME=qst_nvrd_nuvm_nip_nhls_tc1   \033[0m" ; \
	else \
		make sim \
		PAR_SIM_TYPE=$(word 1,$(subst _, ,$(PAR_TC))) \
		PAR_WAVE_TYPE=$(word 2,$(subst _, ,$(PAR_TC))) \
		PAR_UVM_TYPE=$(word 3,$(subst _, ,$(PAR_TC))) \
		PAR_IP_TYPE=$(word 4,$(subst _, ,$(PAR_TC))) \
		PAR_OTHER_TYPE=$(word 5,$(subst _, ,$(PAR_TC))) \
		PAR_SUB_MAKEFILE=Makefile.$(PAR_SIM_TYPE).$(PAR_WAVE_TYPE).$(PAR_UVM_TYPE).$(PAR_IP_TYPE).$(PAR_OTHER_TYPE) ; \
	fi ; 

####Run simulation
.PHONY:sim
sim:buildsim
	cd $(RUNSIM_ROOT)/run_$(PAR_TC) ; \
	make -f $(MAKEFILE_SCRIPT)/$(PAR_SUB_MAKEFILE) preparation ; \
	make -f $(MAKEFILE_SCRIPT)/$(PAR_SUB_MAKEFILE) sim | tee sim.log

####Create the testcase simulation folder and some script...
.PHONY:buildsim
buildsim:
	@if [[ ! -d $(RUNSIM_ROOT)/run_$(PAR_TC) ]]; then \
	   echo -e "\033[48;34m Building our sim environment...\033[0m" ; \
	   mkdir $(RUNSIM_ROOT)/run_$(PAR_TC) ; \
	else \
	   echo -e "\033[48;34m Rebuilding our sim environment...\033[0m" ; \
	fi ; \
    if [[ ! -e $(MAKEFILE_SCRIPT)/$(PAR_SUB_MAKEFILE) ]] ; then \
	   	echo -e "\033[0;31m We havn't this $(PAR_SUB_MAKEFILE)    \033[0m" ; \
	fi ; \
    if [[ ! -e $(RUNSIM_ROOT)/run_$(PAR_TC)/Makefile.flist ]] ; then \
		touch $(RUNSIM_ROOT)/run_$(PAR_TC)/Makefile.flist ; \
	fi ; \
	if [[ ! -d $(RUNSIM_ROOT)/run_$(PAR_TC)/$(PAR_TC) ]]; then \
        ln -s $(MAKEFILE_SCRIPT)/$(PAR_SUB_MAKEFILE) $(RUNSIM_ROOT)/run_$(PAR_TC)/$(PAR_SUB_MAKEFILE) ; \
		if [[ $(PAR_UVM_TYPE) == uvm ]] ; then \
			ln -s $(UTC_ROOT)/$(PAR_TC) $(RUNSIM_ROOT)/run_$(PAR_TC)/$(PAR_TC)  ; \
		else \
			ln -s $(BTC_ROOT)/$(PAR_TC) $(RUNSIM_ROOT)/run_$(PAR_TC)/$(PAR_TC)  ; \
		fi ; \
	fi ;

#Display the verdi gui with code and wave
.PHONY:verdi
verdi:
	@if [[ $(PAR_WAVE_TYPE) == $(Verdi) ]] ; then \
	    if [[ $(TC_WORDS) == 1 ]] ; then \
	        make -f $(MAKEFILE_SCRIPT)/$(PAR_SUB_MAKEFILE) verdi ; \
        else \
	   	    echo -e "\033[0;31m The 'TC_NAME' you chosed are actived more than one \033[0m" ; \
	   	    echo -e "\033[0;31m The 'Please keep only one actived,thank you!       \033[0m" ; \
        fi ; \
    else \
	   	echo -e "\033[0;31m The 'TC_NAME'=$(PAR_TC) you chosed is not support Verdi   \033[0m" ; \
	   	echo -e "\033[0;31m Change other TC_NAME should include vrd in the tc.cfg file\033[0m" ; \
    fi ; 
################################Most common commands end ###########################################

################################Build sim libraray commands begin ##################################
########Build vvd1602
.PHONY:build_vvd1602
build_vvd1602:
	@if [[ ! -d $(SIM_LIBRARY_PATH) ]]; then \
	   echo -e "\033[0;31m SIM_LIBRARY_PATH:: $(SIM_LIBRARY_PATH) does not exist...\033[0m" ; \
	   echo -e "\033[0;31m Please mkdir the $(SIM_LIBRARY_PATH) by your self    ...\033[0m" ; \
	else \
		if [[ ! -d $(VVD1602_LIBRARY_PATH)  ]]; then \
	   		echo -e "\033[48;34m VVD1602_LIBRARY_PATH:: $(VVD1602_LIBRARY_PATH) does not exist...\033[0m" ; \
	   		echo -e "\033[48;34m We will mkdir it automation ...\033[0m" ; \
	   		mkdir $(VVD1602_LIBRARY_PATH) ; \
		fi ; \
		echo "compile_simlib -family all -language all -force -simulator questa -directory $(VVD1602_LIBRARY_PATH)" > $(VVD_SCRIPT)/simlib.tcl ; \
		$(VVD_BIN)/vivado -mode tcl -source $(VVD_SCRIPT)/simlib.tcl ; \
	fi ;
########Build vvd1703
.PHONY:build_vvd1703
build_vvd1703:
	@if [[ ! -d $(SIM_LIBRARY_PATH) ]]; then \
	   echo -e "\033[0;31m SIM_LIBRARY_PATH:: $(SIM_LIBRARY_PATH) does not exist...\033[0m" ; \
	   echo -e "\033[0;31m Please mkdir the $(SIM_LIBRARY_PATH) by your self    ...\033[0m" ; \
	else \
		if [[ ! -d $(VVD1703_LIBRARY_PATH)  ]]; then \
	   		echo -e "\033[48;34m VVD1703_LIBRARY_PATH:: $(VVD1703_LIBRARY_PATH) does not exist...\033[0m" ; \
	   		echo -e "\033[48;34m We will mkdir it automation ...\033[0m" ; \
	   		mkdir $(VVD1703_LIBRARY_PATH) ; \
		fi ; \
		echo "compile_simlib -family all -language all -force -simulator questa -directory $(VVD1703_LIBRARY_PATH)" > $(VVD_SCRIPT)/simlib.tcl ; \
		$(VVD_BIN)/vivado -mode tcl -source $(VVD_SCRIPT)/simlib.tcl ; \
	fi ;
########Build vvd1803
.PHONY:build_vvd1803
build_vvd1803:
	@if [[ ! -d $(SIM_LIBRARY_PATH) ]]; then \
	   echo -e "\033[0;31m SIM_LIBRARY_PATH:: $(SIM_LIBRARY_PATH) does not exist...\033[0m" ; \
	   echo -e "\033[0;31m Please mkdir the $(SIM_LIBRARY_PATH) by your self    ...\033[0m" ; \
	else \
		if [[ ! -d $(VVD1803_LIBRARY_PATH)  ]]; then \
	   		echo -e "\033[48;34m VVD1803_LIBRARY_PATH:: $(VVD1803_LIBRARY_PATH) does not exist...\033[0m" ; \
	   		echo -e "\033[48;34m We will mkdir it automation ...\033[0m" ; \
	   		mkdir $(VVD1803_LIBRARY_PATH) ; \
		fi ; \
		echo "compile_simlib -family all -language all -force -simulator questa -directory $(VVD1803_LIBRARY_PATH)" > $(VVD_SCRIPT)/simlib.tcl ; \
		$(VVD_BIN)/vivado -mode tcl -source $(VVD_SCRIPT)/simlib.tcl ; \
	fi ;
################################Build sim library commands end #####################################
    
####Just test
.PHONY:test
test:
	@echo -e $(PAR_SIM_TYPE)
	@echo -e $(PAR_WAVE_TYPE)
	@echo -e $(PAR_UVM_TYPE)
	@echo -e $(PAR_IP_TYPE)
	@echo -e $(PAR_OTHER_TYPE)
	@echo -e $(TC_LIST)
	@echo -e $(PAR_SUB_MAKEFILE)
	@echo -e $(TC_WORDS)

################################Build vivado project begin #########################################
####create the vivado project
.PHONY:crtvvd
crtvvd:
	@if [[ ! -d $(RUNSIM_ROOT)/$(IP_PRJ) ]]; then \
	   echo -e "\033[48;34m Building our vivado project environment...\033[0m" ; \
	   mkdir $(RUNSIM_ROOT)/$(IP_PRJ) ; \
	else \
	   echo -e "\033[48;34m Rebuilding our vivado project environment...\033[0m" ; \
	fi ; \
	make -f $(MAKEFILE_SCRIPT)/$(MAKEFILE_CMPL) preparation ; \
	$(VVD1604_BIN)/vivado -mode tcl -source $(RUNSIM_ROOT)/$(IP_PRJ)/create.tcl	
################################Build vivado project end   #########################################

################################Web server begin           #########################################
####open webserver and it is always run
.PHONY:openwebserver
openwebserver:
	python $(WEB_ROOT)/webserver.py &

.PHONY:checkwebserver
checkwebserver:
	ps -ef | grep python | grep tornado
    
####kill the pid of webserver
.PHONY:closewebserver
closewebserver:
	ps -ef | grep python | grep tornado | awk '{print $$2}' | sed -n '1p' > kid ; \
    sed 's/^/kill -9 /g' kid > id ; \
    chmod 777 id ; \
    ./id ; \
    rm -rf kid ; \
    rm -rf id ;

####reset web server
.PHONY:resetwebserver
resetwebserver: closewebserver openwebserver

#@ps -ef | grep python | awk '{print $$2}' | sed -n '1p'

####gui 
.PHONY:gui
gui:
	@if [[ $(PAR_UVM_TYPE) == uvm ]] ; then \
	    if [[ $(TC_WORDS) == 1 ]] ; then \
	        make -f $(MAKEFILE_SCRIPT)/$(PAR_SUB_MAKEFILE) gui ; \
        else \
	   	    echo -e "\033[0;31m The 'TC_NAME' you chosed are actived more than one \033[0m" ; \
	   	    echo -e "\033[0;31m The 'Please keep only one actived,thank you!       \033[0m" ; \
        fi ; \
    else \
	   	echo -e "\033[0;31m The 'only uvm option can support the gui command       \033[0m" ; \
	   	echo -e "\033[0;31m The 'TC_NAME'=$(PAR_TC) you chosed is not support gui  \033[0m" ; \
	   	echo -e "\033[0;31m Change other TC_NAME should include uvm in the tc.cfg file\033[0m" ; \
    fi ; 

	
################################Web Server End             #########################################
################################Code Coverage Report Begin #########################################
.PHONY:codereport
codereport:
	@cd $(RUNSIM_ROOT)/run_$(PAR_TC) ; \
	find $(RUNSIM_ROOT)/run_$(PAR_TC) -name "*.ucdb" > ./ucdb.list ; \
	vcover merge all.ucdb `cat ucdb.list` ; \
	vcover report -html -verbose all.ucdb ; \
	cd $(RUNSIM_ROOT) ;

.PHONY:codehtml
codehtml:
	firefox $(RUNSIM_ROOT)/run_$(PAR_TC)/covhtmlreport/index.html &

.PHONY:mvhtml
mvhtml:
	cp -rf $(RUNSIM_ROOT)/run_$(PAR_TC)/covhtmlreport $(RUNSIM_ROOT)

################################Code Coverage Report End   #########################################

####Clean the project
.PHONY:clean
clean:
	cd $(RUNSIM_ROOT) ; \
	rm -rf tv ; \
	rm -rf modelsim.ini ; \
	rm -rf run_* ; \
	rm -rf novas* ; \
	rm -rf vivado* ; \
	rm -rf compile* ; \
	rm -rf webtalk* ; \
	rm -rf verdiLog
