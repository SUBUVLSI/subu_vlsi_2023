`timescale 100ns / 1ps

module gorev_6(
    input clk_i,rst_i,en_i,
    input [7:0] veri_i,
    output veri_al_o,
    output veri_gonder_o,
    output [7:0] veri_o,
    output islem_bitti_o,
    output [5:0] durum_oku_o,
    output [16:0] indis_kontrol
    
    );
    
    parameter max_row = 76800;
    
    parameter VERI_AL1 = 20, VERI_AL2 = 21, VERI_GONDER1 = 22, VERI_GONDER2 = 23;
    
    reg [5:0] durum = VERI_AL1;
    reg [17:0] sayac = 0, gec = 0,ind = 0;
    
    
    
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
    
    reg [7:0] erozyon_arr [0:max_row-1]; // bunu kullanma direkt 0 lı olan diziye aktar 
    reg [17:0] satir = 0;
    reg [17:0] stn = 0;
    reg [17:0] ilk_ind = 323;
    
    parameter max_veri = 77924;
    reg [7:0] ilk_arr [0:77923];
    integer i;
    ///////////
    initial begin
        for (i = 0; i < max_veri; i = i + 1) begin
           ilk_arr[i] <= 8'b00000000;
        end
    end
   
    
    
    reg [7:0] cikti;
    reg [7:0] gray2bw_deg;
    reg [17:0] indis = 0;
    reg veri_al = 1;   
    reg veri_gonder = 0;
    assign veri_al_o = veri_al;
    assign veri_gonder_o = veri_gonder;
    reg [5:0] durum_oku; // boyutu azalt gereksizse 
    assign durum_oku_o = durum_oku;
    assign indis_kontrol = indis;
    
    reg [7:0] veri_o_gorev6;
    assign veri_o = veri_o_gorev6;
    
    always@(posedge clk_i)begin
        if(rst_i)begin
        end else begin
            if(en_i == 1)begin
                sayac <= sayac + 1;
                case(durum)     
                
                    VERI_AL1:begin
                        durum_oku <= durum;
                        if(veri_al == 1)begin
                            if(indis < max_row)begin  
                                if(indis < 1)begin
                                    if(gec < 4)begin 
                                        gec <= gec + 1;
                                        gray2bw_deger_gir <= veri_i;  // her cekilmede veri dataya aktarılacak
                                    end else begin
                                        gec <= 0;
                                        durum <= 1;
                                    end
                                end else begin
                                    if(gec < 2)begin 
                                        gec <= gec + 1;
                                        gray2bw_deger_gir <= veri_i;  // her cekilmede veri dataya aktarılacak
                                    end else begin
                                        gec <= 0;
                                        durum <= 1;
                                    end
                                end
                                   
                                  
                                
                            end else begin
                                veri_al <= 0;
                                indis <= 0;
                                ind <= 0;
                                durum <= 4; // 4
                            end
                        end else begin
                        end 
                    end 
                    
                    VERI_AL2:begin
                        durum_oku <= durum;
                        indis <= indis + 1;
                        durum <= VERI_AL1;
                    end 
                 
                 // GRAY2BW
                        
                    1:begin
                        durum_oku <= durum;
                        en_gray2bw <= 1;
                        veri_i_gray2bw <= gray2bw_deger_gir;
                        durum <= 2;
                    end 
                    2:begin
                        durum_oku <= durum;
                        if(gec < 5)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            en_gray2bw <= 0;
                            gray2bw_deger <= veri_o_gray2bw;
                            durum <= 3;
                        end
                    end
                    
                    3:begin
                        durum_oku <= durum;
                        gray2bw_arr[indis] <= gray2bw_deger;
                        durum <= VERI_AL2;
                    end 
                   
                   // 0 lı olan diziye yaz
                    4:begin
                        durum_oku <= durum;
                        if(ilk_ind < max_veri)begin
                           if(stn < 240)begin 
                                if(satir < 320)begin // 318
                                    ilk_arr[ilk_ind] <=  gray2bw_arr[ind];
                                    satir <= satir + 1;
                                    ilk_ind <= ilk_ind + 1;
                                    ind <= ind + 1;
                                end else begin
                                    satir <= 0;
                                    stn <= stn + 1;
                                    durum <= 5;
                                end
                            end else begin
                                ind <= 0;
                                stn <= 0;
                                ilk_ind <= 0;
                                satir <= 0;
                                durum <= 7; 
                            end
                        end else begin
                            ind <= 0;
                            stn <= 0;
                            ilk_ind <= 0;
                            satir <= 0;
                            durum <= 7; 
                        end
                    end
                    5:begin
                        durum_oku <= durum;
                        ilk_ind <= ilk_ind + 2;
                        durum <= 4;
                    end
                    
                    // KONVOLUSYON
                    7:begin 
                        durum_oku <= durum;
                        if(ind < max_row)begin
                            en_erozyon <= 1;
                            g0 <= ilk_arr[satir]; 
                            g1 <= ilk_arr[satir+1];
                            g2 <= ilk_arr[satir+2];
                            g3 <= ilk_arr[satir+322];
                            g4 <= ilk_arr[satir+323];
                            g5 <= ilk_arr[satir+324];
                            g6 <= ilk_arr[satir+642];
                            g7 <= ilk_arr[satir+643];
                            g8 <= ilk_arr[satir+644];
                            
                            durum <= 8;
                        end else begin
                            ind <= 0;
                            indis <= 0;
                            satir <= 0;
                            stn <= 0;
                            durum <= 10; 
                        end 
                    end 
                    
                    // EROZYON
                    8:begin
                        durum_oku <= durum;
                        if(gec < 16)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            en_erozyon <= 0;
                            erozyon_deger <= veri_o_erozyon;
                            gray2bw_deg <= gray2bw_arr[ind];
                            durum <= 9; //11
                        end 
                    end
                    
                    9:begin
                        durum_oku <= durum;
                        if(stn<320)begin // 318
                            erozyon_arr[ind] <= erozyon_deger;
                            ind <= ind + 1;
                            satir <= satir + 1;
                            stn <= stn + 1;
                            durum <= 11; // 7
                        end else begin
                            satir <= satir + 2;
                            stn<=0;
                            durum<=7;//11
                        end
                    end
                    
                    
                    // GRAY2BW - EROZYON
                    
                    10:begin
                        durum_oku <= durum;
                        ind <= 0;
                        indis <= 0;
                        islem_bitti <= 1;
                        veri_gonder <= 1;
                        durum <= VERI_GONDER1;
                    end 
                    
                    11:begin
                        durum_oku <= durum;
                        if(gray2bw_deg == 8'b00000000 && erozyon_deger == 8'b11111111)begin 
                            cikti <= 8'b00000000;
                            durum <= 12;
                        end else begin
                            cikti <= gray2bw_deg - erozyon_deger; 
                            durum <= 12;
                        end  
                    end 
                    12:begin
                        durum_oku <= durum;
                        //erozyon_arr[ind] <= erozyon_deger;
                        gray2bw_arr[indis] <= cikti;
                        indis <= indis + 1;
                        durum <= 7; 
                    end
                    
                    
                    // UST MODULE YAZMA
                    VERI_GONDER1:begin
                        durum_oku <= durum;
                        if(veri_gonder == 1)begin
                            if(ind < max_row)begin
                                if(gec < 2)begin
                                    gec <= gec + 1;
                                    veri_o_gorev6 <= gray2bw_arr[ind];
                                end else begin
                                    gec <= 0;
                                    durum <= VERI_GONDER2;
                                end 
                            end else begin
                            end
                        end else begin
                            durum <= 13;
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
    
endmodule
