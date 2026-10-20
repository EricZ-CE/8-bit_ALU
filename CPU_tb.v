`timescale 1ns/1ps
module CPU_tb;
reg clk=0;
reg rst=1, enable=0, prog_we=0;
reg [7:0] prog_address=0, prog_data=0;
wire [7:0] data_out,pc,instruction,R0,R1,R2,R3,R4,R5;
integer checks=0;
CPU dut(.clk(clk),.rst(rst),.enable(enable),.prog_we(prog_we),
 .prog_address(prog_address),.prog_data(prog_data),
 .data_out(data_out),.pc(pc),.instruction(instruction),
 .R0(R0),.R1(R1),.R2(R2),.R3(R3),.R4(R4),.R5(R5));
always #5 clk=~clk;

// Program memory is loaded via the CPU's public programming interface.
task load;
 input [7:0] address,value;
 begin
  @(negedge clk);
  prog_we=1; enable=1; prog_address=address; prog_data=value;
  @(posedge clk); #1;
  if ({pc,R0,R1,R2,R3,R4,R5,data_out} !== 64'd0)
   $fatal(1,"Programming changed architectural state");
  if (instruction !== value)
   $fatal(1,"Program readback failed at address %0d",address);
 end
endtask

// Sample after nonblocking assignments have settled.
task step;
 input [7:0] ep,e0,e1,e2,e3,e4,e5,eo;
 begin
  @(posedge clk); #1;
  if ({pc,R0,R1,R2,R3,R4,R5,data_out} !== {ep,e0,e1,e2,e3,e4,e5,eo}) begin
   $display("FAIL check %0d time=%0t",checks+1,$time);
   $display("actual pc=%0d R0=%0d R1=%0d R2=%0d R3=%0d R4=%0d R5=%0d out=%0d",
    pc,R0,R1,R2,R3,R4,R5,data_out);
   $display("expect pc=%0d R0=%0d R1=%0d R2=%0d R3=%0d R4=%0d R5=%0d out=%0d",
    ep,e0,e1,e2,e3,e4,e5,eo);
   $fatal(1,"CPU state mismatch");
  end
  checks=checks+1;
  $display("PASS %0d: pc=%0d R3=%0d out=%0d",checks,pc,R3,data_out);
  @(negedge clk);
 end
endtask

initial begin
 $dumpfile("CPU_tb.vcd");
 $dumpvars(0,CPU_tb);
 // Timeout prevents a stuck testbench from running forever.
 #100000;
 $fatal(1,"Testbench timeout");
end

initial begin
 step(0,0,0,0,0,0,0,0);
 rst=0;
 // enable=1 deliberately: prog_we must still block execution.
 enable=0;
 load(8'd0,8'h05);
 load(8'd1,8'h81);
 load(8'd2,8'h03);
 load(8'd3,8'h82);
 load(8'd4,8'h40);
 load(8'd5,8'h9e);
 load(8'd6,8'h9c);
 load(8'd7,8'h41);
 load(8'd8,8'h0c);
 load(8'd9,8'hc2);
 load(8'd10,8'hc3);
 load(8'd11,8'h3f);
 load(8'd12,8'h44);
 load(8'd13,8'h42);
 load(8'd14,8'h43);
 load(8'd15,8'h45);
 load(8'd16,8'h46);
 load(8'd17,8'h41);
 load(8'd18,8'h99);
 load(8'd19,8'h9a);
 load(8'd20,8'h41);
 load(8'd21,8'h18);
 load(8'd22,8'hc2);
 load(8'd23,8'h3f);
 load(8'd24,8'h9d);
 load(8'd25,8'h1c);
 load(8'd26,8'hc1);
 load(8'd27,8'h3f);
 load(8'd28,8'hc0);
 load(8'd29,8'ha6);
 load(8'd30,8'h1f);
 load(8'd31,8'hc1);
 @(negedge clk); prog_we=0; enable=1;
 step(1,5,0,0,0,0,0,0);
 step(2,5,5,0,0,0,0,0);
 step(3,3,5,0,0,0,0,0);
 step(4,3,5,3,0,0,0,0);
 step(5,3,5,3,8,0,0,0);
 // Pause immediately before MOV R3 -> output; no state may change.
 enable=0;
 step(5,3,5,3,8,0,0,0);
 step(5,3,5,3,8,0,0,0);
 enable=1;
 step(6,3,5,3,8,0,0,8);
 step(7,3,5,3,8,8,0,8);
 step(8,3,5,3,2,8,0,8);
 step(9,12,5,3,2,8,0,8);
 step(10,12,5,3,2,8,0,8);
 step(12,12,5,3,2,8,0,8);
 step(13,12,5,3,6,8,0,8);
 step(14,12,5,3,1,8,0,8);
 step(15,12,5,3,7,8,0,8);
 step(16,12,5,3,10,8,0,8);
 step(17,12,5,3,2,8,0,8);
 step(18,12,5,3,2,8,0,8);
 step(19,12,2,3,2,8,0,8);
 step(20,12,2,2,2,8,0,8);
 step(21,12,2,2,0,8,0,8);
 step(22,24,2,2,0,8,0,8);
 step(24,24,2,2,0,8,0,8);
 step(25,24,2,2,0,8,0,8);
 step(26,28,2,2,0,8,0,8);
 step(28,28,2,2,0,8,0,8);
 step(29,28,2,2,0,8,0,8);
 step(30,28,2,2,0,8,0,8);
 step(31,31,2,2,0,8,0,8);
 step(31,31,2,2,0,8,0,8);
 // Reset must clear registers and output even when execution is disabled.
 enable=0; rst=1;
 step(0,0,0,0,0,0,0,0);
 $display("All CPU tests passed! (%0d state checks + 32 program readbacks)",checks);
 $finish;
end
endmodule
