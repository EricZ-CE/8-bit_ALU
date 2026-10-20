`timescale 1ns/1ps

module RAM(
    input WT, clk,
    input [7:0] address, data_in,
    output [7:0] data_out
    );

    reg [7:0] memory [0:255];

    always @ (posedge clk)
    begin
        if (WT)
            memory[address] <= data_in;
    end

    assign data_out = memory[address];
endmodule