module round_const (
    input wire clock,
    input wire rst,
    input wire strt_round,
    output reg [3:0]round_cnst[0:3][0:3],
    output reg Rconst_done 
);

integer i, m;
reg[7:0]rc = 0;
reg[5:0] do_round_const;
reg[6:0] roundcnst [0:32];

reg [5:0] j;

reg[2:0] round_state;
localparam  initial_state = 3'd0;
localparam  do_roundcnst  = 3'd1;
localparam  update_round  = 3'd2;
localparam  done_round = 3'd3;  

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
        j <= 0;     
    end
    else begin
        Rconst_done <= 0;
        case (round_state)
            initial_state:begin
                Rconst_done <= 0;
                j <= 0; 
                for (i = 0; i < 4; i = i + 1) begin
                    for (m = 0; m < 4; m = m + 1) begin
                        round_cnst[i][m] <= 0;
                    end
                end
                if(strt_round)begin
                    round_state <= update_round;
                end
                else begin
                    round_state <= initial_state;
                end
            end
            update_round : begin
                j <= j + 1;
                round_state <= do_roundcnst;
            end
            do_roundcnst : begin
                round_cnst[0][0] <= 0;
                round_cnst[0][1] <= 0;
                round_cnst[0][2] <= 0;
                round_cnst[0][3] <= roundcnst[j-1][5] || roundcnst[j-1][4] || roundcnst[j-1][3];   // OR operator
                round_cnst[1][0] <= 0;
                round_cnst[1][1] <= 0;
                round_cnst[1][2] <= 1;
                round_cnst[1][3] <= roundcnst[j-1][2] || roundcnst[j-1][1] || roundcnst[j-1][0];  // OR operator
                round_cnst[2][0] <= 0;
                round_cnst[2][1] <= 0;
                round_cnst[2][2] <= 2;
                round_cnst[2][3] <= roundcnst[j-1][5] || roundcnst[j-1][4] || roundcnst[j-1][3];  // OR operator
                round_cnst[3][0] <= 0;
                round_cnst[3][1] <= 0;
                round_cnst[3][2] <= 4;   
                round_cnst[3][3] <= roundcnst[j-1][2] || roundcnst[j-1][1] || roundcnst[j-1][0];  // OR operator
                round_state <= done_round;
            end
            done_round: begin
                Rconst_done <= 1;
                round_state <= initial_state;
            end
            default: begin
                round_state <= initial_state;
            end
        endcase
    end
end

endmodule
