module tb_master();
     wire        sda;
     wire        scl;
	 wire        sda_out;
     wire        scl_out;
     wire        clk2mhz_dummy; 
     wire        rw;
     reg         sda_in;
     reg         clk100mhz;     
     reg         res;
     reg   [7:0] data_to_send; 
     reg   [7:0] addr_to_send;  
     reg   [7:0] addr_reg_send;
     reg   [7:0] addr_reg_read;

     i2c_master_wrapper Master_1(
        .sda(sda),
        .scl(scl),
        .sda_out(sda_out),
        .scl_out(scl),
        .clk2mhz_dummy(clk2mhz_dummy),  
        .rw(rw),
        .sda_in(sda_in),
        .clk100mhz(clk100mhz),  
        .res(res),
        .data_to_send(data_to_send), 
        .addr_to_send(addr_to_send), 
        .addr_reg_send(addr_reg_send),
        .addr_reg_read(addr_reg_read)
      );

     parameter CLK_PERIOD = 10;

      initial begin
        clk100mhz = 1'b1;
        forever #(CLK_PERIOD/2) clk100mhz = ~clk100mhz;
      end

      // Reset
     initial begin
       #0  res = 1'b1;
       #20 res = 1'b0;
     end

     initial begin
//        #50
//        sda_in        = 1'h00;
//        addr_to_send  = 8'h00;          //8
//        addr_reg_send = 8'h00;          //8
//        addr_reg_read = 8'h00;          //8
//        data_to_send  = 8'h00;          //8

        #250
        sda_in        = 1'h00;
        addr_to_send  = 8'h02;          //8
        addr_reg_send = 8'h01;          //8
        addr_reg_read = 8'h00;          //8
        data_to_send  = 8'h01;          //8
        #16000
        sda_in        = 1'b1;

//        #7150
//        sda_in        = 1'h00;
//        addr_to_send  = 8'h03;          //8
//        addr_reg_send = 8'h04;          //8
//        addr_reg_read = 8'h00;          //8
//        data_to_send  = 8'h04;          //8

//        #14300
//        sda_in        = 1'h00;
//        addr_to_send  = 8'h06;          //8
//        addr_reg_send = 8'h01;          //8
//        addr_reg_read = 8'h00;          //8
//        data_to_send  = 8'h01;          //8
     end

   endmodule