`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2025 05:49:47 PM
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb();
    reg clk, rst;
initial begin
    clk = 0;
    forever #1 clk = ~clk; // Toggle clock every 5 time units
end

main my_main(
    .clk(clk),
    .rst(rst)
);

initial begin
    //my_main.reg_file.registers[1] = 32'h00000003; // Initialize memory for testing
    //my_main.reg_file.registers[2] = 32'h00000004; // Initialize memory for testing
    // add and write in 3rd register
    rst = 1; // Assert reset
    my_main.dm.memory[0]=32'h40200000;
    my_main.dm.memory[1]=32'h40100000;
        
    my_main.im.memory[0]=32'b001111_00000_00001_0000000000000000; // lui $1, 0
    my_main.im.memory[1]=32'b001101_00001_00001_0000000000000000; // ori $1, $1, 0
    // lw $2, 0($1)
    my_main.im.memory[2]=32'b100011_00001_00010_0000000000000000; // lw $2, 0($1)
    //lw $3, 0($1)
    my_main.im.memory[3]=32'b100011_00001_00011_0000000000000001; // lw $3, 0($1)
    // mtc1 $2, $f2
    my_main.im.memory[4]=32'b010001_00010_00000_00010_00001_000000; // mtc1 $2, $f2
    // mtc1 $3, $f3
    my_main.im.memory[5]=32'b010001_00011_00000_00011_00001_000000; // mtc1 $3, $f3
    // add.s $f4, $f2, $f3
    my_main.im.memory[6]=32'b010001_00010_00011_00100_00011_000000; // add.s $f4, $f2, $f3
    //mfc1 $4, $f4
    my_main.im.memory[7]=32'b010001_00100_00000_00100_00000_000000; // mfc1 $2, $f4
    // sw $4, 2($1)
    my_main.im.memory[8]=32'b101011_00001_00100_0000000000000000; // sw $4, 0($1)

    #0.5
    rst = 0; // Deassert reset
    $display("pc=%0d",my_main.prog_counter.pc_out);
    // Check if the result is correct
    $display("instruction=%b",my_main.im.read_address);
     $display("pc=%h",my_main.prog_counter.pc_out);
     $display("main control=%b",my_main.write_data_mux);
     $display("write data=%b" ,my_main.write_data);
     $display("ALU a = %h, b = %h, control = %d, shamt = %d", my_main.alu.a, my_main.alu.b, my_main.alu.alu_control_out, my_main.alu.shamt);

    #800
    $display("$f4=%h",my_main.fpr.fp_regs[4]);
    $display("low=%h",my_main.alu.low);
    $display("dm[2]=%h",my_main.dm.memory[2]);
    $display("dm[0]",my_main.dm.memory[0]);
    $display("instruction=%b",my_main.im.read_address);
    $display("pc=%h",my_main.prog_counter.pc_out);
    $display("Test passed: $2 = %h", my_main.reg_file.registers[2]);
    $display("Test passed: $4 = %h", my_main.reg_file.registers[4]);
    $display("Test failed: $3 = %h", my_main.reg_file.registers[3]);
    $display("im[1] =%d",my_main.dm.memory[1]);
    $display("im[2] =%d",my_main.dm.memory[2]);
    $display("im[3] =%d",my_main.dm.memory[3]);
    $display("im[4] =%d",my_main.dm.memory[4]);
    end
endmodule