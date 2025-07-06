module branch_box(opcode,zero,sign,lt_unsigned,out);
    input [5:0] opcode;
    input zero;
    input sign;
    input lt_unsigned;
    output reg out;

    always @(opcode,zero,sign,lt_unsigned) begin
        case (opcode)
            6'b000100: begin // beq
                out = zero;
            end
            6'b000101: begin // bne
                out = ~zero;
            end
            //bgt
            6'b000111: begin // bgt
                out = ~zero & ~sign;
            end
            //bgte
            6'b000110: begin // bgte
                out = zero | ~sign;
            end
            //blt
            6'b000001: begin // blt
                out = ~zero & sign;
            end
            //blte
            6'b011100: begin // blte
                out = zero | sign;
            end

            //bleu
            6'b011110: begin // bleu
                out = lt_unsigned;
            end
            //bgtu
            6'b011111: begin // bgtu
                out = ~lt_unsigned;
            end

            default: begin
                out = 0; // Default case for other opcodes
            end
        endcase
    end
endmodule