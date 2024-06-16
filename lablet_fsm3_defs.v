/*==================================================================================================

   Lablet state machine defines
   $Id: lablet_fsm3_defs.v,v 1.23 2015/12/20 17:49:10 tmaeke Exp tmaeke $

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
===================================================================================================*/

// GLOBAL SWITCHES: and defaults
//`define WITH_ID
//`define  DEF_ID    3'B001      // default id
`define DEF_ID0
//`define DEF_ID0 ... DEF_ID7
`define COND16   // 4bit f. Condition codes SE (else 3)    15151.7 (114FF) 14489.8 (110FF)  + 662
//`define LONGCOND  // some more conditions inside COND16

// Defines per LL variant:
//`define SYSCLK200   // analoginterface_400hz
//`define SYSCLK20    // analoginterface_40hz
//`define DDINCHAN    // if din/dout inside channels (only Lablet3a)
//`define DATA_BIPO   // datasending is bipolar HL and LH on din0/din1
//`define DATA_DCFREE // then LO pulses are as long as HI pulses on the dataline(s)                     
//`define AUTORUN     // if defined LL start after a timeout (~30sec)
    
//---------------------------------------------------------------------------------------------------
`define STRINGIFY(x) `"x`"
`define BIT_MSK(a)  (a==0 ? 0:((1<<(a))-1))    // a = number of bits

//---------------------------------------------------------------------------------------------------

`define  NGRPS  3

// Lengths
`define  PL_PO     2            // *0

`define  PL_REP    2            // *1
`define  PL_DAT    1            // *1
`define  PL_TIM    1            // *1    // LSB von TI[1:0]

`define  PL_TE     0            // *3
`define  PL_EC     1            // *3
`define  PL_SC     2            // *3
`define  PL_EP     3            // *3
`define  PL_CA     3            // *3
`define  PL_PA     3            // *3
`define  PL_NE     1            // *3
`define  PL_TI     1            // *3     // MSB von TI[1:0]

`ifdef COND16
    `define  PL_SE     4            // *3
`else    
    `define  PL_SE     3            // *3
`endif    

`define  PL_STOLEN (1+1+6)      // Sens0 Sens1 RepeatCnt[5:0]
`define  PL_STO     (`PL_SC +`PL_EP +`PL_TI +`PL_SE +`PL_CA +`PL_TE +`PL_PA)


// bit positions in program string
/* Program bits for lablet: the *3 occurence bits are needed for each phase 1-3
   Name length  occurence comment
   REP  2       *1        repeat: 1,4,16,64
   DAT  1       *1        save sensor data
   TIM  1       *1        timestep*: 1,4,16,64 (LSB of TI[1:0])
   TI   1       *3        (MSB of TI[1:0])
   EC   1       *3        group select
   SC   2       *3        sequence select
   EP   3       *3        polarity select
   CA   3       *3        jump
   PA   3       *3        pattern
   NE   1       *3        inversion
   SE   4       *3        condition 
*/

`define  PP_SC0     0
`define  PP_EC0     (`PP_SC0 +`PL_SC)
`define  PP_EP0     (`PP_EC0 +`PL_EC)
`define  PP_TI0     (`PP_EP0 +`PL_EP)
`define  PP_SE0     (`PP_TI0 +`PL_TI)
`define  PP_CA0     (`PP_SE0 +`PL_SE)
`define  PP_TE0     (`PP_CA0 +`PL_CA)    // not used since length set to zero above
`define  PP_PA0     (`PP_TE0 +`PL_TE)
`define  PP_NE0     (`PP_PA0 +`PL_PA)

`define  PP_SC1     (`PP_NE0 +`PL_NE)
`define  PP_EC1     (`PP_SC1 +`PL_SC)
`define  PP_EP1     (`PP_EC1 +`PL_EC)
`define  PP_TI1     (`PP_EP1 +`PL_EP)
`define  PP_SE1     (`PP_TI1 +`PL_TI)
`define  PP_CA1     (`PP_SE1 +`PL_SE)
`define  PP_TE1     (`PP_CA1 +`PL_CA)    // not used since length set to zero above
`define  PP_PA1     (`PP_TE1 +`PL_TE)
`define  PP_NE1     (`PP_PA1 +`PL_PA)

