module text_matrix(
    input wire clck,
    input wire rst,
    input wire [3:0] text[15:0], 
    input wire [3:0] RKey[15:0], 
    output reg [3:0] txt_matrix[3:0][3:0], 
    output reg [3:0] key_matrix[3:0][3:0], 
    output reg matrix_done 
);

reg [4:0] num; 
integer i, j;

reg[2:0] matrix_state;
localparam  idle_matrix = 3'd0;
localparam  set_matrix  = 3'd1;
localparam  update_j    = 3'd2;
localparam  update_i    = 3'd3;
localparam  done_matrix = 3'd4;       


always @(posedge clck or negedge rst) begin
    if (~rst) begin
        num <= 0; 
        matrix_done <= 0;
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                txt_matrix[i][j] <= 0;
                key_matrix[i][j] <= 0;
            end
        end
        matrix_state <= idle_matrix;
    end
    else begin
        matrix_done <= 0;
        case (matrix_state)
            idle_matrix: begin
                num <= 0; 
                i <= 0;
                j <= 0;
                matrix_done <= 0;
                matrix_state <= set_matrix;
            end
            set_matrix:begin
                txt_matrix[i][j] <= text[num];
                key_matrix[i][j] <= RKey[num];
                j <= j + 1;
                num <= num + 1;
                matrix_state <= update_j;
            end 
            update_j : begin
                if (j < 4) begin
                    matrix_state <= set_matrix;
                end else begin
                    j <= 0;
                    i <= i + 1;
                    matrix_state <= update_i;
                end
            end
            update_i : begin
                if (i<4) begin
                    matrix_state <= update_j;
                end else begin
                    matrix_state <= done_matrix;
                end
            end
            done_matrix : begin
                matrix_done <= 1;
                matrix_state <= idle_matrix;
            end
            default:begin
                matrix_state <= idle_matrix;
            end
        endcase
    end
end
endmodule
