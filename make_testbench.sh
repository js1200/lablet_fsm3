#!/bin/bash
#
# For png image:
# inside gtkwave:   Menu | File | Grab to File
#
iverilog  -DDEF_ID0 -s lablet_testb lablet_fsm3_tb.v && ./a.out  && gtkwave ll.vcd fsm.gtkw
iverilog  -DDEF_ID1 -s lablet_testb lablet_fsm3_tb.v && ./a.out  && gtkwave ll.vcd fsm.gtkw
iverilog  -DDEF_ID2 -s lablet_testb lablet_fsm3_tb.v && ./a.out  && gtkwave ll.vcd fsm.gtkw
iverilog  -DDEF_ID3 -s lablet_testb lablet_fsm3_tb.v && ./a.out  && gtkwave ll.vcd fsm.gtkw
iverilog  -DDEF_ID4 -s lablet_testb lablet_fsm3_tb.v && ./a.out  && gtkwave ll.vcd fsm.gtkw
 
# now runs with: 
#  Icarus Verilog version 11.0 (stable)
#  GTKWave Analyzer v3.3.118 (w)1999-2023 BSI

