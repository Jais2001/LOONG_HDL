module LOONG_ENC (
    input wire i_clk,
    input wire i_reset,
    input wire i_do_loong,
    input wire[3:0] i_plaintext[15:0],//since i need to acess each element i stored in array.
    input wire[3:0] i_roundKey[15:0],
    output wire[3:0] o_ciphertext[0:15]
);

wire uart_key_done;
wire [7:0] in_key;

reg do_mixrow;
reg do_mix_coloumn;
reg r_Rconst_cmplt;
reg do_round;
reg[3:0] r_ciphertext[0:15];
reg [59:0] text_plain;
reg [3:0] state[0:3][0:3];
reg [3:0] round_constant[0:3][0:3];
reg [3:0] state_scell[0:3][0:3];
reg [3:0] state_subcell[0:3][0:3];
reg [3:0] state_subcell2[0:3][0:3];
reg [3:0] ste_mxrow[0:3][0:3];
reg [3:0] ste_mxcoloumn[0:3][0:3];
reg [3:0] state_mixrow[0:3][0:3];
reg [3:0] state_mixcoloumn[0:3][0:3];
reg [3:0] plain_matrix[0:3][0:3];
reg [3:0] round_key[0:3][0:3];

reg[3:0] round_key_buff[0:3][0:3];

integer k,l,c,d,i,m;
reg[5:0] g;
reg[6:0] h;
reg do_subcell;
reg sbcell_done;
reg subcell_cmplt;
reg matrix_cmplt;
reg matrix_complete;
reg Rconst_complete;
reg Rconst_cmplt;
reg mixrow_complete;
reg mixrow_cmplt; 
reg mixcoloumn_complete;
reg mixcoloumn_cmplt;

reg[5:0] LOONG_Counter = 6'd0; // counter to run 16 rounds

reg[3:0] loong_states;
localparam start_loong = 4'b0000;
localparam text_key_matrix = 4'b0001;
localparam Add_RoundKey_initial = 4'b0010;
localparam SubCells_state1 = 4'b0011;
localparam Mixrow_state = 4'b0100;
localparam Mixcoloumn_state = 4'b0101;
localparam SubCells_state2 = 4'b0110;
localparam Add_RoundKey_Loop = 4'b0111;
localparam Cipher_state = 4'b1000;

assign o_ciphertext = r_ciphertext;

text_matrix  matirx_form(
    .clck(i_clk),
    .rst(i_reset),
    .text(i_plaintext),
    .RKey(i_roundKey),
    .txt_matrix(plain_matrix),
    .key_matrix(round_key),
    .matrix_done(matrix_cmplt)
);

round_const rnd_cnst(
    .clock(i_clk),
    .rst(i_reset),
    .strt_round(do_round),
    .round_cnst(round_constant),
    .Rconst_done(Rconst_cmplt)
);

subcells subcell(
    .clock(i_clk),
    .rst(i_reset),
    .in_matrix(state),
    .subcell_in(do_subcell),
    .out_matrix(state_scell),
    .subcell_done(sbcell_done)
);

Mixrow mixrow(
    .clock(i_clk),
    .rst(i_reset),
    .st_mixrow(state_subcell),
    .do_mixrow(do_mixrow),
    .mixr_state(ste_mxrow),
    .mixrow_done(mixrow_cmplt)
);

Mixcoloumn mixcoloumn(
    .clock(i_clk),
    .rst(i_reset),
    .st_mixcoloumn(state_mixrow),
    .do_mix_coloumn(do_mix_coloumn),
    .mixc_state(ste_mxcoloumn),
    .mixcoloumn_done(mixcoloumn_cmplt)
);

always @(posedge i_clk or negedge i_reset ) begin
    if (~i_reset) begin
        r_Rconst_cmplt <= 0;
    end
    else begin
        r_Rconst_cmplt <= Rconst_cmplt;
    end
end

