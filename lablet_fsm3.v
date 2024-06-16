/*=============================================================================================
   Lablet state machine
   $Id: lablet_fsm3.v,v 1.24 2015/12/20 15:20:25 tmaeke Exp tmaeke $

   Author: Thomas Maeke, Ruhr Universität Bochum, Germany
   Supervisor: John S. McCaskill, Ruhr Universität, Bochum
   Research conducted as part of EU MICREAgents Project 2012-2016


    CC BY-NC-ND: Creative Commons Attribution-NonCommercial-NoDerivatives 
    Copyright (c) 2015,...,2024 Thomas Maeke and John S. McCaskill

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
*/

/*   
   compile:
       iverilog  -s lablet_testb lablet_fsm3_tb.v && ./a.out  && gtkwave  ll.vcd fsm.gtkw
   

   hierarchy:
       lablet_testb                               Testbench
           mod_lablet: lablet                     Tristate control
               mod_lablet_core: lablet            Clock generation, Data/Clk recovery
                   mod_ll_statem: state_mach      State machine

    pattern control
        Two electrodes on : 10 pairs
        Electrodes not referred to are in high z.

        electrode spatial order is 1, 2, 3, 4, 5 with 3 the end of the long stem channel 
        and 1 and 2 at the ends of the top T channel

        pairs = {{1, 3}, {5, 3}, {1, 5}, {2, 4}, {1, 2}, {5, 4}, {1, 4}, {5, 2}};
        otherpairs = {{2, 3}, {4, 3}};  (*9,10*)
        partners = {{1, 2}, {3, 4}, {5, 6}, {7, 8}};
        partners2 = {{1, 3}, {2, 4}, {5, 9}, {6, 10}};

        triplesquads = {{1, 3 a, 5}, {1 a, 3, 5}, {2, 3 a, 4}, {2 a, 3, 4}, {1, 2, 
        3}, {5, 4, 3}, {1, 2, 3 a, 4, 5}, {1, 2, 3, 4, 5, GND a}};
        
        Choose : pairs or triplesquads
        Choose : low in 8 - bit pattern to mean one of {off, inverse, partners1, partners2}
        The a in the triplesquads means this electrode has opposite sign to all the rest.

    variants:
        Din/Dout default/swapped
        Datatransfer slow/fast
        Dout Hi/Lo asymmetric/symmetric-bipolar

        ================================== V1 =================================================
        
        
                +------------------------------------------------------------------+
                |    |                                         |+-------+|    |    |
                |    |    +-------------------------------+    ||  [0]  ||    |    |      
                | S  |    |                               |    ||  A1   ||    |  D |      
                | U  |    |           SB2    [10]         |    |+-------+|    |  O |      
                | P  |    |_______________________________|    |         |    |  U |
                | 2  |    |                               |    |  o      |    |  T |      
                |[6] |    |_______________________________|    |         |    |[8] |
                |    |    |                               |    |  o      |    |    |      
                |    |    |           SB1    [11]         |    |         |    |    |
                |----+    +-------------------------------+    |+-o-----+|    +----|      
                |                                              ||  S0   ||         |   
                |----------------------------------------------+| o [1] ||         |      
                |+-------+                           +-------+  +-------+|         |   
                || A2 [5]|                           | SR [4]|    o      |         |      
                |+-------+                           +-------+  +-------+|         |   
                |----------------------------------------------+| o S1  ||         |      
                |                                              ||   [2] ||         |   
                |----+    +-------------------------------+    |+-o-----+|    +----|      
                |    |    |           SA2    [12]         |    |         |    |    |
                |    |    |_______________________________|    |  o      |    |    |      
                |    |    |                               |    |         |    | S  |
                | D  |    |_______________________________|    |  o      |    | U  |      
                | I  |    |                               |    |         |    | P  |
                | N  |    |                               |    |+-o-----+|    | 1  |      
                |[7] |    |           SA1    [13]         |    ||  A0   ||    |[9] |
                |    |    +-------------------------------+    || o [3] ||    |    |      
                |    |                                         |+-------+|    |    |
                +-------------------------------------------------o----------------+      
              0,0                                                 ^-Aintf
        
                ----------------------------------Electrodes------------------------
                AnalogInterface          Lablet1a           Lablet1b
                --------------------------------------------------------------------
                Vss(11) (bigger)    ---> SA1[13] SB2[10]        "
                Vsup_2(10)          ---> Sup2[6]                "
                Vsup_1(9)           ---> Sup1[9]               DOUT[8]/A4
                ACTOR_1(8)          ---> A1[0]                  "
                Pad_SENS_2_DOUT(7)  ---> DOUT[8]/A4            Sup1[9]
                Pad_DIN0_ACTOR_2(6) ---> DIN[7]/A2              "
                Pad_SENS_1_ISFET(5) ---> S1[2]                  "
                Pad_REFET(4)        ---> SR[4]                  "
                Pad_SENS_0_ISFET(3) ---> S0[1]                  "
                ACTOR_3(2)          ---> A3[5]                  "
                ACTOR_0(1)          ---> A0[3]                  "
                Vdd(0) (smaller)    ---> SB1[11] SA2[12]        "

        ================================== V2 =================================================
        
                                                                                               
                +------------------------------------------------------------------+
                |    |                                         |+-------+|    |    |
                |    |    +---------------+    +----------+    ||   [0] ||    |    |       
                | S  |    |               |    |          |    ||  A1   ||    |  D |       
                | U  |    |               |    |          |    |+-------+|    |  O |       
                | P  |    |               |    |          |    |         |    |  U |
                | 2  |    |               |    |          |    |  o      |    |  T |       
                |    |    |           SB2 |    | SB1      |    |         |    |[8] |
                |[6] |    |               |    |          |    |+-o-----+|    |    |       
                |    |    |         [10]  |    |  [11]    |    ||  S0   ||    |    |
                |----+    |               |    |          |    || o [1] ||    +----|       
                |         |               |    |          |    |+-------+|         |   
                |         |               |    |          |    |  o      |         |       
                |         +---------------+    +----------+    |+-------+|+-------+|   
                |                                              || oSR[4]|||  A2   ||       
                |         +---------------+    +----------+    |+-------+|+-------+|   
                |         |               |    |          |    |  o      |         |       
                |         |               |    |          |    |+-------+|         |   
                |----+    |               |    |          |    || oS1   ||    +----|       
                |    |    |               |    |          |    ||   [2] ||    |    |
                |    |    |           SA1 |    | SA2      |    |+-o-----+|    |    |       
                |    |    |               |    |          |    |         |    | S  |
                | D  |    |         [13]  |    |  [12]    |    |  o      |    | U  |       
                | I  |    |               |    |          |    |         |    | P  |
                | N  |    |               |    |          |    |+-o-----+|    | 1  |       
                |    |    |               |    |          |    ||  A0   ||    |[9] |
                |[7] |    +---------------+    +----------+    || o [3] ||    |    |       
                |    |                                         |+-------+|    |    |
                +-------------------------------------------------o----------------+       
              0,0                                                 ^-Aintf        

                ----------------------------------Electrodes------------------------
                AnalogInterface          Lablet2a           Lablet2b                
                --------------------------------------------------------------------
                Vss(11) (bigger)    ---> SA1[13] SB2[10]        "                   
                Vsup_2(10)          ---> Sup2[6]                "                   
                Vsup_1(9)           ---> Sup1[9]               DOUT[8]/A4           
                ACTOR_1(8)          ---> A1[0]                  "                   
                Pad_SENS_2_DOUT(7)  ---> DOUT[8]/A4            Sup1[9]              
                Pad_DIN0_ACTOR_2(6) ---> DIN[7]/A2              "                   
                Pad_SENS_1_ISFET(5) ---> S1[2]                  "                   
                Pad_REFET(4)        ---> SR[4]                  "                   
                Pad_SENS_0_ISFET(3) ---> S0[1]                  "                   
                ACTOR_3(2)          ---> A3[5]                  "                   
                ACTOR_0(1)          ---> A0[3]                  "                   
                Vdd(0)              ---> SB1[11] SA2[12]        "                   

        ================================== V3 =================================================
        
        
               +------------------------------------------------------------------+
               |    |                                               |+--------+|  |
               |    |    +-------------------------------------+    ||  [0]   ||  |        
               | S  |    |                                     |    ||  A1    ||  |        
               | U  |    |           SB2          [10]         |    |+--------+|  |        
               | P  |    |_____________________________________|    |+--------+|  |
               | 2  |    |                                     |   o||  [8]   ||  |        
               |[6] |    |_____________________________________|    || DOUT   ||  |
               |    |    |                                     |   o|+--------+|  |        
               |    |    |           SB1          [11]         |    |          |  |
               |----+    +-------------------------------------+   o| +------+ |  |        
               |                                                    | | S0   | |  |   
               |---------------------------------------------------o+ |  [1] | |  |        
               |+-------+                                 +-------+-  +------+ |  |   
               || A2 [5]|                                 | SR [4]|o           |  |        
               |+-------+                                 +-------+-  +------+ |  |   
               |---------------------------------------------------o+ |  S1  | |  |        
               |                                                    | |  [2] | |  |   
               |----+    +-------------------------------------+   o| +------+ |  |        
               |    |    |           SA2          [12]         |    |          |  |
               |    |    |_____________________________________|   o|+--------+|  |        
               | S  |    |                                     |    ||  [7]   ||  |
               | U  |    |_____________________________________|   o||  DIN   ||  |        
               | P  |    |                                     |    |+--------+|  |
               | 1  |    |                                     |   o|+--------+|  |        
               |[9] |    |           SA1          [13]         |    ||  [3]   ||  |
               |    |    +-------------------------------------+   o||  A0    ||  |        
               |    |                                              -|+--------+|  |
               +---------------------------------------------------o--------------+        
             0,0                                                   ^-Aintf

                ----------------------------------Electrodes------------------------
                AnalogInterface          Lablet3a           
                --------------------------------------------------------------------
                Vss(11) (bigger)    ---> SA1[13] SB2[10]        
                Vsup_2(10)          ---> Sup2[6]                
                Vsup_1(9)           ---> Sup1[9]                
                ACTOR_1(8)          ---> A1[0]                  
                Pad_SENS_2_DOUT(7)  ---> DOUT[8]/A4             
                Pad_DIN0_ACTOR_2(6) ---> DIN[7]/A2              
                Pad_SENS_1_ISFET(5) ---> S1[2]                  
                Pad_REFET(4)        ---> SR[4]                  
                Pad_SENS_0_ISFET(3) ---> S0[1]                  
                ACTOR_3(2)          ---> A3[5]                  
                ACTOR_0(1)          ---> A0[3]                  
                Vdd(0) (smaller)    ---> SB1[11] SA2[12]        
        =======================================================================================

    Global:
        REPEAT                   *1 *4 *16 *64


    Table1:  
        Input:  
            PA[phase](3)         pattern sequence select
            SC[phase](2)         sequence length select
            PC=patterncnt(3)     stepped by TI[phase]*clocks
            NE                   inversion
        Output:  
            PO                   output select

    Table2:  
        Input: 
            PO[table1]           output select
            EC[phase]            group select
            EP[phase]            polarity select
        Output:  
            A0+tri   
            A1+tri  
            A2+tri  
            Dout+tri  
            Din+tri  
            PWR                    
=============================================================================================*/

