`timescale 1ns / 1ps

module fourToOneMultiplexer(
    input S1,
    input S0,
    input I0,
    input I1,
    input I2,
    input I3,
    input E,
    output Y
    );
    
    assign Y = E & (~S1&~S0&I0 | ~S1&S0&I1 | S1&~S0&I2 | S1&S0&I3);
    
endmodule