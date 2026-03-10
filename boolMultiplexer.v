`timescale 1ns / 1ps

module boolMultiplexer(
    input A,
    input B,
    input C,
    input D,
    output Y
    );
    wire I0,I1,I2,I3, S0,S1;
    assign S0 = B;
    assign S1 = A;
    
    assign I0 = ~C & D;
    assign I1 = ~C | D;
    assign I2 = ~C & D;
    assign I3 = ~C;
    
    fourToOneMultiplexer mux1(S1,S0,I0,I1,I2,I3,1'b1,Y);
    
endmodule
