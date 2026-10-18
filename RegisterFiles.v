module RegisterFiles();
    input clk, rst, wt;
    input [2:0] wt_address;
    input [7:0] data_in;

    output [7:0] R0, R1, R2, R3, R4, R5
    output reg [7:0] data_out;

    register reg0(
        .IN(data_in),
        .OUT(R0),
        .CLK(clk),
        .RST(rst),
        .WT(wt && wt_address == 3' b000)
    );

    register reg1(
        .IN(data_in),
        .OUT(R1),
        .CLK(clk),
        .RST(rst),
        .WT(wt && wt_address == 3' b001)
    );

    register reg2(
        .IN(data_in),
        .OUT(R2),
        .CLK(clk),
        .RST(rst),
        .WT(wt && wt_address == 3' b010)
    );

    register reg3(
        .IN(data_in),
        .OUT(R3),
        .CLK(clk),
        .RST(rst),
        .WT(wt && wt_address == 3' b011)
    );

    register reg4(
        .IN(data_in),
        .OUT(R4),
        .CLK(clk),
        .RST(rst),
        .WT(wt && wt_address == 3' b100)
    );

    register reg5(
        .IN(data_in),
        .OUT(R5),
        .CLK(clk),
        .RST(rst),
        .WT(wt && wt_address == 3' b101)
    );

    always @ (posedge clk)
    begin
        if (wt_address == 3' b110)
            data_out <= data_in;
    end
endmodule