`include "lablet_fsm3_defs.v"

//`define STAB          // Actor via 2 tables
//`define ATAB          // Actor via 3 tables
//`define DSEL          // dselect switches din/dout
//`define COMT          // comt is a flag to control comunication stuff
//`define DOCKED        // docked flag indicates docked state of LL
`define TMO_RUN         // State == running always resets watchdog

//==========================================================================================
module `mod_lablet (
    CLK,          // I: internal clk ca. 1kHz
    RST,          // I:
    SENS0,        // I
    SENS1,        // I
    DIN1,         // I    DIN1    
    DIN0,         // I    DIN0
    ACT0,         // O    Actor0
    ACT1,         // O    ACTOR1
    ACT2,         // IO   ACTOR and DIN0 or DOUT0
    ACT3,         // O    ACTOR3
    ACT4,         // OI   Actor and DIN1 or DOUT1
    ACT5);        // O    Supply to GND

    //--------------------------------------------------------------------------------------
    // this is mainly for routing of signals
    //--------------------------------------------------------------------------------------
    input  CLK;        // Clk
    input  RST;
    input  SENS0;
    input  SENS1;
    input  DIN0;
    input  DIN1;
    output ACT2;   // 
    output ACT3;   // 
    output ACT1;   // 
    output ACT0;   // 
    output ACT4;   // 
    output ACT5;   // 
    
    //--------------------------------------------------------------------------------------
    wire [5:0] act;
    wire [4:0] actenab;
    wire [1:0] sensw;
    wire CLK;
    wire RST;
    wire [1:0]din;
    //--------------------------------------------------------------------------------------

    assign ACT0 = actenab[0] ? act[0] : 1'Bz;
    assign ACT1 = actenab[1] ? act[1] : 1'Bz;
    assign ACT2 = actenab[2] ? act[2] : 1'Bz;                       
    assign ACT3 = actenab[3] ? act[3] : 1'Bz;   
    assign ACT4 = actenab[4] ? act[4] : 1'Bz; 
    assign ACT5 = act[5];

    assign sensw[0] = SENS0;
    assign sensw[1] = SENS1;
    assign din[0] = DIN0;
    assign din[1] = DIN1;
    //--------------------------------------------------------------------------------------
    `mod_ll_statem state_mach(CLK, RST, sensw, din, act, actenab);
    //--------------------------------------------------------------------------------------
    always @(posedge CLK) begin
    end
endmodule


//==========================================================================================
module `mod_ll_statem (
    CLK,          // I: internal clk ca. 1kHz
    RST,          // I:
    SENS,         // I2
    DIN,          // I2
    ACT,          // O6   Actor
    ACTEN);       // O5   enable
    
    parameter Noofstatebits = 2;
    parameter Noofphasebits = 2;
    parameter CmdByte = `COMMAND; // 8'B110000011;    
    
    //------------------------- ------------------------------------------------------------
    input  CLK;           // Sysclk
    input  RST;
    input  [1:0] DIN;
    input  [1:0] SENS;
    output [5:0] ACT;     // act5 needs no tristate control
    output [4:0] ACTEN;
    //------------------------- ------------------------------------------------------------
                                                     // # Flipflops required         
    reg [Noofstatebits-1:0] state;                                              // 2 
    reg [Noofphasebits-1:0] phase;                                              // 2                          
    reg [2:0] patterncnt;                            // for 8 patterns          // 3   
    reg [6:0] repeatcnt;                             // for up to 127 repeats   // 7
                                                                                        
    reg [(`SYSCLK==200? 11:8):0] clkdivider;                                    //12 = 26                           

    //------------------------- ------------------------------------------------------------
    reg dout;                        // data out stream                         // 1
    reg doutact;                     // dout tristate control                   // 1

    reg  [`PULSECNTBITS-1:0] pulsecnt; // counts high time of din value         // 5
    reg din1;                                                                   // 1
    reg din2;                                                                   // 1
    reg [7:0] commandin;            // receive register                         // 8 = 17

    //------------------------- ------------------------------------------------------------
    `ifdef DSEL
        reg dsel;                    // selects din-input and dout-output       // 1
    `endif
    reg trigd;                       // re/set by commands                      // 1
    `ifdef DOCKED
        reg docked;                  // indicates docked state                  // 1
    `endif        
    reg comd;                        // received a command                      // 1 
    `ifdef COMT
        reg comt;                    // received comtst command                 // 1 =  5
    `endif

    //------------------------- ------------------------------------------------------------
    reg [5:0] act; // one extra                                                 // 6
    reg [4:0] actenab; // one extra                                             // 5 = 11
                                                                     //  Total  // 59
    //------------------------- ------------------------------------------------------------
    reg [`PROGLEN-1:0] prog;                                                    //64
    //------------------------- ------------------------------------------------------------
    wire [1:0] sensw;

    //------------------------- ------------------------------------------------------------
    // dsel==0  default   DIN=A2  DOUT=A4                                          
    assign ACT[0] = act[0];
    assign ACT[1] = act[1];
    assign ACT[3] = act[3];                       
    `ifdef DATA_BIPO
        `ifdef DSEL
            assign ACT[2] = (doutact ? (dsel ? dout:!dout) : act[2]);
            assign ACT[4] = (doutact ? (dsel ?!dout: dout) : act[4]); 
        `else
            assign ACT[2] = (doutact ? !dout : act[2]);
            assign ACT[4] = (doutact ?  dout : act[4]); 
        `endif
    `else
        `ifdef DSEL
            assign ACT[2] = ( dsel & doutact ? dout : act[2]);
            assign ACT[4] = (!dsel & doutact ? dout : act[4]); 
        `else
            assign ACT[2] = act[2];
            assign ACT[4] = doutact ? dout : act[4]; 
        `endif
    `endif
    assign ACT[5] = act[5];                       

    assign sensw[0] = SENS[0];
    assign sensw[1] = SENS[1];
    
    assign ACTEN[0] = actenab[0];
    assign ACTEN[1] = actenab[1];
    assign ACTEN[3] = actenab[3];
    `ifdef DATA_BIPO
        assign ACTEN[2] = ( doutact ? 1'B1 : actenab[2]);
        assign ACTEN[4] = ( doutact ? 1'B1 : actenab[4]);
    `else
        `ifdef DSEL
            assign ACTEN[2] = ( dsel & doutact ? 1'B1 : actenab[2]);
            assign ACTEN[4] = (!dsel & doutact ? 1'B1 : actenab[4]);
        `else
            assign ACTEN[4] = doutact ? 1'B1 : actenab[4];
        `endif
    `endif


    //------------------------- ---------------------------------------------------------
    wire clk_vslow;
    wire clk_slow;
    wire clk_fast;
    wire clk_vfast;
    wire clk_timeout;
    `ifdef SYSCLK200
        assign clk_vfast   = clkdivider[0] & clkdivider[1];              // :4
        assign clk_fast    = clkdivider[3] & clkdivider[2] & clk_vfast;  // :16
        assign clk_slow    = clkdivider[5] & clkdivider[4] & clk_fast;   // :64
        assign clk_vslow   = clkdivider[7] & clkdivider[6] & clk_slow;   // :256
        assign clk_timeout = clkdivider[11] & clkdivider[10] & clk_vslow;  // :1024
        `define CLK_TMO1 10
        `define CLK_TMO2 11
    `else
        assign clk_vfast   = clkdivider[0];                              // :4
        assign clk_fast    = clkdivider[2] & clkdivider[1] & clk_vfast;  // :16
        assign clk_slow    = clkdivider[4] & clkdivider[3] & clk_fast;   // :64
        assign clk_vslow   = clkdivider[6] & clkdivider[5] & clk_slow;   // :256
        assign clk_timeout = clkdivider[8] & clkdivider[7] & clk_vslow;  // :1024
        `define CLK_TMO1 7
        `define CLK_TMO2 8
    `endif

    //------------------------- ---------------------------------------------------------

    `ifdef __SIMULATE__
        reg match;                // matched received cmd
        reg match_send;           // matched received cmd: send
        reg match_run;            // matched received cmd: run
        reg match_prog;           // matched received cmd: prog
        reg match_stop;           // matched received cmd: stop
        reg match_timeout;        // set if timeout ocurres
        reg [7:0] match_cmd;
        reg match_in;             // input stream
        reg timeout;            
        reg sim_wd_reset;
        reg  [`PULSECNTBITS-1:0] sim_maxpulsecnt; // counts high time of din value  // 5
        real sim_time;
        reg sim_stodata;
    `endif


    wire [2:0] id;

    //------------------------- ---------------------------------------------------------
    wire [`PL_EC+`PL_PO+`PL_EP-1:0] paddr;  // p_ec, p_po, p_ep, p_ne?
    wire [`PL_EC-1:0] p_ec;
    wire              p_ne;
    wire [`PL_EP-1:0] p_ep;
    wire [`PL_SC-1:0] p_sc;
    wire [`PL_TIM+`PL_TI-1:0] p_ti;
    wire [`PL_PA-1:0] p_pa;
    wire [`PL_SE-1:0] p_se;
    wire [`PL_CA-1:0] p_ca;
    wire [`PL_REP-1:0] p_rep;
    wire              p_dat;
    wire [`PL_STOLEN-1:0] p_sto0;
    wire [`PL_STOLEN-1:0] p_sto1;
    
    wire [4:0]   p_nee;   // p_ne bundle
    wire [1:0]   p_po;                                                        
    
    //----------------------------------------------------------------------------------
    //    PA bits specify which timing pattern
    //    EP specifies pattern row as before, 
    //       but now directly coded without pattern bit complication
    //    EC specifies pairs or triples+ as in my last scheme
    //    SC specifies duty cycle
    // Access to program entries
    assign id   = `DEF_ID;
    assign p_ep = `P_EP(phase);
    assign p_ec = `P_EC(phase);
    assign p_sc = `P_SC(phase);
    assign p_ti = { `P_TI(phase), `P_TIM };
    assign p_ca = `P_CA(phase);
    assign p_pa = `P_PA(phase);
    assign p_se = `P_SE(phase);
    assign p_rep= `P_REP;
    assign p_dat= `P_DAT;

    assign p_sto0 = `P_STO0;
    assign p_sto1 = `P_STO1;

    assign p_ne = `P_NE(phase);
    assign p_nee = {p_ne,p_ne,p_ne,p_ne,p_ne};

    //----------------------------------------------------------------------------------
    function [1:0] poduty;
       input [1:0] sc;    // seqeunce cycle type (const,short,long,full)
       input [2:0] pc;    // patterncnt
       input [1:0] x;     // pattern output 0..3 from potabx
       input [1:0] gl;    // pattern length 1,2,3 from popatlen
       // called typically as:  
       //       poduty( p_sc,  patterncnt,  potabx(p_pa,patterncnt), popatlen(p_pa))
       // if const or short sequence cycle then 
       //       mask out to 0 in 2nd half of 8 step patterncnt
       if ((pc[2]==1) && (sc[1]==0)) begin
           poduty = 0;
       end
       //  else x except mask out to 0 for {odd pc and (const or long sequence cycle) 
       //                                          and pattern length not 3}
       else begin
           if (pc[0] && (sc[0]==0) && (gl!=2'B11))  poduty = 0;
           else poduty = x;
       end
    endfunction
  
    //----------------------------------------------------------------------------------
    function [1:0] popatlen;
       input [2:0] pa;
       // po pattern length with values 1,2,3
       // pa 0 1 2 3 4 5 6 7
       // fn 3 1 1 1 3 2 2 2
       
       if (pa[0] || pa[1]) begin
           if (pa[2]) popatlen = 2;
           else       popatlen = 1;
       end
       else begin
          popatlen = 3;
       end       
    endfunction

  
    //----------------------------------------------------------------------------------
    function [1:0] potabx;
       input [2:0] pa;
       input [2:0] pc;
       // pa is pattern sequence index 0..7,  pc pattern counter 0..7
       // pc\pa   0   1   2   3   4   5   6   7  check
       //  0      0   1   2   3   0   1   2   3  * 
       //  1      1   1   0   0   2   1   2   3  *
       //  2      2   2   0   0   1   2   3   1  *
       //  3      3   3   0   0   3   2   3   1  *
       //  4      0   1   2   3   0   1   2   3  *
       //  5      1   1   0   0   2   1   2   3  *
       //  6      2   2   0   0   1   2   3   1  *
       //  7      3   3   0   0   3   2   3   1  *
       //  check  *   *   *   *   *   *   *   *  OK
       //  NB symmetry, top and bottom half of 8x8 table : 
       //     result does not depend on pc[2] checked

       if (pc[1:0] == 0) begin
           potabx = pa[1:0];
       end
       else begin
           if (pa[2]==0) begin
               if (pa[1:0]==0) begin
                   potabx = pc[1:0];
               end
               else begin
                   if (pc[1]==0) begin 
                       potabx = pa[1:0];
                   end
                   else begin
                       potabx = 2'B00;
                   end
               end
           end
           else begin
               if (pa[1:0]==0) begin
                   if (pc[1]==pc[0]) begin
                       potabx = pc[1:0];
                   end
                   else begin
                       potabx = {pc[0],pc[1]};
                   end
               end
               else begin
                   if (pc[1]) begin
                      //  potabx = 1,2,3 -> 2,3,1
                      if (pa[1]) begin // 2,3
                         potabx = {!pa[0],1'B1};
                      end
                      else begin // 1
                         potabx = 2'B10;
                      end
                   end
                   else begin
                      potabx = pa[1:0];
                   end
               end
           end
       end
       // duty()
    endfunction


    //----------------------------------------------------------------------------------
    function [1:0] gpcombis;              // return values are 0,1 or 2 only
       input [2:0] ep;
       input [1:0] eg;
       if (eg==3) begin
           if (ep[2]==0) gpcombis = 0;
           else          gpcombis = 2;
       end
       else begin 
           if (ep[1:0]==3) begin 
              if (eg==2)        gpcombis = 1;
              else  begin
                  if (ep[2]==1) gpcombis = 0;
                  else          gpcombis = 1;
              end
           end
           else begin
               if  (ep[1:0]==eg) gpcombis = 1;
               else begin
                  if ( ((ep[1:0]==0)&&(eg==1)) || ((ep[1:0]==1)&&(eg==2)) || 
                       ((ep[1:0]==2)&&(eg==0)) || ((ep[1:0]==3)&&(eg==1)) ) begin
                     if (ep[2]==1) gpcombis = 0;
                     else          gpcombis = 2;
                  end   
                  else  gpcombis = 2;
               end
           end
       end
    endfunction   

    //----------------------------------------------------------------------------------
    function [1:0] gpo;  // gpo(ep,eg,po)
       input [2:0] ep;
       input [1:0] eg;
       input [1:0] po;
       if (po==0) gpo = 2;
       else begin
           if       (po==3) gpo = gpcombis({ep[2], !ep[1],  ep[0]}, eg);
           else  if (po==2) gpo = gpcombis({ep[2],  ep[1], !ep[0]}, eg);
           else             gpo = gpcombis(ep, eg);
       end
    endfunction

    // Individual electrode output functions:
    // {"A0","D0","A2","D1","A1","PWR"}  el1 .. el6
    //----------------------------------------------------------------------------------
    function [1:0] el1;  //  = el1(ec2, ep3, po2)        gpo[EP,0,PO];
       input [1:0] ec;
       input [2:0] ep;
       input [1:0] po;
       el1 = gpo(ep,0,po);
    endfunction

    //----------------------------------------------------------------------------------
    function [1:0] el2;  //  = el2(ec2, ep3, po2)  If[EC==0,gpo[EP,3,PO],gpo[EP,2,PO]];
       input [1:0] ec;
       input [2:0] ep;
       input [1:0] po;
       if  (ec==0) el2 = gpo(ep,3,po);
       else        el2 = gpo(ep,2,po);
    endfunction

    //----------------------------------------------------------------------------------
    function [1:0] el3;  //  = el3(ec2, ep3, po2)  If[EC==0, gpo[EP,2,PO],2];
       input [1:0] ec;
       input [2:0] ep;
       input [1:0] po;
       if (ec==0) el3 = gpo(ep,2,po);
       else       el3 = 2;
    endfunction

    //----------------------------------------------------------------------------------
    function [1:0] el4;  //  = el4(ec2, ep3, po2)  If[EC==0,gpo[EP,3,PO], gpo[EP,2,PO]];
       input [1:0] ec;
       input [2:0] ep;
       input [1:0] po;
       if (ec==0) el4 = gpo(ep,3,po);
       else       el4 = gpo(ep,2,po);
    endfunction

    //----------------------------------------------------------------------------------
    function [1:0] el5;  //  = el5(ec2, ep3, po2)  gpo[EP,1,PO];
       input [1:0] ec;
       input [2:0] ep;
       input [1:0] po;
       el5 = gpo(ep,1,po);
    endfunction

    //----------------------------------------------------------------------------------
    function  el6;       //  = el6(ec2, ep3, po2)  If[EC==0,If[gpo[EP,3,PO]==0,1,0],0]; 
                         // Earlier was If[EC==0,If[gpo[EP,3,PO]==0,0,2],2];
       input [1:0] ec;
       input [2:0] ep;
       input [1:0] po;
       if (ec==0) el6 = (gpo(ep,3,po)==0) ? 1:0;  // 1=active
       else       el6 = 0;  // disable
    endfunction

    //----------------------------------------------------------------------------------
    function negat;
       input [1:0] sc;
       input [2:0] pa;
       input [2:0] pc;
       input ne;
       negat = ((pa[1:0]==0) && (sc[0]==1) && (pc[0]==1)) || (ne && !pc[2]);
       // negat = pc[1] && p_ne;
    endfunction

    // po = poduty(sc,   pc,    potabx(sc,   pa,   pc),    popatlen(pa));
    // el = elx(ec, ep, po);
    // paddr  = {p_ec, poduty(p_sc, patterncnt, potabx(p_sc, p_pa, patterncnt),
    //                        popatlen(p_pa)), p_ep};
    
    //----------------------------------------------------------------------------------
        // PC=patterncnt   stepped by TI[phase]*clocks 0..7  PC [Pattern Counter] 0..7
        // PA[phase]       pattern sequence select           PA [PAtterns] 0..7
        // SC[phase]       sequence duty cycle select        SC [Sequence Cycle] 0..3 
        //                                                       const,short,long,full
        // EP[phase]       polarity select                   EP [Electrode Polarity]
        // EC[phase]       group select                      EC [Electrode Collection]
        // NE[phase]       inversion                         NE [Negate Electrode]
        // +-------------+-------------+---------+----+-------------+----+
        // | PC2 PC1 PC0 | PA2 PA1 PA0 | SC1 SC0 | EC | EP2 EP1 EP0 | NE |
        // +-------------+-------------+---------+----+-------------+----+
        // |             |             |         |    |             |    |
        // +-------------+-------------+---------+----+-------------+----+
        //------------------------- -----------------------------------------------------
    //----------------------------------------------------------------------------------
    `define send_a_bit     patterncnt[1]   
    `define send_cmd_prog  patterncnt[0]   
    
    //----------------------------------------------------------------------------------
    function condition;
        input [1:0] ph;
        // the conditions consume lablet space resources, so that options 8-13 and 14-15
        // are options are only if COND16 and LONGCOND are defined
        case (`P_SE(ph))
           1: condition = SENS[0]==1;                        
           2: condition = SENS[1]==1;                        
           3: condition = (SENS[0]==1) && (SENS[1]==1);      
           4: condition = (SENS[0] != SENS[1]);
           5: condition = trigd == 1;                        
           6: condition = (trigd==1)&& (SENS[0]==0);         
           7: condition = (trigd==1)&& (SENS[1]==1);        
           `ifdef COND16                                     
               8   : condition = SENS[0]==0;                            
               9   : condition = SENS[1]==0;                                                 
               10  : condition = comd == 1;                                                  
               11  : condition = comd == 0;                                                  
               12  : condition = 
                       (SENS[0] != (phase[0]? prog[`PP_STO1+0]:prog[`PP_STO0+0]) );
               13  : condition = 
                       (SENS[1] != (phase[0]? prog[`PP_STO1+1]:prog[`PP_STO1+0]) ); 
               `ifdef LONGCOND
                  14  : condition = 
                       (SENS[0] != (phase[0]? prog[`PP_STO1+0]:prog[`PP_STO0+0]) ) || 
                       (SENS[1] != (phase[0]? prog[`PP_STO1+1]:prog[`PP_STO1+0]) ); 
                  15  : condition = (SENS[0]==1) && (SENS[1]==0);
               `endif
           `endif
           default: condition = 0;
        endcase 
    endfunction


    //----------------------------------------------------------------------------------
    always @(posedge CLK) begin
        if (RST) begin                          // reset logic
            `ifdef DSEL
                dsel   <= id[2];                // ID dependence
            `endif
            `ifdef COMT
                comt   <= 0;
            `endif
            `ifdef DOCKED
                docked <= 0;
            `endif
            din2       <= 0;
            din1       <= 0;
            doutact    <= 0;
            commandin  <= 0;
            repeatcnt  <= 0;
            clkdivider <= 0;
            state      <= 0;
            phase      <= 0;
            trigd      <= 0;
            comd       <= 0;
            prog       <= `THE_PROG;
            
            `ifdef __SIMULATE__
                match      <= 0;                // matched received cmd: all
                match_send <= 0;                // matched received cmd: send
                match_run  <= 0;                // matched received cmd: run
                match_prog <= 0;                // matched received cmd: prog
                match_stop <= 0;                // matched received cmd: stop
                match_timeout <= 0;             // timeout for match
                match_in   <= 0;
                sim_wd_reset   <= 0;
                sim_maxpulsecnt <= 0;
                sim_time <= $realtime;
                sim_stodata <= 0;
            `endif
        end //RST
        else begin                              // operation in absence of reset
            //## ALL:  
            clkdivider <= clkdivider + 1;
            `ifdef __SIMULATE__
                sim_stodata <= 0;
            `endif
            if (state != `STATE_SENDING) begin  // then receiving or running or idle
                `ifdef DSEL  // input pad under the control of dsel signal 
                             // (one of two corner pads)
                    din1 <= DIN[dsel];
                `else
                    din1 <= DIN[0];
                `endif
                din2 <= din1;
                if (din2) begin 
                    pulsecnt <= pulsecnt + 1; 
                    `ifdef __SIMULATE__
                        if (pulsecnt > sim_maxpulsecnt) sim_maxpulsecnt <= pulsecnt;
                    `endif
                end 
                else begin 
                    pulsecnt <= 0; 
                end  // count hi time
                //dclk <= din2 & !din1;  // dclk recognizes a falling slope
                if (din2 & !din1) begin
                    if (state == `STATE_PROGRAMMING) begin
                        prog <= prog << 1;   // load program
                        prog[0] <= (pulsecnt>=`PULSETHRESHOLD);
                        repeatcnt <= repeatcnt -1;
                        if (repeatcnt==0) begin
                            state[1:0] <= `STATE_IDLE;
                        end
                    end
                    else begin
                        commandin <= commandin << 1;
                        commandin[0] <= (pulsecnt>=`PULSETHRESHOLD);  
                        // if pulslength >= threshold clks then Hi else Lo
                        `ifdef __SIMULATE__
                            match_in <= (pulsecnt>=`PULSETHRESHOLD);
                        `endif
                        if ({commandin[7:6],commandin[1:0]} == {CmdByte[7:6],CmdByte[1:0]}) begin // cmd-test
                            // valid command received
                            comd <= 1; // merken
                            $display("#         LL recd command:%X", commandin);
                            `ifdef __SIMULATE__
                                match <= 1;                // matched received cmd
                                match_cmd <= commandin;
                                case (commandin[5:2])
                                    `Comd_Sending: begin 
                                        match_send <= 1;                
                                    end
                                    `Comd_Running: begin
                                        match_run <= 1;                
                                    end
                                    `Comd_Program: begin
                                        match_prog <= 1;                
                                    end
                                    `Comd_Stop: begin
                                        match_stop <= 1;                
                                    end
                                endcase
                            `endif
                            // switch state
                            $display("#--------------- matched command ",commandin[5:2]);
                            // $display("#---------------match command");
                            if (state == `STATE_IDLE) begin
                                case (commandin[5:2])
                                    `Comd_Sending: begin 
                                        state[1:0] <= `STATE_SENDING;  // XX= 00:idle  01:progr  10:run  11:send
                                        doutact <= 1;
                                        repeatcnt <= 9; // 9: so that another LO thereafter  //`PROGLEN;
                                        commandin <= `Cmd_Program;  // or testcommcmd?!
                                        pulsecnt <= 0;
                                        `send_a_bit <= 0;     // 0=hi output  1=lo output
                                        `send_cmd_prog <= 0;  // 0=send command 1=send prog/data
                                        phase <= 0;           // so that long telegram and end with Idle
                                    end

                                    `Comd_Running: begin
                                        state[1:0] <= `STATE_RUNNING;  // XX= 00:idle  01:progr  10:run  11:send
                                        phase <= 0;
                                        patterncnt <= 7;
                                        repeatcnt <= 0;
                                        commandin <= 0;
                                    end

                                    `Comd_Program: begin
                                        state[1:0] <= `STATE_PROGRAMMING; // XX= 00:idle  01:progr  10:run  11:send
                                        repeatcnt <= `PROGLEN;
                                        commandin <= 0;
                                    end

                                endcase
                            end // if state

                            case (commandin[5:2]) 
                                `Comd_Stop: begin
                                               state[1:0] <= `STATE_IDLE; // XX= 00:idle  01:progr  10:run  11:send
                                               commandin <= 0;
                                            end
                                `Comd_TrigLo: begin
                                                  trigd <= 0;
                                                  commandin <= 0;
                                            end  
                                `Comd_TrigHi: begin
                                                  trigd <= 1;
                                                  commandin <= 0;
                                            end  
                                `ifdef DSEL
                                    `Comd_Select: begin
                                                  dsel <= !dsel;
                                                  commandin <= 0;
                                                end  
                                `endif                                                
                                `ifdef COMT
                                    `Comd_Comtst: begin
                                                  comt <= 1;
                                                  commandin <= 0;
                                                end  
                                `endif                
                            endcase
                        end // if comm
                    end //state
                    clkdivider[`CLK_TMO1] <= 0;  // timeout reset
                    clkdivider[`CLK_TMO2] <= 0;
                    `ifdef __SIMULATE__
                        sim_wd_reset <= !sim_wd_reset;
                    `endif
                end //din2
                `ifdef __SIMULATE__
                    if (match) begin
                        match <= 0;  
                        match_send <= 0;                
                        match_run <= 0;                
                        match_prog <= 0;                
                        match_stop <= 0;                
                        match_cmd <= 0;
                    end
                `endif
            end // STATE_SENDING


            case (state) // XX= 00:idle  01:progr  10:run  11:send                                               
                `STATE_IDLE: begin
                        actenab <= 5'B00000;  // all Z
                        act[5] <= 0;
                        `ifdef AUTORUN
                            if (clk_timeout) begin
                                state[1:0] <= `STATE_RUNNING;  // XX= 00:idle  01:progr  10:run  11:send
                                phase <= 0;
                                patterncnt <= 7;
                                repeatcnt <= 0;
                                comd <= 0;
                                `ifdef COMT
                                    comt <= 0;
                                `endif
                                `ifdef __SIMULATE__
                                    match_timeout <= 1;
                                    sim_time = ($realtime-sim_time)/1000000;
                                    $display("# timeout after: ", sim_time, " sec");
                                `endif
                            end
                        `endif
                    end

                //----------------------------------------------------------------------------------
                //
                // send command and data/progr
                //
                //----------------------------------------------------------------------------------
                `STATE_SENDING: begin 
                    if (repeatcnt == 0) begin
                        if (`send_cmd_prog==0) begin // command output
                            if (phase != 2'B00) begin
                                doutact <= 0;
                                state[1:0] <= `STATE_RUNNING;  
                            end
                            else begin
                                `send_cmd_prog<= 1; // now sending program
                                repeatcnt <= `PROGLEN;  // and nun program/data
                                pulsecnt <= 0;
                            end
                        end
                        else begin          // prog/data output
                            doutact <= 0;
                            state[1:0] <= `STATE_IDLE;  
                        end
                    end
                    else begin
                        if (pulsecnt == 0) begin  // bit/pulse end, set new bit
                            `ifdef __SIMULATE__
                                match_in <= (`send_cmd_prog==0) ? commandin[7] : prog[`PROGLEN-1];
                                match_send <= 0;                
                                match <= 0;  
                            `endif
                            if (`send_a_bit == 0) begin // bit output (hi pulse)
                                dout <= 1;
                                if ((`send_cmd_prog==0) ? commandin[7] : prog[`PROGLEN-1]) begin 
                                    pulsecnt <= `MAXPULSECNT - `PULSELONG + 1; // long pulse
                                end
                                else begin  // short pulse
                                    pulsecnt <= `MAXPULSECNT - `PULSESHORT + 1;
                                end
                            end
                            else begin // pause output (lo pulse)
                                dout <= 0;
                                // opt. pulse length also long/short --> DC-free
                                `ifdef DATA_DCFREE
                                    // opt. also long pause/low
                                    if ((`send_cmd_prog==0) ? commandin[7] : prog[`PROGLEN-1]) begin 
                                        pulsecnt <= `MAXPULSECNT - `PULSELONG + 1; // long pulse
                                    end
                                    else begin  // short pulse
                                        pulsecnt <= `MAXPULSECNT - `PULSESHORT + 1;
                                    end
                                `else
                                    pulsecnt <= `MAXPULSECNT - `PULSEPAUSE + 1;
                                `endif
                                // prepare next bit
                                if (`send_cmd_prog==0) begin
                                    // send out command
                                    commandin[7:1] <= commandin[6:0];
                                    commandin[0] <= 0;
                                end
                                else begin
                                    // send out program/data
                                    prog[`PROGLEN-1:1] <= prog[`PROGLEN-2:0];
                                    prog[0] <= prog[`PROGLEN-1];
                                end
                                repeatcnt <= repeatcnt - 1;
                            end
                            // next bit
                            `send_a_bit <= !`send_a_bit;
                        end
                        else begin // wait for bit/pulse end
                            pulsecnt <= pulsecnt+1;
                        end
                    end // repeatcnt
                    clkdivider[`CLK_TMO1] <= 0;  // timeout reset
                    clkdivider[`CLK_TMO2] <= 0;
                    `ifdef __SIMULATE__
                        sim_wd_reset <= !sim_wd_reset;
                        match_timeout <= 0;
                        sim_time = $realtime;
                    `endif
                end // STATE_SENDING:

                `STATE_RUNNING: begin
                    if (  ((p_ti==0) && clk_vfast)
                       || ((p_ti==1) && clk_fast)
                       || ((p_ti==2) && clk_slow)
                       || ((p_ti==3) && clk_vslow) ) begin

                        if (patterncnt == 7) begin
                             // end of a 8-step pattern: repeat or start new phase

                             patterncnt <= 0;
                             if (condition(phase)) begin
                                 if (p_ca[1:0] == `CA_RST) begin
                                    phase <= 0; 
                                    state[1:0] <= `STATE_IDLE; 
                                 end
                                 else begin
                                     if (p_ca[1:0] == `CA_PREV) begin
                                        phase <= phase-1;
                                     end
                                     else begin
                                         if (p_ca[1:0] == `CA_NEXT) begin
                                             phase <= phase+1;
                                         end
                                         // no change in phase for remaining value of p_ca[1:0] 
                                         // i.e `CA_NONE [=1], this repeats same phase
                                     end
                                     case (p_rep) // this is global: one value from program, 
                                                  // common to all phases
                                         0: repeatcnt <= 1-1;          
                                         1: repeatcnt <= 4-1;          
                                         2: repeatcnt <= 16-1;         
                                         3: repeatcnt <= 64-1;         
                                     endcase
                                 end
                                 if (p_ca[2]) begin  // program for current phase says SEND on completion
                                     state     <= `STATE_SENDING;  // XX= 00:idle  01:progr  10:run  11:send
                                     doutact   <= 1;
                                     repeatcnt <= 9;       // 9:damit noch ein LO hinterher  //`PROGLEN;
                                     pulsecnt  <= 0;
                                     `send_a_bit    <= 0;  // 0=hi output  1=lo output
                                     `send_cmd_prog <= 0;  // 0=send command 1=send prog/data
                                     // phase != 0;  // so that short telegram and end with RUN
                                     // phase == 0;  // then long telegram and end with IDLE
                                     if (p_ca[1:0]==`CA_RST) begin   // or aimed at next phase==0 
                                         commandin <= `Cmd_Program;  // or testcommcmd  
                                     end
                                     else begin
                                         commandin <= `Cmd_Comtst; 
                                     end
                                 end 
                                 if (p_dat) begin
                                     // ohne:  14752 114 FFs + 206
                                     // mit 1: 14958 114 FFs + 193
                                     // mit 2: 15151 114 FFs
                                     // p_sto0 <= { repeatcnt[5:0], SENS[0], SENS[1] };
                                     `ifdef __SIMULATE__
                                         sim_stodata <= 1;
                                     `endif
                                     if (phase[0]) begin  // this is different from orig. specs: 
                                                          // in phases 1 and 3 store in STO0
                                                          // in phases 0 and 2 store in STO1
                                         prog[`PP_STO0+`PL_STOLEN-1:`PP_STO0] <= { repeatcnt[5:0], SENS[1], SENS[0] };
                                     end
                                     else begin
                                         prog[`PP_STO1+`PL_STOLEN-1:`PP_STO1] <= { repeatcnt[5:0], SENS[1], SENS[0] };
                                     end
                                 end
                             end  // condition

                             else begin
                                 if (repeatcnt != 0) begin
                                    repeatcnt <= repeatcnt - 1;
                                    `ifdef TMO_REPEAT
                                        clkdivider[`CLK_TMO1] <= 0;  // timeout reset
                                        clkdivider[`CLK_TMO2] <= 0;
                                        `ifdef __SIMULATE__
                                            sim_wd_reset <= !sim_wd_reset;
                                            match_timeout <= 0;
                                            sim_time = $realtime;
                                        `endif
                                    `endif
                                 end 
                                 else begin
                                     phase <= phase+1;  // next phase
                                     if ((phase==3)||(phase==2 && p_dat)) begin
                                         state[1:0] <= `STATE_IDLE; 
                                     end
                                     case (p_rep) 
                                         0: repeatcnt <= 1-1;
                                         1: repeatcnt <= 4-1;
                                         2: repeatcnt <= 16-1;
                                         3: repeatcnt <= 64-1;
                                     endcase
                                 end
                             end

                        end
                        else begin
                            patterncnt <= patterncnt + 1;
                            //if (!condition(phase)) begin    // NB no condition during patterncnt loop !
                            //    patterncnt <= 7;            // end prematurely
                            //end
                        end
                        
                        
                        if ((phase==0)) begin //  || (p_po_z) ) begin
                            actenab <= 5'B00000;  // all Z
                            act[5] <= 0;
                        end
                        else begin    
                            // {"A0","D0","A2","D1","A1","PWR"}  el1 .. el6
                            // act0 ... act5 = a0 a1 din a2 dout power
                            //       el <= elx(  ec,   ep, poduty(  sc,pc,   potabx(  pa,pc  ),popatlen(  pa)) );
                            // 
                            {actenab[0], act[0]} <= {1'B0,negat(p_sc,p_pa,patterncnt,p_ne)} ^ 
                                el1(p_ec, p_ep, poduty(p_sc,patterncnt,potabx(p_pa,patterncnt),popatlen(p_pa)) );
                            {actenab[1], act[1]} <= {1'B0,negat(p_sc,p_pa,patterncnt,p_ne)} ^ 
                                el5(p_ec, p_ep, poduty(p_sc,patterncnt,potabx(p_pa,patterncnt),popatlen(p_pa)) );
                            {actenab[2], act[2]} <= {1'B0,negat(p_sc,p_pa,patterncnt,p_ne)} ^ 
                                el2(p_ec, p_ep, poduty(p_sc,patterncnt,potabx(p_pa,patterncnt),popatlen(p_pa)) );
                            {actenab[3], act[3]} <= {1'B0,negat(p_sc,p_pa,patterncnt,p_ne)} ^ 
                                el3(p_ec, p_ep, poduty(p_sc,patterncnt,potabx(p_pa,patterncnt),popatlen(p_pa)) );
                            {actenab[4], act[4]} <= {1'B0,negat(p_sc,p_pa,patterncnt,p_ne)} ^ 
                                el4(p_ec, p_ep, poduty(p_sc,patterncnt,potabx(p_pa,patterncnt),popatlen(p_pa)) );
                            act[5]  <=       negat(p_sc,p_pa,patterncnt,p_ne)? 0:
                                el6(p_ec, p_ep, poduty(p_sc,patterncnt,potabx(p_pa,patterncnt),popatlen(p_pa)) );
                            
                            `ifdef DDINCHAN            // if din/dout inside channels (Lablet3a)
                            `else
                            `endif // DINCHAN
                        end // ((phase==0) || (p_po_z) )
                        
                        `ifdef TMO_RUN
                            clkdivider[`CLK_TMO1] <= 0;  // timeout reset
                            clkdivider[`CLK_TMO2] <= 0;
                            `ifdef __SIMULATE__
                                sim_wd_reset <= !sim_wd_reset;
                                match_timeout <= 0;
                                sim_time = $realtime;
                            `endif
                        `endif
                    end // P_TI
                end // state running

                `STATE_PROGRAMMING: begin   
                    clkdivider[`CLK_TMO1] <= 0;  // timeout reset
                    clkdivider[`CLK_TMO2] <= 0;
                    `ifdef __SIMULATE__
                        sim_wd_reset <= !sim_wd_reset;
                        match_timeout <= 0;
                        sim_time = $realtime;
                    `endif
                end
            endcase

        end // !RST
    end // always   

endmodule

//=========================================================================================================================================================================

