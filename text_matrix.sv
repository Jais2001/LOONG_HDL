module text_matrix(
    input wire clck,
    input wire rst,
    input wire [3:0] text[15:0], 
    input wire [3:0] RKey[15:0], 
    output reg [3:0] txt_matrix[0:3][0:3], 
    output reg [3:0] key_matrix[0:3][0:3], 
    output reg matrix_done 
);

reg [3:0] num; 
integer i, j;

initial begin
    matrix_done <= 0;
    num <= 4'd15; 
end

always @(posedge clck or negedge rst) begin
    if (!rst) begin
        matrix_done <= 0;
        num <= 4'd15; 
    end else begin
        if (matrix_done == 0) begin
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 4; j = j + 1) begin
                    txt_matrix[i][j] <= text[num];
                    key_matrix[i][j] <= RKey[num];
                    num <= num - 1;
                end
            end
            matrix_done <= 1; 
        end else begin
            matrix_done <= 0; 
        end
    end
end

endmodule


// module text_matrix(
//     input wire clck,
//     input wire [63:0] text,   // Flattened input: 16 * 4 bits = 64 bits
//     input wire [63:0] RKey,   // Flattened input: 16 * 4 bits = 64 bits
//     output reg [3:0] txt_matrix[0:3][0:3], // 4x4 matrix
//     output reg [3:0] key_matrix[0:3][0:3], // 4x4 matrix
//     output reg [1:0] matrix_done
// );

//     reg [5:0] num = 5'd16;
//     integer i, j;

//     always @(posedge clck) begin
//         for (i = 0; i < 4; i = i + 1) begin
//             for (j = 0; j < 4; j = j + 1) begin
//                 if (num > 0) begin
//                     // Extract 4-bit segments from the flattened input arrays
//                     txt_matrix[i][j] <= text[(num-1)*4 +: 4];
//                     key_matrix[i][j] <= RKey[(num-1)*4 +: 4];
//                     num <= num - 1;
//                 end
//             end
//         end
//         matrix_done <= 1;  
//     end
// endmodule
