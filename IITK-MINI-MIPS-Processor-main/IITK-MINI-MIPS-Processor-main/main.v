
module mux_write_register(input sel,input [4:0] reg1,input [4:0] reg2,output [4:0] out);
    assign out = (sel) ? reg2 : reg1;
endmodule

module sign_extend(input [15:0] immediate,output [31:0] extended_immediate);
    assign extended_immediate = {{16{immediate[15]}}, immediate};
endmodule

module mux_alu_input(input [31:0] reg_out,input [31:0] sign_out,input sel,output [31:0] out);
    assign out = (sel) ? sign_out : reg_out;
endmodule

module mux_write_data(input [31:0] data_mem_out,input [31:0] alu_out,input sel,output [31:0] out);
    assign out = (sel) ? data_mem_out : alu_out;
endmodule

module pc_mux(input [31:0] just4, input [31:0] fromaddr, input sel, output [31:0] out);
    assign out = (sel) ? fromaddr : just4;
endmodule

module jump_mux(input [31:0] pc_mux_out,input [31:0] jump_addr,input sel,output [31:0] out);
    assign out = (sel) ? jump_addr : pc_mux_out;
endmodule

module lui_mux(input sel,input [31:0] lui_out,input [31:0] reg_out,output [31:0] out);
    assign out = (sel) ? lui_out : reg_out; 
endmodule

module main(clk,rst);
    // assuming instructions and data is loaded in the memory
    input clk,rst;
    wire [31:0] next_pc, pc,adder1_out, adder_out, instruction, sign_out, reg_out1, reg_out2, alu_result, write_data, read_mem_data,alu_input;
    wire [31:0] pc_mux_out;
    wire [4:0] write_register;
    wire mux_sel_write_reg, write_data_mux, mem_we, mux_sel_alu_input, reg_we,zero,jumpsel;
    wire [2:0] ALU_OP;
    wire [4:0] alu_control_out;
    wire [31:0] jump_address;
    wire sign,lt_unsigned;
    wire jump_return;
    wire jal;
    wire [4:0] final_write_reg=jal?5'b11111:write_register;
    wire [31:0] write_data_mux_out=jal?pc+1:write_data;
    reg [31:0] instr_reg;
    wire [31:0] lui_out;
    wire lui_sel;
    wire [31:0] final_alu_im;
    wire is_float,fpr_we;
    wire [31:0] fpu_out;
    wire [31:0] fpu_a,fpu_b;
    wire [3:0] fpu_control_out;
    wire fpr_we;
    wire [31:0] fpu_in;
    wire [31:0] final_wite_data=is_float?fpu_out:write_data_mux_out;

    always @(posedge clk or posedge rst) begin
        if (rst)
            instr_reg <= 32'b0;
        else
            instr_reg <= instruction;
    end
    assign jump_address = jump_return ? reg_out1:{pc[31:26], instruction[25:0]};
    instruction_memory im(.write_address(0),.write_data(0),.read_address(pc[8:0]),.clk(clk),.we(0),.instr_out(instruction));
    data_memory dm(.write_address(alu_result[8:0]),.write_data(reg_out2),.read_address(alu_result[8:0]),.clk(clk),.we(mem_we),.data_out(read_mem_data));
    registers reg_file(.read_register1(instruction[25:21]),.read_register2(instruction[20:16]),.write_register(final_write_reg),.write_data(final_wite_data),.reg_write(reg_we),.read_data_out1(reg_out1),.read_data_out2(reg_out2),.clk(clk));
    program_counter prog_counter(clk,next_pc,pc,rst);
    adder1 a1(pc,adder1_out,rst);
    adder a2(adder1_out,sign_out,adder_out);
    wire mux_sel_pc;
    pc_mux p_mux(adder1_out,adder_out,mux_sel_pc,pc_mux_out);
    jump_mux j_mux(pc_mux_out,jump_address,jumpsel,next_pc);
    mux_write_register mwr(mux_sel_write_reg,instruction[20:16],instruction[15:11],write_register);
    sign_extend se(instruction[15:0],sign_out);
    alu_control ac(instruction[5:0],ALU_OP,alu_control_out);
    mux_alu_input mau(reg_out2,sign_out,mux_sel_alu_input,alu_input);
    main_control mc(instruction[31:26],mux_sel_write_reg,write_data_mux,ALU_OP,mem_we,mux_sel_alu_input,reg_we,jumpsel,jump_return,jal,lui_sel,is_float,fpr_we,fpu_control_out,instruction[10:6]);
    mux_write_data mwdata(read_mem_data,alu_result,write_data_mux,write_data);
    ALU alu(reg_out1,final_alu_im,alu_control_out,alu_result,zero,sign,lt_unsigned,instr_reg[10:6],clk);
    branch_box bb(instruction[31:26],zero,sign,lt_unsigned,mux_sel_pc);
    lui_extend lui(instruction[15:0],lui_out);
    lui_mux lui_m(lui_sel,lui_out,alu_input,final_alu_im);

    //floating point unit
    
    /* module fp_registers(
    input [4:0] read_reg1, read_reg2, write_reg,
    input [31:0] write_data,
    input reg_write, clk,
    output [31:0] read_data1, read_data2
); */
/* module fpu(reg1,reg2,function_code,clk,result,gpr1,is_float); */
    fp_registers fpr(.read_reg1(instruction[25:21]),.read_reg2(instruction[20:16]),.write_reg(instruction[15:11]),.write_data(fpu_out),.reg_write(fpr_we),.clk(clk),.read_data1(fpu_a),.read_data2(fpu_b));
    fpu fpu_unit(fpu_a,fpu_b,fpu_control_out,clk,fpu_out,reg_out1,is_float);
endmodule