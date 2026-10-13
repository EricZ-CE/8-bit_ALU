# 8-bit input, the highest 2-bit determine the mod
module ID(IN, OUT, active);
    input active;
    input [7:0] IN;
    output reg [2:0] OUT;

    always @ (posedge active)
    begin
        OUT = {IN[7],IN[6]};
    end
endmodule