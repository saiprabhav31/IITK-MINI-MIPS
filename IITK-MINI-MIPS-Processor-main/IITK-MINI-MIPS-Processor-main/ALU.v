module ALU(input [31:0] a,input [31:0] b,input [4:0] alu_control_out,output reg [31:0] result,output zero,output sign,output lt_unsigned,input [4:0] shamt,input clk);
    reg z, s, ltu;
    assign zero = z;
    assign sign = s;
    assign lt_unsigned = ltu;
    reg [31:0] high;
    reg [31:0] low;
    reg [63:0] product;
    always@(posedge clk) begin
        if(alu_control_out==5'b01011)begin
            low<=product[31:0];
            high<=product[63:32];
        end
    end
    always @(a, b, alu_control_out,shamt) begin
        //low=a+b;
        case (alu_control_out)
            0: result = a & b; // AND
            1: result = a | b; // OR
            2: result = $signed(a) + $signed(b); // ADD
            3: result = $signed(a) - $signed(b); // SUB
            4: result = a ^ b; // XOR
            5: result = ~(a | b); // NOR
            6: result = ($signed(a) < $signed(b)) ? 1 : 0; // SLT
            7: result = b << shamt; // Shift left logical
            8: result = b >> shamt; // Shift right logical
            9: result = $signed(b) >>> shamt; // Shift right arithmetic
            10: result = b << shamt; // Shift left arithmetic
            11:begin
             //product=a*b;
             product= a*b;
             end // Multiply
            //mflo
            12: result = low; // Move from LO
            //mfhi
            13: result = high; // Move from HI
            //for future use
            /* 7: result = a << b; // Shift left logical
            8: result = a >> b; // Shift right logical
            9: result = $signed(a) >>> b; // Shift right arithmetic
            10: result = a << b; // Shift left arithmetic
            //madd
            11: result = a * b; // Multiply
            //muddu
            12: result = a * b; // Multiply immediate
            //mul
            13: result=a*b; // Multiply unsigned */
            14: result=a+b; //Add unsigned
            15: result=a-b; //Sub unsigned
            default: result = 0; // Default operation
        endcase
         z = (result == 0);
        s = result[31];
        ltu = (a < b);
    end
endmodule