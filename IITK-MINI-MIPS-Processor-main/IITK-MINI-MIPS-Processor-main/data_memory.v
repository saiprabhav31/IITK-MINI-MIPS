
module data_memory(write_address,write_data,read_address,clk,we,data_out);
    input [8:0] write_address,read_address;
    input [31:0] write_data;
    input clk,we;
    output [31:0] data_out;

    /*dist_mem_gen_1 data_mem (
        .a(write_address),        // input wire [8 : 0] a
        .d(write_data),          // input wire [31 : 0] d
        .dpra(read_address),     // input wire [8 : 0] dpra
        .clk(clk),               // input wire clk
        .we(we),                 // input wire we
        .dpo(data_out)          // output wire [31 : 0] dpo
    );*/
    reg [31:0] memory[511:0];
    always @(posedge clk) begin
        if (we) begin
            memory[write_address] <= write_data;
        end
    end
    assign data_out = memory[read_address];
endmodule