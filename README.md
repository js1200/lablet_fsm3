# lablet_fsm3
MICREAgents lablet finite state machine verilog code and test bench 

This repository contains the source code and testbench used to produce and verify the programming of the 3rd generation autonomous lablets (CMOS3) [1,2].
Lablets are microscopic autonomous electrochemical agents based on CMOS, and equipped with AC bipolar solution energy harvesting and a supercap for power.
Microsystems Chemistry and Biomolecular Information Processing (BioMIP), Ruhr University Bochum, Germany.

Originally designed at 100x100x50 µm with back side supercapacitor, the current lablets are ca. twice the area 140x140 µm to accommodate a front side supercapacitor.
Lablets are designed with an ultra-low power slow clock (e.g. 200 Hz) and analog subsystem (including power up) [3].
They were built in many combinatorial digital variants ( specifyable by this software) in a whole wafer run in 180nm CMOS via Europractice with TSMC.

This software was written in verilog by Thomas Maeke in collaboration with John S. McCaskill (design input) at the Ruhr Universität Bochum, Germany in 2015.
For a complete description of the motivation, design and functioning of lablets see [2].
The software was developed under the Linux (Ubuntu) operating system using the Icarus Verilog compiler: Icarus Verilog version 11.0 (stable).
Visualization of the resulting signals and waveforms can be performed with the gtkwave software. GTKWave Analyzer v3.3.118 (w)1999-2023 BSI

The files in the distribution are:
make_testbench.sh   The shellscript contains examples of running the five different finite state machines (FSMs) with the software.
lablet_fsm3_tb.v    The testbench verilog file contains the testbench for simulating the verilog code.
fsm.gtk             The gtkwave file defines the variables traced in the simulation window.
lablet_fsm3_defs.v  The definition verilog file contains the definitions of constants and macros required to implement the five versions of the FSM.
lablet_fsm3.v       The main verilog file contain the finite state machine.
idx.png  x=0-4      Images of the gtkwave simulation output for the five different state machines.

Note that 9 different tests can be activated by uncommenting the numbered sections of the testbench file.

Lablets are now (2024) being deployed and developed further in a team led by John McCaskill in the group of Oliver Schmidt at the 
Research Center for Materials, Architectures, and Integration of Nanomembranes (MAIN, Chemnitz University of Technology, 09126 Chemnitz, Germany

[1] McCaskill J S, et al. 2012 Microscale Chemically Reactive Electronic Agents International Journal of Unconventional Computing 8(4) 289-299.

[2] Maeke T., McCaskill J., Funke D., Mayr P., Sharma A., Tangen U., Oehm J. (2024) "Autonomous programmable microscopic electronic lablets optimized with digital control."
ArXiv:2405.20110    http://arxiv.org/abs/2405.20110  This is a minor edit of an article submitted (2016) to the EU as Supporting Information for the Final Report of the EU Project MICREAgents.

[3] Funke D.A., Hillger P., Oehm J., Mayr P., Straczek L., Pohl N., McCaskill J.S., 2017. A 200 µm by 100 µm Smart Submersible System with an Average Current Consumption of 1.3 nA and a Compatible Voltage Converter. IEEE Transactions on Circuits and Systems Online., 1-12.
