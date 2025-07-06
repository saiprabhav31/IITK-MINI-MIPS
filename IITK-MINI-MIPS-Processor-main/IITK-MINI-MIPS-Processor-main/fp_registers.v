module fp_registers(
    input [4:0] read_reg1, read_reg2, write_reg,
    input [31:0] write_data,
    input reg_write, clk,
    output [31:0] read_data1, read_data2
);
    reg [31:0] fp_regs[0:31];

    initial begin
        fp_regs[0] = 32'b0; // optional: fp regs are not usually hardwired
    end

    always @(posedge clk) begin
        if (reg_write) begin
            fp_regs[write_reg] <= write_data;
        end
    end

    assign read_data1 = fp_regs[read_reg1];
    assign read_data2 = fp_regs[read_reg2];
endmodule