`timescale 1ns/1ps

module cond(
    input [7:0] IN,
    input [2:0] condition,
    input active,
    output reg OUT
    );
    
    always @ (*)
    begin
        case (condition)
            3'b000: OUT = 1'b0;
            3'b001: OUT = 1'b1;
            3'b010: OUT = ($signed(IN) == 0);
            3'b011: OUT = ($signed(IN) != 0);
            3'b100: OUT = ($signed(IN) < 0);
            3'b101: OUT = ($signed(IN) >= 0);
            3'b110: OUT = ($signed(IN) <= 0);
            3'b111: OUT = ($signed(IN) > 0);
        endcase
    end
endmodule
