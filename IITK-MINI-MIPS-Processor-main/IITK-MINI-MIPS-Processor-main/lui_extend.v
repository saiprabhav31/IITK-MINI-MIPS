`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2025 10:58:32 PM
// Design Name: 
// Module Name: lui_extend
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

module lui_extend (
    input [15:0] imm_in,
    output [31:0] imm_out
);
    assign imm_out = {imm_in, 16'b0}; // shift left by 16
endmodule
