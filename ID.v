# 8-bit input, the highest 2-bit determine the mod
module ID(
    input [7:0] IN,
    output [1:0] opcode
);

    assign opcode = IN[7:6];
endmodule