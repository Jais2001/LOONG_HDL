module round_const (
    input wire clock,
    input wire rst,
    input wire[5:0] j,
    output reg [3:0]round_cnst[0:3][0:3],
    output reg Rconst_done 
);

// reg[1:0]a;
// reg[1:0]b;
reg[7:0]rc = 0;
reg[5:0] do_round_const;
reg[6:0] roundcnst [0:32];

initial begin
    roundcnst[0] = 8'h01;
    roundcnst[1] = 8'h03;
    roundcnst[2] = 8'h07;
    roundcnst[3] = 8'h0F;
    roundcnst[4] = 8'h1F;
    roundcnst[5] = 8'h3E;
    roundcnst[6] = 8'h3D;
    roundcnst[7] = 8'h3B;
    roundcnst[8] = 8'h37;
    roundcnst[9] = 8'h2F;
    roundcnst[10] = 8'h1E;
    roundcnst[11] = 8'h3C;
    roundcnst[12] = 8'h39;
    roundcnst[13] = 8'h33;
    roundcnst[14] = 8'h27;
    roundcnst[15] = 8'h0E;
    roundcnst[16] = 8'h1D;
    roundcnst[17] = 8'h3A;
    roundcnst[18] = 8'h35;
    roundcnst[19] = 8'h2B;
    roundcnst[20] = 8'h16;
    roundcnst[21] = 8'h2C;
    roundcnst[22] = 8'h18;
    roundcnst[23] = 8'h30;
    roundcnst[24] = 8'h21;
    roundcnst[25] = 8'h02;
    roundcnst[26] = 8'h05;
    roundcnst[27] = 8'h0B;
    roundcnst[28] = 8'h17;
    roundcnst[29] = 8'h2E;
    roundcnst[30] = 8'h1c;
    roundcnst[31] = 8'h38;
    roundcnst[32] = 8'h31;   
end
always @(posedge clock or negedge rst) begin
    if (~rst) begin
        Rconst_done <= 0;       
    end
    else begin
        if(Rconst_done == 0)begin
            round_cnst[0][0] <= 0;
            round_cnst[0][1] <= 0;
            round_cnst[0][2] <= 0;
            round_cnst[0][3] <= roundcnst[j][5] || roundcnst[j][4] || roundcnst[j][3];   // OR operator
            round_cnst[1][0] <= 0;
            round_cnst[1][1] <= 0;
            round_cnst[1][2] <= 1;
            round_cnst[1][3] <= roundcnst[j][2] || roundcnst[j][1] || roundcnst[j][0];  // OR operator
            round_cnst[2][0] <= 0;
            round_cnst[2][1] <= 0;
            round_cnst[2][2] <= 2;
            round_cnst[2][3] <= roundcnst[j][5] || roundcnst[j][4] || roundcnst[j][3];  // OR operator
            round_cnst[3][0] <= 0;
            round_cnst[3][1] <= 0;
            round_cnst[3][2] <= 4;   
            round_cnst[3][3] <= roundcnst[j][2] || roundcnst[j][1] || roundcnst[j][0];  // OR operator
            Rconst_done <= 1;
        end else begin
            Rconst_done <= 0;  
        end
    end
end

endmodule
