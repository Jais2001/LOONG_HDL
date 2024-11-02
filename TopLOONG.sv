module TopLOONG(
    input wire clck,
    input wire reset,
    input wire text_key_in,
    output reg[3:0] ciphertext[15:0]
);

wire [7:0] text_key_out;
wire uart_txt_done;
reg do_LOONG;
reg[0:127] plain_key_text;
reg[0:63] plaintext;
reg[0:63] roundKey;
reg[3:0] plain_text[15:0];//since i need to acess each element i stored in array.
reg[3:0] round_Key[15:0];

integer h,i,m;

uart_rx #(.CLKS_PER_BIT(434)) uart_in_text(
    .i_Clock(clck),
    .i_Rx_Serial(text_key_in),
    .o_Rx_DV(uart_txt_done),
    .o_Rx_Byte(text_key_out)
);

LOONG_ENC loong(
    .i_clk(clck),
    .i_reset(reset),
    .i_do_loong(do_LOONG),
    .i_plaintext(plain_text),
    .i_roundKey(round_Key),
    .o_ciphertext(ciphertext)
);

reg[3:0] uart_state;
localparam in_text_to_plaintext = 4'd0;
localparam append_text_key = 4'd1;
localparam stop_bit = 4'd2;
localparam do_array = 4'd3;
localparam finish_append = 4'd4;

always @(posedge clck or negedge reset) begin
    if (~reset) begin
        uart_state <= in_text_to_plaintext;
        m <= 0;
        plain_key_text <= 128'd0;
        plaintext <= 64'd0;
        roundKey <= 64'd0;
        do_LOONG <= 0;
    end
    else begin
        do_LOONG <= 0;
        case (uart_state)
           in_text_to_plaintext: begin
                if(uart_txt_done) begin
                    if (text_key_out == 8'hAA) begin  // start bit 
                        h <= 0; 
                        m <= 0;
                        uart_state <= append_text_key;
                    end
                    else begin
                        uart_state <= in_text_to_plaintext;
                    end
                end
           end
           append_text_key :begin
                if(uart_txt_done)begin
                    if (h < 5'd16) begin
                        plain_key_text <= {plain_key_text,text_key_out};
                        h <= h + 1;
                    end
                    else begin 
                        uart_state <= stop_bit;
                    end
                end
            end 
            stop_bit : begin
                if(text_key_out == 8'hFF)begin
                    plaintext <= plain_key_text[0:63]; // appending effect
                    roundKey <= plain_key_text[64:127];
                    uart_state <= do_array;
                end
                else begin
                    uart_state <= stop_bit;
                end
            end
            do_array :begin
                if (m < 5'd16) begin // less than 16
                    plain_text[m] <= plaintext[63-(m*4)-:4]; // The syntx is - [start_bit -: width]
                    round_Key[m] <= roundKey[63-(m*4)-:4];
                    m <= m + 1;
                end else begin
                    uart_state <= finish_append;
                end
            end
            finish_append:begin
                do_LOONG <= 1;
                uart_state <= in_text_to_plaintext;
            end
            default: begin
                uart_state <= in_text_to_plaintext;
            end
        endcase
    end
end
endmodule

