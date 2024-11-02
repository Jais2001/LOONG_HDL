module Mixrow(
    input wire clock,
    input wire rst,
    input wire[3:0] st_mixrow[0:3][0:3],
    input wire do_mixrow,
    output reg[3:0] mixr_state[0:3][0:3],
    output reg mixrow_done
);

reg [3:0] ans;
reg [7:0] temp_a;
reg[3:0] r_input_mixrow[0:3][0:3];
reg check;
reg [3:0]temp;
integer i,j,k,l,a,m,c,b;

reg [3:0] mixrow_matrix[3:0][3:0];
initial begin
    mixrow_matrix[0][0] = 4'd1;  mixrow_matrix[0][1] = 4'd4;  mixrow_matrix[0][2] = 4'd9;  mixrow_matrix[0][3] = 4'd13;
    mixrow_matrix[1][0] = 4'd4;  mixrow_matrix[1][1] = 4'd1;  mixrow_matrix[1][2] = 4'd13; mixrow_matrix[1][3] = 4'd9;
    mixrow_matrix[2][0] = 4'd9;  mixrow_matrix[2][1] = 4'd13; mixrow_matrix[2][2] = 4'd1;  mixrow_matrix[2][3] = 4'd4;
    mixrow_matrix[3][0] = 4'd13; mixrow_matrix[3][1] = 4'd9;  mixrow_matrix[3][2] = 4'd4;  mixrow_matrix[3][3] = 4'd1;
end

function [3:0] galiosmultiplication;
    input [3:0] a, b;
    reg [3:0] temp_a;
    reg [3:0] temp_b;
    reg [3:0] ans;
    reg [3:0] check;
    integer i;
    begin
        ans = 4'b0000;
        temp_a = a;
        temp_b = b;
        for (i = 0; i < 4; i = i + 1) begin
            if (temp_b[0] == 1'b1) begin
                ans = ans ^ temp_a;
            end
            check = temp_a & 4'b1000; // whtr MSB of temp_a is set
            temp_a = temp_a << 1;
            if (check == 4'b1000) begin
                temp_a = temp_a ^ 4'b0011; // XOR with irreducible polynomial
            end
            temp_b = temp_b >> 1;
        end
        galiosmultiplication = ans % 16; // jst to ensure result is within 4 bits
    end
endfunction

reg[2:0] mxrw_state; // states

localparam initial_state = 3'd0;
localparam do_mixrw = 3'd1;
localparam update_l = 3'd2;
localparam store_temp = 3'd3;
localparam clear_temp = 3'd4;
localparam update_k = 3'd5;
localparam update_j = 3'd6;
localparam done_mxrow = 3'd7;


always @(posedge clock or negedge rst) begin
    if (~rst) begin
        for (c = 0; c < 4; c = c + 1) begin
            for (b = 0; b < 4; b = b + 1) begin
                r_input_mixrow[c][b] <= 4'b0;
            end
        end
    end
    else begin
        r_input_mixrow <= st_mixrow;  // 1 clock cycle delay
    end
end

always @(posedge clock or negedge rst) begin
    if (~rst) begin
        mxrw_state <= initial_state;
        mixrow_done <= 0;
        temp <= 4'b0000;
        for (a = 0; a < 4; a = a + 1) begin
            for (m = 0; m < 4; m = m + 1) begin
                mixr_state[a][m] <= 0;
            end
        end
    end
    else begin
        mixrow_done <= 0;
        case (mxrw_state)
           initial_state:begin
                j<=0;
                l<=0;
                k<=0;
                temp <= 4'b0000;
                if (do_mixrow == 1) begin
                    mxrw_state <= do_mixrw;
                end
                else begin
                    mxrw_state <= initial_state;
                end
           end
           do_mixrw:begin
                temp = temp ^ galiosmultiplication(r_input_mixrow[j][l],mixrow_matrix[l][k]);
                l <= l + 1;
                mxrw_state <= update_l;
           end
           update_l : begin
                if (l < 4) begin
                    mxrw_state <= do_mixrw;
                end 
                else begin
                    l <= 0;
                    mxrw_state <= store_temp;
                end
           end
           store_temp:begin
                mixr_state[j][k] <= temp;
                k <= k + 1;
                mxrw_state <= clear_temp;
           end
           clear_temp:begin
                temp <= 4'b0000;
                mxrw_state <= update_k;
           end
           update_k : begin
                if (k < 4) begin 
                    mxrw_state <= update_l;
                end
                else begin
                    k <= 0;
                    j <= j + 1;
                    mxrw_state <= update_j;
                end
           end
           update_j : begin
                if (j < 4) begin
                    mxrw_state <= update_k;
                end
                else begin
                    mxrw_state <= done_mxrow;
                end
           end
           done_mxrow : begin
                mixrow_done <= 1;
                mxrw_state <= initial_state;
           end
            default: begin
                mxrw_state <= initial_state;
            end
        endcase
    end
end
endmodule




// always @(posedge clock or negedge rst) begin
//     if (~rst) begin
//         mixrow_done <= 0;
//     end else begin
//         if (mixrow_done == 0) begin
//             for (j=0;j<4;j = j +1) begin
//                 for (k=0;k<4;k = k +1) begin
//                     temp = 4'b0000;
//                     for (l = 0;l<4 ;l = l + 1) begin
//                         temp = temp ^ galiosmultiplication(st_mixrow[j][l],mixrow_matrix[l][k]);
//                     end
//                     mixr_state[j][k] <= temp;
//                 end      
//             end
//             mixrow_done <= 1;
//         end else begin
//             mixrow_done <= 0;
//         end      
//     end
// end