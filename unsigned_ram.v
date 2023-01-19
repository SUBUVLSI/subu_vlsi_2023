`timescale 1ns / 1ps

// UNSIGNED RAM
// V = rom a yazýlacak verinin boyutu
// S  = rom un satýr sayýsý
// A = adres için boyut // 3 bitlik adres, 8 satýrý adreslemiþ olur.
module unsigned_ram#(parameter V = 8, S = 76800, A = 20)(
    input clk_i,we_i,
    input [V-1:0] data_i,
    output [V-1:0] data_o,  //data_out baþka yere giriþ olacaðý zaman wire olmalý
    input  [A-1:0]address_i
    );
    
    reg [V-1:0] data_out;
    assign data_o = data_out;
    
    reg [V-1:0] RAM [0:S-1]; // reg [V-1:0] RAM [0:S-1]; de yazýlabilir
    
    always@(posedge(clk_i))begin
        if(we_i)begin
            RAM[address_i] = data_i;
        end
        else begin
            data_out = RAM[address_i];
        end
    end
endmodule