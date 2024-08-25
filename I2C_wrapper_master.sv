`timescale 1ns / 1ps

module i2c_master_wrapper(
    inout        sda,
    inout        scl,
    output       sda_out,
    output       scl_out,
    output       clk2mhz_dummy,
    output       rw,
    input        sda_in,
    input        clk100mhz,
    input        res,
    input  [7:0] data_to_send,
    input  [7:0] addr_to_send,
    input  [7:0] addr_reg_send,
    input  [7:0] addr_reg_read
);

    // Instantiating the i2c_master module
    i2c_master i2c_master_wrap1 (
        .sda_out(sda_out),
        .scl_out(scl_out),
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

    reg sda_r;
    reg scl_r;

    assign sda = sda_r;
    assign scl = scl_r;

    always@*begin
    if(rw == 1)begin
        sda_r = sda_out;
        scl_r = scl_out;
    end else begin
        sda_r = sda_in;
        scl_r = scl_out;
    end
end

endmodule