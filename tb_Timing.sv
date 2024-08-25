`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2024 20:13:46
// Design Name: 
// Module Name: tb_Timing
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


module tb_Timing();

    reg  clk100mhz;    // 100 MHz input clock
    reg  reset;     // Reset signal
    wire clk2mhz;

    Timing_Counter T1(
        .clk100mhz(clk100mhz),
        .reset(reset),
        .clk2mhz(clk2mhz)
    );

    parameter CLK_PERIOD = 10;

    initial begin
        clk100mhz = 1'b1;
        forever #(CLK_PERIOD/2) clk100mhz = ~clk100mhz;
    end
    
    initial begin
              reset = 1'b0;
        #20   reset = 1'b1;
//        #1500 $finish();
    end
 
endmodule
