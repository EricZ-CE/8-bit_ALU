module PC(jump, jump_address, clk, rst, pc);
    input jump,clk,rst;
    input [7:0] jump_address;
    output reg [7:0] pc;

    always @ (clk)
    begin
        if (rst)
            pc <= 0;
        else if (jump)
            pc <= jump_address;
        else
            pc <= pc + 8' b1;
    end

endmodule