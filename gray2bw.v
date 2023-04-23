`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.01.2023 17:05:22
// Design Name: 
// Module Name: gray2bw
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


module gray2bw(
    input clk_i,rst_i,en_i,
    input [7:0] veri_i,
    input [7:0] treshold_degeri_i,
    output [7:0] veri_o
    
    );
    
    integer sayac = 0;
    reg [2:0] durum = 0;
    
    reg [7:0] treshold, veri, cikti;
    assign veri_o = cikti;
    always@(posedge clk_i)begin
        if(!rst_i)begin
        end else begin
            if(en_i)begin
                sayac <= sayac + 1;
                case(durum) 
                    0:begin
                        if(sayac <= 2)begin
                            treshold <= treshold_degeri_i;
                            veri <= veri_i;
                        end else begin
                            durum <= 1;
                        end
                    end 
                    
                    1:begin
                        if(veri < treshold)begin
                            cikti <= 0;
                            durum <= 2;
                        end 
                        else begin // veri >= treshold
                            cikti <= 8'b11111111; // 255
                            durum <= 2;
                        end
                    end
                    
                    2:begin
                        durum <= 0;
                        sayac <= 0;
                        treshold <= 0;
                        veri <= 0;
                    end
                endcase
            end else begin
            end
        end
    end 
endmodule
