module Mixcoloumn(
    input wire clock,
    input wire rst,
    input wire[3:0] st_mixcoloumn[0:3][0:3],
    output reg[3:0] mixc_state[0:3][0:3],
    output reg[1:0] mixcoloumn_done
);

reg [3:0] ans;
reg [7:0] temp_a;
reg [3:0] temp_b;
reg[3:0] check;
reg [3:0]temp;
integer i,j,k,l;

reg [3:0] mixcoloumn_matrix[3:0][3:0];
initial begin
    mixcoloumn_matrix[0][0] = 4'd13;  mixcoloumn_matrix[0][1] = 4'd9;  mixcoloumn_matrix[0][2] = 4'd4;  mixcoloumn_matrix[0][3] = 4'd1;
    mixcoloumn_matrix[1][0] = 4'd9;  mixcoloumn_matrix[1][1] = 4'd13;  mixcoloumn_matrix[1][2] = 4'd1; mixcoloumn_matrix[1][3] = 4'd4;
    mixcoloumn_matrix[2][0] = 4'd4;  mixcoloumn_matrix[2][1] = 4'd1; mixcoloumn_matrix[2][2] = 4'd13;  mixcoloumn_matrix[2][3] = 4'd9;
    mixcoloumn_matrix[3][0] = 4'd1; mixcoloumn_matrix[3][1] = 4'd4;  mixcoloumn_matrix[3][2] = 4'd9;  mixcoloumn_matrix[3][3] = 4'd13;
end

function [3:0] galiosmultiplication;
    input[3:0] a,b;
    begin
        ans = 4'b0000;  
        temp_a = a;
        temp_b = b;
        for (i = 0; i < 4; i = i + 1) begin
            if (temp_b[0] == 1'b1) begin
                ans = ans ^ temp_a; 
            end
            check = temp_a & 4'b1000; 
            temp_a = temp_a << 1;
            if (check == 4'b1000) begin
                temp_a = temp_a ^ 4'b0011; //  x^4 + x + 1
            end
            temp_b = temp_b >> 1;
        end
        galiosmultiplication = ans % 16;
    end
endfunction

always @(posedge clock or negedge rst) begin
    if (~rst) begin
        mixcoloumn_done <= 0;
    end else begin
        if (mixcoloumn_done == 0) begin
            for (j=0;j<4;j = j +1) begin
                for (k=0;k<4;k = k +1) begin
                    temp = 4'b0000;
                    for (l = 0;l<4 ;l = l +1) begin
                        temp = temp ^ galiosmultiplication(mixcoloumn_matrix[j][l],st_mixcoloumn[l][k]);
                    end
                    mixc_state[j][k] <= temp;
                end      
            end
            mixcoloumn_done <= 1;    
        end else begin
            mixcoloumn_done <= 0;
        end
    end
end
endmodule
