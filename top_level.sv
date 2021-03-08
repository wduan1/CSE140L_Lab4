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
*/


// my dummy state counter to return a "done" flag
//  63 clocks after init from test bench
// yours should be tied to completion of your actual operations
  logic[5:0] ct;
  always @(posedge clk)
    if(init)
      ct <= 0;
    else
      ct <= ct + 1;
  assign done = &ct;

endmodule
