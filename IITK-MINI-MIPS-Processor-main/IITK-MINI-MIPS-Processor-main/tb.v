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
    $monitor($time,"pc=%d d1=%0d d2=%0d d3=%0d d4=%0d",my_main.pc,my_main.dm.memory[1],my_main.dm.memory[2],my_main.dm.memory[3],my_main.dm.memory[4]);    
     rst = 1; // Assert reset
    //my_main.reg_file.registers[1] = 32'h00000003; // Initialize memory for testing
    //my_main.reg_file.registers[2] = 32'h00000004; // Initialize memory for testing
    // add and write in 3rd register
    my_main.dm.memory[7]=32'h00000004; // Initialize memory for testing
    my_main.dm.memory[1]=32'hffffffff; // Initialize memory for testing
    my_main.dm.memory[2]=32'h00000003; // Initialize memory for testing
    my_main.dm.memory[3]=32'h00000002; // Initialize memory for testing
    my_main.dm.memory[4]= 32'h00000001; // Initialize memory for testing

    
    my_main.im.memory[0]=32'b001111_00000_00001_0000000000000000; // lui $1, 0
    my_main.im.memory[1]=32'b001101_00001_00001_0000000000000111; // ori $1, $1, 0
    //n=4
    my_main.im.memory[2]=32'b100011_00001_00100_0000000000000000; // lw $4, 0($1)
    //i=1
    my_main.im.memory[3]=32'b001111_00000_00001_0000000000000000; // lui $1, 0
    my_main.im.memory[4]=32'b001101_00001_00001_0000000000000001; // ori $1, $1, 1

    //lui $s3,0
    //ori $s3,$s3,1
    my_main.im.memory[5]=32'b001111_00000_00011_0000000000000000; // lui $3, 0
    my_main.im.memory[6]=32'b001101_00011_00011_0000000000000001; // ori $3, $3, 1

    //loop
    //slt $16,$1,$4 i<n
    my_main.im.memory[7]=32'b000000_00001_00100_10000_00000_101010; // slt $16, $1, $4

    //beq $16,$0,500
    my_main.im.memory[8]=32'b000100_10000_00000_0000000000111100; // beq $16, $0, 500

   // add $s7,$s3,$s1; # address of memory[i]
    my_main.im.memory[9]=32'b000000_00011_00001_00111_00000_100000; // add $s7, $s3, $s1

    //lw $t1, $s7; # load the current element (memory[i])
    my_main.im.memory[10]=32'b100011_00111_10001_0000000000000000; // lw $t1, 0($s7)

    //addi $s2, $s1, -1; # j = i - 1
    my_main.im.memory[11]=32'b001000_00001_00010_1111111111111111; // addi $s2, $s1, -1

    //slt $t0, $s2, $zero; # check if j < 0
    my_main.im.memory[12]=32'b000000_00010_00000_10000_00000_101010; // slt $t0, $s2, $zero

    //bne $16, $zero, 500; # if j < 0, jump to end
    my_main.im.memory[13]=32'b000101_10000_00000_0000_0000_0000_0111; // beq $16, $zero, 500

    //add $s5,$s3,$s2; # address of memory[j]
    my_main.im.memory[14]=32'b000000_00011_00010_00101_00000_100000; // add $s5, $s3, $s2

    // lw $18, $s5; # load the current element (memory[j])

    my_main.im.memory[15]=32'b100011_00101_10010_0000000000000000; // lw $t2, 0($s5)

    //slt $16, $17, $18; # check if current element < memory[j]
    my_main.im.memory[16]=32'b000000_10001_10010_10000_00000_101010; // slt $16, $t1, $t2

    //beq $16, $zero, 500; # if current element < memory[j], jump to end
    my_main.im.memory[17]=32'b000100_10000_00000_0000_0000_0000_0011; // beq $16, $zero, 500

    //sw $18, 1($s5); # move memory[j] to memory[j+1]
    my_main.im.memory[18]=32'b101011_00101_10010_0000000000000001; // sw $t2, 1($s5)

    //addi $s2, $s2, -1; # j--
    my_main.im.memory[19]=32'b001000_00010_00010_1111111111111111; // addi $s2, $s2, -1

    //j 12; # jump to the beginning of the loop
    my_main.im.memory[20]=32'b000010_00000_00000_00000_00000_001100; // j 12

    //endloop2
    //add $s5,$s3,$s2; # address of memory[j]
    my_main.im.memory[21]=32'b000000_00011_00010_00101_00000_100000; // add $s5, $s3, $s2

    //sw $t1, 1($s5); # insert current element at memory[j+1]
    my_main.im.memory[22]=32'b101011_00101_10001_0000000000000001; // sw $t1, 1($s5)

    //addi $s4, $s4, 1; # i++
    my_main.im.memory[23]=32'b001000_00001_00001_0000000000000001; // addi $s1, $s1, 1

    // j loop; # repeat loop
    my_main.im.memory[24]=32'b000010_00000_00000_00000_00000_000111; // j loop

    
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