`timescale 1ns / 1ps
// V = rom a yaz�lacak verinin boyutu
// S  = rom un sat�r say�s�
// A = adres i�in boyut // 3 bitlik adres, 8 sat�r� adreslemi� olur.
module ram#(parameter V = 8, S = 76800, A = 20)(
    input clk_i,we_i,
    input [V-1:0] data_i,
    output reg [V-1:0] data_o,  //data_out ba�ka yere giri� olaca�� zaman wire olmal�
    input [A-1:0]address_i
    );
    reg [V-1:0] RAM [0:76799]; // reg [V-1:0] RAM [0:S-1]; de yaz�labilir
    
    always@(posedge(clk_i))begin
        if(we_i)begin
            RAM[address_i]=data_i;
        end
        else begin
            data_o=RAM[address_i];
        end
    end
endmodule