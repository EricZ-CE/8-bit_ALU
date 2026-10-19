module ALU (
    input [7:0] A, B,
    input [2:0] option,
    output zero,
    output reg [7:0] result
);

    always @ (*)
    begin
        case (option)
            3' b000: result = A + B;
            3' b001: result = A - B;
            3' b010: result = A & B;
            3' b011: result = A | B;
            3' b100: result = A ^ B;
            3' b100: result = A << 1;
            3' b101: result = A >> 1;
            default: result = 8' b0;
        endcase
    assign zero = (result == 8' b0);
endmodule