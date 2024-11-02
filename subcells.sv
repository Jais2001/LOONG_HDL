module subcells (
    input wire clock,
    input wire rst,
    input wire[3:0] in_matrix[0:3][0:3],
    input wire subcell_in,
    output reg[3:0] out_matrix[0:3][0:3],
    output reg subcell_done
);

integer m,n,l,k,a,b;
reg[3:0] r_subcell_matrix[0:3][0:3];

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

reg[2:0] scell_state;
localparam  initial_state = 3'd0;
localparam  check_state  = 3'd1;
localparam  dosub_state = 3'd2;
localparam  update_n    = 3'd3;
localparam  update_m     = 3'd4;
localparam  done_state  = 3'd5;    

always @(posedge clock or negedge rst) begin
    if (~rst) begin
        for (a = 0; a < 4; a = a + 1) begin
            for (b = 0; b < 4; b = b + 1) begin
                r_subcell_matrix[a][b] <= 4'b0;
            end
        end
    end else begin
        r_subcell_matrix <= in_matrix;  // 1 clock cycle delay
    end
end

always @(posedge clock or negedge rst) begin
    if(~rst)begin
        subcell_done <= 0;
        m<=0;
        n<=0;
        scell_state <= initial_state;
        for (l = 0; l < 4; l = l + 1) begin
            for (k = 0; k < 4; k = k + 1) begin
                out_matrix[l][k] <= 4'b0;
            end
        end
    end
    else begin
        subcell_done <= 0;
        case (scell_state)
            initial_state:begin
                m<=0;
                n<=0;
                subcell_done <= 0; 
                scell_state <= check_state;
            end 
            check_state:begin
                if (subcell_in) begin
                    scell_state <= dosub_state;
                end
                else begin
                    scell_state <= check_state;
                end
            end
            dosub_state : begin
                    out_matrix[m][n] <= s_box[r_subcell_matrix[m][n]];
                    scell_state <= update_n;
                    n <= n + 1;
            end
            update_n : begin
                if (n < 4) begin
                    scell_state <= dosub_state;
                end
                else begin
                    n <= 0;
                    m <= m + 1;
                    scell_state <= update_m;
                end
            end
            update_m : begin
                if (m < 4) begin
                    scell_state <= update_n;
                end else begin
                    scell_state <= done_state;
                end
            end
            done_state : begin
                subcell_done <= 1;
                scell_state <= initial_state;
            end
            default: begin
                scell_state <= initial_state;
            end
        endcase
    end
end  
endmodule