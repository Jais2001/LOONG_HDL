module subcells (
    input wire clock,
    input wire rst,
    input wire[3:0] in_matrix[0:3][0:3],
    input wire subcell_in,
    output reg[3:0] out_matrix[0:3][0:3],
    output reg subcell_done
);

integer m,n;

initial begin
    subcell_done <= 0;
end

reg [3:0] s_box[0:15];
initial begin 
    s_box[0] = 4'hC;
    s_box[1] = 4'hA;
    s_box[2] = 4'hD;
    s_box[3] = 4'h3;
    s_box[4] = 4'hE;
    s_box[5] = 4'hB;
    s_box[6] = 4'hF;
    s_box[7] = 4'h7;
    s_box[8] = 4'h9;
    s_box[9] = 4'h8;
    s_box[10] = 4'h1;
    s_box[11] = 4'h5;
    s_box[12] = 4'h0;
    s_box[13] = 4'h2;
    s_box[14] = 4'h4;
    s_box[15] = 4'h6;
end

always @(posedge clock or negedge rst) begin 
    if (!rst) begin
        subcell_done <= 0;
    end else if (subcell_in) begin
        for (m = 0; m < 4; m = m + 1) begin
            for (n = 0; n < 4; n = n + 1) begin
                out_matrix[m][n] <= s_box[in_matrix[m][n]];
            end    
        end
        subcell_done <= 1;
    end else begin
        subcell_done <= 0;
    end
end    
endmodule