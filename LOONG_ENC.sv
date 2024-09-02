module LOONG_ENC (
    input wire clk,
    input wire reset,
    input wire[3:0] plaintext[15:0],//since i need to acess each element i stored in array.
    input wire[3:0] roundKey[15:0],
    output reg[3:0] ciphertext[15:0]
);

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

integer k,l,c,d;
reg[5:0] i;
reg[5:0] g;
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

reg[3:0] loong_states;
localparam text_key_matrix = 4'b0000;
localparam AddRoundKey_initial = 4'b0001;
localparam SubCells_state1 = 4'b0010;
localparam Mixrow_state = 4'b0011;
localparam  Mixcoloumn_state = 4'b0100;
localparam SubCells_state2 = 4'b0101;
localparam AddRoundKey_Loop = 4'b0110;
localparam Cipher_state = 4'b0111 ;

text_matrix  matirx_form(
    .clck(clk),
    .rst(reset),
    .text(plaintext),
    .RKey(roundKey),
    .txt_matrix(plain_matrix),
    .key_matrix(round_key),
    .matrix_done(matrix_cmplt)
);

round_const rnd_cnst(
    .clock(clk),
    .rst(reset),
    .j(i),
    .round_cnst(round_constant),
    .Rconst_done(Rconst_cmplt)
);

subcells subcell(
    .clock(clk),
    .rst(reset),
    .in_matrix(state),
    .subcell_in(do_subcell),
    .out_matrix(state_scell),
    .subcell_done(sbcell_done)
);

Mixrow mixrow(
    .clock(clk),
    .rst(reset),
    .st_mixrow(state_subcell),
    .mixr_state(ste_mxrow),
    .mixrow_done(mixrow_cmplt)
);

Mixcoloumn mixcoloumn(
    .clock(clk),
    .rst(reset),
    .st_mixcoloumn(state_mixrow),
    .mixc_state(ste_mxcoloumn),
    .mixcoloumn_done(mixcoloumn_cmplt)
);

// initial begin
    
// end

// function [3:0] text_hex;
//     input[7:0] text;
//     begin
//         if (text >="0" && text <="9") begin
//             text_hex = text - "0";
//         end
//         else if(text >="a" && text <="f")begin
//             text_hex = text - "a" + 4'hA;
//         end 
//         else if(text >="A" && text <="F")begin
//             text_hex = text - "A" + 4'hA;
//         end
//         else begin
//             text_hex = 4'h0;
//         end
//     end   
// endfunction

always @(posedge clk or negedge reset) begin
    if(~reset)begin
        loong_states <= text_key_matrix;
        matrix_complete <= 0;
        Rconst_complete <=0;
        do_subcell <= 0;
        subcell_cmplt <= 0; 
        mixrow_complete <= 0;
        mixcoloumn_complete <= 0;  
        g <= 0;
    end
    else begin
        case (loong_states)
            text_key_matrix:begin //0 state
                // matrix_complete <= matrix_cmplt;
                if(matrix_cmplt == 1)begin
                    state <= plain_matrix;
                    // matrix_complete <= 0;
                    i <= 0;
                    loong_states <= AddRoundKey_initial;
                end 
                else begin
                    loong_states <= text_key_matrix;
                end                
            end 
            AddRoundKey_initial:begin //1 state
                // Rconst_complete <= Rconst_cmplt;
                if (Rconst_cmplt == 1)begin
                    for (k=0;k<4;k=k+1) begin
                        for (l=0;l<4;l=l+1) begin
                            state[k][l] <= plain_matrix[k][l] ^ round_key[k][l] ^ round_constant[k][l];
                        end
                    end
                    // Rconst_complete <=0;
                    do_subcell <= 1;
                    loong_states <= SubCells_state1;
                end
                else begin
                    loong_states <= AddRoundKey_initial;
                end
            end
            SubCells_state1 : begin //2 state
                // subcell_cmplt <= sbcell_done;
                if (sbcell_done == 1) begin
                    state_subcell <= state_scell;
                    do_subcell <= 0;
                    // subcell_cmplt <= 0;   
                    loong_states <= Mixrow_state;
                end
                else begin
                    loong_states <= SubCells_state1;
                end           
            end
            Mixrow_state : begin //3 state
                // mixrow_complete <= mixrow_cmplt;
                if(mixrow_cmplt == 1 )begin
                    state_mixrow <= ste_mxrow;
                    // mixrow_complete <= 0;
                    loong_states <= Mixcoloumn_state;
                end
                else begin
                    loong_states <= Mixrow_state;
                end
            end
            Mixcoloumn_state : begin //4 state
                // mixcoloumn_complete <= mixcoloumn_cmplt;
                if(mixcoloumn_cmplt == 1)begin
                    state_mixcoloumn <= ste_mxcoloumn;
                    // mixcoloumn_complete <= 0;
                    state <= state_mixcoloumn;
                    do_subcell <= 1;
                    loong_states <= SubCells_state2;
                end
                else begin
                    loong_states <= Mixcoloumn_state;
                end               
            end
            SubCells_state2 : begin //5 state
                // subcell_cmplt <= sbcell_done;
                if (sbcell_done == 1) begin
                    state_subcell2 <= state_scell;
                    do_subcell <= 0;
                    // subcell_cmplt <= 0;   
                    i <= i + 1;
                    loong_states <= AddRoundKey_Loop;
                end
                else begin
                    loong_states <= SubCells_state2;
                end     
            end
            AddRoundKey_Loop:begin //6 state
                // Rconst_complete <= Rconst_cmplt;
                if(Rconst_cmplt == 1)begin
                    for (k=0;k<4;k=k+1) begin
                        for (l=0;l<4;l=l+1) begin
                            state[k][l] <= state_subcell2[k][l] ^ round_key[k][l] ^ round_constant[k][l];
                        end
                    end
                    // Rconst_complete <= 0;
                    if (i <= 15) begin // 16 rounds
                        do_subcell <= 1;
                        loong_states <= SubCells_state1;
                    end
                    else begin
                        loong_states <= Cipher_state;
                    end
                end
                else begin
                    loong_states <= AddRoundKey_Loop;
                end
            end
            Cipher_state : begin // 7 state
                for(c=0;c<4;c=c+1)begin
                    for (d=0;d<4;d=d+1) begin
                        ciphertext[g] <= state[c][d];
                        g = g + 1;
                    end
                end
            end
            default: begin
                loong_states <= text_key_matrix;
            end
        endcase
    end    
end   
endmodule
