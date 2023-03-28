`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2023 14:28:59
// Design Name: 
// Module Name: dual_port_ram
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


module dual_port_ram #(parameter V = 8, S = 76800, A = 20)(
    input clk_i,we_i,en_i,
    input [V-1:0] data_i,
    output [V-1:0] data_o,  //data_out başka yere giriş olacağı zaman wire olmalı
    input [A-1:0] address_i,
    input [A-1:0] address_o
    );
    
    reg [V-1:0] data_out;
    assign data_o = data_out;
    
    reg [V-1:0] RAM [0:S-1]; // reg [V-1:0] RAM [0:S-1]; de yazılabilir
    
    always@(posedge(clk_i))begin
        if(en_i == 1)begin
            if(we_i == 1)begin
                RAM[address_i] = data_i;
            end
            else begin
                data_out = RAM[address_o];
            end
        end else begin
        end 
    end
endmodule