`define  PP_SC2     (`PP_NE1 +`PL_NE)
`define  PP_EC2     (`PP_SC2 +`PL_SC)
`define  PP_EP2     (`PP_EC2 +`PL_EC)
`define  PP_TI2     (`PP_EP2 +`PL_EP)
`define  PP_SE2     (`PP_TI2 +`PL_TI)
`define  PP_CA2     (`PP_SE2 +`PL_SE)
`define  PP_TE2     (`PP_CA2 +`PL_CA)    // not used since length set to zero above
`define  PP_PA2     (`PP_TE2 +`PL_TE)
`define  PP_NE2     (`PP_PA2 +`PL_PA)

`define  PP_REP     (`PP_NE2 +`PL_NE)
`define  PP_DAT     (`PP_REP +`PL_REP)
//`define  PP_EC      (`PP_DAT +`PL_DAT)
`define  PP_TIM     (`PP_DAT +`PL_DAT)

`define  PROGLEN    (`PP_TIM +`PL_TIM)  // (`PP_DAT +`PL_DAT)   // (`PP_EC  +`PL_EC)

`define  PP_STO0    (`PP_SC2)
`define  PP_STO1    (`PP_SC2+`PL_STOLEN)

// Trigger sensitivity
`define  TRG_OFF 0
`define  TRG_ON  1


// Selectable event clocks  TI
`define CLK_1    0
`define CLK_4    0
`define CLK_16   1
`define CLK_64   1

// Selectable event clocks  TIM
`define CLKM_1    0
`define CLKM_4    1
`define CLKM_16   0
`define CLKM_64   1

// Repeat factors
`define REP_1    0
`define REP_4    1
`define REP_16   2
`define REP_64   3


// EC Actors
`define EC_A0A1A2D 0    // A0  A1   A2 DIN,DOUT
`define EC_DDA2V   1    // DIN DOUT A2 VSupp
`define EC_A0A1A2X 2    // A0  A1   A2 DIN,DOUT
`define EC_DDA2VX  3    // DIN DOUT A2 VSupp


// Sensortest
`define  TS_NO      4'B0000
`define  TS_S0      4'B0001
`define  TS_S1      4'B0010
`define  TS_S0S1    4'B0011
`define  TS_S0NS1   4'B0100
`define  TS_TRG     4'B0101
`define  TS_TRGS0   4'B0110
`define  TS_TRGN    4'B0111
`ifdef COND16
    `define  TS_S1NS0   4'B1000
    `define  TS_9       4'B1001
    `define  TS_10      4'B1010
    `define  TS_11      4'B1011
    `define  TS_12      4'B1100
    `define  TS_13      4'B1101
    `define  TS_14      4'B1110
    `define  TS_15      4'B1111
