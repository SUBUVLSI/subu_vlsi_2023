`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.03.2023 12:52:00
// Design Name: 
// Module Name: gorev4_histogram_table
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


module gorev4_histogram_table(
input clk_i, rst_i, en_i,
    input [7:0] veri_i,
    output veri_al_o,veri_gonder_o,
    output [31:0] veri_o,
    output islem_bitti_o
    );

integer i=0, sayac=0;


parameter VERI_AL1 = 20, VERI_AL2 = 21, VERI_GONDER1 = 22, VERI_GONDER2 = 23;
reg [6:0] durum = VERI_AL1;
reg [23:0] histogram_out [0:255] ;
reg [31:0] data_out [0:255] ;
reg [7:0] data_indeks [0:255] ;
reg [7:0] a;
reg bitti=0;
parameter max_row = 76800;
reg [7:0] mem [0:max_row-1];


reg veri_al = 1;   
reg veri_gonder = 0;
assign veri_al_o = veri_al;
assign veri_gonder_o = veri_gonder;

reg [31:0] veri_o_gorev4;
assign veri_o = veri_o_gorev4;
reg [5:0] durum_oku;

reg islem_bitti;
assign islem_bitti_o = islem_bitti;

reg [18:0] indis = 0, gec = 0, ind = 0;

reg [8:0] k = 0, m = 0;

    always @(posedge clk_i) begin
        if(rst_i)begin
        end else begin
            if(en_i == 1)begin
                sayac=sayac+1;
                case(durum)
                
                    VERI_AL1:begin
                        durum_oku <= durum;
                        if(veri_al == 1)begin
                            if(indis < max_row)begin     
                                if(indis < 1)begin
                                    if(gec < 4)begin 
                                        gec <= gec + 1;
                                        mem[indis] <= veri_i;  // her cekilmede veri dataya aktarýlacak
                                        // veri_kontrol <= veri_i;
                                    end else begin
                                        gec <= 0;
                                        durum <= VERI_AL2;
                                    end 
                                end else begin
                                    if(gec < 2)begin 
                                        gec <= gec + 1;
                                        mem[indis] <= veri_i;  // her cekilmede veri dataya aktarýlacak
                                        // veri_kontrol <= veri_i;
                                    end else begin
                                        gec <= 0;
                                        durum <= VERI_AL2;
                                    end  
                                end
                            end else begin
                                veri_al <= 0;
                                indis <= 0;
                                ind <= 0;
                                durum <= 0;
                            end
                        end else begin
                        end 
                    end 
                    VERI_AL2:begin
                        durum_oku <= durum;
                        indis <= indis + 1;
                        durum <= VERI_AL1;
                    end 
            
                    0:begin                  
                        if(i<256) begin
                           histogram_out[i] <= 0;
                           i<=i+1;
                        end else begin
                          i<=0;
                          durum<=1; end
                    end
                    
                    1:begin                     
                       if(i<max_row) begin
                          a<=mem[i];
                          durum<=2;
                       end else begin
                          durum<=3;                         
                       end      
                    end
                    
                    2:begin
                          histogram_out[a] <= histogram_out[a] + 1;
                          i<=i+1;
                          durum<=1;
                     end
                     3:begin
                        if(k < 256) begin
                            data_indeks[k] <= k;
                            k <= k+1;
                        end else begin
                            durum<=4;
                        end
                     end
                     4:begin
                          if(m<256) begin
                            data_out[m] = {data_indeks[m], histogram_out[m]};
                            m <= m+1;
                          end else begin
                            durum<=5;
                          end
                     end

                     

                     
                    5:begin
                        bitti=1;
                        islem_bitti <= 1;
                        veri_gonder <= 1;
                        durum <= VERI_GONDER1;
                     end
                     
                     // UST MODULE YAZMA
                    VERI_GONDER1:begin
                        durum_oku <= durum;
                        if(veri_gonder == 1)begin
                            if(ind < 256)begin
                                if(gec < 2)begin
                                    gec <= gec + 1;
                                    veri_o_gorev4 <= data_out[ind];
                                end else begin
                                    gec <= 0;
                                    durum <= VERI_GONDER2;
                                end 
                            end else begin
                            end
                        end else begin
                            durum <= 15;
                        end 
                    end
                    
                    VERI_GONDER2:begin
                        durum_oku <= durum;
                        ind <= ind + 1;
                        durum <= VERI_GONDER1;
                    end
                endcase
            end
        end
    end
    
endmodule
