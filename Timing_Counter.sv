`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.08.2024 13:57:48
// Design Name: 
// Module Name: Timing_Counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



//    input  wire clk_in,    // 100 MHz input clock
//    input  wire reset,     // Reset signal
//    output reg  clk_out   // 2 MHz output clock
//);

//    // Parameter to define the division factor
//    parameter DIV_FACTOR = 50; // 100 MHz / 2 MHz = 50

//    // Counter to keep track of clock cycles
//    logic [5:0] counter;

//    // Clock divider logic
//    always_ff @(posedge clk_in or posedge reset) begin
//        if (reset) begin
//            counter <= 0;
//            clk_out <= 0;
//        end else begin
//            if (counter == (DIV_FACTOR - 1)) begin
//                counter <= 0;
//                clk_out <= 1; // Toggle the output clock
//            end else begin
//                counter <= counter + 1;
//            end
//        end
//    end

//endmodule



module Timing_Counter(
    input      clk100mhz,
    input      reset,
    output     clk2mhz
);

    reg [5:0] count = 6'b000000;
    reg clock_temp;
    assign clk2mhz = clock_temp; 
       
    always_ff@(posedge clk100mhz or posedge reset)begin          // or always_comb? Check after running tb
            if (reset) begin
                clock_temp <= 0;
                count      <= 0;
            end else begin
                if(count <= 24) begin
                    clock_temp <= 1;
                    count   <= count + 1;
                end else if(count < 49)begin 
                              clock_temp <= 0;
                            count   <= count + 1;
                         end else if(count==49)begin
                              clock_temp <= 0;
                              count   <= 0;
                         end /*else begin
                              count <= count + 1;
                         end*/
            end
    end 
     
    endmodule  
//    always_ff@(posedge clk100mhz)begin
//            count <= count + 1;
//        if(count>=0 && count<=24) begin
//            clk2mhz       <= 0;
////            clk2mhz_dummy <= 0;
//        end else begin 
//            clk2mhz       <= 1;
////            clk2mhz_dummy <= 1;
//        end
//        if(count==49)begin
//            count   <= 0;
//        end
//     end
     
//endmodule
