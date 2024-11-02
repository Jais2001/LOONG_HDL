module Mixcoloumn(
    input wire clock,
    input wire rst,
    input wire[3:0] st_mixcoloumn[0:3][0:3],
    input wire do_mix_coloumn,
    output reg[3:0] mixc_state[0:3][0:3],
    output reg mixcoloumn_done
);

reg [3:0] ans;
reg [7:0] temp_a;
reg [3:0] temp_b;
reg[3:0] check;
reg [3:0]temp;
integer i,j,k,l,a,m,c,b;

reg[3:0] r_input_mixcoloumn[0:3][0:3];

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

reg[2:0] mixcoloumn_state; // states

localparam initial_state = 3'd0;
localparam do_mixclm = 3'd1;
localparam update_l = 3'd2;
localparam store_temp = 3'd3;
localparam clear_temp = 3'd4;
localparam update_k = 3'd5;
localparam update_j = 3'd6;
localparam done_mxclm = 3'd7;

always @(posedge clock or negedge rst) begin
    if (~rst) begin
        for (c = 0; c < 4; c = c + 1) begin
            for (b = 0; b < 4; b = b + 1) begin
                r_input_mixcoloumn[c][b] <= 4'b0;
            end
        end
    end
    else begin
        r_input_mixcoloumn <= st_mixcoloumn;  // 1 clock cycle delay
    end
end


always @(posedge clock or negedge rst) begin
    if (~rst) begin
        mixcoloumn_state <= initial_state;
        mixcoloumn_done <= 0;
        temp <= 4'b0000;
        for (a = 0; a < 4; a = a + 1) begin
            for (m = 0; m < 4; m = m + 1) begin
                mixc_state[a][m] <= 0;
            end
        end
    end
    else begin
        mixcoloumn_done <= 0;
        case (mixcoloumn_state)
           initial_state:begin
                j<=0;
                l<=0;
                k<=0;
                temp <= 4'b0000;
                if (do_mix_coloumn == 1) begin
                    mixcoloumn_state <= do_mixclm;
                end
                else begin
                    mixcoloumn_state <= initial_state;
                end
           end
           do_mixclm:begin
                temp = temp ^ galiosmultiplication(mixcoloumn_matrix[j][l],r_input_mixcoloumn[l][k]);
                l <= l + 1;
                mixcoloumn_state <= update_l;
           end
           update_l : begin
                if (l < 4) begin
                    mixcoloumn_state <= do_mixclm;
                end 
                else begin
                    l <= 0;
                    mixcoloumn_state <= store_temp;
                end
           end
           store_temp:begin
                mixc_state[j][k] <= temp;
                k <= k + 1;
                mixcoloumn_state <= clear_temp;
           end
           clear_temp:begin
                temp <= 4'b0000;
                mixcoloumn_state <= update_k;
           end
           update_k : begin
                if (k < 4) begin 
                    mixcoloumn_state <= update_l;
                end
                else begin
                    k <= 0;
                    j <= j + 1;
                    mixcoloumn_state <= update_j;
                end
           end
           update_j : begin
                if (j < 4) begin
                    mixcoloumn_state <= update_k;
                end
                else begin
                    mixcoloumn_state <= done_mxclm;
                end
           end
           done_mxclm : begin
                mixcoloumn_done <= 1;
                mixcoloumn_state <= initial_state;
           end
            default: begin
                mixcoloumn_state <= initial_state;
            end
        endcase
    end
end
endmodule
// always @(posedge clock or negedge rst) begin
//     if (~rst) begin
//         mixcoloumn_done <= 0;
//     end else begin
//         if (mixcoloumn_done == 0) begin
//             for (j=0;j<4;j = j +1) begin
//                 for (k=0;k<4;k = k +1) begin
//                     temp = 4'b0000;
//                     for (l = 0;l<4 ;l = l +1) begin
//                         temp = temp ^ galiosmultiplication(mixcoloumn_matrix[j][l],st_mixcoloumn[l][k]);
//                     end
//                     mixc_state[j][k] <= temp;
//                 end      
//             end
//             mixcoloumn_done <= 1;    
//         end else begin
//             mixcoloumn_done <= 0;
//         end
//     end
// end
