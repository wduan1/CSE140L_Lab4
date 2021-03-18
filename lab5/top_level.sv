// shell for Lab 5 CSE140L
// this will be top level of your DUT
// W is data path width (8 bits)
// byte count = number of "words" (bytes) in reg_file
//   or data_memory

// CODE FOR LAB 5
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
  logic[ 8:0] parity2;
  logic[15:0] temp1, temp2;
  logic       temp1_enh, temp1_enl, temp2_en, temp3_en;
  logic[ 8:0] result;
  logic[ 3:0] check;
  logic       corrections;
  logic       flag;

// Parity bits from the given data
//Order in which we read and check the parity bits matters!
  assign parity[8] = ^temp1[15:9];
  assign parity[4] = (^temp1[15:12])^(^temp1[7:5]);
  assign parity[2] = temp1[15]^temp1[14]^temp1[11]^temp1[10]^temp1[7]^temp1[6]^temp1[3];
  assign parity[1] = temp1[15]^temp1[13]^temp1[11]^temp1[9]^temp1[7]^temp1[5]^temp1[3];
  assign parity[0] = ^temp1[15:1];

// Parties from a message
  assign parity2[8] = temp1[8];
  assign parity2[4] = temp1[4];
  assign parity2[2] = temp1[2];
  assign parity2[1] = temp1[1];
  assign parity2[0] = temp1[0];

// XOR results from parity bits from data and the message
  assign result = parity ^ parity2;
  assign check = {result[8],result[4],result[2],result[1]};
  assign flag = result[8] || result[4] || result[2] || result[1] || result[0];

  always @(posedge clk)
    if(init) begin
      count <= 0;
      temp1 <= 'b0;
      temp2 <= 'b0;
      corrections <= 'b0;
    end
    else begin
      count                     <= count + 1;
      if(temp1_enh) temp1[15:8] <= data_out;
      if(temp1_enl) temp1[ 7:0] <= data_out;
      if(temp2_en)  begin
      
      //0 error case
      if (result[0] == 0 && flag == 0) begin
        temp2 <= {5'b00000,temp1[15:9],temp1[7:5], temp1[3]};
        end
       // Two errors
      if (result[0] == 0 && flag == 1) begin
        temp2 <= {16'b1000011111111111};
        end
      // One error - data bit / parity bit detection
      if (result[0] == 1 && flag == 1) begin
         corrections = 'b1;
        end
      end
    // One bit correction
     if (temp3_en && corrections == 'b1) begin
        temp1[check] = temp1[check] ^ 1;
        temp2        <= {5'b01000,temp1[15:9],temp1[7:5],temp1[3]};
        corrections = 'b0;
      end
    end
  always_comb begin
// defaults  
    temp1_enl        = 'b0;
    temp1_enh        = 'b0;
    temp2_en         = 'b0;
    temp3_en         = 'b0;
    raddr            = 'b0;
    waddr            = 'b0;
    write_en         = 'b0;
    data_in          = temp2[7:0];   
    case(count[2:0])
      1: begin                  // step 1: load from data_mem into lower byte of temp1
//           raddr     = function of count[6:3]
           raddr = 2*count[6:3] + 64;
           temp1_enl = 'b1;
         end  
      2: begin                  // step 2: load from data_mem into upper byte of temp1
//           raddr      = function of count[6:3]
           raddr = 2*count[6:3] + 65;
           temp1_enh = 'b1;
         end
      3: temp2_en    = 'b1;     // step 3: copy from temp1 and parity bits into temp2
      4: temp3_en    = 'b1;
      5: begin                  // step 4: store from one bytte of temp2 into data_mem 
           write_en = 'b1;
//           waddr    = function of count[6:3]
//           data_in  = bits from temp2
           waddr = 2*count[6:3] + 94;
           data_in = temp2[7:0];
         end
      6: begin
           write_en = 'b1;      // step 5: store from other byte of temp2 into data_mem
//           waddr    = function of count[6:3]
//           data_in  = bits from temp2
           waddr = 2*count[6:3]+95;
           data_in = temp2[15:8];
         end
    endcase
  end

// automatically stop at count 127; 120 might be even better (why?)
  assign done = &count;

endmodule
