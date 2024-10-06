`timescale 1ns/1ps
module LOONG_tb();
parameter c_BIT_PERIOD      = 8680;

reg clock = 0;
reg rst;
// reg [3:0]plaintxt[15:0];
// reg [3:0] RKey[15:0];
reg text_key;
wire[3:0] Ciphertext[15:0];

TopLOONG DUT(
    .clck(clock),
    .reset(rst),
    .text_key_in(text_key),
    .ciphertext(Ciphertext)
);

task  WRITE_UART;
    input[7:0] in_data;
    // input[7:0] in_text;
    integer i;
    begin
        text_key = 1'b0;
        // key = 1'b0;
        #(c_BIT_PERIOD);
        #1000;
        for (i=0;i<8;i=i+1) begin
            text_key = in_data[i];
            // key = in_text[i];
            $display("WRITE_UART - Assigning bit %0d: text = %b", i, text_key);
            #(c_BIT_PERIOD);
        end
        text_key = 1'b1;
        // key = 1'b1;
        #(c_BIT_PERIOD);
    end
endtask

initial begin
    rst = 0;
    #1000;
    rst = 1;
    #1000;
    repeat(15) @(posedge clock);

    repeat(15) @(posedge clock);
    WRITE_UART(8'hAA); //header
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00); 
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00);  
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00); 
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00); 
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00); 
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00); 
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00);  
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00); 
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00);  
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00); 
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00); 
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00);  
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00); 
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00);  
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00);
    repeat(15) @(posedge clock);
    WRITE_UART(8'h00); 
    repeat(15) @(posedge clock);
    // WRITE_UART(8'h10); 
    // repeat(15) @(posedge clock);
    WRITE_UART(8'hFF); //footer
    repeat(100000) @(posedge clock);
end


always
    #10 clock <= ~ clock;
endmodule
