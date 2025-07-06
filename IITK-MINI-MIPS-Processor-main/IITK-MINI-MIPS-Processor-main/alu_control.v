module alu_control(funct,ALU_OP,alu_control_out);
    input [5:0] funct;
    input [2:0] ALU_OP;
    output reg [4:0] alu_control_out;

    always @(funct, ALU_OP) begin
        case (ALU_OP)
            3'b000: alu_control_out = 5'b00010; // ADD
            3'b001: alu_control_out = 5'b00011; // SUB
            3'b010: begin // R-type
                case (funct)
                    6'b100000: alu_control_out = 5'b00010; // ADD
                    6'b100010: alu_control_out = 5'b00011; // SUB
                    6'b100100: alu_control_out = 5'b00000; // AND
                    6'b100101: alu_control_out = 5'b00001; // OR
                    6'b101010: alu_control_out = 5'b00110; // SLT
                    6'b100111: alu_control_out = 5'b00101; // NOR
                    6'b100001: alu_control_out = 5'b01110; // ADDU
                    6'b100011: alu_control_out = 5'b01111; // SUBU
                    6'b100110: alu_control_out = 5'b00100; // XOR
                    6'b000000: alu_control_out = 5'b00111; // SLL
                    6'b000010: alu_control_out = 5'b01000; // SRL
                    6'b000011: alu_control_out = 5'b01001; // SRA
                    6'b011000: alu_control_out = 5'b01011; // MULT
                    6'b010010: alu_control_out = 5'b01100; // MFLO
                    6'b010000: alu_control_out = 5'b01101; // MFHI
                    //for future use
                    /* 6'b000000: alu_control_out = 5'b00111; // SLL
                    6'b000010: alu_control_out = 5'b01000; // SRL
                    6'b000011: alu_control_out = 5'b01001; // SRA
                    6'b000100: alu_control_out = 5'b01010; // SLLV
                    6'b011000: alu_control_out = 5'b01100; // MULT
                    6'b011001: alu_control_out = 5'b01101; // MADDU
                    6'b011010: alu_control_out = 5'b01110; // MUDDU
                    6'b011011: alu_control_out = 5'b01111; // MUL */
                    default: alu_control_out = 5'b00000; // Default operation
                endcase
            end
            3'b011: alu_control_out = 5'b00000; // AND
            3'b100: alu_control_out = 5'b00001; // OR
            3'b101: alu_control_out = 5'b00100; // XOR
            3'b110: alu_control_out = 5'b00110; // SLT
            default: alu_control_out = 5'b00000; // Default operation
        endcase
    end
endmodule