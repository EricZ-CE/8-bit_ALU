`timescale 1ns/1ps

module ID(
    input [7:0] IN,
    output [1:0] opcode
    );

    assign opcode=IN[7:6];
endmodule