always @(posedge i_clk or negedge i_reset ) begin
    if (~i_reset) begin
        for (i = 0; i < 4; i = i + 1) begin
            for (m = 0; m < 4; m = m + 1) begin
                round_key_buff[i][m] <= 0;
            end
        end
    end
    else begin
        if (~r_Rconst_cmplt && Rconst_cmplt) begin
            round_key_buff <= round_key;
        end
    end
end

always @(posedge i_clk or negedge i_reset) begin
    if(~i_reset)begin
        loong_states <= start_loong;
        do_subcell <= 0; 
        do_round <= 0;
        do_mixrow <= 0;
        do_mix_coloumn <= 0;
        LOONG_Counter <= 6'd0;  
        g <= 0;
        h <= 0;
    end
    else begin
        do_round <= 0;
        do_subcell <= 0;
        do_mixrow <= 0;
        do_mix_coloumn <= 0;
        case (loong_states)
            start_loong : begin
                if (i_do_loong) begin
                    loong_states <= text_key_matrix;
                end
                else begin
                    loong_states <= start_loong;
                end
            end
            text_key_matrix:begin //1 state
                if(matrix_cmplt == 1)begin
                    state <= plain_matrix;
                    do_round <= 1;
                    loong_states <= Add_RoundKey_initial;
                end 
                else begin
                    loong_states <= text_key_matrix;
                end                
            end 
            Add_RoundKey_initial:begin //2 state
                if (Rconst_cmplt == 1)begin
                    for (k=0;k<4;k=k+1) begin
                        for (l=0;l<4;l=l+1) begin
                            state[k][l] <= plain_matrix[k][l] ^ round_key_buff[k][l] ^ round_constant[k][l];
                        end
                    end
                    do_subcell <= 1;
                    loong_states <= SubCells_state1;
                end
                else begin
                    loong_states <= Add_RoundKey_initial;
                end
            end
            SubCells_state1 : begin //3 state
                if (sbcell_done == 1) begin
                    state_subcell <= state_scell;
                    do_mixrow <= 1;
                    loong_states <= Mixrow_state;
                end
                else begin
                    loong_states <= SubCells_state1;
                end           
            end
            Mixrow_state : begin //4 state
                if(mixrow_cmplt == 1 )begin
                    state_mixrow <= ste_mxrow;
                    do_mix_coloumn <= 1;
                    loong_states <= Mixcoloumn_state;
                end
                else begin
                    loong_states <= Mixrow_state;
                end
            end
            Mixcoloumn_state : begin //5 state
                if(mixcoloumn_cmplt == 1)begin
                    state <= ste_mxcoloumn;
                    do_subcell <= 1;
                    loong_states <= SubCells_state2;
                end
                else begin
                    loong_states <= Mixcoloumn_state;
                end               
            end
            SubCells_state2 : begin //6 state
                if (sbcell_done == 1) begin
                    state_subcell2 <= state_scell;
                    do_round <= 1;  
                    loong_states <= Add_RoundKey_Loop;
                end
                else begin
                    loong_states <= SubCells_state2;
                end     
            end
            Add_RoundKey_Loop:begin //7 state
                if(Rconst_cmplt == 1)begin
                    for (k=0;k<4;k=k+1) begin
                        for (l=0;l<4;l=l+1) begin
                            state[k][l] <= state_subcell2[k][l] ^ round_key_buff[k][l] ^ round_constant[k][l];
                        end
                    end
                    if (LOONG_Counter <= 6'd16) begin // 16 rounds
                        LOONG_Counter <= LOONG_Counter + 1;
                        do_subcell <= 1;
                        loong_states <= SubCells_state1;
                    end
                    else begin
                        loong_states <= Cipher_state;
                    end
                end
                else begin
                    loong_states <= Add_RoundKey_Loop;
                end
            end
            Cipher_state : begin // 8 state
                for(c=0;c<4;c=c+1)begin
                    for (d=0;d<4;d=d+1) begin
                        r_ciphertext[g] <= state[c][d];
                        g = g + 1;
                    end
                end
                loong_states <= start_loong;
            end
            default: begin
                loong_states <= start_loong;
            end
        endcase
    end    
end   
endmodule
