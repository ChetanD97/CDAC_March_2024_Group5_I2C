`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
 // 
//////////////////////////////////////////////////////////////////////////////////

// Source: https://github.com/karthikkbs05/I2C-Master-using-verilog-RTL-coding/blob/main/i2c_master.v

module i2c_master(
    output       reg  sda_out,
    output       reg  scl_out,
    output       reg  clk2mhz_dummy,                         // Reference clock for utilizing in slave unit
    output       reg  rw,
    input             sda_in,
    input             clk100mhz,                             // Why 2 Mhz, and not use 100 Mhz directly?
    input             res,
    input  [7:0]      data_to_send, 
    input  [7:0]      addr_to_send,                           // contains 5 bit slave address and 2 bit dummy and                                                         // last bit says the read/write
    input  [7:0]      addr_reg_send,
    input  [7:0]      addr_reg_read
);
    
      parameter [3:0]   idle                = 4'b0000,          // states named and defined for use in case 
                        idle_2              = 4'b0001,          // statement, FSM
                        start               = 4'b0010, 
                        address_send        = 4'b0011,
                        address_ack         = 4'b0100,
                        data_send_init      = 4'b0101,
                        data_send_ad        = 4'b0110,
                        data_send_ad_ack    = 4'b0111,
                        data_send           = 4'b1000,
                        data_send_ack       = 4'b1001,
                        data_read_ad        = 4'b1010,
                        data_read_ad_ack    = 4'b1011,
                        data_read           = 4'b1100,
                        data_read_ack       = 4'b1101,
                        stop                = 4'b1110;


      reg  [3:0] state = idle;                                  // State Register to iterate through states, initialized to idle state
     
      wire     clk2mhz;                                         // module variables redefined, initialized
      reg       sda_h      = 1,
                scl_h      = 0,
                sda_mode   = 0,
                scl_mode   = 0,
                sda_toggle = 0,
                scl_toggle = 0;
                
      reg [7:0] addr_to_send_store = 8'b00000000;               // Temporary registers defined, identicle to default
                                                                // Here, send = write, store = temporary inputs and
      reg [7:0] data_to_send_store  = 8'b00000000;  
      reg [7:0] data_read_store     = 8'b00000000;              // outputs
      reg [7:0] addr_reg_send_store = 8'b00000000;
      reg [7:0] addr_reg_read_store = 8'b00000000;

      Timing_Counter Clk_gen(
        .clk100mhz(clk100mhz),
        .reset(res),
        .clk2mhz(clk2mhz)
     );      

      always@(data_to_send or addr_to_send)
      begin
          addr_to_send_store  = addr_to_send;    
          data_to_send_store  = data_to_send;
          addr_reg_send_store = addr_reg_send;
          addr_reg_read_store = addr_reg_read;
      end

      assign rw = addr_to_send_store[0];                         // assigning LSB of the temporary register to rw
                                                                 // to define read or write cycle

      reg [5:0] count     = 0;                                   // defining and initializing temporary variables
      reg [3:0] bit_count = 8;
      reg [3:0] addressing_mode = 7;
      // count_ack_wait = 4,
      // count_sda_wait = 2; 
      
//      assign sda_mode ? 1'bZ  sda_toggle ? sda_in : sda_out;   // w.r.t. pull up registers, why high Z
                                                                // We will make changes here w.r.t. buffers: sda_in, sda_out
      assign scl_out = scl_mode ? 1'bZ : scl_toggle ? clk2mhz : scl_h;
     
      always@* begin
        if(sda_toggle) begin
//          sda_in  = 1'b1;                                // Since sda_in is input, we intend to enable them, which we will do in the wrapper file
          sda_out = 1'bZ;
        end else begin
//          sda_in  = 1'bZ;                                // Disconnecting sda_in for sending bits through sda_out is again achieved through the wrapper, based on rw
          sda_out = 1'b1;
        end
      end      
     
     assign clk2mhz_dummy = clk2mhz;
     
     always@(posedge clk2mhz_dummy, posedge res) begin
         if(res) begin
            state <= idle;
         end else begin 
                case(state)
                              idle : begin
//                                      sda_mode   <= 0;
                                      sda_toggle <= 0;
                                      sda_out    <= 1;
                                      scl_mode   <= 1;
                                      scl_toggle <= 0;
                                      scl_h      <= 1;
                                    
                                      if(addr_to_send_store!=0)
                                       begin
                                          state <= idle_2;
                                       end else begin
                                          state    <= idle;
                                       end
                                     end

                            idle_2 : begin
//                                         sda_mode   <= 0;
                                         sda_toggle <= 0;
                                         sda_out    <= 0;
                                         scl_mode   <= 0;
                                         scl_toggle <= 0;
                                         scl_h      <= 1;
                                         state      <= start;
                                     end

                             start : begin
//                                         sda_mode   <= 0;
                                         sda_toggle <= 0;
                                         sda_out    <= 0;
                                         scl_mode   <= 0;
                                         scl_h      <= 0;
                                         state      <= address_send;
                                     end    
                    
                      address_send : begin
                                       sda_mode   <= 0;
                                       scl_toggle <= 1;
                                       sda_toggle <= 0;
                                       sda_out    <= addr_to_send_store[count];
                                       count  <= count + 1;
                                       if(count == addressing_mode + 1)
                                        begin
                                         //scl_toggle <= 0;
                                         count     <= 0;
                                         sda_mode  <= 1;
//                                         sda_out   <= 1;
                                         state     <= address_ack;
                                        end
                                       else
                                           state   <= address_send; 
                                     end    

                       address_ack : begin
                                       if(sda_in == 0  && rw == 0) begin         // if(sda == 0 && addr_to_send_store[0] == 1)
                                           sda_mode   <= 0;
                                           sda_toggle <= 0;
                                           sda_out    <= 1;
                                           state      <= data_send_init;        // directs to the Write operation initializing conditino
                                       end else begin 
                                            if(sda_in == 0 && rw == 1) begin                                                
                                               sda_mode <= 1;
                                               sda_out  <= 1;
                                               state    <= data_read_ad;       // directs to the Read operation
                                            end else begin
                                               state    <= idle;
                                            end
                                       end
                                     end
                                      
                    data_send_init : begin
                                        sda_mode   <= 0;
                                        sda_toggle <= 0;
                                        sda_out    <= 0;
                                        scl_mode   <= 0;
                                        sda_toggle <= 0;
                                        scl_h      <= 0;
                                        state      <= data_send_ad;
                                     end 

                      data_send_ad : begin
                                        sda_mode   <= 0;
                                        scl_toggle <= 1;
                                        sda_toggle <= 0;
                                        sda_out    <= addr_reg_send_store[count];
                                        count      <= count + 1;
                                        if(count == addressing_mode + 1) begin
                    //                      scl_toggle <= 0;
                                           count      <= 0;
                                           sda_mode   <= 0;
                                           sda_toggle <= 1;
//                                           sda_in     <= 1;
                                           state      <= data_send_ad_ack;
                                        end else 
                                           state      <= data_send_ad;
                                     end

                  data_send_ad_ack : begin
                                           if(sda_in == 1) begin
                                               sda_mode   <= 0;
                                               sda_toggle <= 0;
                                               sda_out    <= 0;
                                               scl_mode   <= 0;
                                               scl_h      <= 1;                             //nack
                                               state      <= stop;                               //sda made high in tb
                                           end else begin
                                               sda_mode   <= 0;
                                               sda_toggle <= 0;
                                               sda_out    <= 0;
                                               scl_mode   <= 0;
                                               scl_h      <= 0;
                                               state      <= data_send;
                                          end
                                     end  

                         data_send : begin
                                        scl_toggle <= 1;
                                        sda_toggle <= 0;
                                        sda_out    <= data_to_send_store[count];
                                        count      <= count + 1;
                                        if(count == addressing_mode + 1) begin
                    //                      scl_toggle <= 0;
                                            count      <= 0;
                                            sda_mode   <= 0;
                                            sda_toggle <= 1;
//                                            sda_in     <= 1;
                                            state      <= data_send_ack;
                                        end else 
                                            state      <= data_send;
                                     end

                     data_send_ack : begin
                                      // count_ack_wait = count_ack_wait - 1;
                                      // if(count_ack_wait < 0) begin
                                        if(sda_in == 1)begin                             //nack
                                          sda_mode   <= 0;
                                          sda_toggle <= 0;
                                          sda_out    <= 1;
                                          scl_mode   <= 1;
                                          scl_h      <= 0;
                                          state      <= stop;                        //sda made high in tb
                                        end else begin
                                          sda_mode   <= 0;
                                          sda_toggle <= 0;
                                          sda_out    <= 0;
                                          scl_mode   <= 0;
                                          scl_h      <= 0;
                                          state      <= data_send_ad;
                                        end
                                     end

                      data_read_ad : begin
                                        scl_toggle <= 1;
                                        sda_out    <= addr_reg_read_store[count - 1];
                                        bit_count  <= bit_count - 1;
                                        if(bit_count == 0) begin
                    //                      scl_toggle <= 0;
                                           bit_count  <= 8;
                                           sda_mode   <= 0;
                                           sda_toggle <= 1;
//                                           sda_in     <= 1;
                                           state      <= data_read_ad_ack;
                                        end else 
                                           state     <= data_read_ad;
                                     end

                  data_read_ad_ack : begin
                                        if(sda_in == 1)                             //nack
                                         state <= stop;                             //sda made high in tb
                                        else begin
                                         sda_mode   <= 0;
                                         sda_toggle <= 1;
                                         sda_out    <= 1;
                                         state      <= data_read;
                                        end
                                     end

                         data_read : begin
                                         scl_toggle <= 1;
                                         data_read_store[bit_count - 1] <= sda_in;
                                         bit_count  <= bit_count - 1;
                                         if(bit_count == 0) begin
                       //                  scl_toggle <= 0;
                                           bit_count  <= 8;
                                           state      <= data_read_ack;                 // stop_init;
                                           sda_mode   <= 0;
                                           sda_toggle <= 1;
//                                           sda_in     <= 1;
                                         end else 
                                           state      <= data_read;
                                     end

                     data_read_ack : begin
                                         if(sda_in == 1) begin //nack
                                          sda_mode   <= 0;
                                          sda_toggle <= 0;
                                          sda_out    <= 0;
                                          scl_mode   <= 0;
                                          scl_h      <= 1;
                                          state      <= stop;                            //sda made high in tb
                                         end else begin
                                           sda_mode   <= 0;
                                           sda_toggle <= 0;
                                           sda_out    <= 1;
                                           state      <= data_read_ad;
                                         end
                                     end

                              stop : begin
                                        sda_mode           <= 0;
                                        sda_toggle         <= 0;
                                        sda_out            <= 1;
                                        scl_toggle         <= 0;
                                        scl_h              <= 1;
                                        scl_mode           <= 1;
                                        data_to_send_store <= 8'b0000_0000;
                                        addr_to_send_store <= 8'b0000_0000;
                                        state              <= idle;
                                     end
                            default: begin
                                        state              <= idle;
                                     end
             endcase
          end
     end
endmodule
