module TopLOONG(
    input wire clck,
    input wire reset,
    input wire text_key_in,
    output reg[3:0] ciphertext[15:0]
);

wire [7:0] text_key_out;
wire uart_txt_done;
reg do_LOONG;
reg[6:0] h;
reg[3:0] plaintext[15:0];//since i need to acess each element i stored in array.
reg[3:0] roundKey[15:0];
reg[3:0] plain_text[15:0];//since i need to acess each element i stored in array.
reg[3:0] round_Key[15:0];

uart_rx #(.CLKS_PER_BIT(434)) uart_in_text(
    .i_Clock(clck),
    .i_Rx_Serial(text_key_in),
    .o_Rx_DV(uart_txt_done),
    .o_Rx_Byte(text_key_out)
);

LOONG_ENC loong(
    .clk(clck),
    .reset(reset),
    .do_loong(do_LOONG),
    .plaintext(plain_text),
    .roundKey(round_Key),
    .ciphertext(ciphertext)
);

reg[1:0] uart_state;
localparam in_text_to_plaintext = 2'b00;
localparam append_state = 2'b01;
localparam stop_bit = 2'b10;
localparam finish = 2'b11;

always @(posedge clck or negedge reset) begin
    if (~reset) begin
        uart_state <= in_text_to_plaintext;
        do_LOONG <= 0;
    end
    else begin
        case (uart_state)
           in_text_to_plaintext: begin
                if(uart_txt_done) begin
                    if (text_key_out == 8'hAA) begin
                        h <= 0;
                        uart_state <= append_state;
                    end
                    else begin
                        uart_state <= in_text_to_plaintext;
                    end
                end
           end
           append_state :begin
                if(uart_txt_done)begin
                    // for (h=0;h<16;h=h+1) begin
                    plaintext[h] <= text_key_out[3:0];
                    roundKey[h]  <= text_key_out[7:4];
                    h = h + 1;
                    if( h == 5'b10000)
                        uart_state <= stop_bit;
                    else begin
                        uart_state <= append_state;
                    end
                end
            end 
            stop_bit :begin
                if(text_key_out == 8'hFF) begin
                    plain_text <= plaintext;
                    round_Key <= roundKey;
                    do_LOONG <= 1;
                    uart_state <= finish;
                end
            end
            finish:begin
                do_LOONG <= 0;
                uart_state <= in_text_to_plaintext;
            end
            default: begin
                uart_state <= in_text_to_plaintext;
            end
        endcase
    end
end
    
endmodule