module registers(read_register1,read_register2,write_register,write_data,reg_write,read_data_out1,read_data_out2,clk);
    input [4:0] read_register1,read_register2,write_register;
    input [31:0] write_data;
    input reg_write,clk;
    output [31:0] read_data_out1,read_data_out2;

    reg [31:0] registers[0:31];
    
    initial begin
        registers[0] = 32'b0;
    end

    always @(posedge clk) begin
        if (reg_write && write_register!=0) begin
            registers[write_register] <= write_data;
        end
    end

    assign read_data_out1 = registers[read_register1];
    assign read_data_out2 = registers[read_register2];
endmodule