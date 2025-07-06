module main_control(opcode,mux_sel_write_reg,mux_write_data_frommem,ALU_OP,mem_we,mux_sel_alu_input,reg_we,jumpsel,jump_return,jal,lui_sel,is_float,fpr_we,fpu_control,func_code);
    input [5:0] opcode;
    output reg mux_sel_write_reg,mux_write_data_frommem,mem_we,mux_sel_alu_input,reg_we,jumpsel,jump_return,jal,lui_sel,is_float,fpr_we;
    output reg [3:0] fpu_control;
    input [4:0] func_code;
    output reg [2:0] ALU_OP;


    always @(opcode or func_code) begin
        case (opcode)
            //floating point operations
            //mfc1
            6'b010001: begin
                if(func_code==5'b00000) begin 
                    is_float = 1;
                    fpu_control = 4'b0111;
                    fpr_we = 0;
                    reg_we = 1;
                    mux_sel_write_reg = 1;
                end else if(func_code==5'b00001) begin //mtc1
                    is_float = 1;
                    fpu_control = 4'b1000;
                    fpr_we = 1;
                    reg_we = 0;
                    mux_sel_write_reg = 0;
                    
                end
                //add.s
                else if(func_code==5'b00010) begin 
                    is_float = 1;
                    fpu_control = 4'b0000;
                    fpr_we = 1;
                    reg_we = 0;
                    mux_sel_write_reg = 0;
                  
                end
                //sub.s
                else if(func_code==5'b00011) begin 
                    is_float = 1;
                    fpu_control = 4'b0001;
                    fpr_we = 1;
                    reg_we = 0;
                    mux_sel_write_reg = 0;
                    
                end
                //mov.s
                else if(func_code==5'b00100) begin 
                    is_float = 1;
                    fpu_control = 4'b1001;
                    fpr_we = 1;
                    reg_we = 0;
                    mux_sel_write_reg = 0;
                    
                end
                else begin
                    is_float = 1;
                    fpu_control = 4'b0000; // Default operation
                    fpr_we = 0;
                    reg_we = 0;
                    mux_sel_write_reg = 0;
                    
                end
                mux_write_data_frommem = 0; // No memory write for floating point operations
                mem_we = 0; // No memory write for floating point operations
                mux_sel_alu_input = 0; // Use first register input for floating point operations
                jumpsel = 0; // No jump for floating point operations
                jump_return = 0; // No jump return for floating point operations
                jal = 0; // No jump and link for floating point operations
                lui_sel = 0; // No load upper immediate for floating point operations
                ALU_OP = 3'b000; // Default operation for floating point operations

            end

            6'b000000: begin // R-type
                mux_sel_write_reg = 1;//regdst
                mux_write_data_frommem = 0;//memto_reg
                mem_we = 0;//mem_write
                mux_sel_alu_input = 0;//alu_src
                reg_we = 1;//reg_write
                ALU_OP = 3'b010; // R-type operation
                jumpsel = 0;
                jump_return = 0; // No jump return for R-type
                jal = 0; // No jump and link for R-type
                lui_sel = 0; // No load upper immediate for R-type
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            // Add other cases for different opcodes here
            //load word
            6'b100011: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 1;
                mem_we = 0;
                mux_sel_alu_input = 1; // Use sign-extended immediate
                reg_we = 1;
                ALU_OP = 3'b000; // Load word operation
                jumpsel = 0;
                jump_return = 0; // No jump return for load word
                jal = 0; // No jump and link for load word
                lui_sel = 0; // No load upper immediate for load word
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            //store word
            6'b101011: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 1; // Write to memory
                mux_sel_alu_input = 1; // Use sign-extended immediate
                reg_we = 0; // No register write
                ALU_OP = 3'b000; // Store word operation
                jumpsel = 0;
                jump_return = 0; // No jump return for store word
                jal = 0; // No jump and link for store word
                lui_sel = 0; // No load upper immediate for store word
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            //beq
            6'b000100: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 0; // Use second register input
                reg_we = 0; // No register write
                ALU_OP = 3'b001; // Subtract for branch comparison
                jumpsel = 0;
                jump_return = 0; // No jump return for branch equal
                jal = 0; // No jump and link for branch equal
                lui_sel = 0; // No load upper immediate for branch equal
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            //bne
            6'b000101: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 0; // Use second register input
                reg_we = 0; // No register write
                ALU_OP = 3'b001; // Subtract for branch comparison
                jumpsel = 0; // Branch not equal operation
                jump_return = 0; // No jump return for branch not equal
                jal = 0; // No jump and link for branch not equal
                lui_sel = 0; // No load upper immediate for branch not equal
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            //bgt
            6'b000111: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 0; // Use second register input
                reg_we = 0; // No register write
                ALU_OP = 3'b001; // Subtract for branch comparison
                jumpsel = 0; // Branch greater than operation
                jump_return = 0; // No jump return for branch greater than
                jal = 0; // No jump and link for branch greater than
                lui_sel = 0; // No load upper immediate for branch greater than
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            //bgte
            6'b000110: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 0; // Use second register input
                reg_we = 0; // No register write
                ALU_OP = 3'b001; // Subtract for branch comparison
                jumpsel = 0; // Branch greater than or equal to operation
                jump_return = 0; // No jump return for branch greater than or equal to
                jal = 0; // No jump and link for branch greater than or equal to
                lui_sel = 0; // No load upper immediate for branch greater than or equal to
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            //blt
            6'b000001: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 0; // Use second register input
                reg_we = 0; // No register write
                ALU_OP = 3'b001; // Subtract for branch comparison
                jumpsel = 0; // Branch less than operation
                jump_return = 0; // No jump return for branch less than
                jal = 0; // No jump and link for branch less than
                lui_sel = 0; // No load upper immediate for branch less than
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            //blte
            6'b011100: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 0; // Use second register input
                reg_we = 0; // No register write
                ALU_OP = 3'b001; // Subtract for branch comparison
                jumpsel = 0; // Branch less than or equal to operation
                jump_return = 0; // No jump return for branch less than or equal to
                jal = 0; // No jump and link for branch less than or equal to
                lui_sel = 0; // No load upper immediate for branch less than or equal to
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            
            //bltu
            6'b011110: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 0; // Use second register input
                reg_we = 0; // No register write
                ALU_OP = 3'b001; // Subtract for branch comparison
                jumpsel = 0; // Branch less than or equal to operation
                jump_return = 0; // No jump return for branch less than or equal to
                jal = 0; // No jump and link for branch less than or equal to
                lui_sel = 0; // No load upper immediate for branch less than or equal to
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
               
            end
            //bgtu
            6'b011111: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 0; // Use second register input
                reg_we = 0; // No register write
                ALU_OP = 3'b001; // Subtract for branch comparison
                jumpsel = 0; // Branch less than or equal to operation
                jump_return = 0; // No jump return for branch less than or equal to
                jal = 0; // No jump and link for branch less than or equal to
                lui_sel = 0; // No load upper immediate for branch less than or equal to
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
               
            end
            
            
            // jump
            6'b000010: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 0; // Use first register input
                reg_we = 0; // No register write
                ALU_OP = 3'b000; // Default operation
                jumpsel = 1; // Jump operation
                jump_return = 0; // No jump return for jump
                jal = 0; // No jump and link for jump
                lui_sel = 0; // No load upper immediate for jump
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            // addi
            6'b001000: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 1; // Use sign-extended immediate
                reg_we = 1; // Register write enabled
                ALU_OP = 3'b000; // Add immediate operation
                jumpsel = 0;
                jump_return = 0; // No jump return for add immediate
                jal = 0; // No jump and link for add immediate
                lui_sel = 0; // No load upper immediate for add immediate
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
               
            end
            // andi
            6'b001100: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 1; // Use sign-extended immediate
                reg_we = 1; // Register write enabled
                ALU_OP = 3'b011; // AND immediate operation
                jumpsel = 0;
                jump_return = 0; // No jump return for AND immediate
                jal = 0; // No jump and link for AND immediate
                lui_sel = 0; // No load upper immediate for AND immediate
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            // ori
            6'b001101: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 1; // Use sign-extended immediate
                reg_we = 1; // Register write enabled
                ALU_OP = 3'b100; // OR immediate operation
                jumpsel = 0;
                jump_return = 0; // No jump return for OR immediate
                jal = 0; // No jump and link for OR immediate
                lui_sel = 0; // No load upper immediate for OR immediate
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            //xori
            6'b001110: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 1; // Use sign-extended immediate
                reg_we = 1; // Register write enabled
                ALU_OP = 3'b101; // XOR immediate operation
                jumpsel = 0;
                jump_return = 0; // No jump return for XOR immediate
                jal = 0; // No jump and link for XOR immediate
                lui_sel = 0; // No load upper immediate for XOR immediate
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            //slti
            6'b001010: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 1; // Use sign-extended immediate
                reg_we = 1; // Register write enabled
                ALU_OP = 3'b110; // Set less than immediate operation
                jumpsel = 0;
                jump_return = 0; // No jump return for set less than immediate
                jal = 0; // No jump and link for set less than immediate
                lui_sel = 0; // No load upper immediate for set less than immediate
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            //jr
            6'b011000: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 0; // Use first register input
                reg_we = 0; // No register write
                ALU_OP = 3'b000; // Default operation
                jumpsel = 1; // Jump register operation
                jump_return = 1; // Jump return enabled
                jal = 0; // No jump and link for jump register
                lui_sel = 0; // No load upper immediate for jump register
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            //jal
            6'b000011: begin
                mux_sel_write_reg = 1; // Write to link register
                mux_write_data_frommem = 0; // No memory write
                mem_we = 0;
                mux_sel_alu_input = 0; // Use first register input
                reg_we = 1; // Register write enabled
                ALU_OP = 3'b000; // Default operation
                jumpsel = 1; // Jump and link operation
                jump_return = 0; // No jump return for jump and link
                jal = 1; // Jump and link enabled
                lui_sel = 0; // No load upper immediate for jump and link
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            //lui
            6'b001111: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 1; // Use sign-extended immediate
                reg_we = 1; // Register write enabled
                ALU_OP = 3'b000; // Load upper immediate operation
                jumpsel = 0;
                jump_return = 0; // No jump return for load upper immediate
                jal = 0; // No jump and link for load upper immediate
                lui_sel = 1; // Load upper immediate enabled
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
            
            default: begin
                mux_sel_write_reg = 0;
                mux_write_data_frommem = 0;
                mem_we = 0;
                mux_sel_alu_input = 0;
                reg_we = 0;
                ALU_OP = 3'b000; // Default operation
                jumpsel = 0;
                jump_return = 0; // No jump return for default case
                jal = 0; // No jump and link for default case
                is_float = 0; // Not a floating point operation
                fpr_we = 0; // No floating point register write
                fpu_control = 4'b0000; // Default operation for R-type
                
            end
        endcase
    end
endmodule