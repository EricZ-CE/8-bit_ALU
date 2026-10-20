`timescale 1ns/1ps

module PC(
    input jump, clk, rst, enable,
    input [7:0] jump_address,
    output reg [7:0] pc
    );

    always @ (posedge clk)
    begin
        if (rst)
            pc <= 8'b0;
        else if (enable)
        begin
            if (jump)
                pc <= jump_address;
            else
                pc <= pc + 8'b1;
        end
    end
endmodule