`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.01.2023 22:17:40
// Design Name: 
// Module Name: tb_DC_deger
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_DC_deger(
        input clk_i
    );
    
    reg [2:0] giris1 = 3'b101;
    wire [3:0] cikis1;
    reg en= 1'b1;
    
    reg [5:0] giris2= 6'b111110;
    wire [3:0] cikis2;
    
    DC_deger#(.uzunluk(3)) DC_deger_tb1(
        .clk_i(clk_i),
        .en_i(en),
        .giris_i(giris1),
        .cikis_o(cikis1));
     
     DC_deger#(.uzunluk(6)) DC_deger_tb2(
        .clk_i(clk_i),
        .en_i(en),
        .giris_i(giris2),
        .cikis_o(cikis2));
endmodule
