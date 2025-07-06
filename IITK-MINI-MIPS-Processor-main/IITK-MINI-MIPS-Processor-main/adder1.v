module adder1(input [31:0] present_pc,output reg [31:0] next_pc,input rst);
    always @(*) begin
        if (rst) begin
            next_pc = 0; // Reset the program counter to 0
        end else begin
        next_pc = present_pc + 1; // Increment the program counter by 1
        end
    end
endmodule