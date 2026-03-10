`timescale 1ns / 1ps

module boolMultiplexer_tb();
    reg A,B,C,D;
    wire Y;
    
    boolMultiplexer uut(A,B,C,D,Y);
    integer i;
    initial begin
        $display("A B C D | Y");
        $display("--------|--");

        for (i = 0; i < 16; i = i + 1) begin
            {A,B,C,D} = i;
            #10;
            $display("%b %b %b %b | %b", A, B, C, D, Y);
        end
    end
endmodule
