/*=========================================================

   Lablet state machine test bench
   $Id: lablet_fsm3_tb.v,v 1.23 2015/12/20 15:20:25 tmaeke Exp tmaeke $

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
 
=========================================================================================*/

//  compile and run:  choose x in [0,1,2,3,4] for one of 5 lablet alternatives 
//  iverilog -DDEF_IDx -s lablet_testb lablet_fsm3_tb.v && ./a.out && gtkwave ll.vcd fsm.gtkw
//  the variants x and other options are defined in the include file lablet_fsm3_defs.v 
//
//   hierarchy:
//       lablet_testb                           Test bench module (this file)
//           mod_lablet: lablet                 Clock generation, Data/Clk recovery
//               mod_ll_statem: state_mach      State machine


`timescale 1us/1us

`define __SIMULATE__

// already includes "lablet_fsm3_defs.v"
`include "lablet_fsm3.v"       


`define DBG_SEND 1          // extra $display in sendtasks
`define SENDDEF 1'B0        // din0/1 stays active as output (or 1`Bz)

//========================================================================================
module lablet_testb ();
   integer tb_step;
   integer tb_substep;
   integer cfac;            // clock step
   integer cfac2;           // clock2 step for sending
   integer tb_clkcnt;
   integer debug;
   integer tmp_i, tmp_j, tmp_k, tmp_m, tmp_n, tmp_o, tmp_p;
   
   reg tb_clk;
   reg tb_clk2;
   reg tb_RST;
   reg [10:0] tb_timer;
   reg [`PROGLEN-1:0] dummyprog;

   wire act0;
   wire act1;
   wire act2;
   wire act3;
   wire act4;
   wire act5;

   reg [1:0] tb_sens;

   reg dselect;             // 0:  din0 is din,  act2 is dout,    1: din1 is din, act4 is dout
   wire tb_din1;
   wire tb_din0;
   reg  tb_din0alt;         // in case din0 is universal input
   reg  tb_din1alt;         // in case din1 is universal input
   reg  sendbit, tb_sending, tb_receiving;
   wire tb_dout;
   reg [1:0] tb_rec_state;
   
   reg tb_dout2, tb_dclk, tb_dout1;
   reg [`PULSECNTBITS-1:0] tb_doutc;
   reg [`PROGLEN-1:0] tb_rec_reg;
   reg [7:0] tb_rec_cnt;
   reg [`PROGLEN-1:0] tb_send_prog;
   reg [`PROGLEN-1:0] tb_rec_prog;
   reg [8*8-1:0] tb_rec_cmd;

   reg [4*8-1:0] tb_state;       

   //----------------------------------------------------------------------------------------------       
   //assign tb_dout = !dselect ? act4 : act2;
   assign tb_din0 = !dselect ? (tb_sending ? sendbit : 1'bz): 1'bz;  //tb_din0alt;
   assign tb_din1 =  dselect ? (tb_sending ? sendbit : 1'bz): 1'bz;  //tb_din1alt;
   assign tb_dout =  dselect ? act2 : act4;


   //----------------------------------------------------------------------------------------------       
   `mod_lablet lablet(tb_clk,    // I: internal clk ca. 1kHz
                     tb_RST,     // I:
                     tb_sens[0], // I       
                     tb_sens[1], // I       
                     tb_din1,    // I    DIN1 
                     tb_din0,    // I    DIN0 
                     act0,       // O    Actor0 
                     act1,       // O    ACTOR1 
                     act2,       // IO   ACTOR and DIN0 or DOUT0
                     act3,       // O    ACTOR3                 
                     act4,       // OI   Actor and DIN1 or DOUT1
                     act5);      // O    Supply to GND          

   //task ev;
   //    input [7:0] num;
       // repeat (num) begin  #1; events = 1;  #1; events = 0;  end
   //endtask

   task astep; //----------------------------------------------------------------------------------
       input [15:0] tststep;
       begin
           tb_step = tststep;
           $display("");
           $display("#===========================================================================");
           $display("#%10d======================== %1d ==========================", $time, tb_step);
           //legend();
           //tb_step = tb_step+1;
       end
   endtask     

   task disasm; //---------------------------------------------------------------------------------
       input [`PROGLEN-1:0] p;
       `DISASM_CODE(p)
   endtask

   task wait_idle; //------------------------------------------------------------------------------
       // wait until state machine goes into idle mode
       begin
          while ( lablet.state_mach.state != 0 ) begin 
              #(cfac*10); 
          end
       end
   endtask     

      
   task sendonebit; //-----------------------------------------------------------------------------
       input sendonebitval;
       begin
           sendbit = 1;   
           #(cfac2*(sendonebitval ? `PULSELONG:`PULSESHORT)); // Hi -> longpulse, Lo -> short pulse
           sendbit = 0;   
           `ifdef DATA_DCFREE
               #(cfac2*(sendonebitval ? `PULSELONG:`PULSESHORT));
           `else
               #(cfac2*`PULSEPAUSE); 
           `endif
       end
   endtask    

   task sendcmd; // MSB first //-------------------------------------------------------------------
       input [7:0] sendcmdval;
       integer i;
       begin
           tb_sending = 1;
           if (debug & `DBG_SEND) begin
               $display("#--------sendcmd:  ---start %2X       (step %4d)", sendcmdval, tb_step);
           end
           sendonebit(0);
           sendonebit(0);
           sendonebit(0);
           sendonebit(0);
           sendonebit(0);
           sendonebit(0);
           sendonebit(0);
           sendonebit(0);
           for(i = 7; i >= 0; i = i-1) sendonebit(sendcmdval[i]);
           sendonebit(0);
           //$display("#--------end %X", sendcmdval);
           tb_sending = `SENDDEF;
           #(cfac*5);
           // tb_sens = tb_sens+1;
           if (debug & `DBG_SEND) $display("#--------sendcmd:  ---end");
       end
   endtask    

   task sendprog; // MSB first //------------------------------------------------------------------
       input [`PROGLEN-1:0] sendprogval;
       integer i;
       begin
           tb_sending = 1;
           tb_send_prog = sendprogval;
           if (debug & `DBG_SEND) begin
                $display("#--------sendprog: ---start %X   (step %4d)", sendprogval, tb_step);
           end
           disasm(sendprogval);
           sendonebit(0);
           for(i = `PROGLEN-1; i >= 0; i = i-1) sendonebit(sendprogval[i]); // MSB first
           sendonebit(0);
           sendonebit(0);
           sendonebit(0);
           //$display("#--------end %X", sendprogval);
           tb_sending = `SENDDEF;
           #(cfac*10);
           //$display("#--------sendprog: ---end   %X ---> %s ", lablet.core.state_mach.prog,
           // (lablet.core.state_mach.prog == sendprogval) ? "ok!":"transmission error!");
       end
   endtask    


   task waitbusy; //-------------------------------------------------------------------------------
       integer i;
       begin
           i = 0;
           $display("#--------wait busy");
           `ifdef COMPILEDALL
               `ifdef FROM_DV
                   #(cfac*1000);
               `else
                   while ( //( lablet.core.state_mach.state[1] 
                           //| lablet.core.state_mach.state[0]) 
                         //& 
                         (i<10000) ) 
                   begin 
                       #(cfac*10); 
                       i=i+1; 
                   end
               `endif
           `else
               while (//(lablet.core.state_mach.state != 0) 
                     //& 
                     (i<10000) )
               begin 
                   #(cfac*10); 
                   i=i+1;
               end
           `endif
           #1000;
       end
   endtask    

   task test_sender; //----------------------------------------------------------------------------
       input [15:0] tststep;
       integer j;
       begin
           tb_step = tststep;
           // Send with different frequencies  // Cmd Send  CF
           //   `define  PULSETHRESHOLD  4   // number of clock to determine btw. Hi and Lo
           //   `define  PULSELONG  7        // no of clks for Hi pulse
           //   `define  PULSESHORT 2        // no of clks for Lo pulse
           //   `define  PULSEPAUSE 2        // no of clks btw. pulses
           // tb_substep = cfac2:
           // 33 first sporadic cmd
           // 36 first cmd recognized
           // 105 last cmd recognized
           // 111 last sporadic cmd
           // 119 last wrong runcmd match
           // 124 last match
           j = 2;           
           repeat (115) begin
               cfac2 =  j;       
               tb_substep =j;  
               sendcmd(`Cmd_Sending);       
               #(cfac*50);

               cfac2 =  j;       
               tb_substep =j;  
               sendcmd(`Cmd_Running);       
               #(cfac*50);

               j = j+1;
           end
           cfac2 = 2*cfac;
       end
   endtask

   always begin //---------------------------------------------------------------------------------
       #cfac  tb_clk = ~tb_clk; // Toggle clock every tick
       tb_clkcnt = tb_clkcnt+1;
   end
                             
   always begin //---------------------------------------------------------------------------------
       #(cfac2/2)  tb_clk2 = ~tb_clk2; // Toggle clock every tick
   end
                             
   always @(posedge tb_clk) begin //---------------------------------------------------------------
        tb_dout2 <= tb_dout;
        if (tb_dout) begin tb_doutc <= tb_doutc + 1; end else begin tb_doutc <= 0; end
        tb_dclk <= tb_dout2 & !tb_dout;
        tb_dout1 <= (tb_doutc>=`PULSETHRESHOLD) & tb_dout2 & !tb_dout;
        
        case (lablet.state_mach.state) 
            `STATE_IDLE        : tb_state = "IDLE";
            `STATE_PROGRAMMING : tb_state = "PROG";
            `STATE_RUNNING     : tb_state = "RUN";
            `STATE_SENDING     : tb_state = "SEND";
        endcase  
   end
   
   always @(posedge tb_dclk) begin //--------------------------------------------------------------
       tb_rec_reg <= tb_rec_reg << 1;
       tb_rec_reg[0] <= tb_dout1;
       tb_rec_cnt <= tb_rec_cnt +1;
       tb_receiving <= 1;
       
       case (tb_rec_state)
         0: begin 
               if ({tb_rec_reg[7:6],tb_rec_reg[1:0]} == 4'B1111) begin
                   tb_rec_cmd = "unknown";
                   if (tb_rec_reg[5:2] == `Comd_Program) begin
                       tb_rec_state <= 1;
                       tb_rec_cmd = "Program";
                   end
                   if (tb_rec_reg[5:2] == `Comd_Comtst) begin
                       tb_rec_state <= 2;
                       tb_rec_cmd = "Comtst";
                   end
                   tb_receiving <= 0;
                   // tb_rec_cmd = tb_rec_reg[7:0];
               end
            end
         1: begin   // rec program
                if (tb_rec_cnt >= 67) begin
                   tb_rec_state <= 0;
                   tb_rec_cnt <= 0;
                   tb_rec_prog = tb_rec_reg;
                   tb_receiving <= 0;
                end
            end  // program comes
         2: begin  // rec command
                tb_rec_state <= 0;
                tb_receiving <= 0;
            end
       endcase  
   end
   
   always @(posedge tb_clk) begin //---------------------------------------------------------------
       tb_timer <= tb_timer +1;
       if (tb_timer == 0) begin
           tb_sens <= tb_sens +1;
       end
   end

   task test_pulswidth; //-------------------------------------------------------------------------
       input [15:0] tststep;
       begin
           astep(tststep);
           // Test H/L recognition, variable pulslength
           #(cfac*30);
    //      waitbusy();
           tb_sending = 1;
           sendbit = 1;   #(cfac*1);        sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*2);        sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*3);        sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*4);        sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*5);        sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*6);        sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*7);        sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*8);        sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*9);        sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*10);       sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*11);       sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*12);       sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*13);       sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*14);       sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*15);       sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*16);       sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*17);       sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*18);       sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*19);       sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*20);       sendbit = 0;   #(cfac*6); 
           sendbit = 1;   #(cfac*1);        sendbit = 0;   #(cfac*6); 
    //       tb_sending = 0;
           #(cfac*30);
           //sense2act(0);
       end
   endtask     


   task test_send_cmd; //--------------------------------------------------------------------------
       input [15:0] tststep;
       input [7:0] cmd;
       input [319:0] txt;
       begin
           if (tststep != 0) astep(tststep);
           $display("# SendCmd:%X   %s", cmd, txt);
           wait_idle();
           sendcmd(cmd); 
           #(cfac*10);
       end
   endtask     
   
   task test_send_cmd_nowait; //-------------------------------------------------------------------
       input [15:0] tststep;
       input [7:0] cmd;
       input [319:0] txt;
       begin
           if (tststep != 0) astep(tststep);
           $display("# SendCmd:%X   %s", cmd, txt);
           sendcmd(cmd); 
           #(cfac*10);
       end
   endtask     
   

   
   task test_download_to_LL; //--------------------------------------------------------------------
       input [15:0] tststep;
       input [`PROGLEN-1:0] tst_progprog;
       input [319:0] txt;
       begin
           // Send programm command and program down to lablet
           astep(tststep);
           $display("# download %s", txt);
           test_send_cmd(0,`Cmd_Program, "init download");    // Cmd Prog   C7
           sendprog(tst_progprog);       //  prog value
           #(cfac*5);
           $display("# (step=%3d): sent program %X", tb_step, tst_progprog);
           $display("#         actual program now %X", lablet.state_mach.prog);
           disasm(lablet.state_mach.prog);
           #(cfac*500);
       end
   endtask     
   
   task test_dummycmd; //--------------------------------------------------------------------------
       input [15:0] tststep;
       begin
           astep(tststep);
           //       waitbusy();
           tb_step = 2;  sendcmd(8'H00);    
           tb_step = 3;  sendcmd(8'H5A);           
           tb_step = 4;  sendcmd(8'H96);    
           tb_step = 5;  sendcmd(8'H00);    
           #(cfac*100);
       end
   endtask     


   task test_upload_from_LL; //--------------------------------------------------------------------
       input [15:0] tststep;
       input [319:0] txt;
       reg [`PROGLEN-1:0] rrec_reg;
       reg [7:0] rrec_cnt;
       real t1,t2;
       begin
           // Receive programm from lablet
           tb_rec_cnt = 0;
           rrec_reg = 0;
           t1 = $time;
           astep(tststep);
           $display("#         actual program now %X", lablet.state_mach.prog);
           $display("# Cmd:Send   %s", txt);
           test_send_cmd(0,`Cmd_Sending,"initiate upload");    // Cmd Send  CF
           tb_receiving = 1;
           while ((tb_rec_cnt < `PROGLEN+9) && ($time-t1 <  cfac * 400 * `PULSELONG)) begin
               #(cfac*2);
               //t2 = $time - t1;
               //$display(" %d  %d  %d",tb_rec_cnt, $time, t2);
           end
           #(cfac*2);
           rrec_reg = tb_rec_reg >> (tb_rec_cnt-`PROGLEN-9);
           rrec_cnt = tb_rec_cnt;
           t2 = $time;
           $display("#         rec-time: %f", (t2-t1)/1000, "ms (",cfac *0.400 * `PULSELONG,"ms)");
           $display("#         received:          %X  %2d bits", rrec_reg, rrec_cnt);
           #(cfac*2);
           tb_rec_prog = rrec_reg;
           disasm(tb_rec_prog);
           $display("#         LL program now     %X", lablet.state_mach.prog);
           disasm(lablet.state_mach.prog);
           tb_receiving = 0;
       end
   endtask     
   //488   
   task test_run; //-------------------------------------------------------------------------------
       input [15:0] tststep;
       input [319:0] txt;
       begin
           astep(tststep);
           $display("# Cmd:Run   %s", txt);
           test_send_cmd(0,`Cmd_Running,"into runmode");   
           #(cfac*500);
       end
   endtask     
   

   task test_stop; //------------------------------------------------------------------------------
       input [15:0] tststep;
       input [319:0] txt;
       begin
           astep(tststep);
           $display("# Cmd:Stop %s", txt);
           sendcmd(`Cmd_Stop); 
           #(cfac*50);
       end
   endtask     

   task footer; //---------------------------------------------------------------------------------
       begin
        $display("# footer");
        //legend();
        legend_desc();
        astep(tb_step);
        $display("# that's it");
        $display("# DEF_ID        : ", `DEF_ID        );
        $display("# THE_PROG      : ", `THE_PROG      );
        $display("# PULSETHRESHOLD: ", `PULSETHRESHOLD);
        $display("# PULSELONG     : ", `PULSELONG     );
        $display("# PULSESHORT    : ", `PULSESHORT    );
        $display("# PULSEPAUSE    : ", `PULSEPAUSE    );
        $display("# MAXPULSECNT   : ", `MAXPULSECNT   );

        $display("# TOPFILE       : ",  `TOPFN);
        $display("# TOPFILEY      : ", `TOPFNY);
        $display("# TOPFILEF      : ", `TOPFNF); 

        $display("# Mod_lablet    : ", `STRINGIFY(`mod_lablet));
        $display("# Mod..statem   : ", `STRINGIFY(`mod_ll_statem));

        $display("# Codes:");
        `SHOW_CMDS
       `ifdef DATA_BIPO
           $display("# defined       : DATA_BIPO"); 
       `else
           $display("# undef'd       : DATA_BIPO"); 
       `endif
       `ifdef DATA_DCFREE
           $display("# defined       : DATA_DCFREE"); 
       `else
           $display("# undef'd       : DATA_DCFREE"); 
       `endif

       
       `ifdef WITH_ID
           $display("# defined       : WITH_ID  DEF_ID=", `DEF_ID); 
       `else
           $display("# undef'd       : WITH_ID"); 
       `endif
       `ifdef WITH_LSEND
           $display("# defined       : WITH_LSEND"); 
       `else
           $display("# undef'd       : WITH_LSEND"); 
       `endif
       `ifdef ELEC_CHG
           $display("# defined       : ELEC_CHG"); 
       `else
           $display("# undef'd       : ELEC_CHG"); 
       `endif

       `ifdef COMPILED
           $display("# defined       : COMPILED"); 
       `else
           $display("# undef'd       : COMPILED"); 
       `endif
       `ifdef COMPILEDALL
           $display("# defined       : COMPILEDALL"); 
       `else
           $display("# undef'd       : COMPILEDALL"); 
       `endif
       `ifdef FROM_YO
           $display("# defined       : FROM_YO"); 
       `else
           $display("# undef'd       : FROM_YO"); 
       `endif
       `ifdef FROM_DV
           $display("# defined       : FROM_DV"); 
       `else
           $display("# undef'd       : FROM_DV"); 
       `endif
       `ifdef YOSYS
           $display("# defined       : YOSYS"); 
       `else
           $display("# undef'd       : YOSYS"); 
       `endif
       `ifdef __SIMULATE__
           $display("# defined       : __SIMULATE__"); 
       `else
           $display("# undef'd       : __SIMULATE__"); 
       `endif
       `ifdef __ICARUS__
           $display("# defined       : __ICARUS__"); 
       `else
           $display("# undef'd       : __ICARUS__"); 
       `endif
       $display("# Program length: ", `PROGLEN);
       $display("# Storage length: ", `PL_STO, " at ", `PP_STO0);
       /*
       `ifdef 
           $display("# defined: "); 
       `else
           $display("# undef'd: "); 
       `endif
       */
       end
   endtask

   task legend_desc; //----------------------------------------------------------------------------
       begin
         $display(
        "# time[us]  d0=din0    d1=din1   a5=pwrcontrol   a4=dout0  a2=dout1  st=state ph=phase");
       end
   endtask

   task legend_actio; //---------------------------------------------------------------------------
       begin
           $display("#      time  a0 a1 a2 a3 a4 a5  s0 s1  d0 d1  st ph");  
       end
   endtask
           
   task header_actio;   //--------------------------------------------------------------------------
       // $monitor displays every time one of the signals changes value. 
       // Only one $monitor in simulation can be active at a time.
       begin
          $monitor(" %10d  %b  %b  %b  %b  %b  %b   %b  %b   %b  %b  %2d %2d", 
                      $time, act0, act1, act2, act3, act4, act5, 
                      tb_sens[0], tb_sens[1], tb_din1, tb_din0,
                      lablet.state_mach.state, lablet.state_mach.phase);
       end
   endtask

           
   task legend_actctrl; //--------------------------------------------------------------------------
       begin
           $display("# time           ph PA SC PC EC EP PO NE  a0 a1 a2 a3 a4 a5");  
       end
   endtask
           
   task header_actctrl; //--------------------------------------------------------------------------
       // $monitor displays every time one of the signals changes value. 
       // Only one $monitor in simulation can be active at a time.
       begin
           $monitor(" %10d      %d  %d  %d  %d  %d  %d  %d  %d    %b  %b  %b  %b  %b  %b", 
                        $time,
                        lablet.state_mach.phase,
                        lablet.state_mach.p_pa, 
                        lablet.state_mach.p_sc, 
                        lablet.state_mach.patterncnt, 
                        lablet.state_mach.p_ec, 
                        lablet.state_mach.p_ep, 
                        lablet.state_mach.p_po, 
                        lablet.state_mach.p_ne, 
                        act0, act1, act2, act3, act4, act5);
       end
   endtask
   
   task legend; //---------------------------------------------------------------------------------
       begin
         //legend_actio();
         legend_actctrl();
       end
   endtask
           
   task header; //---------------------------------------------------------------------------------
       begin
          //header_actio();
          legend();
          header_actctrl();
       end
   endtask

   task waitms; //---------------------------------------------------------------------------------
       input integer ms;
       begin
           if (`SYSCLK == 200) #(500*ms);
           else #(5000*ms);
       end
   endtask

   task test_prog_var; //--------------------------------------------------------------------------
       // stop running, dowload new program,  start, wait
       input [15:0] tststep;
       input [`PROGLEN-1:0] tst_progprog;
       input [319:0] txt;
       begin
          if  ( lablet.state_mach.state != 0 ) begin 
              test_stop(tststep+0, "Abort the running progr.");
          end
          test_download_to_LL(tststep+1, tst_progprog, txt);
          test_run(tststep+2, "run it");
          wait_idle();
          // #(cfac*110);
       end
   endtask


    //============================================================================================
    function [1:0] poduty; //---------------------------------------------------------------------
       input [1:0] sc;
       input [2:0] pc;
       input [1:0] x;
       input [1:0] gl;
       if ((pc[2]==1) && (sc[1]==0)) begin
           poduty = 0;
       end
       else begin
           if (pc[0] && (sc[0]==0) && (gl!=2'B11))  poduty = 0;
           else poduty = x;
       end
    endfunction
  
    function [1:0] popatlen; //-------------------------------------------------------------------
       input [2:0] pa;
       
       if (pa[0] || pa[1]) begin
           if (pa[2]) popatlen = 2;
           else       popatlen = 1;
       end
       else begin
          popatlen = 3;
       end       
    endfunction

    // po = poduty(sc,   pc,    potabx(sc,   pa,   pc),    popatlen(pa));
  
    function [1:0] potabx; //---------------------------------------------------------------------
       input [1:0] sc;
       input [2:0] pa;
       input [2:0] pc;
       
       if (pc[1:0] == 0) begin
           potabx = pa[1:0];
       end
       else begin
           if (pa[2]==0) begin
               if (pa[1:0]==0) begin
                   potabx = pc[1:0];
               end
               else begin
                   if (pc[1]==0) begin //(pc[1:0]<2)
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

    function [1:0] gpcombis; //-----------------------------------------------------------------
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
                  if ( ((ep[1:0]==0)&&(eg==1)) || ((ep[1:0]==1)&&(eg==2)) 
                    || ((ep[1:0]==2)&&(eg==0)) || ((ep[1:0]==3)&&(eg==1)) ) begin
                     if (ep[2]==1) gpcombis = 0;
                     else          gpcombis = 2;
                  end   
                  else  gpcombis = 2;
               end
           end
       end
    endfunction   

    function [1:0] gpcombis0; //----------------------------------------------------------------
       input [2:0] ep;
       input [1:0] eg;
       if (eg==3) begin
           if (ep[2]==0) gpcombis0 = 0;
           else          gpcombis0 = 2;
       end
       else begin //1
           if (ep[2]==0) begin //2
              if ((ep[0]==1)&&(ep[1]==1)) begin
                  gpcombis0 = 1;
              end
              else  begin
                  if (ep[1]==0) begin
                      if (eg==ep[1:0]) gpcombis0 = 1;
                      else             gpcombis0 = 2;
                  end
                  else begin
                     gpcombis0 = !eg[0]+eg[1];
                  end
              end
           end
           else begin
               if ( (ep[0]==1)&&(ep[1]==1) ) begin
                  if (eg[1]==1) begin
                      if (eg[0]==1) gpcombis0 = 2;
                      else          gpcombis0 = 1;
                  end
                  else begin
                      gpcombis0 = 0;
                  end
               end   
               else begin
                  if (eg==ep[1:0]) begin
                     gpcombis0 = 0;
                  end
                  else begin
                     //if (eg==mod(ep[1:0]+1,3) gpcombis0 = 1;
                     if ( ((ep[1:0]==0)&&(eg==1)) || ((ep[1:0]==1)&&(eg==2)) 
                       || ((ep[1:0]==2)&&(eg==0)) || ((ep[1:0]==3)&&(eg==1)) ) gpcombis0 = 1;
                     else                                                      gpcombis0 = 2;
                  end   
               end
           end
       end
    endfunction   


    function [1:0] gpo;  // gpo(ep,eg,po) //--------------------------------------------------
       input [2:0] ep;
       input [1:0] eg;
       input [1:0] po;
       if (po==0) gpo = 2;
       else begin
           if (po==3) gpo = gpcombis({ep[2], !ep[1],  ep[0]}, eg);
           else  if (po==2) gpo = gpcombis({ep[2],  ep[1], !ep[0]}, eg);
                 else       gpo = gpcombis(ep, eg);
       end
    endfunction

    function [1:0] el1;  // A0/act0 = el1(ec2, ep3, po2)    gpo[EP,0,PO]; //------------------
       input [1:0] ec;
       input [2:0] ep;
       input [1:0] po;
       el1 = gpo(ep,0,po);
    endfunction

    function [1:0] el2;  // din/act2 = el2(ec2, ep3, po2)  If[EC==0,gpo[EP,3,PO],gpo[EP,2,PO]];
       input [1:0] ec;
       input [2:0] ep;
       input [1:0] po;
       if  (ec==0) el2 = gpo(ep,3,po);
       else        el2 = gpo(ep,2,po);
    endfunction

    function [1:0] el3;  // A2/act3 = el3(ec2, ep3, po2)   If[EC==0, gpo[EP,2,PO],2];
       input [1:0] ec;
       input [2:0] ep;
       input [1:0] po;
       if (ec==0) el3 = gpo(ep,2,po);
       else       el3 = 2;
    endfunction

    function [1:0] el4;  // Dout/act4 = el4(ec2, ep3, po2) If[EC==0,gpo[EP,3,PO], gpo[EP,2,PO]];
       input [1:0] ec;
       input [2:0] ep;
       input [1:0] po;
       if (ec==0) el4 = gpo(ep,3,po);
       else       el4 = gpo(ep,2,po);
    endfunction

    function [1:0] el5;  // A1/act5 = el5(ec2, ep3, po2)  gpo[EP,1,PO]; //---------------------
       input [1:0] ec;
       input [2:0] ep;
       input [1:0] po;
       el5 = gpo(ep,1,po);
    endfunction

    function  el6;  // PWR/act6 = el6(ec2, ep3, po2) If[EC==0,If[gpo[EP,3,PO]==0,0,2],2]; //--
       input [1:0] ec;
       input [2:0] ep;
       input [1:0] po;
       if (ec==0) el6 = (gpo(ep,3,po)==0) ? 1:0;  // 1=active
       else       el6 = 0;  // disable
    endfunction

    function [1:0] el6j;  // act0 = el6(ec2, ep3, po2) //--------------------------------------
       input [1:0] ec;
       input [2:0] ep;
       input [1:0] po;
       if (ec==0) el6j = (gpo(ep,3,po)==0) ? 0:2;  //
       else       el6j = 2;
    endfunction
    // 895
    // po = poduty(sc,   pc,    potabx(sc,   pa,   pc),    popatlen(pa));
    // el = elx(ec, ep, poduty(sc,pc,potabx(sc,pa,pc),popatlen(pa)));

  
   // Initialize all variables ----------------------------------------------------------------
   initial begin
        $dumpfile("ll.vcd");
        $dumpvars(0, lablet_testb);

        if (`SYSCLK == 200) cfac = 2500;   
        else                cfac = 25000;
        //  `timescale                               1ms/1us   1us/1us
        //    20Hz                               :=> 25         25000
        //    50Hz ~ 20ms   10ms-hi + 10ms-lo    :=> 10         10000
        //    80Hz                               :=>  6          6250
        //   100Hz                               :=>  5          5000
        //   200Hz                               :=>  2.5        2500
        //    1kHz                               :=>  0.5         500
        cfac2 = 2*cfac;

        debug = 0;   // Maske f. diff. Ausgaben
        tb_clk = 1;
        tb_clk2 = 1;
        tb_RST = 1; 
        tb_clkcnt =0;
        tb_timer = 1;
        tb_step = 0;
        tb_substep = 0;
        tb_sens[0] = 1;
        tb_sens[1] = 0;
        // 925
        dselect = 0;  
        tb_din0alt = 1'Bz;
        tb_din1alt = 1'Bz;
        sendbit = 0;  // tristate ctrl f. dinX
        tb_sending = 0;
        tb_receiving = 0;
        tb_rec_reg = 0;
        tb_rec_cnt = 0;
        tb_dclk = 0;
        tb_rec_state = 0;

        //-------------------------------------------------------------------------------------
        astep(0);
        #(cfac*16); 
        tb_RST = 0; 
        #(cfac*4);
        astep(1);
        header();
        
        // 1. Test actors for whole range of patterns
        //-------------------------------------------------------------------------------------
        if (0) begin
            /*
               Complete actortest:

               PC=patterncnt        stepped by TI[phase]*clocks 0..7
               PA[phase]            pattern sequence select
               SC[phase]            sequence length select
               EP[phase]            polarity select
               EC[phase]            group select
               NE[phase]            inversion
               +-------------+-------------+---------+----+-------------+----+
               | PC2 PC1 PC0 | PA2 PA1 PA0 | SC1 SC0 | EC | EP2 EP1 EP0 | NE |
               +-------------+-------------+---------+----+-------------+----+
               |             |             |         |    |             |    |
               +-------------+-------------+---------+----+-------------+----+
               
               SC_CONST 0 CLK_1  0  CA_NEXT 0  EC_A0A1A2D 0  TS_NO   4'B0000  TS_S0NS1  4'B0100
               SC_SHORT 1 CLK_4  1  CA_SKIP 1  EC_DDA2V   1  TS_S0   4'B0001  TS_S1NS0  4'B0101
               SC_LONG  2 CLK_16 2  CA_PREV 2                TS_S1   4'B0010  TS_TRG    4'B0110
               SC_FULL  3 CLK_64 3  CA_RST  3                TS_S0S1 4'B0011  TS_TRGS0  4'B0111
                                                                              TS_TRGN   4'B1000
            */
            
            //$dumpflush();
            //$dumpoff();
            //$dumpfile("llx.vcd");
            //$dumpvars(0, lablet_testb);
            //$dumpon();
            tmp_n = 100;
            for(tmp_i = 0; tmp_i < 2; tmp_i = tmp_i+1) begin  // EC 0..1
              for(tmp_k = 0; tmp_k < 8; tmp_k = tmp_k+1) begin // EP 0..7
                for(tmp_j = 0; tmp_j < 8; tmp_j = tmp_j+1) begin // PA 0..7
                  for(tmp_m = 0; tmp_m < 4; tmp_m = tmp_m+1) begin // SC 0..3
                    for(tmp_o = 1; tmp_o < 2; tmp_o = tmp_o+1) begin // NE 0..1
                                //     SC     EP      TI      SE      CA       PA     NE  
                        test_prog_var(tmp_n, 
                            `PROGRAM(tmp_m ,tmp_k ,`CLK_1 ,`TS_NO ,`CA_RST,  tmp_j, tmp_o, tmp_i, 
                                     tmp_m ,tmp_k ,`CLK_1, `TS_NO ,`CA_STOP, tmp_j, tmp_o, tmp_i, 
                                     tmp_m ,tmp_k ,`CLK_1, `TS_NO ,`CA_STOP, tmp_j, tmp_o, tmp_i,
                                     0,0,0), " test1*1");
                        tmp_n = tmp_n + 5;
                        /*
                        test_prog_var(tmp_n, 
                            `PROGRAM(tmp_m ,tmp_k ,`CLK_16,`TS_NO ,`CA_STOP, tmp_j, tmp_o, tmp_i, 
                                     tmp_m ,tmp_k ,`CLK_4, `TS_NO ,`CA_STOP, tmp_j, tmp_o, tmp_i, 
                                     tmp_m ,tmp_k ,`CLK_1, `TS_NO ,`CA_STOP, tmp_j, tmp_o, tmp_i,
                                     1,0,0), " test1*4");
                        tmp_n = tmp_n + 5;
                        */
                    end
                  end
                end
              end
            end
        end            
        
        // 2a. Display table of duty cycles for PA 0..7  SC 0..3  PC 0..7
        //-------------------------------------------------------------------------------------
        if (0) begin
            $display("");
            $display("Table duty: PA 0..7  SC 0..3  PC 0..7");
            for(tmp_i = 0; tmp_i < 8; tmp_i = tmp_i+1) begin  // PA
              //$display("%% PA:", tmp_i);
              for(tmp_k = 0; tmp_k < 4; tmp_k = tmp_k+1) begin // SC
                $write("  {");
                for(tmp_j = 0; tmp_j < 8; tmp_j = tmp_j+1) begin // PC
                    tmp_n = poduty(tmp_k,tmp_j, potabx(tmp_k,tmp_i,tmp_j), popatlen(tmp_i));
                    // po = poduty(sc,   pc,    potabx(sc,   pa,   pc),    popatlen(pa));
                    $write("%1d",tmp_n);
                    if (tmp_j!=7) $write(",");
                end
                $write("}");
                if (tmp_k!=3) $write(",");
              end
              $display("");
            end
            $display("");
        end        

        // 2b. Dissect further details of actuator signal processing PA,SC,PC and display
        //-------------------------------------------------------------------------------------
        if (0) begin
            for(tmp_i = 0; tmp_i < 8; tmp_i = tmp_i+1) begin  // PA
              $display("%% PA:", popatlen(tmp_i));
            end
            tmp_i = potabx(0,    5,    1);
            tmp_j = popatlen(5);
            tmp_k = poduty(0,    1,  tmp_i, tmp_j);
            $display("%% ", tmp_i, tmp_j, tmp_k);
                          // po = poduty(sc,   pc,    potabx(sc,   pa,   pc),    popatlen(pa));
            $display("%%PD() = ", poduty(0,    1,     potabx(0,    5,    1),     popatlen(5)) );
            $display("%%PD(soll 0) = ", poduty(0, 1, 1 ,2) );
        end
        
        // 2c. Display table of gpcombis for EP 0..7 EG 0..3 and el for EC 0..1  PO 0..3  EP 0..7
        //-------------------------------------------------------------------------------------
        if (0) begin
            $display("Table gpcombis: EP 0..7  EG 0..3");
            $write("  {{");
            for(tmp_i = 0; tmp_i < 8; tmp_i = tmp_i+1) begin  // EP
              for(tmp_k = 0; tmp_k < 4; tmp_k = tmp_k+1) begin // EG
                  tmp_n = gpcombis(tmp_i, tmp_k);
                  $write("%1d",tmp_n);
                  if (tmp_k!=3) $write(",");
              end
              $write("}");
              if (tmp_i!=7) $write(",{");
            end
            $display("}");
            $display("");


            $display("Table el:  EC 0..1  PO 0..3  EP 0..7");
            for(tmp_m = 0; tmp_m < 2; tmp_m = tmp_m+1) begin // EC
              for(tmp_k = 0; tmp_k < 4; tmp_k = tmp_k+1) begin // PO
                $write("    ");
                for(tmp_i = 0; tmp_i < 8; tmp_i = tmp_i+1) begin  // EP
                    // act0 = el1(ec2, ep3, po2)
                    $write("{%1d,%1d,%1d,%1d,%1d,%1d}", 
                            el1(tmp_m, tmp_i, tmp_k), 
                            el2(tmp_m, tmp_i, tmp_k),
                            el3(tmp_m, tmp_i, tmp_k),
                            el4(tmp_m, tmp_i, tmp_k),
                            el5(tmp_m, tmp_i, tmp_k),
                            el6j(tmp_m, tmp_i, tmp_k) );
                    if (tmp_i<7)  $write(", "); 
                 end
                 $display("");
              end
            end
            $display("");
        end


        // 3. Test prog variants 2710,2720,2730,2740
        //-------------------------------------------------------------------------------------
        if (1) begin
            test_prog_var(2710, `PROGRAM(`SC_CONST  ,7 ,`CLK_16,`TS_NO    ,`CA_STOP, 7,0,
                           `EC_A0A1A2D, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0), " test1");
            test_prog_var(2720, `PROGRAM(`SC_SHORT  ,7 ,`CLK_16,`TS_NO    ,`CA_STOP, 7,0,
                           `EC_A0A1A2D, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0), " test1");
            test_prog_var(2730, `PROGRAM(`SC_LONG   ,7 ,`CLK_16,`TS_NO    ,`CA_STOP, 7,0,
                           `EC_A0A1A2D, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0), " test1");
            test_prog_var(2740, `PROGRAM(`SC_FULL   ,7 ,`CLK_16,`TS_NO    ,`CA_STOP, 7,0,
                           `EC_A0A1A2D, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0), " test1");
        end
        // 1067


        // 4. Display progs Dummy,01,02,03 and Test execution
        //-------------------------------------------------------------------------------------
        if (1) begin
          $display("# The four alternative initial inbuilt lablet programs");
          dummyprog = `DEF_PROG;
          $display("# DEF_PROG       %X", dummyprog);
          dummyprog = `PROG_01;
          $display("# PROG_01        %X", dummyprog);
          dummyprog = `PROG_02;
          $display("# PROG_02        %X", dummyprog);
          dummyprog = `PROG_03;
          $display("# PROG_03        %X", dummyprog);

          astep(1);
          test_pulswidth(2);
          #(cfac*100);
          /*
          test_dummycmd(3);
          #(cfac*100);

          test_stop(4, "Abort the running progr.");
          test_download_to_LL(4, `PROG_01, "prog 01");
          #(cfac*100);

          //test_sender(5);
          //#(cfac*100);
          */
        end
        //1102  

        // 5. Test abort of running program (stop)   
        //-------------------------------------------------------------------------------------
        if (0) begin
        
          test_stop(100, "Abort the running progr.");
          test_download_to_LL(101, `PROGRAM(
                              // SC     EP  TI       SE         CA       PA      
                             `SC_FULL  ,3 ,`CLK_4  ,`TS_NO    ,`CA_NEXT, 6, 0,0,
                             `SC_LONG  ,7 ,`CLK_4  ,`TS_NO    ,`CA_NEXT, 5, 0,1,
                             `SC_FULL  ,6 ,`CLK_1  ,`TS_NO    ,`CA_STOP, 6, 0,0,
                              1, 1, 0), " download a test progr. into the LL");
          test_run(102, "run it");
          #(cfac*10100);
          test_stop(103, "Abort the running progr.");
        end
        

        // 6. Test trigger and Select cmd to change din/dout
        //-------------------------------------------------------------------------------------
        if (0) begin       // Thomas last opened with 1
          // test condition (trg)
          test_download_to_LL(110, `PROGRAM(
                              // SC     EP  TI       SE         CA       PA      
                             `SC_FULL  ,3 ,`CLK_4  ,`TS_NO    ,`CA_RST,  6, 0,1,
                             `SC_LONG  ,7 ,`CLK_1  ,`TS_TRGN  ,`CA_PREV, 5, 0,0,
                             `SC_FULL  ,6 ,`CLK_16 ,`TS_NO    ,`CA_STOP, 6, 0,1,
                             `REP_4, 0, 0), " download a test progr. into the LL");
          test_run(111, "run it");
          #(cfac*10100);
          test_stop(112, "Abort the running progr.");


          test_upload_from_LL(7, "upload from LL");
          test_stop(8, "Abort the running progr.");

          #(cfac*5000);
          test_run(9, "run it");
          #(cfac*15000);

          test_send_cmd_nowait(10, `Cmd_TrigHi, "Set trigd flag");   
          #(cfac*5000);

          test_send_cmd_nowait(11, `Cmd_TrigLo, "Clr trigd flag");   
          #(cfac*5000);

          test_send_cmd_nowait(12, `Cmd_TrigHi, "Set trigd flag");   
          #(cfac*5000);

          test_send_cmd_nowait(13, `Cmd_TrigLo, "Clr trigd flag");   
          #(cfac*3000);
         
          test_stop(14, "Abort running progr.");
          #(cfac*10);
          test_upload_from_LL(15, "upload via dout0");

          `ifdef DSEL
              test_send_cmd(16, `Cmd_Select, "change din/dout via din0");    // change Din/Dout
              dselect = !dselect;
              #(cfac*10);
              test_upload_from_LL(17, "upload via dout1");

              test_send_cmd(18, `Cmd_Select, "change din/dout via din1");    // change Din/Dout
              dselect = !dselect;
              #(cfac*5000);
          `endif

          test_send_cmd_nowait(12, `Cmd_TrigHi, "Set trigd flag");   
          #(cfac*5000);
        end



        // 7. Test data-store, + send program back
        //-------------------------------------------------------------------------------------
        if (0) begin
          // test data-store, + send program back
          tb_sens = 0;
          test_download_to_LL(110, `PROGRAM(
                              // SC      EP  TI       SE         CA       PA  NE  EC    
                             `SC_FULL  , 3 ,`CLK_4  ,`TS_S1  ,`CA_NEXT  ,  6,  0,  0,
                             `SC_LONG  , 7 ,`CLK_4  ,`TS_S0  ,4+`CA_RST ,  4,  0,  1,
                             0,0,0,0,0,0,0,0,
                             `REP_64 , 1, 0), 
                             " download a test progr. for data storage into the LL");
          tb_sens = 0;
          test_run(111, "run it");
          tb_sens = 0;
          
          #(cfac*20100);
          test_stop(112, "Abort the running progr.");

          // test data-store, + send comtest
          tb_sens = 0;
          test_download_to_LL(110, `PROGRAM(
                              // SC      EP  TI       SE         CA       PA  NE  EC  
                             `SC_FULL  , 3 ,`CLK_4  ,`TS_S1  ,4+`CA_NEXT,  6,  0,  0,
                             `SC_LONG  , 7 ,`CLK_4  ,`TS_S0  ,  `CA_RST,   4,  0,  1,
                             0,0,0,0,0,0,0,0,  
                             `REP_64, 1, 0), 
                             " download a test progr. for data storage into the LL");
          tb_sens = 0;
          test_run(111, "run it");
          tb_sens = 0;
          
          #(cfac*20100);
          test_stop(112, "Abort the running progr.");

          test_upload_from_LL(7, "upload from LL");
          test_stop(8, "Abort the running progr.");
          end



        // 8. Test two different Send/Prog/Run cmd sequences with PROG_02 and PROG_03 
        //    then try Send with different frequencies
        //-------------------------------------------------------------------------------------
        if (0) begin     
          $display("# Cmd:Send");
          tb_step =12;  sendcmd(`Cmd_Sending);    // Cmd Send   CF
          #(cfac*5000);

          tb_step=19;   waitbusy();
          $display("# Cmd:Prog");
          tb_step =20;  sendcmd(`Cmd_Program);    // Cmd Prog    C7
          $display("# Data: %X", `PROG_02);
          tb_step =21;  sendprog(`PROG_02);       //  prog value    s1h s0l
          $display("# Cmd:Send");
          tb_step =22;  sendcmd(`Cmd_Sending);    // Cmd Send  CF
          #(cfac*4000);
          tb_step =23;  sendcmd(`Cmd_Sending);    // Cmd Send  CF
          tb_step =24;  sendcmd(`Cmd_Sending);    // Cmd Send  CF
          #(cfac*20000);
          
          tb_step=29;    waitbusy();
          $display("# Cmd:Run");
          tb_step =30;  sendcmd(`Cmd_Running);    // Cmd Run   Cb
          #(cfac*20000);
          
          tb_step=31;   waitbusy();
          $display("# Cmd:Prog");
          tb_step =32;  sendcmd(`Cmd_Program);    // Cmd Prog    C7
          $display("# Data: %X", `PROG_03);
          tb_step =33;  sendprog(`PROG_03);       //  prog value
          $display("# Cmd: 00 (sync)");
          tb_step =34;  sendcmd(8'H00);    
          $display("# Cmd:Run");
          tb_step =35;  sendcmd(`Cmd_Running);    // Cmd Run   Cb
          #(cfac*20000);
          
          tb_step=39; waitbusy();
          $display("# Cmd:Prog");
          tb_step =40;  sendcmd(`Cmd_Program);    // Cmd Prog  C7
          $display("# Data: %X", `PROG_04);
          tb_step =41;  sendprog(`PROG_04);       //  prog value
          $display("# Cmd:Run");
          tb_step =42;  sendcmd(`Cmd_Running);    // Cmd Run   Cb
          #(cfac*30000);

          //while ( lablet.core.state_mach.state != 0 ) 
          //begin 
          //    #(cfac*10); 
          //end
          // Send with different frequencies  // Cmd Send  CF
          repeat (1) begin 
              test_sender(6);
              #(cfac*3000);
          end
        end

  
        // 9. Wait for timeout
        //-------------------------------------------------------------------------------------
        if (0) begin  // timeout nach 31 sec
            #(cfac*10000);  // wait for timeout
            #(cfac*10000);  // wait for timeout
            #(cfac*10000);  // wait for timeout
            #(cfac*10000);  // wait for timeout
            #(cfac*10000);  // wait for timeout
            wait_idle();
        end
        //-------------------------------------------------------------------------------------
        #(cfac*100);
        footer();      
        $finish;
   end                                                               
endmodule


