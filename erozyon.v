`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.01.2023 17:25:17
// Design Name: 
// Module Name: erozyon
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


// max 15 clock
module erozyon(
    input clk_i, rst_i,en_i,
    input [7:0] g0_i,g1_i,g2_i,g3_i,g4_i,g5_i,g6_i,g7_i,g8_i,
    output [7:0] veri_o
    );
    
    reg [2:0] durum = 0;
    integer sayac = 0, i = 0;
    
    reg [7:0] erozyon_arr [0:8];
    reg [7:0] cikti;
    assign veri_o = cikti;
    
    always@(posedge clk_i)begin
        if(rst_i)begin
        end else begin
            if(en_i)begin
                sayac <= sayac + 1;
                case(durum)
                    0:begin
                        if(sayac <= 2)begin
                            erozyon_arr[0] <= g0_i;
                            erozyon_arr[1] <= g1_i;
                            erozyon_arr[2] <= g2_i;
                            erozyon_arr[3] <= g3_i;
                            erozyon_arr[4] <= g4_i;
                            erozyon_arr[5] <= g5_i;
                            erozyon_arr[6] <= g6_i;
                            erozyon_arr[7] <= g7_i;
                            erozyon_arr[8] <= g8_i;
                        end else begin
                            durum <= 1;
                        end
                    end
                    
                    1:begin
                        if(i < 9)begin
                            if(erozyon_arr[i] == 0)begin // herhangi bir deger 0 ise
                                cikti <= 0;
                                durum <= 2;
                            end else begin
                                i <= i + 1;
                                durum <= 1;
                            end
                        end else begin // butun degerler 255
                            cikti <= 8'b11111111;
                            durum <= 2;
                        end
                    end
                    
                    2:begin
                        durum <= 0;
                        sayac <= 0;
                        i <= 0;
                        erozyon_arr[0] <= 0;
                        erozyon_arr[1] <= 0;
                        erozyon_arr[2] <= 0;
                        erozyon_arr[3] <= 0;
                        erozyon_arr[4] <= 0;
                        erozyon_arr[5] <= 0;
                        erozyon_arr[6] <= 0;
                        erozyon_arr[7] <= 0;
                        erozyon_arr[8] <= 0;
                        
                    end
                endcase
            end else begin
                durum <= 0;
                sayac <= 0;
                i <= 0;
                erozyon_arr[0] <= 0;
                erozyon_arr[1] <= 0;
                erozyon_arr[2] <= 0;
                erozyon_arr[3] <= 0;
                erozyon_arr[4] <= 0;
                erozyon_arr[5] <= 0;
                erozyon_arr[6] <= 0;
                erozyon_arr[7] <= 0;
                erozyon_arr[8] <= 0;
                
                cikti <= 0;
            end
        end
    end 
endmodule
