`timescale 1ns/1ps

module register(
    input [7:0] IN,
    input CLK, RST, WT,
    output reg [7:0] OUT
    );

    always @ (posedge CLK)
    begin
        if (RST)
            OUT <= 8'b0;
        else if (WT)
            OUT <= IN;
    end
endmodule
        