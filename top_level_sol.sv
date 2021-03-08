// shell for Lab 4 CSE140L
// this will be top level of your DUT
// W is data path width (8 bits)
// byte count = number of "words" (bytes) in reg_file
//   or data_memory
module top_level #(parameter W=8,
                   byte_count = 256)(
  input        clk, 
               init,	           // req. from test bench
  output logic done);	           // ack. to test bench

// memory interface = 
//   write_en, raddr, waddr, data_in, data_out: 
  logic write_en;                  // store enable for dat_mem

// address pointers for reg_file/data_mem
  logic[$clog2(byte_count)-1:0] raddr, waddr;

// data path connections into/out of reg file/data mem
  logic[W-1:0] data_in;
  wire [W-1:0] data_out; 

/* instantiate data memory (reg file)
   Here we can override the two parameters, if we 
     so desire (leaving them as defaults here) */
  dat_mem #(.W(W),.byte_count(byte_count)) 
    dm1(.*);		               // reg_file or data memory

/* ********** insert your code here
   read from data mem, manipulate bits, write
   result back into data_mem  ************

// load
// read 2 bytes from dat_mem  write into 16-bit register
 always @ (posedge clk)
  1. raddr = 0+2*ct	 // lab 4       64+2*ct // Lab 5
     inl = data_out
	 loadl = 1+2*ct, loadh = 0

  2. raddr = 1		  // lab 4    65+2*ct // Lab 5
     inh = data_out
	 loadh = 1, loadl = 0


// compute parities
  3. p8 = ^reg1[10:4];   // d11:d5
     p4 = 
	 p2 =
	 p1 =
	 p0 = ^reg1[15:1];

// bit fiddling / spacing / parity injection
  4. bit fiddling / spacing 

     0 0 0 0 0 11 10  9	 8 7 6 5 4  3  2  1

     8 7 6 5 4  3  2  1




	 8 7 6 5 4  3  2  1				Mem[0]
	 0 0 0 0 0 11 10  9             Mem[1]	

	 8 7 6 5 4  3  2  1				Mem[2]
	 0 0 0 0 0 11 10  9             Mem[3]	

	 8 7 6 5 4  3  2  1				Mem[4]
	 0 0 0 0 0 11 10  9             Mem[5]	




 {d1_in[i][11:5],p8,d1_in[i][4:2],p4,d1_in[i][1],p2,p1,p0};

    11 10  9  8  7  6  5  p8  4  3  2  p4  1  p2 p1 p0

 always @(posedge clk)
   reg2[15:0] <= 

 {d1_in[i][10:4],p8,d1_in[i][3:1],p4,d1_in[i][0],p2,p1,p0};

   s8 = reg1[15:9];   p8 should have been 
   s4 =... 
   s2
   s1

   s0  = ^reg1[15:1];  !=p0

      ERR[3:0] = {s8,s4,s2,s1} ^ {p8,p4,p2,p1};
	  1'b1 << ERR; 
  posedge clk: 
	 reg2 <= reg1 ^ (1'b1<<ERR);



  5. waddr = 30+2*ct  wen = 1	// lab 4   // lab5: 94+2*ct   
     data_in <= reg2[7:0];

  6. always @(posedge clk)
     waddr = 31+2*ct  wen = 1    memory store	   95+2*ct
	 data_in <= reg2[15:8];


Scenario 1: no errors:
  ERR = 0;  s0 = p0;  

Scenario 2A: one error:
  ERR != 0;  s0 =!p0; 

Scenario 2B: one error:
  ERR = 0;  s0 != p0 	 bad p0

Scenaro 3: two errors:
  ERR != 0;  s0 = p0;



*/

  



// my dummy state counter to return a "done" flag
//  63 clocks after init from test bench
// yours should be tied to completion of your actual operations
  logic[15:0] ct;
  always @(posedge clk)
    if(init)
      ct <= 0;
    else
      ct <= ct + 1;
  assign done = ct==147;// &ct;

endmodule
