`timescale 1ns/1ps
module LOONG_tb();

reg clock = 0;
reg rst;
reg [3:0]plaintxt[15:0];
reg [3:0] RKey[15:0];
wire[3:0] Ciphertext[15:0];

LOONG_ENC DUT(
    .clk(clock),
    .reset(rst),
    .plaintext(plaintxt),
    .roundKey(RKey),
    .ciphertext(Ciphertext)
);

initial begin
    rst = 0;
    #80
    rst = 1;
    #10
    plaintxt[0] <= 4'b0000;
    plaintxt[1] <= 4'b0000;
    plaintxt[2] <= 4'b0000;
    plaintxt[3] <= 4'b0000;
    plaintxt[4] <= 4'b0000;
    plaintxt[5] <= 4'b0000;
    plaintxt[6] <= 4'b0000;
    plaintxt[7] <= 4'b0000;
    plaintxt[8] <= 4'b0000;
    plaintxt[9] <= 4'b0000;
    plaintxt[10] <= 4'b0000;
    plaintxt[11] <= 4'b0000;
    plaintxt[12] <= 4'b0000;
    plaintxt[13] <= 4'b0000;
    plaintxt[14] <= 4'b0000;
    plaintxt[15] <= 4'b0000;

    RKey[0] <= 4'b0000;
    RKey[1] <= 4'b0000;
    RKey[2] <= 4'b0000;
    RKey[3] <= 4'b0000;
    RKey[4] <= 4'b0000;
    RKey[5] <= 4'b0000;
    RKey[6] <= 4'b0000;
    RKey[7] <= 4'b0000;
    RKey[8] <= 4'b0000;
    RKey[9] <= 4'b0000;
    RKey[10] <= 4'b0000;
    RKey[11] <= 4'b0000;
    RKey[12] <= 4'b0000;
    RKey[13] <= 4'b0000;
    RKey[14] <= 4'b0000;
    RKey[15] <= 4'b0000;
end


always
    #10 clock <= ~ clock;
endmodule
