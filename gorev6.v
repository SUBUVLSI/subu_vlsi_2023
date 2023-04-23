`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2023 14:58:30
// Design Name: 
// Module Name: gorev6
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

module gorev6(
    input clk_i,rst_i,en_i,
    input [7:0] veri_i,
    output veri_al_o,
    output veri_gonder_o,
    output [7:0] veri_o,
    output islem_bitti_o
    );
    
    parameter max_row = 76800;
    
    parameter 
        VERI_AL1 = 22, 
        VERI_AL2 = 23, 
        VERI_AL3 = 24,
        ILK_VERI = 25,
        DIGER_VERILER = 26,
        VERI_GONDER1 = 27, 
        VERI_GONDER2 = 28,
        VERI_GONDER3 = 29,
        RAM_SIFIRLA = 30;
    
    reg [5:0] durum = VERI_AL1;
    integer sayac = 0, gec = 0,ind = 0;
    
    
    
    reg islem_bitti;
    assign islem_bitti_o = islem_bitti;
    

    // GARY2BW
    reg en_gray2bw;              
    reg [7:0] veri_i_gray2bw;             
    reg [7:0] treshold_degeri = 140; 
    wire [7:0] veri_o_gray2bw; 
    reg [7:0] gray2bw_deger; // direkt diziye yaz
    reg [7:0] gray2bw_deger_gir;
    reg [7:0] gray2bw_arr [0:max_row-1];
    
    // EROZYON
    reg en_erozyon;
    reg [7:0] g0,g1,g2,g3,g4,g5,g6,g7,g8;
    wire [7:0] veri_o_erozyon;
    reg [7:0] erozyon_deger;
    
    reg [17:0] satir = 0;
    reg [17:0] stn = 0;
    reg [17:0] ilk_ind = 323;
    
    parameter max_veri = 77924;
    integer i;
    
    reg [7:0] cikti;
    reg [7:0] gray2bw_deg;
    reg [17:0] indis = 0;
    reg veri_al = 1;   
    reg veri_gonder = 0;
    assign veri_al_o = veri_al;
    assign veri_gonder_o = veri_gonder;
    
    reg [7:0] veri_o_gorev6;
    assign veri_o = veri_o_gorev6;
    
    
    
    // gray2bwRAM
    reg en_ram_gray2bw;
    reg we_ram_gray2bw;
    reg [16:0] addr_i_ram_gray2bw=0;
    reg [16:0] addr_o_ram_gray2bw=0;
    reg [7:0] data_i_ram_gray2bw;
    wire [7:0] data_o_ram_gray2bw;
    reg [17:0] ind_gray2bw = 0;
    
    
    //ram ilk_arr 
    reg en_ram_ilk_arr;
    reg we_ram_ilk_arr;
    reg [16:0] addr_ram_ilk_arr;
    reg [7:0] data_i_ram_ilk_arr;
    wire [7:0] data_o_ram_ilk_arr;
    
    reg [4:0] drm = 0;
    
    
    always@(posedge clk_i)begin
        if(!rst_i)begin
        end else begin
            if(en_i == 1)begin
                sayac <= sayac + 1;
                case(durum)     
                
                    VERI_AL1:begin
                        if(veri_al == 1 && indis < max_row)begin
                            durum <= VERI_AL2;
                        end else begin
                            veri_al <= 0;
                            indis <= 0;
                            ind <= 0;
                            addr_i_ram_gray2bw <= 0;
                            ind_gray2bw <= 0;
                            en_ram_gray2bw <= 1;
                            we_ram_gray2bw <= 0; // okuma
                            addr_ram_ilk_arr <= 0;
                            durum <= RAM_SIFIRLA; // 4
                        end 
                    end 
                    
                    VERI_AL2:begin
                        if(indis < 1)begin
                            durum<= ILK_VERI;
                        end else begin
                            durum <= DIGER_VERILER;
                        end 
                    end 
                    
                    ILK_VERI:begin
                        if(gec < 4)begin 
                            gec <= gec + 1;
                            gray2bw_deger_gir <= veri_i;  // her cekilmede veri dataya aktarılacak
                        end else begin
                            gec <= 0;
                            durum <= 1;
                        end
                    end 
                    
                    DIGER_VERILER:begin
                        if(gec < 2)begin 
                            gec <= gec + 1;
                            gray2bw_deger_gir <= veri_i;  // her cekilmede veri dataya aktarılacak
                        end else begin
                            gec <= 0;
                            durum <= 1;
                        end
                    end 
                    
                    VERI_AL3:begin
                        indis <= indis + 1;
                        durum <= VERI_AL1;
                    end
                    
                 
                 // GRAY2BW      
                    1:begin
                        en_gray2bw <= 1;
                        veri_i_gray2bw <= gray2bw_deger_gir;
                        durum <= 2;
                    end 
                    2:begin
                        if(gec < 5)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            en_gray2bw <= 0;
                            gray2bw_deger <= veri_o_gray2bw;
                            addr_i_ram_gray2bw <= ind_gray2bw;
                            durum <= 3;
                        end
                    end
                    
                    3:begin
                        en_ram_gray2bw <= 1;
                        we_ram_gray2bw <= 1; // yazma
                        data_i_ram_gray2bw <= gray2bw_deger;
                        ind_gray2bw <= ind_gray2bw + 1;
                        durum <= VERI_AL3;
                    end 
                   
                   // ILK ARR RAM 0 ILE DOLDURURLUR
                   RAM_SIFIRLA:begin
                         if(i<max_veri)begin
                            en_ram_ilk_arr <= 1'b1;
                            we_ram_ilk_arr <= 1'b1;
                            data_i_ram_ilk_arr <= 8'b00000000;
                            addr_ram_ilk_arr <= addr_ram_ilk_arr + 1;
                            i <= i+ 1;
                        end else begin
                            en_ram_ilk_arr <= 1'b1;
                            we_ram_ilk_arr <= 1'b1; // yazma
                            addr_ram_ilk_arr <= ilk_ind; // 323
                            durum <= 4;
                        end 
                   end
                   
                   // ILK ARR RAM GRAY2BW ÇIKTILARI ILE DOLDURULUR
                   4:begin
                        if(ilk_ind < max_veri && stn < 240)begin
                            durum <= 5;
                        end else begin
                            addr_o_ram_gray2bw <= 0;
                            addr_i_ram_gray2bw <= 0; 
                            addr_ram_ilk_arr <= 0;
                            ind <= 0;
                            stn <= 0;
                            ilk_ind <= 0;
                            satir <= 0;
                            durum <= 7; 
                        end
                   end 
                   
                   5:begin
                        if(satir < 320)begin // 318
                            en_ram_ilk_arr <= 1'b1;
                            we_ram_ilk_arr <= 1'b1;
                            addr_ram_ilk_arr <= ilk_ind;
                            en_ram_gray2bw <= 1;
                            we_ram_gray2bw <= 0; // okuma
                            data_i_ram_ilk_arr <= data_o_ram_gray2bw;
                            addr_o_ram_gray2bw <= addr_o_ram_gray2bw + 1;
                            satir <= satir + 1;
                            ilk_ind <= ilk_ind + 1;
                            ind <= ind + 1;
                        end else begin
                            satir <= 0;
                            stn <= stn + 1;
                            durum <= 6;
                        end
                    end
                   
                    6:begin
                        ilk_ind <= ilk_ind + 2;
                        durum <= 4;
                    end 
                   
                    // KONVOLUSYON
                    7:begin
                        if(ind < max_row)begin
                            en_erozyon <= 1;
                            durum <= 8;
                        end else begin
                            ind <= 0;
                            indis <= 0;
                            satir <= 0;
                            stn <= 0;
                            durum <= 21; 
                        end
                    end
                    // g0
                    8:begin
                        addr_ram_ilk_arr <= satir;
                        if(gec <= 3)begin
                            gec <= gec + 1;
                            en_ram_ilk_arr <= 1'b1;
                            we_ram_ilk_arr <= 1'b0;
                            g0 <= data_o_ram_ilk_arr;
                        end else begin
                            gec <= 0;
                            durum <= 9;
                        end
                    end
                    // g1
                    9:begin
                        addr_ram_ilk_arr <= satir+1;
                        if(gec <= 3)begin
                            gec <= gec + 1;
                            en_ram_ilk_arr <= 1'b1;
                            we_ram_ilk_arr <= 1'b0;
                            g1 <= data_o_ram_ilk_arr;
                        end else begin
                            gec <= 0;
                            durum <= 10;
                        end
                    end 
                    // g2
                    10:begin
                        addr_ram_ilk_arr <= satir+2;
                        if(gec <= 3)begin
                            gec <= gec + 1;
                            en_ram_ilk_arr <= 1'b1;
                            we_ram_ilk_arr <= 1'b0;
                            g2 <= data_o_ram_ilk_arr;
                        end else begin
                            gec <= 0;
                            durum <= 11;
                        end
                    end    
                    // g3 
                    11:begin
                        addr_ram_ilk_arr <= satir+322;
                        if(gec <= 3)begin
                            gec <= gec + 1;
                            en_ram_ilk_arr <= 1'b1;
                            we_ram_ilk_arr <= 1'b0;
                            g3 <= data_o_ram_ilk_arr;
                        end else begin
                            gec <= 0;
                            durum <= 12;
                        end
                    end
                    // g4
                    12:begin
                        addr_ram_ilk_arr <= satir+323;
                        if(gec <= 3)begin
                            gec <= gec + 1;
                            en_ram_ilk_arr <= 1'b1;
                            we_ram_ilk_arr <= 1'b0;
                            g4 <= data_o_ram_ilk_arr;
                        end else begin
                            gec <= 0;
                            durum <= 13;
                        end
                    end
                    // g5
                    13:begin
                        addr_ram_ilk_arr <= satir+324;
                        if(gec <= 3)begin
                            gec <= gec + 1;
                            en_ram_ilk_arr <= 1'b1;
                            we_ram_ilk_arr <= 1'b0;
                            g5 <= data_o_ram_ilk_arr;
                        end else begin
                            gec <= 0;
                            durum <= 14;
                        end
                    end     
                    // g6
                    14:begin
                        addr_ram_ilk_arr <= satir+642;
                        if(gec <= 3)begin
                            gec <= gec + 1;
                            en_ram_ilk_arr <= 1'b1;
                            we_ram_ilk_arr <= 1'b0;
                            g6 <= data_o_ram_ilk_arr;
                        end else begin
                            gec <= 0;
                            durum <= 15;
                        end
                    end 
                    // g7
                    15:begin
                        addr_ram_ilk_arr <= satir+643;
                        if(gec <= 3)begin
                            gec <= gec + 1;
                            en_ram_ilk_arr <= 1'b1;
                            we_ram_ilk_arr <= 1'b0;
                            g7 <= data_o_ram_ilk_arr;
                        end else begin
                            gec <= 0;
                            durum <= 16;
                        end
                    end
                    // g8
                    16:begin
                        addr_ram_ilk_arr <= satir+644;
                        if(gec <= 3)begin
                            gec <= gec + 1;
                            en_ram_ilk_arr <= 1'b1;
                            we_ram_ilk_arr <= 1'b0;
                            g8 <= data_o_ram_ilk_arr;
                        end else begin
                            gec <= 0;
                            durum <= 17;
                        end
                    end 
                    
                    // EROZYON
                    17:begin
                        if(gec < 18)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            en_erozyon <= 0;
                            erozyon_deger <= veri_o_erozyon;
                            en_ram_gray2bw <= 1;
                            we_ram_gray2bw <= 0; // okuma
                            gray2bw_deg <= data_o_ram_gray2bw;
                            addr_o_ram_gray2bw <= ind;
                            durum <= 18; //11
                        end 
                    end 
                    
                    18:begin
                        if(stn<320)begin // 318
                            ind <= ind + 1;
                            satir <= satir + 1;
                            stn <= stn + 1;
                            durum <= 19; 
                        end else begin
                            satir <= satir + 2;
                            stn<=0;
                            durum<=7; 
                        end
                    end
                    
                    // GRAY2BW - EROZYON
                    19:begin
                        if(gray2bw_deg == 8'b00000000 && erozyon_deger == 8'b11111111)begin 
                            cikti <= 8'b00000000;
                        end else begin
                            cikti <= gray2bw_deg - erozyon_deger;
                        end  
                        addr_i_ram_gray2bw <= indis;
                        durum <= 20;
                    end   
                    
                    20:begin
                        if(gec < 2)begin
                            gec <= gec + 1;
                            en_ram_gray2bw <= 1;
                            we_ram_gray2bw <= 1; // yazma
                            data_i_ram_gray2bw <= cikti;
                        end else begin
                            gec <= 0;
                            indis <= indis + 1;
                            durum <= 7;
                        end
                    end
                    
                    21:begin
                        addr_o_ram_gray2bw <= 0;
                        ind <= 0;
                        indis <= 0;
                        islem_bitti <= 1;
                        veri_gonder <= 1;
                        durum <= VERI_GONDER1;
                    end 
                    
                    
                    // UST MODULE YAZMA
                    VERI_GONDER1:begin
                        if(veri_gonder == 1 && ind < max_row)begin
                            durum <= VERI_GONDER2;
                        end else begin
                            durum <= 31; // SON
                        end 
                    end 
                    
                    VERI_GONDER2:begin
                        if(gec < 3)begin // 2
                            gec <= gec + 1;
                            we_ram_gray2bw <= 0; // okuma
                            addr_o_ram_gray2bw <= ind;
                            veri_o_gorev6 <= data_o_ram_gray2bw;
                        end else begin
                            gec <= 0;
                            durum <= VERI_GONDER3;
                        end 
                    end 
                    
                    VERI_GONDER3:begin
                        ind <= ind + 1;
                        durum <= VERI_GONDER1;
                    end
                    
                    
                endcase
            end 
        end 
    end 
    
   
   
    gray2bw GRAY2BW(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_gray2bw),    
        .veri_i(veri_i_gray2bw),
        .treshold_degeri_i(treshold_degeri),
        .veri_o(veri_o_gray2bw)
        );
        
        
    erozyon EROZYON(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_erozyon),
    .g0_i(g0),
    .g1_i(g1),
    .g2_i(g2),
    .g3_i(g3),
    .g4_i(g4),
    .g5_i(g5),
    .g6_i(g6),
    .g7_i(g7),
    .g8_i(g8),
    .veri_o(veri_o_erozyon)
    );
    
    
    // gray2bw ram 
    // 8 bitlik ram / 76800 satır
    dual_port_ram#(.V(8),.S(76800),.A(17)) gray2bwRAM(
        .clk_i(clk_i),
        .en_i(en_ram_gray2bw),
        .we_i(we_ram_gray2bw),
        .address_i(addr_i_ram_gray2bw),
        .address_o(addr_o_ram_gray2bw),
        .data_i(data_i_ram_gray2bw),
        .data_o(data_o_ram_gray2bw)
    );
    
    
    
    
    ram#(.V(8),.S(77923),.A(17)) RAM_ilk_arr(
        .clk_i(clk_i),
        .en_i(en_ram_ilk_arr),
        .we_i(we_ram_ilk_arr),
        .address_i(addr_ram_ilk_arr),
        .data_i(data_i_ram_ilk_arr),
        .data_o(data_o_ram_ilk_arr)
    );
    
    
endmodule