`endif

// Nextstep   CA[2]=senddata CA[1:0]=jump
`define CA_NEXT 0 
`define CA_SKIP 1
`define CA_NONE 1
`define CA_PREV 2 
`define CA_RST  3 
`define CA_STOP 3 

// SC
`define SC_CONST  0 
`define SC_SHORT  1
`define SC_LONG   2 
`define SC_FULL   3 

`define P_PA(ph)  (phase==2 ? prog[`PP_PA1+`PL_PA-1:`PP_PA1]: \
                  (phase==3 ? prog[`PP_PA2+`PL_PA-1:`PP_PA2]: prog[`PP_PA0+`PL_PA-1:`PP_PA0]))
`define P_NE(ph)  (phase==2 ? prog[`PP_NE1+`PL_NE-1:`PP_NE1]: \
                  (phase==3 ? prog[`PP_NE2+`PL_NE-1:`PP_NE2]: prog[`PP_NE0+`PL_NE-1:`PP_NE0]))
`define P_SC(ph)  (phase==2 ? prog[`PP_SC1+`PL_SC-1:`PP_SC1]: \
                  (phase==3 ? prog[`PP_SC2+`PL_SC-1:`PP_SC2]: prog[`PP_SC0+`PL_SC-1:`PP_SC0]))
`define P_EC(ph)  (phase==2 ? prog[`PP_EC1+`PL_EC-1:`PP_EC1]: \
                  (phase==3 ? prog[`PP_EC2+`PL_EC-1:`PP_EC2]: prog[`PP_EC0+`PL_EC-1:`PP_EC0]))
`define P_EP(ph)  (phase==2 ? prog[`PP_EP1+`PL_EP-1:`PP_EP1]: \
                  (phase==3 ? prog[`PP_EP2+`PL_EP-1:`PP_EP2]: prog[`PP_EP0+`PL_EP-1:`PP_EP0]))
`define P_TI(ph)  (phase==2 ? prog[`PP_TI1+`PL_TI-1:`PP_TI1]: \
                  (phase==3 ? prog[`PP_TI2+`PL_TI-1:`PP_TI2]: prog[`PP_TI0+`PL_TI-1:`PP_TI0]))
`define P_SE(ph)  (phase==2 ? prog[`PP_SE1+`PL_SE-1:`PP_SE1]: \
                  (phase==3 ? prog[`PP_SE2+`PL_SE-1:`PP_SE2]: prog[`PP_SE0+`PL_SE-1:`PP_SE0]))
`define P_CA(ph)  (phase==2 ? prog[`PP_CA1+`PL_CA-1:`PP_CA1]: \
                  (phase==3 ? prog[`PP_CA2+`PL_CA-1:`PP_CA2]: prog[`PP_CA0+`PL_CA-1:`PP_CA0]))


`define P_STO0    prog[`PP_STO0+`PL_STOLEN-1:`PP_STO0]
`define P_STO1    prog[`PP_STO1+`PL_STOLEN-1:`PP_STO1]

//`define P_EC(ph)    prog[`PP_EC+`PL_EC-1:`PP_EC]

`define P_TIM     prog[`PP_TIM+`PL_TIM-1:`PP_TIM]
`define P_DAT     prog[`PP_DAT+`PL_DAT-1:`PP_DAT]
`define P_REP     prog[`PP_REP+`PL_REP-1:`PP_REP]

// `define P_CA(ph)  prog[(ph<<4)+PP_CA0+PL_CA-1:(ph<<4)+PP_CA0]

`define  PROGRAM(sc0,ep0,ti0,se0,ca0,pa0,ne0,ec0, 
                 sc1,ep1,ti1,se1,ca1,pa1,ne1,ec1, 
                 sc2,ep2,ti2,se2,ca2,pa2,ne2,ec2, rep,dat,tim ) ( \
                       (((sc0) &`BIT_MSK(`PL_SC) ) << `PP_SC0)  \
                     | (((ep0) &`BIT_MSK(`PL_EP) ) << `PP_EP0)  \
                     | (((ti0) &`BIT_MSK(`PL_TI) ) << `PP_TI0)  \
                     | (((se0) &`BIT_MSK(`PL_SE) ) << `PP_SE0)  \
                     | (((ca0) &`BIT_MSK(`PL_CA) ) << `PP_CA0)  \
                     | (((pa0) &`BIT_MSK(`PL_PA) ) << `PP_PA0)  \
                     | (((ne0) &`BIT_MSK(`PL_NE) ) << `PP_NE0)  \
                     | (((sc1) &`BIT_MSK(`PL_SC) ) << `PP_SC1)  \
                     | (((ep1) &`BIT_MSK(`PL_EP) ) << `PP_EP1)  \
                     | (((ti1) &`BIT_MSK(`PL_TI) ) << `PP_TI1)  \
                     | (((se1) &`BIT_MSK(`PL_SE) ) << `PP_SE1)  \
                     | (((ca1) &`BIT_MSK(`PL_CA) ) << `PP_CA1)  \
                     | (((pa1) &`BIT_MSK(`PL_PA) ) << `PP_PA1)  \
                     | (((ne1) &`BIT_MSK(`PL_NE) ) << `PP_NE1)  \
                     | (((sc2) &`BIT_MSK(`PL_SC) ) << `PP_SC2)  \
                     | (((ep2) &`BIT_MSK(`PL_EP) ) << `PP_EP2)  \
                     | (((ti2) &`BIT_MSK(`PL_TI) ) << `PP_TI2)  \
                     | (((se2) &`BIT_MSK(`PL_SE) ) << `PP_SE2)  \
                     | (((ca2) &`BIT_MSK(`PL_CA) ) << `PP_CA2)  \
                     | (((pa2) &`BIT_MSK(`PL_PA) ) << `PP_PA2)  \
                     | (((ne2) &`BIT_MSK(`PL_NE) ) << `PP_NE2)  \
                     | (((rep) &`BIT_MSK(`PL_REP)) << `PP_REP)  \
                     | (((ec0) &`BIT_MSK(`PL_EC) ) << `PP_EC0)  \
                     | (((ec1) &`BIT_MSK(`PL_EC) ) << `PP_EC1)  \
                     | (((ec2) &`BIT_MSK(`PL_EC) ) << `PP_EC2)  \
                     | (((tim) &`BIT_MSK(`PL_TIM)) << `PP_TIM)  \
                     | (((dat) &`BIT_MSK(`PL_DAT)) << `PP_DAT)  )

`define  DISASM_CODE(p) \
              integer sc0;  integer ec0;  integer ec1;  integer ec2;  integer ep0; \
              integer ti0;  integer se0;  integer ca0; \
              integer sc1;  integer ep1;  integer ti1;  integer se1;  integer ca1; \
              integer sc2;  integer ep2;  integer ti2;  integer se2;  integer ca2; \
              integer rep;  integer dat;  integer tim; \
              integer pa0;  integer pa1;  integer pa2; \
              integer ne0;  integer ne1;  integer ne2; \
              begin \
                  sc0 =  ( ((p) >> `PP_SC0)  & `BIT_MSK(`PL_SC)   ); \
                  ep0 =  ( ((p) >> `PP_EP0)  & `BIT_MSK(`PL_EP)   ); \
                  ti0 =  ( ((p) >> `PP_TI0)  & `BIT_MSK(`PL_TI)   ); \
                  se0 =  ( ((p) >> `PP_SE0)  & `BIT_MSK(`PL_SE)   ); \
                  ca0 =  ( ((p) >> `PP_CA0)  & `BIT_MSK(`PL_CA)   ); \
                  pa0 =  ( ((p) >> `PP_PA0)  & `BIT_MSK(`PL_PA)   ); \
                  ne0 =  ( ((p) >> `PP_NE0)  & `BIT_MSK(`PL_NE)   ); \
                  sc1 =  ( ((p) >> `PP_SC1)  & `BIT_MSK(`PL_SC)   ); \
                  ep1 =  ( ((p) >> `PP_EP1)  & `BIT_MSK(`PL_EP)   ); \
                  ti1 =  ( ((p) >> `PP_TI1)  & `BIT_MSK(`PL_TI)   ); \
                  se1 =  ( ((p) >> `PP_SE1)  & `BIT_MSK(`PL_SE)   ); \
                  ca1 =  ( ((p) >> `PP_CA1)  & `BIT_MSK(`PL_CA)   ); \
                  pa1 =  ( ((p) >> `PP_PA1)  & `BIT_MSK(`PL_PA)   ); \
                  ne1 =  ( ((p) >> `PP_NE1)  & `BIT_MSK(`PL_NE)   ); \
                  sc2 =  ( ((p) >> `PP_SC2)  & `BIT_MSK(`PL_SC)   ); \
                  ep2 =  ( ((p) >> `PP_EP2)  & `BIT_MSK(`PL_EP)   ); \
                  ti2 =  ( ((p) >> `PP_TI2)  & `BIT_MSK(`PL_TI)   ); \
                  se2 =  ( ((p) >> `PP_SE2)  & `BIT_MSK(`PL_SE)   ); \
                  ca2 =  ( ((p) >> `PP_CA2)  & `BIT_MSK(`PL_CA)   ); \
                  pa2 =  ( ((p) >> `PP_PA2)  & `BIT_MSK(`PL_PA)   ); \
                  ne2 =  ( ((p) >> `PP_NE2)  & `BIT_MSK(`PL_NE)   ); \
                  rep =  ( ((p) >> `PP_REP)  & `BIT_MSK(`PL_REP)  ); \
                  tim =  ( ((p) >> `PP_TIM)  & `BIT_MSK(`PL_TIM)  ); \
                  dat =  ( ((p) >> `PP_DAT)  & `BIT_MSK(`PL_DAT)  ); \
                  ec0 =  ( ((p) >> `PP_EC0)  & `BIT_MSK(`PL_EC)   ); \
                  ec1 =  ( ((p) >> `PP_EC1)  & `BIT_MSK(`PL_EC)   ); \
                  ec2 =  ( ((p) >> `PP_EC2)  & `BIT_MSK(`PL_EC)   ); \
                  $display("#          ph1: SC:%3d  EP:%3d  TI:%2d*  SE:%3d  CA:%3d  PA:%3d  NE:%3d  EC:%3d",\
                           sc0,ep0,1<<(ti0*2),se0,ca0,pa0,ne0,ec0);\
                  $display("#          ph2: SC:%3d  EP:%3d  TI:%2d*  SE:%3d  CA:%3d  PA:%3d  NE:%3d  EC:%3d",\
                           sc1,ep1,1<<(ti1*2),se1,ca1,pa1,ne1,ec1);\
                  $display("#          ph3: SC:%3d  EP:%3d  TI:%2d*  SE:%3d  CA:%3d  PA:%3d  NE:%3d  EC:%3d",\
                           sc2,ep2,1<<(ti2*2),se2,ca2,pa2,ne2,ec2);\
                  $display("#          repeat %2d*     datactrl: %2d    tim: %1d", 1<<(rep*2), dat, tim); \
              end

//---------------------------------------------------------------------------------------------------
// default programm   

                          // SC      EP  TI       SE         CA       PA NE EC  REPEAT D    
// some test programs        1       3     4       5         6        7       
`define DEF_PROG `PROGRAM(`SC_SHORT ,7 ,`CLK_4  ,`TS_S0NS1 ,`CA_NEXT ,7 ,0,0,\
                          `SC_LONG  ,3 ,`CLK_4  ,`TS_S0S1  ,`CA_NEXT ,3 ,1,0,\
                          `SC_FULL  ,2 ,`CLK_64 ,`TS_NO    ,`CA_NEXT ,2 ,1,1, 3,     0, 0)

`define PROG_01  `PROGRAM(`SC_SHORT ,3 ,`CLK_1  ,`TS_S1    ,`CA_NEXT ,3 ,0,0,\
                          `SC_LONG  ,2 ,`CLK_4  ,`TS_NO    ,`CA_NEXT ,2 ,1,0,\
                          `SC_FULL  ,7 ,`CLK_4  ,`TS_NO    ,`CA_NEXT ,7 ,1,1, 2,     1, 0)

`define PROG_02  `PROGRAM(`SC_SHORT ,2 ,`CLK_1  ,`TS_S0    ,`CA_NEXT ,2 ,0,0,\
                          `SC_LONG  ,3 ,`CLK_4  ,`TS_NO    ,`CA_NEXT ,3 ,0,1,\
                          `SC_FULL  ,3 ,`CLK_64 ,`TS_NO    ,`CA_NONE ,3 ,1,1, 1,     2, 1)

`define PROG_03  `PROGRAM(`SC_CONST ,3 ,`CLK_1  ,`TS_TRG   ,`CA_NEXT ,3 ,0,0,\
                          `SC_SHORT ,7 ,`CLK_4  ,`TS_NO    ,`CA_NEXT ,7 ,0,1,\
                          `SC_SHORT ,7 ,`CLK_1  ,`TS_NO    ,`CA_RST  ,7 ,1,1, 1,     3, 1)

`define PROG_04  `PROGRAM(`SC_SHORT ,3 ,`CLK_1  ,`TS_NO    ,`CA_NEXT ,3 ,0,0,\
                          `SC_LONG  ,0 ,`CLK_1  ,`TS_NO    ,`CA_NEXT ,7 ,1,0,\
                          `SC_CONST ,0 ,`CLK_1  ,`TS_NO    ,`CA_RST  ,7 ,1,1, 1,     3, 0)

`define  WITH_RESET

`define  Noofactors   4
`define  Noofsensors  3


`define  PULSETHRESHOLD  9   // number of clock to determine btw. Hi and Lo
`define  PULSELONG 16        // no of clks for Hi pulse
`define  PULSESHORT 3        // no of clks for Lo pulse
`define  PULSEPAUSE 7        // no of clks btw. pulses

`define  PULSETHRESHOLD  4   // number of clock to determine btw. Hi and Lo
`define  PULSELONG  7        // no of clks for Hi pulse
`define  PULSESHORT 2        // no of clks for Lo pulse
`define  PULSEPAUSE 2        // no of clks btw. pulses

//                     11XXXX11   XXXX = command
`define  COMMAND    8'B11000011     // C3
//                     11XXXX11
`define  Comd_TrigLo  4'B0000       // C3   Clr Trigger
`define  Comd_Running 4'B0001       // C7   Re/Start program
`define  Comd_Program 4'B0010       // CB   Program follows
`define  Comd_Sending 4'B0011       // CF   Transmit program/state
`define  Comd_Stop    4'B0100       // D3   Stop, goto idle mode
`define  Comd_Select  4'B0101       // D7   Id follows ?!?  sets internal select-bit
`define  Comd_Dedock  4'B0110       // DB
`define  Comd_TrigHi  4'B0111       // DF   set Trigger
`define  Comd_Comtst  4'B1000       // E3

`define  Cmd_Stop     (`COMMAND+(`Comd_Stop   <<2))   
`define  Cmd_Program  (`COMMAND+(`Comd_Program<<2))
`define  Cmd_Running  (`COMMAND+(`Comd_Running<<2))
`define  Cmd_Sending  (`COMMAND+(`Comd_Sending<<2))
`define  Cmd_TrigLo   (`COMMAND+(`Comd_TrigLo <<2))
`define  Cmd_TrigHi   (`COMMAND+(`Comd_TrigHi <<2))
`define  Cmd_Select   (`COMMAND+(`Comd_Select <<2))
`define  Cmd_Dedock   (`COMMAND+(`Comd_Dedock <<2))
`define  Cmd_Comtst   (`COMMAND+(`Comd_Comtst <<2))



// XX= 00:idle  01:progr  10:run  11:send
`define  Cmd_Alt      8'B00001000
 
`define  SHOW_CMDS \
      $display("#          Cmd_Stop     0x%2X  = 11 - 0x%1X - 11", `Cmd_Stop,     `Comd_Stop   );\
      $display("#          Cmd_Program  0x%2X  = 11 - 0x%1X - 11", `Cmd_Program,  `Comd_Program);\
      $display("#          Cmd_Running  0x%2X  = 11 - 0x%1X - 11", `Cmd_Running,  `Comd_Running);\
      $display("#          Cmd_Sending  0x%2X  = 11 - 0x%1X - 11", `Cmd_Sending,  `Comd_Sending);\
      $display("#          Cmd_TrigLo   0x%2X  = 11 - 0x%1X - 11", `Cmd_TrigLo,   `Comd_TrigLo );\
      $display("#          Cmd_TrigHi   0x%2X  = 11 - 0x%1X - 11", `Cmd_TrigHi,   `Comd_TrigHi );\
      $display("#          Cmd_Select   0x%2X  = 11 - 0x%1X - 11", `Cmd_Select,   `Comd_Select );\
      $display("#          Cmd_Dedock   0x%2X  = 11 - 0x%1X - 11", `Cmd_Dedock,   `Comd_Dedock );\
      $display("#          Cmd_Comtst   0x%2X  = 11 - 0x%1X - 11", `Cmd_Comtst,   `Comd_Comtst );\


`define STATE_IDLE        0     // receiving
`define STATE_PROGRAMMING 1
`define STATE_RUNNING     2     // receiving
`define STATE_SENDING     3

//===================================================================================================
/*
    Combinations:
    
      FSM 0..3
          - BipolarSending (DOUT0 and !DOUT1)
          - DCfreeSending  (low pulse same length as high pulse)
          - Fast/slower/slow sending   5/9/16 clock for high pulse  
            (id3 2.4s/id2 3.7s/id0 6.3s transfer Cmd+Progr.@200Hz)
          - ID 0..2             din/dout select initially = ID2
          - Din/Dout inside or outside channels coding of actors (inside only for Electrodes 3a)
          
      Analog
          - 20Hz
          - 200Hz
      
      Electrode: 
          - 1a    Long T, Din/Dout outside
          - 1b      "                       switched: Dout/Sup1 
          - 2a    Short T, Din/Dout outside
          - 2b      "                       switched: Dout/Sup1
          - 3a    Long T, Din/Dout inside
    

    +---------+---------+------+------+---------+-------+--------+--------------+               
    | Lablet: | . . . . . . . .FSM. . . . . . . . . . . | Analog | Electrodes   |
    |         | Uni-    | DC   | Fast | Inside  |  ID   | 20Hz   |              |
    |         | bipolar | free | Slow | Outside |       | 200Hz  | 1a,b 2a,b 3a |
    +---------+---------+------+------+---------+-------+--------+--------------+               
    |   n     |  0/1    | 0/1  | 0/1  |   0/1   | 0..7  |  0/1   |  0..4        |
    |         |         |      |      |         |       |        |              |
    +---------+---------+------+------+---------+-------+--------+--------------+               


*/
 `ifdef DEF_ID0  //----------------------------------------------------------------------------------
     `define SYSCLK200   
     `undef  SYSCLK20
     `define DEF_ID          3'B000
     `define WITH_ID
     `define THE_PROG        `PROG_02
     `define AUTORUN
     `define DDINCHAN            // if din/dout inside channels (Lablet3a)
     `define DATA_BIPO           // datasending is bipolar HL and LH on din0/din1
     `undef  DATA_DCFREE         // then LO pulses are as long as HI pulses on the dataline(s)                     
     `define PULSECNTBITS    5   // bits for pulse length counter
     `define PULSETHRESHOLD  4   // number of clock to determine btw. Hi and Lo
     `define PULSELONG       7   // no of clks for Hi pulse
     `define PULSESHORT      2   // no of clks for Lo pulse
     `define PULSEPAUSE      3   // no of clks btw. pulses if not DCFREE

     `define TOPFN           "fsm3_id0.v"
     `define TOPFNY          "fsm3_id0_y.v"
     `define TOPFNF          "f_fsm3_id0.v"
     `define mod_lablet      fsm3_id0_lablet
     `define mod_ll_statem   fsm3_id0_lablet_sm
 `endif
 `ifdef DEF_ID1  //---------------------------------------------------------------------------------- 
     `define SYSCLK200   
     `undef  SYSCLK20
     `define DEF_ID          3'B001
     `define WITH_ID
     `define THE_PROG        `PROG_02
     `define AUTORUN
     `define DDINCHAN            // if din/dout inside channels (Lablet3a)
     `define DATA_BIPO           // datasending is bipolar HL and LH on din0/din1
     `define DATA_DCFREE         // then LO pulses are as long as HI pulses on the dataline(s)                     
     `define PULSECNTBITS    5   // bits for pulse length counter
     `define PULSETHRESHOLD  9   // number of clock to determine btw. Hi and Lo 
     `define PULSELONG       16  // no of clks for Hi pulse
     `define PULSESHORT      2   // no of clks for Lo pulse
     `define PULSEPAUSE      7   // no of clks btw. pulses if not DCFREE

     `define TOPFN           "fsm3_id1.v"
     `define TOPFNY          "fsm3_id1_y.v"
     `define TOPFNF          "f_fsm3_id1.v"
     `define mod_lablet      fsm3_id1_lablet
     `define mod_ll_statem   fsm3_id1_lablet_sm
 `endif
 `ifdef DEF_ID2  //---------------------------------------------------------------------------------- 
     `define SYSCLK200   
     `undef  SYSCLK20
     `define DEF_ID          3'B010
     `define WITH_ID
     `define THE_PROG        `DEF_PROG
     `define LONGCOND
     `undef  AUTORUN
     `undef  DDINCHAN            // if din/dout inside channels (Lablet3a)
     `undef  DATA_BIPO           // datasending is bipolar HL and LH on din0/din1
     `undef  DATA_DCFREE         // then LO pulses are as long as HI pulses on the dataline(s)                     
     `define PULSECNTBITS    5   // bits for pulse length counter
     `define PULSETHRESHOLD  9   // number of clock to determine btw. Hi and Lo
     `define PULSELONG       16  // no of clks for Hi pulse
     `define PULSESHORT      3   // no of clks for Lo pulse
     `define PULSEPAUSE      7   // no of clks btw. pulses if not DCFREE

     `define TOPFN           "fsm3_id2.v"
     `define TOPFNY          "fsm3_id2_y.v"
     `define TOPFNF          "f_fsm3_id2.v"
     `define mod_lablet      fsm3_id2_lablet
     `define mod_ll_statem   fsm3_id2_lablet_sm
 `endif
 `ifdef DEF_ID3  //----------------------------------------------------------------------------------
     `define SYSCLK200   
     `undef  SYSCLK20
     `define DEF_ID          3'B011
     `define WITH_ID
     `define THE_PROG        `PROG_03
     `define AUTORUN
     `undef  DDINCHAN            // if din/dout inside channels (Lablet3a)
     `define DATA_BIPO           // datasending is bipolar HL and LH on din0/din1   
     `define DATA_DCFREE         // then LO pulses are as long as HI pulses on the dataline(s)  
     `define PULSECNTBITS    4   // bits for pulse length counter                             
     `define PULSETHRESHOLD  3   // number of clock to determine btw. Hi and Lo
     `define PULSELONG       5   // no of clks for Hi pulse
     `define PULSESHORT      2   // no of clks for Lo pulse
     `define PULSEPAUSE      1   // no of clks btw. pulses if not DCFREE

     `define TOPFN           "fsm3_id3.v"
     `define TOPFNY          "fsm3_id3_y.v"
     `define TOPFNF          "f_fsm3_id3.v"
     `define mod_lablet      fsm3_id3_lablet
     `define mod_ll_statem   fsm3_id3_lablet_sm
 `endif
 `ifdef DEF_ID4  //----------------------------------------------------------------------------------
      // slow clocked LL
     `undef  SYSCLK200
     `define SYSCLK20
     `define DEF_ID          3'B100
     `define WITH_ID
     `define THE_PROG        `PROG_04
     `define AUTORUN
     `define LONGCOND
     `undef  DDINCHAN            // if din/dout inside channels (Lablet3a)
     `define DATA_BIPO           // datasending is bipolar HL and LH on din0/din1
     `define DATA_DCFREE         // then LO pulses are as long as HI pulses on the dataline(s)                     
     `define PULSECNTBITS    5   // bits for pulse length counter
     `define PULSETHRESHOLD  3   // number of clock to determine btw. Hi and Lo
     `define PULSELONG       5   // no of clks for Hi pulse
     `define PULSESHORT      2   // no of clks for Lo pulse
     `define PULSEPAUSE      1   // no of clks btw. pulses if not DCFREE

     `define TOPFN           "fsm3_id4.v"
     `define TOPFNY          "fsm3_id4_y.v"
     `define TOPFNF          "f_fsm3_id4.v"
     `define mod_lablet      fsm3_id4_lablet
     `define mod_ll_statem   fsm3_id4_lablet_sm
 `endif

// derived defines: ----------------------------------------------------------------------------------

`ifdef  SYSCLK200
    `define SYSCLK 200
`else
    `define SYSCLK 20    
`endif

`define  MAXPULSECNT (1<<`PULSECNTBITS)

//====================================================================================================
