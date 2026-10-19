module CPU(
    input clk, rst, enable, prog_we,
    input [7:0] prog_address, prog_data,
    output [7:0] data_out, pc, instruction,
    output [7:0] R0, R1, R2, R3, R4, R5,
);

    wire [1:0] opcode;
    wire [7:0] alu_result, source_data;
    wire alu_zero, condition_met
    wire running = enable && !prog_we && !rst;
    wire [7:0] memory_address = prog_we ? prog_address : pc;
    wire jump = (opcode == 2' b11) && condition_met;
    reg wt;
    reg [2:0] wt_address;
    reg [7:0] write_data;

    RAM program_memory(
        .WT(prog_we),
        .clk(clk),
        .address(memory_address),
        .data_in(prog_data),
        .data_out(instruction)
    );

    ID decoder(
        .IN(instruction),
        .opcode(opcode),
    );

    PC program_counter(
        .jump(jump),
        .jump_address(R0),
        .clk(clk),
        .rst(rst),
        .enable(running),
        .pc(pc)
    );

    ALU arithmetic_unit(
        .A(R1),
        .B(R2),
        .option(instruction[2:0]),
        .result(alu_result),
        .zero(alu_zero)
    );

    cond condition_unit(
        .IN(R3),
        .condition(instruction[2:0]),
        .OUT(condition_met)
    );

    RegisterFiles registers(
        .clk(clk),
        .rst(rst),
        .wt(wt),
        .wt_address(wt_address),
        .rd_address(instruction[5:3]),
        .data_in(write_data),
        .read_data(source_data),
        .data_out(data_out),
        .R0(R0),
        .R1(R1),
        .R2(R2),
        .R3(R3),
        .R4(R4),
        .R5(R5)
    );

    always @ (*)
    begin
        wt = 1' b0;
        wt_address = 3' b0;
        write_data = 8' b0;
        if (running)
        begin
            case (opcode)
                2' b00:
                begin
                    wt = 1' b1;
                    wt_address = 3' b0;
                    write_data = {2' b00, instruction[5:0]};
                end

                2' b01:
                begin
                    wt = 1' b1;
                    wt_address = 3' d3;
                    write_data = alu_result;
                end

                2' b10:
                begin
                    wt = 1' b1;
                    wt_address = instruction[2:0];
                    write_data = source_data;
                end

                default:
                begin
                end
            endcase
        end
    end
endmodule