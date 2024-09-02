module Mixrow(
    input wire clock,
    input wire rst,
    input wire[3:0] st_mixrow[0:3][0:3],
    output reg[3:0] mixr_state[0:3][0:3],
    output reg mixrow_done
);

reg [3:0] ans;
reg [7:0] temp_a;
// reg [3:0] temp_b;
reg check;
reg [3:0]temp;
integer i,j,k,l;

reg [3:0] mixrow_matrix[3:0][3:0];
initial begin
    mixrow_matrix[0][0] <= 4'd1;  mixrow_matrix[0][1] <= 4'd4;  mixrow_matrix[0][2] <= 4'd9;  mixrow_matrix[0][3] <= 4'd13;
    mixrow_matrix[1][0] <= 4'd4;  mixrow_matrix[1][1] <= 4'd1;  mixrow_matrix[1][2] <= 4'd13; mixrow_matrix[1][3] <= 4'd9;
    mixrow_matrix[2][0] <= 4'd9;  mixrow_matrix[2][1] <= 4'd13; mixrow_matrix[2][2] <= 4'd1;  mixrow_matrix[2][3] <= 4'd4;
    mixrow_matrix[3][0] <= 4'd13; mixrow_matrix[3][1] <= 4'd9;  mixrow_matrix[3][2] <= 4'd4;  mixrow_matrix[3][3] <= 4'd1;
end

// function [7:0] galiosmultiplication;
//     input[3:0] a,b;
//     begin
//         ans = 4'b0000;  
//         temp_a = a;
//         temp_b = b;
//         for (i = 0; i < 4; i = i + 1) begin
//             if (temp_b[i] == 1'b1) begin
//                 ans = ans ^ temp_a;  // ||
//             end
//             check = temp_a[3];  
//             temp_a = temp_a << 1; 
//             temp_b = temp_b >> 1;  
//             if (check == 1'b1) begin
//                 temp_a = temp_a && 4'b0011; 
//             end
//         end
//         galiosmultiplication = ans % 4'b10000; 
//     end
// endfunction

function [3:0] galiosmultiplication;
    input [3:0] a, b;
    begin
        ans = 8'b00000000; 
        temp_a = {4'b0000, a}; 
        for (i = 0; i < 4; i = i + 1) begin
            if (b[i] == 1'b1) begin
                ans = ans ^ temp_a; 
            end
            if (temp_a[7] == 1'b1) begin
                temp_a = (temp_a << 1) ^ 8'h13; //  x^4 + x + 1
            end else begin
                temp_a = temp_a << 1; 
            end
        end
        galiosmultiplication = ans[3:0]; //ans % 4'b1000; //
    end
endfunction

always @(posedge clock or negedge rst) begin
    if (~rst) begin
        mixrow_done <= 0;
    end else begin
        if (mixrow_done == 0) begin
            for (j=0;j<4;j = j +1) begin
                for (k=0;k<4;k = k +1) begin
                    temp = 4'b0000;
                    for (l = 0;l<4 ;l = l + 1) begin
                        temp = temp ^ galiosmultiplication(st_mixrow[j][l],mixrow_matrix[l][k]); // ||
                    end
                    mixr_state[j][k] <= temp;
                end      
            end
            mixrow_done <= 1;
        end else begin
            mixrow_done <= 0;
        end      
    end
end
endmodule
