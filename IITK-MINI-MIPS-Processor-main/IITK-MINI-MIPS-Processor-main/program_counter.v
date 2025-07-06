module program_counter(clk,next_pc,pc_out,rst);
    input clk,rst;
    input [31:0] next_pc;
    output reg [31:0] pc_out;
     always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 0; // Reset the program counter to 0
        end else begin
            pc_out <= next_pc; // Update the program counter with the next address
        end 
    end
endmodule