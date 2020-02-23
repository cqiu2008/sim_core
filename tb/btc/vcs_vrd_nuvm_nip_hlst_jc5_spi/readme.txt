Confidential:
-------------
This file and all files delivered herewith are Micron Confidential Information.


Disclaimer of Warranty:
-----------------------
This software code and all associated documentation, comments
or other information (collectively "Software") is provided 
"AS IS" without warranty of any kind. MICRON TECHNOLOGY, INC. 
("MTI") EXPRESSLY DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO, NONINFRINGEMENT OF THIRD PARTY
RIGHTS, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS
FOR ANY PARTICULAR PURPOSE. MTI DOES NOT WARRANT THAT THE
SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE OPERATION OF
THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. FURTHERMORE,
MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR THE
RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS,
ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT
OF USE OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO
EVENT SHALL MTI, ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE
LIABLE FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR
SPECIAL DAMAGES (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS
OF PROFITS, BUSINESS INTERRUPTION, OR LOSS OF INFORMATION)
ARISING OUT OF YOUR USE OF OR INABILITY TO USE THE SOFTWARE,
EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
Because some jurisdictions prohibit the exclusion or limitation
of liability for consequential or incidental damages, the above
limitation may not apply to you.

Copyright 2012 Micron Technology, Inc. All rights reserved.

Getting Started:
----------------
Unzip nand_model.zip to a folder.
Point your simulator to the folder where you located the files.
At the ModelSim command prompt, type "do tb.do"  

File Descriptions:
------------------
nand_model_spi.v        --Structural wrapper for nand_spi
nand_spi.v              --Nand model of a single die
nand_spi_parameters.vh  --File that contains all parameters used by the model
readme.txt              --This file
tb_spi.v                --Test bench
subtest.vh              --Example test demonstrating device behavior
tb.do                   --File that compiles and runs the above files 
nand_spi_chip_mem.vmf   --File to initialize mem array.



Supported Simulators
---------------------
This model supports ModelSim, VCS, and NC-Verilog.  Verilog-2001 
support is required.  VCS and NCV may require extra
compile switches to enable this support.  Example simulation compile 
commands are shown below:

ModelSim : vlog tb_spi.v nand_model_spi.v nand_spi.v 
VCS: 	   vcs +v2k tb_spi.v nand_model_spi.v nand_spi.v 
NCV: 	   ncverilog tb_spi.v nand_model_spi.v nand_spi.v 

Reduced Reset Timing:
---------------------
In order to reduce simulation time due to Power-On-Reset and Soft-Reset, the nand
model has a define called "SHORT_RESET"
    simulator   command line
    ---------   ------------
    ModelSim : vlog +define+SHORT_RESET tb_spi.v nand_model_spi.v nand_spi.v 
    VCS: 	   vcs +v2k +define+SHORT_RESET tb_spi.v nand_model_spi.v nand_spi.v 
    NCV: 	   ncverilog +define+SHORT_RESET tb_spi.v nand_model_spi.v nand_spi.v 

Macro for different Models
D_1Gb/D_2Gb/D_4Gb  -- 1Gb/2Gb/4Gb density size
V33/V18            -- 3.3v/1.8v Operating Voltage Range
SOP/DFN/TBGA       -- package for SF/12/W9

For the model MT29F2G01ABAGD12, please define the macro "+define+D_2Gb +define+V33 +define+DFN"


About initilization of mem array:
  Currently the model assume the host ramcode size is one page.  
	If the ramcode size is greater than one page, 
	please update the lines 282~284 of the " nand_spi.v" file.  
	As we don't know size of the ramcode, 
	so it's customer's responsibility to update it.  

  Assuming the ramcode size is 3 page and will be initialized to block 0, page0,page1 and page 2 the codes will be changed to :

        memory_used  = 3;
        memory_addr[memory_index] = 0; // row address block 0, page0
        memory_index = memory_index + 1'b1;
        memory_addr[memory_index] =1; // row address block 0, page1
        memory_index = memory_index + 1'b1;
        memory_addr[memory_index] =2; // row address block 0, page2
        memory_index = memory_index + 1'b1;
