module LOONG_ENC (
    input wire clk,
    input wire reset,
    // input wire text_key,
    input wire do_loong,
    input wire[3:0] plaintext[15:0],//since i need to acess each element i stored in array.
    input wire[3:0] roundKey[15:0],
    output reg[3:0] ciphertext[0:15]
);


// reg[3:0] plaintext[15:0];//since i need to acess each element i stored in array.
// reg[3:0] roundKey[15:0];
// wire uart_txt_done;
wire uart_key_done;
// wire [7:0] in_text_key;
wire [7:0] in_key;
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

integer k,l,c,d;
reg[5:0] i;
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

reg[3:0] loong_states;
// localparam in_text_to_plaintext = 4'b0000;
// localparam append_state = 4'b0001;
// localparam stop_bit = 4'b0010;
localparam start_loong = 4'b0000;
localparam text_key_matrix = 4'b0001;
localparam AddRoundKey_initial = 4'b0010;
localparam SubCells_state1 = 4'b0011;
localparam Mixrow_state = 4'b0100;
localparam  Mixcoloumn_state = 4'b0101;
localparam SubCells_state2 = 4'b0110;
localparam AddRoundKey_Loop = 4'b0111;
localparam Cipher_state = 4'b1000;

// uart_rx #(.CLKS_PER_BIT(434)) uart_in_text(
//     .i_Clock(clk),
//     .i_Rx_Serial(text_key),
//     .o_Rx_DV(uart_txt_done),
//     .o_Rx_Byte(in_text_key)
// );

// uart_rx #(.CLKS_PER_BIT(434)) uart_in_key(
//     .i_Clock(clk),
//     .i_Rx_Serial(key),
//     .o_Rx_DV(uart_key_done),
//     .o_Rx_Byte(in_key)
// );

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
        loong_states <= start_loong;
        matrix_complete <= 0;
        Rconst_complete <=0;
        do_subcell <= 0;
        subcell_cmplt <= 0; 
        mixrow_complete <= 0;
        mixcoloumn_complete <= 0;  
        g <= 0;
        h <= 0;
    end
    else begin
        // case (loong_states)
        //     in_text_to_plaintext:begin
        //         if (uart_txt_done) begin
        //             if (in_text_key == 8'hAA) begin
        //                 h <= 0;
        //                 loong_states <= append_state;
        //             end
        //             else begin
        //                 loong_states <= in_text_to_plaintext;
        //             end
        //         end
        //         else begin
        //             loong_states <= in_text_to_plaintext;
        //         end
        //     end
        //     append_state :begin
        //         if(uart_txt_done)begin
        //             // for (h=0;h<16;h=h+1) begin
        //             plaintext[h] <= in_text_key[3:0];
        //             roundKey[h]  <= in_text_key[7:4];
        //             h = h + 1;
        //             if( h == 4'b1111)
        //                 loong_states <= stop_bit;
        //             else begin
        //                 loong_states <= append_state;
        //             end
        //         end
        //     end
        //     stop_bit:begin
        //         if(in_text_key == 8'hFF)begin
        //             loong_states <= text_key_matrix;
        //         end
        //         else begin
        //             loong_states <= stop_bit;
        //         end
        //     end
        case (loong_states)
            start_loong : begin
                if (do_loong) begin
                    loong_states <= text_key_matrix;
                end
                else begin
                    loong_states <= start_loong;
                end
            end
            text_key_matrix:begin //0 state
                if(matrix_cmplt == 1)begin
                    state <= plain_matrix;
                    i <= 0;
                    loong_states <= AddRoundKey_initial;
                end 
                else begin
                    loong_states <= text_key_matrix;
                end                
            end 
            AddRoundKey_initial:begin //1 state
                if (Rconst_cmplt == 1)begin
                    for (k=0;k<4;k=k+1) begin
                        for (l=0;l<4;l=l+1) begin
                            state[k][l] <= plain_matrix[k][l] ^ round_key[k][l] ^ round_constant[k][l];
                        end
                    end
                    do_subcell <= 1;
                    loong_states <= SubCells_state1;
                end
                else begin
                    loong_states <= AddRoundKey_initial;
                end
            end
            SubCells_state1 : begin //2 state
                if (sbcell_done == 1) begin
                    state_subcell <= state_scell;
                    do_subcell <= 0;
                    loong_states <= Mixrow_state;
                end
                else begin
                    loong_states <= SubCells_state1;
                end           
            end
            Mixrow_state : begin //3 state
                if(mixrow_cmplt == 1 )begin
                    state_mixrow <= ste_mxrow;
                    loong_states <= Mixcoloumn_state;
                end
                else begin
                    loong_states <= Mixrow_state;
                end
            end
            Mixcoloumn_state : begin //4 state
                // mixcoloumn_complete <= mixcoloumn_cmplt;
                if(mixcoloumn_cmplt == 1)begin
                    // state_mixcoloumn <= ste_mxcoloumn;
                    state <= ste_mxcoloumn;
                    // mixcoloumn_complete <= 0;
                    // state <= state_mixcoloumn;
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
                    i <= i + 1;
                    loong_states <= AddRoundKey_Loop;
                end
                else begin
                    loong_states <= SubCells_state2;
                end     
            end
            AddRoundKey_Loop:begin //6 state
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
                loong_states <= start_loong;
            end
            default: begin
                loong_states <= start_loong;
            end
        endcase
    end    
end   
endmodule
