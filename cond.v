# The low 3-bit of the value in reg 3 is used to determine the condition
module cond(IN,OUT,condition,active);
    input [7:0] IN, condition;
    input active;
    output reg [7:0] OUT;

    reg [2:0] jump;
    
    always @ (posedge active)
    begin
        jump = {condition[2],condition[1],condition[0]};
        case (jump)
            3' b000 OUT = 0;
            3' b001 OUT = 1;
            3' b010 OUT = (IN == 0);
            3' b011 OUT = (IN != 0);
            3' b100 OUT = (IN < 0);
            3' b101 OUT = (IN >= 0);
            3' b110 OUT = (IN <= 0);
            3' b111 OUT = (IN > 0);
        endcase
    end
endmodule
