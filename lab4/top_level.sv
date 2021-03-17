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
// program counter: bits[6:3] count passes through for loop/subroutine
// bits[2:0] count clock cycles within subroutine (I use 5 out of 8 possible, pad w/ 3 no ops)
  logic[ 6:0] count;
  logic[ 8:0] parity;
  logic[15:0] temp1, temp2;
  logic       temp1_enh, temp1_enl, temp2_en;



  //
 
  assign parity[8] = ^temp1[10:4];
  //
  assign parity[4] = (^temp1[10:7])^(^temp1[3:1]);
  //XOR all the data bits together to check for parity
  assign parity[2] = temp1[10]^temp1[9]^temp1[6]^temp1[5]^temp1[3]^temp1[2]^temp1[0];
  assign parity[1] = temp1[10]^temp1[8]^temp1[6]^temp1[4]^temp1[3]^temp1[1]^temp1[0];
  //XOR all parity values to check dual error correction
  assign parity[0] = ^temp1^parity[8]^parity[4]^parity[2]^parity[1];


  always @(posedge clk)
    if(init) begin
      count <= 0;
      temp1 <= 'b0;
      temp2 <= 'b0;
    end
    else begin
      count                     <= count + 1;
      if(temp1_enh) temp1[15:8] <= data_out;
      if(temp1_enl) temp1[ 7:0] <= data_out;
    //if(temp2_en)  temp2       <= function of temp1 and parity bits
      if(temp2_en)  temp2       <= {temp1[10:4],parity[8],temp1[3:1],parity[4],temp1[0],parity[2:0]};
    end  

  always_comb begin
// defaults  
    temp1_enl        = 'b0;
    temp1_enh        = 'b0;
    temp2_en         = 'b0;
    raddr            = 'b0;
    waddr            = 'b0;
    write_en         = 'b0;
    data_in          = temp2[7:0];   
    case(count[2:0])
      1: begin                  // step 1: load from data_mem into lower byte of temp1
//           raddr     = function of count[6:3]
           raddr = 2*count[6:3];
           temp1_enl = 'b1;
         end  
      2: begin                  // step 2: load from data_mem into upper byte of temp1
//           raddr      = function of count[6:3]
           raddr = 2 * count[6:3] + 1;
           temp1_enh = 'b1;
         end
      3: temp2_en    = 'b1;     // step 3: copy from temp1 and parity bits into temp2
      4: begin                  // step 4: store from one bytte of temp2 into data_mem 
           write_en = 'b1;
//           waddr    = function of count[6:3]
//           data_in  = bits from temp2
            waddr = 2 * count[6:3] + 30;
            data_in = temp2[7:0];
         end
      5: begin
           write_en = 'b1;      // step 5: store from other byte of temp2 into data_mem
//           waddr    = function of count[6:3]
//           data_in  = bits from temp2
            waddr = 2 * count[6:3] + 31;
            data_in = temp2[15:8];
         end
    endcase
  end

// automatically stop at count 127; 120 might be even better (why?)
  assign done = &count;

endmodule
