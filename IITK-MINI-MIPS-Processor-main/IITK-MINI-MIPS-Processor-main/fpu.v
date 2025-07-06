module Float_Add(
    input [31:0] X, Y,   
    output reg [31:0] sum   
);

    reg X_sign, Y_sign, sum_sign;
    reg [7:0] X_exp, Y_exp, sum_exp;
    reg [23:0] X_mant, Y_mant, X_mantissa, Y_mantissa;
    reg [24:0] sum_mantissa_temp;
    reg [7:0] expsub;
    reg is_X_inf, is_Y_inf, is_X_nan, is_Y_nan, is_X_zero, is_Y_zero;
    integer lead_zero;
    integer i;

    

    always @(*) begin
        X_sign = X[31];
        X_exp = X[30:23];
        X_mant = (X_exp != 0) ? {1'b1, X[22:0]} : {1'b0, X[22:0]}; 
        Y_sign = Y[31];
        Y_exp = Y[30:23];
        Y_mant = (Y_exp != 0) ? {1'b1, Y[22:0]} : {1'b0, Y[22:0]}; 
        // Check Special Cases
        is_X_inf = (X_exp == 8'hFF) && (X[22:0] == 0);
        is_Y_inf = (Y_exp == 8'hFF) && (Y[22:0] == 0);
        is_X_nan = (X_exp == 8'hFF) && (X[22:0] != 0);
        is_Y_nan = (Y_exp == 8'hFF) && (Y[22:0] != 0);
        is_X_zero = (X_exp == 0) && (X[22:0] == 0);
        is_Y_zero = (Y_exp == 0) && (Y[22:0] == 0);

        // Handle NaN/Inf/Zero
        if (is_X_nan || is_Y_nan) begin
            sum_sign = 0;
            sum_exp = 8'hFF;
            sum_mantissa_temp = {1'b1, 23'h1}; // NaN
        end
        else if (is_X_inf || is_Y_inf) begin
            if (is_X_inf && is_Y_inf && (X_sign != Y_sign)) begin
                sum_sign = 0;
                sum_exp = 8'hFF;
                sum_mantissa_temp = {1'b1, 23'h1}; // NaN for Inf-Inf
            end else begin
                sum_sign = is_X_inf ? X_sign : Y_sign;
                sum_exp = 8'hFF;
                sum_mantissa_temp = 25'h0; // Inf
            end
        end
        else if (is_X_zero && is_Y_zero) begin
            sum_sign = X_sign & Y_sign; // -0 + -0 = -0
            sum_exp = 0;
            sum_mantissa_temp = 25'h0;
        end
        else if (is_X_zero) begin
            sum_sign = Y_sign;
            sum_exp = Y_exp;
            sum_mantissa_temp = Y_mant;
        end
        else if (is_Y_zero) begin
            sum_sign = X_sign;
            sum_exp = X_exp;
            sum_mantissa_temp = X_mant;
        end
        else begin
            
            
            if (Y_exp>X_exp) begin 
                expsub = Y_exp - X_exp;
                X_mantissa = X_mant >> (expsub);
                Y_mantissa = Y_mant;
                sum_exp = Y_exp;
            end else begin
                expsub = X_exp - Y_exp;
                X_mantissa = X_mant;
                Y_mantissa = Y_mant >> expsub;
                sum_exp = X_exp;
            end

            
            if (X_sign == Y_sign) begin
                sum_mantissa_temp = X_mantissa + Y_mantissa;
                sum_sign = X_sign;
            end else begin
                if (X_mantissa > Y_mantissa) begin
                    sum_mantissa_temp = X_mantissa - Y_mantissa;
                    sum_sign = X_sign;
                end else begin
                    sum_mantissa_temp = Y_mantissa - X_mantissa;
                    sum_sign = Y_sign;
                end
            end

            // Normalize Result
            if (sum_mantissa_temp[24]) begin // Overflow
                sum_mantissa_temp = sum_mantissa_temp >> 1;
                sum_exp = sum_exp + 1;
                if (sum_exp == 8'hFF) sum_mantissa_temp = 25'h0;
                else begin
                    sum_mantissa_temp=sum_mantissa_temp;
                end 
            end else begin
                
                lead_zero = 24;
                for (i = 23; i >= 0; i = i - 1) begin
                    if (sum_mantissa_temp[i] && lead_zero == 24) begin
                        lead_zero = 23 - i;
                    end
                    else begin
                        lead_zero = lead_zero;
                    end
                end

                if (lead_zero != 24) begin
                    if (sum_exp > lead_zero) begin
                        sum_exp = sum_exp - lead_zero;
                        sum_mantissa_temp = sum_mantissa_temp << lead_zero;
                    end else begin
                        sum_mantissa_temp = sum_mantissa_temp << (sum_exp - 1);
                        sum_exp = 0;
                    end
                end
                else begin
                    sum_exp = 0;
                end
            end
        end
        sum = {sum_sign, sum_exp, sum_mantissa_temp[22:0]};
    end
endmodule

module fpu(reg1,reg2,function_code,clk,result,gpr1,is_float);
    input [31:0] reg1,reg2;
    input is_float;
    input [3:0] function_code;
    input [31:0] gpr1;
    input clk;
    output reg [31:0] result;
    reg [2:0] cc;
    reg [2:0] cc1;
    wire [31:0] add_result,sub_result;
    always @(posedge clk) begin
        if (is_float && (function_code==4'b0010 || function_code==4'b0011 || function_code==4'b0100 || function_code==4'b0101 || function_code==4'b0110 ) ) begin
            cc <=cc1; // Reset cc on clock edge
        end else begin
            cc <= 3'b000; // Reset cc on clock edge
        end
    end
    
    Float_Add fadd(
        .X(reg1),
        .Y(reg2),
        .sum(add_result)
    );
    Float_Add fsub(
        .X(reg1),
        .Y({~reg2[31],reg2[30:0]}),
        .sum(sub_result)
    );
    always @(*) begin
        case(function_code)
            4'b0000: begin // ADD
                result = add_result;
            end
            4'b0001: begin // SUB
                result = sub_result;
            end
            //c.eq.s
            4'b0010: begin // C.EQ.S
                cc1 = (reg1 == reg2) ? 3'b001 : 3'b000;
                result = {cc, 29'b0};
            end
            //c.lt.s
            4'b0011: begin // C.LT.S
                if(reg1[31] == 0 && reg2[31] == 1) begin
                    cc1 = 3'b001;
                end else if (reg1[31] == 1 && reg2[31] == 0) begin
                    cc1 = 3'b000;
                end else if (reg1[31] == 0 && reg2[31] == 0) begin
                    cc1 = (reg1 < reg2) ? 3'b001 : 3'b000;
                end else begin
                    cc1 = (reg2 < reg1) ? 3'b001 : 3'b000;
                end
                result = {cc, 29'b0};
            end
            //c.le.s
            4'b0100: begin // C.LE.S
                if(reg1[31] == 0 && reg2[31] == 1) begin
                    cc1 = 3'b001;
                end else if (reg1[31] == 1 && reg2[31] == 0) begin
                    cc1 = 3'b000;
                end else if (reg1[31] == 0 && reg2[31] == 0) begin
                    cc1 = (reg1 <= reg2) ? 3'b001 : 3'b000;
                end else begin
                    cc1 = (reg2 <= reg1) ? 3'b001 : 3'b000;
                end
                result = {cc, 29'b0};
            end
            //c.gt.s
            4'b0101: begin // C.GT.S
                if(reg1[31] == 0 && reg2[31] == 1) begin
                    cc1 = 3'b000;
                end else if (reg1[31] == 1 && reg2[31] == 0) begin
                    cc1 = 3'b001;
                end else if (reg1[31] == 0 && reg2[31] == 0) begin
                    cc1 = (reg1 > reg2) ? 3'b001 : 3'b000;
                end else begin
                    cc1 = (reg2 > reg1) ? 3'b001 : 3'b000;
                end
                result = {cc, 29'b0};
            end
            //c.ge.s
            4'b0110: begin // C.GE.S
                if(reg1[31] == 0 && reg2[31] == 1) begin
                    cc1 = 3'b000;
                end else if (reg1[31] == 1 && reg2[31] == 0) begin
                    cc1 = 3'b001;
                end else if (reg1[31] == 0 && reg2[31] == 0) begin
                    cc1 = (reg1 >= reg2) ? 3'b001 : 3'b000;
                end else begin
                    cc1 = (reg2 >= reg1) ? 3'b001 : 3'b000;
                end
                result = {cc, 29'b0};
            end
            //mfc1
            4'b0111: begin // MFC1
                result = reg1;
            end
            //mtc1
            4'b1000: begin // MTC1
                result = gpr1;
            end
            //mov.s cc f0,f1
            4'b1001: begin // MOV.S
                result = reg1;
            end
            default begin
            result=0;
            end
            
        endcase
    end

endmodule