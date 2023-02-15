`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.01.2023 15:16:58
// Design Name: 
// Module Name: inverse_AC
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


module inverse_AC(
    input clk_i,rst_i, en_i,
    input [31:0] encoded_veri_i, // 100001 // 1111011 0111010110100101111000000
    output [31:0] encoded_veri_o,
    output [17:0] ac_deger_o,
    output [10:0] asil_deger_o,
    output [4:0] sagdaki_sifir_sayisi_o, // max 20 olabilir
    output [4:0] ondeki_sifir_sayisi_o, // asil sayi onundeki 0 sayisi / ramde asil sayi onune yazilacak  
    output eob_kontrol_o // bu 1 olursa ilk matris bitmiş olur
    );
    
    
    // CIKTILAR ICIN
    reg [8:0] ram_deger0; // ac_deger ciktisi, signed olarak 9 bit yeter
    reg [10:0] ram_deger1; // asil sayi ciktisi, signed olarak 8 bit yeter 
    reg [10:0] ram_deger_asil; // asil sayi ciktisi, signed olarak 8 bit yeter / ram e yazılacak
    reg [31:0] encoded_veri_cikti; // kaydirmalar sonucu kalan encoded_veri cikti
    reg [4:0] cikis_sifir,cikis_sifir_deger; // asil sayi onundeki 0 sayisi / ramde asil sayi onune yazilacak 
    reg eob_kontrol= 0,eob_kontrol_oku = 0;
    integer kaydirma = 0,kaydirma1 = 0, kaydirma1_deger = 0; 
    // kaydirma = ilk kaydirma / kaydirma1 = toplam kaydirma => bunla beraber encoded_veri_i ne kadar kaydirilmis olacak o kontrol edilir ve sağ tafata biriken 0 sayisi kontrol edilmiş olur
    assign sagdaki_sifir_sayisi_o = kaydirma1_deger; // sagdaki 0 ların sayisi ile bir sonraki matrise gelecek degerlerin kontrolü
    assign ondeki_sifir_sayisi_o = cikis_sifir_deger;
    assign eob_kontrol_o = eob_kontrol_oku;
    assign encoded_veri_o = encoded_veri_cikti;
    assign ac_deger_o = ram_deger0;
    assign asil_deger_o = ram_deger_asil;
    
    // genel degiskenler
    reg [31:0] encoded_veri_deger; // bu shift left işlemi haric degismeyecek
    reg [5:0] durum = 0;
    integer sayac=0, gec = 0;
    integer i = 0; // sayinin tersini almada kullanilir
    integer j = 0; // ram_deger1 in 2 ye tümleyenini almak icin // ram_deger_asil olusturmak
    
    // rotate_shift icin 
    reg en_r1,en_r2,en_r3,en_r4,en_r5,en_r6,en_r7,en_r8,en_r9,en_r10,en_r11,en_r12,en_r13,en_r14,en_r15,en_r16; // enable / ac_icin max 16 bit kaydrılabilir / ac_deger icin / cikis_deger icin max 10
    reg [31:0] sayi_r; // rotate shift giris
    
    // ara degiskenler bit uzunluguna göre degisir max 16 // rotate shiftten cikip , ac_deger e girer
    wire [0:0] ara_deger1; // 1 bitlik
    wire [1:0] ara_deger2; // 2 bitlik
    wire [2:0] ara_deger3; // 3 bitlik
    wire [3:0] ara_deger4; // 4 bitlik
    wire [4:0] ara_deger5; // 5 bitlik
    wire [5:0] ara_deger6; // 6 bitlik
    wire [6:0] ara_deger7; // 7 bitlik
    wire [7:0] ara_deger8; // 8 bitlik
    wire [8:0] ara_deger9; // 9 bitlik
    wire [9:0] ara_deger10; // 10 bitlik
    wire [10:0] ara_deger11; // 11 bitlik
    wire [11:0] ara_deger12; // 12 bitlik
    wire [12:0] ara_deger13; // 13 bitlik
    wire [13:0] ara_deger14; // 14 bitlik
    wire [14:0] ara_deger15; // 15 bitlik
    wire [15:0] ara_deger16; // 16 bitlik
    
    // AC DEGERI ICIN
    // cikis 
    reg [3:0] cikis_deger; // cikti
    // giris // max 16 bit
    reg [0:0] ac_deger1; // 1 bitlik
    reg [1:0] ac_deger2; // 2 bitlik
    reg [2:0] ac_deger3; // 3 bitlik
    reg [3:0] ac_deger4; // 4 bitlik
    reg [4:0] ac_deger5; // 5 bitlik
    reg [5:0] ac_deger6; // 6 bitlik
    reg [6:0] ac_deger7; // 7 bitlik
    reg [7:0] ac_deger8; // 8 bitlik
    reg [8:0] ac_deger9; // 9 bitlik
    reg [9:0] ac_deger10; // 10 bitlik
    reg [10:0] ac_deger11; // 11 bitlik
    reg [11:0] ac_deger12; // 12 bitlik
    reg [12:0] ac_deger13; // 13 bitlik
    reg [13:0] ac_deger14; // 14 bitlik
    reg [14:0] ac_deger15; // 15 bitlik
    reg [15:0] ac_deger16; // 16 bitlik        
            
    // ASIL SAYILAR ICIN
    reg [0:0] asil_deger1; // 1 bitlik
    reg [1:0] asil_deger2; // 2 bitlik
    reg [2:0] asil_deger3; // 3 bitlik
    reg [3:0] asil_deger4; // 4 bitlik
    reg [4:0] asil_deger5; // 5 bitlik
    reg [5:0] asil_deger6; // 6 bitlik
    reg [6:0] asil_deger7; // 7 bitlik
    reg [7:0] asil_deger8; // 8 bitlik
    reg [8:0] asil_deger9; // 9 bitlik
    reg [9:0] asil_deger10; // 10 bitlik
    
    
    always@(posedge clk_i)begin
        if(rst_i)begin
        end else begin
            sayac = sayac+1;
            if(en_i == 1)begin
                sayac = sayac + 1;
                case(durum) 
                    0:begin
                        if(sayac<=3)begin  // 3 clk beklettik
                            encoded_veri_deger = encoded_veri_i; // veriyi aldık 
                        end 
                        else begin
                            durum = 3; // 2 bitlik kontrolden başlar
                        end
                    end
                    
                    // GENEL AC KONTROL
                    1:begin
                         
                         // 2 BITLIK
                        if(kaydirma == 2)begin
                            if(ac_deger2 == 2'b00)begin
                               cikis_sifir = 4'b0000; // 0 
                               cikis_deger = 4'b0001; // 1
                               ram_deger0 = 2'b00; // ramin ilk satırına ac_degeri yazilir
                               durum = 5; // geldigi yerden bir sonraki yere / 4->5
                            end 
                            else if(ac_deger2 == 2'b01)begin
                                cikis_sifir = 4'b0000; // 0
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 2'b01; // ramin ilk satırına ac_degeri yazilir
                                durum = 5; // geldigi yerden bir sonraki yere / 4->5
                            end
                            else begin
                                cikis_sifir = 4'bxxxx; // tanımsız
                                cikis_deger = 4'bxxx; // tanımsız
                                en_r2 = 0; // kaydir = 2
                                en_r3 = 1; // kaydir = 3
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 6; // kontrol sonucu bir veri elde edilmezse => 3 bitlik kontrole gidilir   
                            end
                        end
                        
                        // 3 BITLIK
                        else if(kaydirma == 3)begin
                            if(ac_deger3 == 3'b100) begin
                                cikis_sifir = 4'b0000; // 0
                                cikis_deger = 4'b0011; // 3   
                                ram_deger0 = 3'b100; // ramin ilk satırına ac_degeri yazilir
                                durum = 7; // geldigi yerden bir sonraki yere / 6->7
                            end else begin
                                cikis_sifir = 4'bxxxx; // tanımsız
                                cikis_deger = 4'bxxx; // tanımsız
                                en_r3 = 0; 
                                en_r4 = 1; 
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 8; // kontrol sonucu bir veri elde edilmezse => 4 bitlik kontrole gidilir 
                            end
                        end
                        
                        // 4 BITLIK
                        else if(kaydirma == 4)begin
                            if(ac_deger4 == 4'b1011) begin
                                cikis_sifir = 4'b0000; // 0
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 4'b1011; // ramin ilk satırına ac_degeri yazilir
                                durum = 9; // geldigi yerden bir sonraki yere / 8->9
                            end
                            else if(ac_deger4 == 4'b1100) begin
                                cikis_sifir = 4'b0001; // 1
                                cikis_deger = 4'b0001; // 1
                                ram_deger0 = 4'b1100; // ramin ilk satırına ac_degeri yazilir
                                durum = 9; // geldigi yerden bir sonraki yere / 8->9
                            end 
                            
                            else if(ac_deger4 == 4'b1010) begin  // eob ise bitti 
                                // EOB 
                                eob_kontrol = 1;
                                kaydirma1 = 4;
                                durum = 35;
                            end 
                            else begin
                                cikis_sifir = 4'bxxxx; // tanımsız
                                cikis_deger = 4'bxxx; // tanımsız
                                en_r4 = 0; 
                                en_r5 = 1; 
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 10; // kontrol sonucu bir veri elde edilmezse => 5 bitlik kontrole gidilir 
                            end
                        end
                        
                        // 5 BITLIK
                        else if(kaydirma == 5)begin
                            if(ac_deger5 == 5'b11010) begin
                                cikis_sifir = 4'b0000; // 0
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 5'b11010; // ramin ilk satırına ac_degeri yazilir
                                durum = 11; // geldigi yerden bir sonraki yere / 10->11
                            end
                            else if(ac_deger5 == 5'b11011) begin
                                cikis_sifir = 4'b0001; // 1
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 5'b11011; // ramin ilk satırına ac_degeri yazilir
                                durum = 11; // geldigi yerden bir sonraki yere / 10->11
                            end
                            else if(ac_deger5 == 5'b11100) begin
                                cikis_sifir = 4'b0010; // 2
                                cikis_deger = 4'b0001; // 1
                                ram_deger0 = 5'b11100; // ramin ilk satırına ac_degeri yazilir
                                durum = 11; // geldigi yerden bir sonraki yere / 10->11
                            end
                            else begin
                                cikis_sifir = 4'bxxxx; // tanımsız
                                cikis_deger = 4'bxxx; // tanımsız
                                en_r5 = 0; 
                                en_r6 = 1; 
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 12; // kontrol sonucu bir veri elde edilmezse => 6 bitlik kontrole gidilir                                 
                            end
                        end
                        
                        // 6 BITLIK KONTROL
                        else if(kaydirma == 6) begin
                            if(ac_deger6 == 6'b111010)begin
                                cikis_sifir = 4'b0011; // 3
                                cikis_deger = 4'b0001; // 1
                                ram_deger0 = 6'b111010; // ramin ilk satırına ac_degeri yazilir
                                durum = 13; // geldigi yerden bir sonraki yere / 12->13
                            end
                            else if(ac_deger6 == 6'b111011)begin
                                cikis_sifir = 4'b0100; // 4
                                cikis_deger = 4'b0001; // 1
                                ram_deger0 = 6'b111011; // ramin ilk satırına ac_degeri yazilir
                                durum = 13; // geldigi yerden bir sonraki yere / 12->13
                            end
                            else begin
                                cikis_sifir = 4'bxxxx; // tanımsız
                                cikis_deger = 4'bxxx; // tanımsız
                                en_r6 = 0; 
                                en_r7 = 1; 
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 14; // kontrol sonucu bir veri elde edilmezse => 7 bitlik kontrole gidilir   
                            end
                        end
                        
                        // 7 BITLIK
                        else if(kaydirma == 7)begin
                            if(ac_deger7 == 7'b1111000)begin
                                cikis_sifir = 4'b0000; // 0
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 7'b1111000; // ramin ilk satırına ac_degeri yazilir
                                durum = 15; // geldigi yerden bir sonraki yere / 14->15
                            end
                            else if(ac_deger7 == 7'b1111001)begin
                                cikis_sifir = 4'b0001; // 1
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 7'b1111001; // ramin ilk satırına ac_degeri yazilir
                                durum = 15; // geldigi yerden bir sonraki yere / 14->15
                            end
                            else if(ac_deger7 == 7'b1111010)begin
                                cikis_sifir = 4'b0101; // 5
                                cikis_deger = 4'b0001; // 1
                                ram_deger0 = 7'b1111010; // ramin ilk satırına ac_degeri yazilir
                                durum = 15; // geldigi yerden bir sonraki yere / 14->15
                            end
                            else if(ac_deger7 == 7'b1111011)begin
                                cikis_sifir = 4'b0110; // 6
                                cikis_deger = 4'b0001; // 1
                                ram_deger0 = 7'b1111011; // ramin ilk satırına ac_degeri yazilir
                                durum = 15; // geldigi yerden bir sonraki yere / 14->15
                            end else begin
                                cikis_sifir = 4'bxxxx; // tanımsız
                                cikis_deger = 4'bxxx; // tanımsız
                                en_r7 = 0; 
                                en_r8 = 1; 
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 16; // kontrol sonucu bir veri elde edilmezse => 8 bitlik kontrole gidilir 
                            end
                        end
                        
                        // 8 BITLIK 
                        else if(kaydirma == 8)begin
                            if(ac_deger8 == 8'b11111000)begin
                                cikis_sifir = 4'b0000; // 0
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 8'b11111000; // ramin ilk satırına ac_degeri yazilir
                                durum = 17; // geldigi yerden bir sonraki yere / 16->17
                            end
                            else if(ac_deger8== 8'b11111001)begin
                                cikis_sifir = 4'b0010; // 2
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 8'b11111001; // ramin ilk satırına ac_degeri yazilir
                                durum = 17; // geldigi yerden bir sonraki yere / 16->17
                            end
                            else if(ac_deger8== 8'b11111010)begin
                                cikis_sifir = 4'b0111; // 7
                                cikis_deger = 4'b0001; // 1
                                ram_deger0 = 8'b11111010; // ramin ilk satırına ac_degeri yazilir
                                durum = 17; // geldigi yerden bir sonraki yere / 16->17
                            end else begin 
                                cikis_sifir = 4'bxxxx; // tanımsız
                                cikis_deger = 4'bxxx; // tanımsız
                                en_r8 = 0; 
                                en_r9 = 1; 
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 18; // kontrol sonucu bir veri elde edilmezse => 9 bitlik kontrole gidilir 
                            end
                        end
                        
                        // 9 BITLIK
                        else if(kaydirma == 9)begin
                            if(ac_deger9 == 9'b111110110)begin
                                cikis_sifir = 4'b0001; // 1
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 9'b111110110; // ramin ilk satırına ac_degeri yazilir
                                durum = 19; // geldigi yerden bir sonraki yere / 18->19
                            end
                            else if(ac_deger9 == 9'b111110111)begin
                                cikis_sifir = 4'b0011; // 3
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 9'b111110111; // ramin ilk satırına ac_degeri yazilir
                                durum = 19; // geldigi yerden bir sonraki yere / 18->19
                            end
                            else if(ac_deger9 == 9'b111111000)begin
                                cikis_sifir = 4'b1000; // 8
                                cikis_deger = 4'b0001; // 1
                                ram_deger0 = 9'b111111000; // ramin ilk satırına ac_degeri yazilir
                                durum = 19; // geldigi yerden bir sonraki yere / 18->19
                            end
                            else if(ac_deger9 == 9'b111111001)begin
                                cikis_sifir = 4'b1001; // 9
                                cikis_deger = 4'b0001; // 1
                                ram_deger0 = 9'b111111001; // ramin ilk satırına ac_degeri yazilir
                                durum = 19; // geldigi yerden bir sonraki yere / 18->19
                            end
                            else if(ac_deger9 == 9'b111111010)begin
                                cikis_sifir = 4'b1010; // 10
                                cikis_deger = 4'b0001; // 1
                                ram_deger0 = 9'b111111010; // ramin ilk satırına ac_degeri yazilir
                                durum = 19; // geldigi yerden bir sonraki yere / 18->19
                            end else begin
                                cikis_sifir = 4'bxxxx; // tanımsız
                                cikis_deger = 4'bxxx; // tanımsız
                                en_r9 = 0; 
                                en_r10 = 1; 
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 20; // kontrol sonucu bir veri elde edilmezse => 10 bitlik kontrole gidilir 
                            end
                        end
                        
                        // 10 BITLIK 
                        else if(kaydirma == 10)begin
                            if(ac_deger10 == 10'b1111110110)begin
                                cikis_sifir = 4'b0000; // 0
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 10'b1111110110; // ramin ilk satırına ac_degeri yazilir
                                durum = 21; // geldigi yerden bir sonraki yere / 20->21
                            end
                            else if(ac_deger10 == 10'b1111110111)begin
                                cikis_sifir = 4'b0010; // 2
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 10'b1111110111; // ramin ilk satırına ac_degeri yazilir
                                durum = 21; // geldigi yerden bir sonraki yere / 20->21
                            end
                            else if(ac_deger10 == 10'b1111111000)begin
                                cikis_sifir = 4'b0100; // 4
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 10'b1111111000; // ramin ilk satırına ac_degeri yazilir
                                durum = 21; // geldigi yerden bir sonraki yere / 20->21
                            end
                            else if(ac_deger10 == 10'b1111111001)begin
                                cikis_sifir = 4'b1011; // 11
                                cikis_deger = 4'b0001; // 1
                                ram_deger0 = 10'b1111111001; // ramin ilk satırına ac_degeri yazilir
                                durum = 21; // geldigi yerden bir sonraki yere / 20->21
                            end 
                            else if(ac_deger10 == 10'b1111111010)begin
                                cikis_sifir = 4'b1100; // 12
                                cikis_deger = 4'b0001; // 1
                                ram_deger0 = 10'b1111111010; // ramin ilk satırına ac_degeri yazilir
                                durum = 21; // geldigi yerden bir sonraki yere / 20->21
                            end 
                            else begin
                                cikis_sifir = 4'bxxxx; // tanımsız
                                cikis_deger = 4'bxxx; // tanımsız
                                en_r10 = 0; 
                                en_r11 = 1; 
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 22; // kontrol sonucu bir veri elde edilmezse => 11 bitlik kontrole gidilir 
                            end
                        end
                        
                        // 11 BITLIK 
                        else if(kaydirma == 11)begin
                            if(ac_deger11 == 11'b11111110110)begin
                                cikis_sifir = 4'b0001; // 1
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 11'b11111110110; // ramin ilk satırına ac_degeri yazilir
                                durum = 23; // geldigi yerden bir sonraki yere / 22->23
                            end
                            else if(ac_deger11 == 11'b11111110111)begin
                                cikis_sifir = 4'b0101; // 5
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 11'b11111110111; // ramin ilk satırına ac_degeri yazilir
                                durum = 23; // geldigi yerden bir sonraki yere / 22->23
                            end
                            else if(ac_deger11 == 11'b11111111000)begin
                                cikis_sifir = 4'b1101; // 13
                                cikis_deger = 4'b0001; // 1
                                ram_deger0 = 11'b11111111000; // ramin ilk satırına ac_degeri yazilir
                                durum = 23; // geldigi yerden bir sonraki yere / 22->23
                            end 
                            else if(ac_deger11 == 11'b11111111001) begin
                                cikis_sifir = 5'b10000; // 16
                                kaydirma1 = 11; 
                                durum = 35;
                            end else begin
                                cikis_sifir = 4'bxxxx; // tanımsız
                                cikis_deger = 4'bxxx; // tanımsız
                                en_r11 = 0; 
                                en_r12 = 1; 
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 24; // kontrol sonucu bir veri elde edilmezse => 12 bitlik kontrole gidilir 
                            end
                        end
                        
                        
                        // 12 BITLIK
                        else if(kaydirma == 12)begin
                            if(ac_deger12 == 12'b111111110100)begin
                                cikis_sifir = 4'b0010; // 2
                                cikis_deger = 4'b1000; // 4
                                ram_deger0 = 12'b111111110100; // ramin ilk satırına ac_degeri yazilir
                                durum = 25; // geldigi yerden bir sonraki yere / 24->25
                            end
                            else if(ac_deger12 == 12'b111111110101)begin
                                cikis_sifir = 4'b0011; // 3
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 12'b111111110101; // ramin ilk satırına ac_degeri yazilir
                                durum = 25; // geldigi yerden bir sonraki yere / 24->25
                            end
                            else if(ac_deger12 == 12'b111111110110)begin
                                cikis_sifir = 4'b0110; // 6
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 12'b111111110110; // ramin ilk satırına ac_degeri yazilir
                                durum = 25; // geldigi yerden bir sonraki yere / 24->25
                            end
                            else if(ac_deger12 == 12'b111111110111)begin
                                cikis_sifir = 4'b0111; // 7
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 12'b111111110111; // ramin ilk satırına ac_degeri yazilir
                                durum = 25; // geldigi yerden bir sonraki yere / 24->25
                            end else begin
                                cikis_sifir = 4'bxxxx; // tanımsız
                                cikis_deger = 4'bxxx; // tanımsız
                                en_r12 = 0; 
                                en_r15 = 1; 
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 26; // kontrol sonucu bir veri elde edilmezse => 15 bitlik kontrole gidilir 
                            end
                        end
                        
                        // 15 BITLIK 
                        else if(kaydirma == 15) begin
                            if(ac_deger15 == 15'b111111111000000)begin
                                cikis_sifir = 4'b1000; // 8
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 15'b111111111000000; // ramin ilk satırına ac_degeri yazilir
                                durum = 27; // geldigi yerden bir sonraki yere / 26->27
                            end else begin
                                cikis_sifir = 4'bxxxx; // tanımsız
                                cikis_deger = 4'bxxx; // tanımsız
                                en_r15 = 0; 
                                en_r16 = 1; 
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 28; // kontrol sonucu bir veri elde edilmezse => 16 bitlik kontrole gidilir 
                            end
                       end
                       
                       // 16 BITLIK 
                       else if(kaydirma == 16) begin
                            if(ac_deger16 == 16'b1111111110000010)begin
                                cikis_sifir = 4'b0000; // 0
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111110000010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end 
                            else if(ac_deger16 == 16'b1111111110000011)begin 
                                cikis_sifir = 4'b0000; // 0
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111110000011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110000100)begin
                                cikis_sifir = 4'b0001; // 1
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 16'b1111111110000100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110000101)begin
                                cikis_sifir = 4'b0001; // 1
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 16'b1111111110000101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110000110)begin
                                cikis_sifir = 4'b0001; // 1
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 16'b1111111110000110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110000111)begin
                                cikis_sifir = 4'b0001; // 1
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111110000111; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110001000)begin
                                cikis_sifir = 4'b0001; // 1
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111110001000; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            
                            else if(ac_deger16 == 16'b1111111110001001)begin
                                cikis_sifir = 4'b0010; // 2
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 16'b1111111110001001; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            
                            else if(ac_deger16 == 16'b1111111110001010)begin
                                cikis_sifir = 4'b0010; // 2
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 16'b1111111110001010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110001011)begin
                                cikis_sifir = 4'b0010; // 2
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 16'b1111111110001011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110001100)begin
                                cikis_sifir = 4'b0010; // 2
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 16'b1111111110001100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110001101)begin
                                cikis_sifir = 4'b0010; // 2
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111110001101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110001110)begin
                                cikis_sifir = 4'b0010; // 2
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111110001110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            
                            else if(ac_deger16 == 16'b1111111110001111)begin
                                cikis_sifir = 4'b0011; // 3
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 16'b1111111110001111; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110010000)begin
                                cikis_sifir = 4'b0011; // 3
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 16'b1111111110010000; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110010001)begin
                                cikis_sifir = 4'b0011; // 3
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 16'b1111111110010001; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110010010)begin
                                cikis_sifir = 4'b0011; // 3
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 16'b1111111110010010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110010011)begin
                                cikis_sifir = 4'b0011; // 3
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 16'b1111111110010011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110010100)begin
                                cikis_sifir = 4'b0011; // 3
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111110010100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110010101)begin
                                cikis_sifir = 4'b0011; // 3
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111110010101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            
                            else if(ac_deger16 == 16'b1111111110010110)begin
                                cikis_sifir = 4'b0100; // 4
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 16'b1111111110010110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110010111)begin
                                cikis_sifir = 4'b0100; // 4
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 16'b1111111110010111; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110011000)begin
                                cikis_sifir = 4'b0100; // 4
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 16'b1111111110011000; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110011001)begin
                                cikis_sifir = 4'b0100; // 4
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 16'b1111111110011001; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110011010)begin
                                cikis_sifir = 4'b0100; // 4
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 16'b1111111110011010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110011011)begin
                                cikis_sifir = 4'b0100; // 4
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 16'b1111111110011011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110011100)begin
                                cikis_sifir = 4'b0100; // 4
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111110011100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110011101)begin
                                cikis_sifir = 4'b0100; // 4
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111110011101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            
                            else if(ac_deger16 == 16'b1111111110011110)begin
                                cikis_sifir = 4'b0101; // 5
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 16'b1111111110011110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110011111)begin
                                cikis_sifir = 4'b0101; // 5
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 16'b1111111110011111; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110100000)begin
                                cikis_sifir = 4'b0101; // 5
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 16'b1111111110100000; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110100001)begin
                                cikis_sifir = 4'b0101; // 5
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 16'b1111111110100001; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110100010)begin
                                cikis_sifir = 4'b0101; // 5
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 16'b1111111110100010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110100011)begin
                                cikis_sifir = 4'b0101; // 5
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 16'b1111111110100011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110100100)begin
                                cikis_sifir = 4'b0101; // 5
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111110100100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110100101)begin
                                cikis_sifir = 4'b0101; // 5
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111110100101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            
                            else if(ac_deger16 == 16'b1111111110100110)begin
                                cikis_sifir = 4'b0110; // 6
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 16'b1111111110100110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110100111)begin
                                cikis_sifir = 4'b0110; // 6
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 16'b1111111110100111; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110101000)begin
                                cikis_sifir = 4'b0110; // 6
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 16'b1111111110101000; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110101001)begin
                                cikis_sifir = 4'b0110; // 6
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 16'b1111111110101001; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110101010)begin
                                cikis_sifir = 4'b0110; // 6
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 16'b1111111110101010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110101011)begin
                                cikis_sifir = 4'b0110; // 6
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 16'b1111111110101011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110101100)begin
                                cikis_sifir = 4'b0110; // 6
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111110101100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110101101)begin
                                cikis_sifir = 4'b0110; // 6
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111110101101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            
                            else if(ac_deger16 == 16'b1111111110101110)begin
                                cikis_sifir = 4'b0111; // 7
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 16'b1111111110101110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110101111)begin
                                cikis_sifir = 4'b0111; // 7
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 16'b1111111110101111; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110110000)begin
                                cikis_sifir = 4'b0111; // 7
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 16'b1111111110110000; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110110001)begin
                                cikis_sifir = 4'b0111; // 7
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 16'b1111111110110001; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110110010)begin
                                cikis_sifir = 4'b0111; // 7
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 16'b1111111110110010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110110011)begin
                                cikis_sifir = 4'b0111; // 7
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 16'b1111111110110011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110110100)begin
                                cikis_sifir = 4'b0111; // 7
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111110110100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110110101)begin
                                cikis_sifir = 4'b0111; // 7
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111110110101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            
                            else if(ac_deger16 == 16'b1111111110110110)begin
                                cikis_sifir = 4'b1000; // 8
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 16'b1111111110110110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110110111)begin
                                cikis_sifir = 4'b1000; // 8
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 16'b1111111110110111; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110111000)begin
                                cikis_sifir = 4'b1000; // 8
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 16'b1111111110111000; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110111001)begin
                                cikis_sifir = 4'b1000; // 8
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 16'b1111111110111001; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110111010)begin
                                cikis_sifir = 4'b1000; // 8
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 16'b1111111110111010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110111011)begin
                                cikis_sifir = 4'b1000; // 8
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 16'b1111111110111011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110111100)begin
                                cikis_sifir = 4'b1000; // 8
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111110111100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110111101)begin
                                cikis_sifir = 4'b1000; // 8
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111110111101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            
                            else if(ac_deger16 == 16'b1111111110111110)begin
                                cikis_sifir = 4'b1001; // 9
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 16'b1111111110111110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111110111111)begin
                                cikis_sifir = 4'b1001; // 9
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 16'b1111111110111111; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111000000)begin
                                cikis_sifir = 4'b1001; // 9
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 16'b1111111111000000; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111000001)begin
                                cikis_sifir = 4'b1001; // 9
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 16'b1111111111000001; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111000010)begin
                                cikis_sifir = 4'b1001; // 9
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 16'b1111111111000010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111000011)begin
                                cikis_sifir = 4'b1001; // 9
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 16'b1111111111000011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111000100)begin
                                cikis_sifir = 4'b1001; // 9
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 16'b1111111111000100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111000101)begin
                                cikis_sifir = 4'b1001; // 9
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111111000101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111000110)begin
                                cikis_sifir = 4'b1001; // 9
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111111000110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            
                            else if(ac_deger16 == 16'b1111111111000111)begin
                                cikis_sifir = 4'b1010; // 10
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 16'b1111111111000111; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111001000)begin
                                cikis_sifir = 4'b1010; // 10
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 16'b1111111111001000; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111001001)begin
                                cikis_sifir = 4'b1010; // 10
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 16'b1111111111001001; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111001010)begin
                                cikis_sifir = 4'b1010; // 10
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 16'b1111111111001010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111001011)begin
                                cikis_sifir = 4'b1010; // 10
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 16'b1111111111001011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111001100)begin
                                cikis_sifir = 4'b1010; // 10
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 16'b1111111111001100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111001101)begin
                                cikis_sifir = 4'b1010; // 10
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 16'b1111111111001101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111001110)begin
                                cikis_sifir = 4'b1010; // 10
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111111001110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111001111)begin
                                cikis_sifir = 4'b1010; // 10
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111111001111; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            
                            else if(ac_deger16 == 16'b1111111111010000)begin
                                cikis_sifir = 4'b1011; // 11
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 16'b1111111111010000; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111010001)begin
                                cikis_sifir = 4'b1011; // 11
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 16'b1111111111010001; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111010010)begin
                                cikis_sifir = 4'b1011; // 11
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 16'b1111111111010010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111010011)begin
                                cikis_sifir = 4'b1011; // 11
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 16'b1111111111010011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111010100)begin
                                cikis_sifir = 4'b1011; // 11
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 16'b1111111111010100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111010101)begin
                                cikis_sifir = 4'b1011; // 11
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 16'b1111111111010101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111010110)begin
                                cikis_sifir = 4'b1011; // 11
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 16'b1111111111010110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111010111)begin
                                cikis_sifir = 4'b1011; // 11
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111111010111; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111011000)begin
                                cikis_sifir = 4'b1011; // 11
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111111011000; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            
                            else if(ac_deger16 == 16'b1111111111011001)begin
                                cikis_sifir = 4'b1100; // 12
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 16'b1111111111011001; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111011010)begin
                                cikis_sifir = 4'b1100; // 12
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 16'b1111111111011010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111011011)begin
                                cikis_sifir = 4'b1100; // 12
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 16'b1111111111011011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111011100)begin
                                cikis_sifir = 4'b1100; // 12
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 16'b1111111111011100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111011101)begin
                                cikis_sifir = 4'b1100; // 12
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 16'b1111111111011101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111011110)begin
                                cikis_sifir = 4'b1100; // 12
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 16'b1111111111011110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111011111)begin
                                cikis_sifir = 4'b1100; // 12
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 16'b1111111111011111; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111100000)begin
                                cikis_sifir = 4'b1100; // 12
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111111100000; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111100001)begin
                                cikis_sifir = 4'b1100; // 12
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111111100001; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            
                            else if(ac_deger16 == 16'b1111111111100010)begin
                                cikis_sifir = 4'b1101; // 13
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 16'b1111111111100010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111100011)begin
                                cikis_sifir = 4'b1101; // 13
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 16'b1111111111100011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111100100)begin
                                cikis_sifir = 4'b1101; // 13
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 16'b1111111111100100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111100101)begin
                                cikis_sifir = 4'b1101; // 13
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 16'b1111111111100101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111100110)begin
                                cikis_sifir = 4'b1101; // 13
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 16'b1111111111100110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111100111)begin
                                cikis_sifir = 4'b1101; // 13
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 16'b1111111111100111; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111101000)begin
                                cikis_sifir = 4'b1101; // 13
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 16'b1111111111101000; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111101001)begin
                                cikis_sifir = 4'b1101; // 13
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111111101001; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111101010)begin
                                cikis_sifir = 4'b1101; // 13
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111111101010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            
                            else if(ac_deger16 == 16'b1111111111101011)begin
                                cikis_sifir = 4'b1110; // 14
                                cikis_deger = 4'b0001; // 1
                                ram_deger0 = 16'b1111111111101011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111101100)begin
                                cikis_sifir = 4'b1110; // 14
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 16'b1111111111101100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111101101)begin
                                cikis_sifir = 4'b1110; // 14
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 16'b1111111111101101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111101110)begin
                                cikis_sifir = 4'b1110; // 14
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 16'b1111111111101110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111101111)begin
                                cikis_sifir = 4'b1110; // 14
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 16'b1111111111101111; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111110000)begin
                                cikis_sifir = 4'b1110; // 14
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 16'b1111111111110000; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111110001)begin
                                cikis_sifir = 4'b1110; // 14
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 16'b1111111111110001; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111110010)begin
                                cikis_sifir = 4'b1110; // 14
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 16'b1111111111110010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111110011)begin
                                cikis_sifir = 4'b1110; // 14
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111111110011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111110100)begin
                                cikis_sifir = 4'b1110; // 14
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111111110100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            
                            else if(ac_deger16 == 16'b1111111111110101)begin
                                cikis_sifir = 4'b1111; // 15
                                cikis_deger = 4'b0001; // 1
                                ram_deger0 = 16'b1111111111110101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111110110)begin
                                cikis_sifir = 4'b1111; // 15
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 16'b1111111111110110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111110111)begin
                                cikis_sifir = 4'b1111; // 15
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 16'b1111111111110111; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111111000)begin
                                cikis_sifir = 4'b1111; // 15
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 16'b1111111111111000; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111111001)begin
                                cikis_sifir = 4'b1111; // 15
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 16'b1111111111111001; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111111010)begin
                                cikis_sifir = 4'b1111; // 15
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 16'b1111111111111010; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111111011)begin
                                cikis_sifir = 4'b1111; // 15
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 16'b1111111111111011; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111111100)begin
                                cikis_sifir = 4'b1111; // 15
                                cikis_deger = 4'b1000; // 8
                                ram_deger0 = 16'b1111111111111100; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111111101)begin
                                cikis_sifir = 4'b1111; // 15
                                cikis_deger = 4'b1001; // 9
                                ram_deger0 = 16'b1111111111111101; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end
                            else if(ac_deger16 == 16'b1111111111111110)begin
                                cikis_sifir = 4'b1111; // 15
                                cikis_deger = 4'b1010; // 10
                                ram_deger0 = 16'b1111111111111110; // ramin ilk satırına ac_degeri yazilir
                                durum = 29; // geldigi yerden bir sonraki yere / 28->29
                            end else begin
                                cikis_sifir = 4'bxxxx; // tanımsız
                                cikis_deger = 4'bxxx; // tanımsız
                                en_r16 = 0; 
                                // en_r16 = 1; 
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 36; // kontrol sonucu bir veri elde edilmezse => BITTI 
                            end
                        end else begin
                             cikis_deger = 4'bxxxx;
                             durum = 36; // kontrol sonucu bir veri elde edilmezse => BITTI
                        end
                    end
                    
                    // GENEL KULLANILABILIR (HER SAYIDA BİT KONTROLÜ ICIN) // ASIL SAYIYI ALMAK ICIN // MAX 10 bit olur 
                    2:begin
                        // asil sayi icin shift rotate islemleri 
                        if(en_r1 == 1)begin
                            // 1 bitlik kaydirma
                            if(gec < 7)begin 
                                gec = gec + 1;
                            end else begin
                                asil_deger1 <= ara_deger1; // asil sayi => ramin ikinci satırına yazılacak
                                en_r1 = 0;
                                kaydirma1 = kaydirma + 1; // 1 bit daha kaydirildi rotate shift ile
                                gec = 0;
                                durum = 30; // son durum // asil sayi komtrolü
                            end 
                        end
                        else if(en_r2 == 1)begin
                            // 2 bitlik kaydirma
                            if(gec < 7)begin 
                                gec = gec + 1;
                            end else begin
                                asil_deger2 <= ara_deger2; // asil sayi => ramin ikinci satırına yazılacak
                                en_r2 = 0;
                                kaydirma1 = kaydirma + 2; // 2 bit daha kaydirildi rotate shift ile
                                gec = 0;
                                durum = 30;
                            end
                        end
                        else if(en_r3 == 1)begin
                            // 3 bitlik kaydirma
                            if(gec < 7)begin 
                                gec = gec + 1;
                            end else begin
                                asil_deger3 <= ara_deger3; // asil sayi => ramin ikinci satırına yazılacak
                                en_r3 = 0;
                                kaydirma1 = kaydirma + 3; // 3 bit daha kaydirildi rotate shift ile / toplam kaydirma ve 0 sayısı bulundu
                                gec = 0;
                                durum = 30;
                            end
                        end
                        else if(en_r4 == 1)begin
                            // 4 bitlik kaydirma
                            if(gec < 7)begin 
                                gec = gec + 1;
                            end else begin
                                asil_deger4 <= ara_deger4; // asil sayi => ramin ikinci satırına yazılacak
                                en_r4 = 0;
                                kaydirma1 = kaydirma + 4; // 4 bit daha kaydirildi rotate shift ile / toplam kaydirma ve 0 sayısı bulundu
                                gec = 0;
                                durum = 30;
                            end
                        end
                        
                        else if(en_r5 == 1)begin
                            // 5 bitlik kaydirma
                            if(gec < 7)begin 
                                gec = gec + 1;
                            end else begin
                                asil_deger5 <= ara_deger5; // asil sayi => ramin ikinci satırına yazılacak
                                en_r5 = 0;
                                kaydirma1 = kaydirma + 5; // 5 bit daha kaydirildi rotate shift ile / toplam kaydirma ve 0 sayısı bulundu
                                gec = 0;
                                durum = 30;
                            end
                        end
                        else if(en_r6 == 1)begin
                            // 5 bitlik kaydirma
                            if(gec < 7)begin 
                                gec = gec + 1;
                            end else begin
                                asil_deger6 <= ara_deger6; // asil sayi => ramin ikinci satırına yazılacak
                                en_r6 = 0;
                                kaydirma1 = kaydirma + 6; // 6 bit daha kaydirildi rotate shift ile
                                gec = 0;
                                durum = 30;
                            end
                        end
                        else if(en_r7 == 1)begin
                            // 7 bitlik kaydirma
                            if(gec < 7)begin 
                                gec = gec + 1;
                            end else begin
                                asil_deger7 <= ara_deger7; // asil sayi => ramin ikinci satırına yazılacak
                                en_r7 = 0;
                                kaydirma1 = kaydirma + 7; // 7 bit daha kaydirildi rotate shift ile
                                gec = 0;
                                durum = 30;
                            end
                        end
                        else if(en_r8 == 1)begin
                            // 8 bitlik kaydirma
                            if(gec < 7)begin 
                                gec = gec + 1;
                            end else begin
                                asil_deger8 <= ara_deger8; // asil sayi => ramin ikinci satırına yazılacak
                                en_r8 = 0;
                                kaydirma1 = kaydirma + 8; // 8 bit daha kaydirildi rotate shift ile
                                gec = 0;
                                durum = 30;
                            end
                        end
                        else if(en_r9 == 1)begin
                            // 9 bitlik kaydirma
                            if(gec < 7)begin 
                                gec = gec + 1;
                            end else begin
                                asil_deger9 <= ara_deger9; // asil sayi => ramin ikinci satırına yazılacak
                                en_r9 = 0;
                                kaydirma1 = kaydirma + 9; // 9 bit daha kaydirildi rotate shift ile
                                gec = 0;
                                durum = 30;
                            end
                        end
                        else if(en_r10 == 1)begin
                            // 10 bitlik kaydirma
                            if(gec < 7)begin 
                                gec = gec + 1;
                            end else begin
                                asil_deger10 <= ara_deger10; // asil sayi => ramin ikinci satırına yazılacak
                                en_r10 = 0;
                                kaydirma1 = kaydirma + 10; // 10 bit daha kaydirildi rotate shift ile
                                gec = 0;
                                durum = 30;
                            end
                        end
                        
                    end
                    
                    3:begin
                        // şimdi parçalamak için rotate shift e göndermemiz lazım 
                        sayi_r = encoded_veri_deger;
                        en_r2 = 1; // ilk iki biti shift rotate ile kaydırıp alcaz 
                        durum = 4;
                    end
                    
                    4:begin
                        // 2 BİTLİK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger2 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // ac_deger tabosunda var
                                ac_deger2 <= ara_deger2;
                                // encoded_veri_deger  asil sayi icin 2 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 2; // 2 kez bit kaydirildi rotate shift ile
                                en_r2 = 0;
                                durum  = 1; // 2 bitlik ara_deger2 ac deger kontrolüne gider 
                            end else begin // 2 bitlik sayi elde edemezsek
                                en_r2 = 0;
                            end
                        end
                    end
                    5:begin
                        sayi_r <= encoded_veri_deger << 2; // 2 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b0001)begin                                                                        
                            // 1 bit rotate shift islemi                                                            
                            en_r1 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma                                                                     
                        end                                                                                         
                        else if(cikis_deger == 4'b0010)begin                                                      
                            // 2 bit rotate shift islemi                                                            
                            en_r2 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma                                                                      
                        end else begin
                        end
                    end
                    
                    6:begin
                        // 3 BİTLİK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger3 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // ac_deger tabosunda var
                                ac_deger3 <= ara_deger3;
                                // encoded_veri_deger  asil sayi icin 3 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 3; // 3 kez bit kaydirildi rotate shift ile
                                en_r3 = 0;
                                durum  = 1; // 3 bitlik ara_deger2 ac deger kontrolüne gider 
                            end else begin // 3 bitlik sayi elde edemezsek
                                en_r3 = 0;
                            end
                        end
                    end
                    7:begin
                        sayi_r <= encoded_veri_deger << 3; // 3 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b0011)begin                                                                        
                            // 3 bit rotate shift islemi                                                            
                            en_r3 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma                                                                     
                        end else begin
                        end
                    end
                    
                    8:begin
                        // 4 BİTLİK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger4 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // ac_deger tabosunda var
                                ac_deger4 <= ara_deger4;
                                // encoded_veri_deger  asil sayi icin 4 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 4; // 4 kez bit kaydirildi rotate shift ile
                                en_r4 = 0;
                                durum  = 1; // 4 bitlik ara_deger2 ac deger kontrolüne gider 
                            end else begin // 4 bitlik sayi elde edemezsek
                                en_r4 = 0;
                            end
                        end
                    end
                    9:begin
                        sayi_r <= encoded_veri_deger << 4; // 4 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b0100)begin                                                                        
                            // 4 bit rotate shift islemi                                                            
                            en_r4 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma                                                                     
                        end 
                        else if(cikis_deger == 4'b0001) begin
                            // 1 bit rotate shift islemi                                                            
                            en_r1 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else begin
                        end
                    end
                    
                    10:begin
                        // 5 BİTLİK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger5 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // ac_deger tabosunda var
                                ac_deger5 <= ara_deger5;
                                // encoded_veri_deger  asil sayi icin 5 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 5; // 5 kez bit kaydirildi rotate shift ile
                                en_r5 = 0;
                                durum  = 1; // 5 bitlik ara_deger2 ac deger kontrolüne gider 
                            end else begin // 5 bitlik sayi elde edemezsek
                                en_r5 = 0;
                            end
                        end
                    end
                    11:begin
                        sayi_r <= encoded_veri_deger << 5; // 5 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b0101)begin                                                                        
                            // 5 bit rotate shift islemi                                                            
                            en_r5 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma                                                                     
                        end 
                        else if(cikis_deger == 4'b0010) begin
                            // 2 bit rotate shift islemi                                                            
                            en_r2 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else if(cikis_deger == 4'b0001) begin
                            // 1 bit rotate shift islemi                                                            
                            en_r1 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else begin
                        end
                    end
                    
                    12:begin
                        // 6 BİTLİK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger6 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // ac_deger tabosunda var
                                ac_deger6 <= ara_deger6;
                                // encoded_veri_deger  asil sayi icin 6 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 6; // 6 kez bit kaydirildi rotate shift ile
                                en_r6 = 0;
                                durum  = 1; // 6 bitlik ara_deger6 ac deger kontrolüne gider 
                            end else begin // 6 bitlik sayi elde edemezsek
                                en_r6 = 0;
                            end
                        end
                    end
                    13:begin
                        sayi_r <= encoded_veri_deger << 6; // 6 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b0001)begin                                                                        
                            // 1 bit rotate shift islemi                                                            
                            en_r1 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma                                                                     
                        end 
                        else begin
                        end
                    end
                    
                    14:begin
                        // 7 BİTLİK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger7 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // ac_deger tabosunda var
                                ac_deger7 <= ara_deger7;
                                // encoded_veri_deger  asil sayi icin 7 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 7; // 7 kez bit kaydirildi rotate shift ile
                                en_r7 = 0;
                                durum  = 1; // 7 bitlik ara_deger7 ac deger kontrolüne gider 
                            end else begin // 7 bitlik sayi elde edemezsek
                                en_r7 = 0;
                            end
                        end
                    end
                    15:begin
                        sayi_r <= encoded_veri_deger << 7; // 7 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b0110)begin                                                                        
                            // 6 bit rotate shift islemi                                                            
                            en_r6 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma                                                                     
                        end 
                        else if(cikis_deger == 4'b0011) begin
                            // 3 bit rotate shift islemi                                                            
                            en_r3 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else if(cikis_deger == 4'b0001) begin
                            // 1 bit rotate shift islemi                                                            
                            en_r1 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end else begin
                        end
                    end
                    
                    16:begin
                        // 8 BİTLİK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger8 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // ac_de8er tabosunda var
                                ac_deger8 <= ara_deger8;
                                // encoded_veri_deger  asil sayi icin 8 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 8; // 8 kez bit kaydirildi rotate shift ile
                                en_r8 = 0;
                                durum  = 1; // 8 bitlik ara_deger8 ac deger kontrolüne gider 
                            end else begin // 8 bitlik sayi elde edemezsek
                                en_r8 = 0;
                            end
                        end
                    end
                    17:begin
                        sayi_r <= encoded_veri_deger << 8; // 8 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b0111)begin                                                                        
                            // 7 bit rotate shift islemi                                                            
                            en_r7 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma                                                                     
                        end 
                        else if(cikis_deger == 4'b0010) begin
                            // 2 bit rotate shift islemi                                                            
                            en_r2 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else if(cikis_deger == 4'b0001) begin
                            // 1 bit rotate shift islemi                                                            
                            en_r1 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end else begin
                        end
                    end
                    
                    18:begin
                        // 9 BİTLİK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger9 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // ac_deger tabosunda var
                                ac_deger9 <= ara_deger9;
                                // encoded_veri_deger  asil sayi icin 9 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 9; // 9 kez bit kaydirildi rotate shift ile
                                en_r9 = 0;
                                durum  = 1; // 9 bitlik ara_deger9 ac deger kontrolüne gider 
                            end else begin // 9 bitlik sayi elde edemezsek
                                en_r9 = 0;
                            end
                        end
                    end
                    19:begin
                        sayi_r <= encoded_veri_deger << 9; // 9 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b0100)begin                                                                        
                            // 4 bit rotate shift islemi                                                            
                            en_r4 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma                                                                     
                        end 
                        else if(cikis_deger == 4'b0010) begin
                            // 2 bit rotate shift islemi                                                            
                            en_r2 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else if(cikis_deger == 4'b0001) begin
                            // 1 bit rotate shift islemi                                                            
                            en_r1 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end else begin
                        
                        end
                    end
                    
                    20:begin
                        // 10 BİTLİK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger10 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // ac_deger tabosunda var
                                ac_deger10 <= ara_deger10;
                                // encoded_veri_deger  asil sayi icin 10 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 10; // 10 kez bit kaydirildi rotate shift ile
                                en_r10 = 0;
                                durum  = 1; // 10 bitlik ara_deger10 ac deger kontrolüne gider 
                            end else begin // 10 bitlik sayi elde edemezsek
                                en_r10 = 0;
                            end
                        end
                    end
                    21:begin
                        sayi_r <= encoded_veri_deger << 10; // 10 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b1000)begin                                                                        
                            // 8 bit rotate shift islemi                                                            
                            en_r8 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma                                                                     
                        end 
                        else if(cikis_deger == 4'b0011) begin
                            // 3 bit rotate shift islemi                                                            
                            en_r3 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else if(cikis_deger == 4'b0010) begin
                            // 2 bit rotate shift islemi                                                            
                            en_r2 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else if(cikis_deger == 4'b0001) begin
                            // 1 bit rotate shift islemi                                                            
                            en_r1 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end else begin
                        end
                    end
                    
                    22:begin
                        // 11 BİTLİK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger11 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // ac_deger tabosunda var
                                ac_deger11 <= ara_deger11;
                                // encoded_veri_deger  asil sayi icin 11 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 11; // 11 kez bit kaydirildi rotate shift ile
                                en_r11 = 0;
                                durum  = 1; // 11 bitlik ara_deger8 ac deger kontrolüne gider 
                            end else begin // 11 bitlik sayi elde edemezsek
                                en_r11 = 0;
                            end
                        end
                    end
                    23:begin
                        sayi_r <= encoded_veri_deger << 11; // 11 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b0101)begin                                                                        
                            // 5 bit rotate shift islemi                                                            
                            en_r5 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma                                                                     
                        end 
                        else if(cikis_deger == 4'b0010) begin
                            // 2 bit rotate shift islemi                                                            
                            en_r2 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else if(cikis_deger == 4'b0001) begin
                            // 1 bit rotate shift islemi                                                            
                            en_r1 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end else begin
                        end
                    end
                    
                    24:begin
                        // 12 BİTLİK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger12 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // ac_deger tabosunda var
                                ac_deger12 <= ara_deger12;
                                // encoded_veri_deger  asil sayi icin 12 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 12; // 12 kez bit kaydirildi rotate shift ile
                                en_r12 = 0;
                                durum  = 1; // 12 bitlik ara_deger8 ac deger kontrolüne gider 
                            end else begin // 12 bitlik sayi elde edemezsek
                                en_r12 = 0;
                            end
                        end
                    end
                    25:begin
                        sayi_r <= encoded_veri_deger << 12; // 12 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b0011)begin                                                                        
                            // 3 bit rotate shift islemi                                                            
                            en_r3 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma                                                                     
                        end 
                        else if(cikis_deger == 4'b0010) begin
                            // 2 bit rotate shift islemi                                                            
                            en_r2 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end else begin
                        end
                    end
                    
                    26:begin
                        // 15 BİTLİK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger15 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // ac_deger tabosunda var
                                ac_deger15 <= ara_deger15;
                                // encoded_veri_deger  asil sayi icin 15 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 15; // 15 kez bit kaydirildi rotate shift ile
                                en_r15 = 0;
                                durum  = 1; // 15 bitlik ara_deger8 ac deger kontrolüne gider 
                            end else begin // 15 bitlik sayi elde edemezsek
                                en_r12 = 0;
                            end
                        end
                    end
                    27:begin
                        sayi_r <= encoded_veri_deger << 15; // 15 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b0010) begin
                            // 2 bit rotate shift islemi                                                            
                            en_r2 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end else begin
                        end
                    end
                    
                    28:begin
                        // 16 BİTLİK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger16 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // ac_deger tabosunda var
                                ac_deger16 <= ara_deger16;
                                // encoded_veri_deger  asil sayi icin 16 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 16; // 16 kez bit kaydirildi rotate shift ile
                                en_r16 = 0;
                                durum  = 1; // 16 bitlik ara_deger16 ac deger kontrolüne gider 
                            end else begin // 16 bitlik sayi elde edemezsek
                                en_r16 = 0;
                            end
                        end
                    end
                    29:begin
                        sayi_r <= encoded_veri_deger << 16; // 16 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b0001) begin
                            // 1 bit rotate shift islemi                                                            
                            en_r1 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end 
                        else if(cikis_deger == 4'b0010) begin
                            // 2 bit rotate shift islemi                                                            
                            en_r2 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else if(cikis_deger == 4'b0011) begin
                            // 3 bit rotate shift islemi                                                            
                            en_r3 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else if(cikis_deger == 4'b0100) begin
                            // 4 bit rotate shift islemi                                                            
                            en_r4 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else if(cikis_deger == 4'b0101) begin
                            // 5 bit rotate shift islemi                                                            
                            en_r5 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else if(cikis_deger == 4'b0110) begin
                            // 6 bit rotate shift islemi                                                            
                            en_r6 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else if(cikis_deger == 4'b0111) begin
                            // 7 bit rotate shift islemi                                                            
                            en_r7 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else if(cikis_deger == 4'b1000) begin
                            // 8 bit rotate shift islemi                                                            
                            en_r8 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else if(cikis_deger == 4'b1001) begin
                            // 9 bit rotate shift islemi                                                            
                            en_r9 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end
                        else if(cikis_deger == 4'b1010) begin
                            // 10 bit rotate shift islemi                                                            
                            en_r10 = 1;                                                                              
                            durum = 2; // asil sayi icin kaydirma     
                        end else begin
                        end
                    end
                    
                    30:begin
                    
                        encoded_veri_cikti = encoded_veri_i << kaydirma1; // diger ac_degerler icin kalan encoded sayimiz 
                        // asil sayi kontrol edilecek , 0 ile basliyorsa tersini alıp eksilisini al
                        // 1 ile başlıyorsa aynısını yaz
                        if(asil_deger1 !== 1'bx)begin
                            if(asil_deger1 == 1) begin
                                // pozitif 
                                ram_deger1 = asil_deger1;
                                durum = 34;
                            end else begin
                                // negatif / 0 la basliyor       
                                durum = 31; // 2ye tümleyen alma 
                            end
                        end
                        
                        else if(asil_deger2 !== 2'bxx)begin 
                            if(asil_deger2[1] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger2;
                                durum = 34;
                            end else begin
                                // negatif / 0 la basliyor       
                                durum = 31; // 2ye tümleyen alma 
                            end
                        end
                        
                        else if(asil_deger3 !== 3'bxxx)begin 
                            if(asil_deger3[2] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger3;
                                durum = 34;
                            end else begin
                                // negatif / 0 la basliyor   
                                durum = 31; // 2ye tümleyen alma 
                            end
                        end
                        
                        else if(asil_deger4 !== 4'bxxxx)begin 
                            if(asil_deger4[3] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger4;
                                durum = 34;
                            end else begin
                                // negatif / 0 la basliyor     
                                durum = 31;
                            end
                        end
                        
                        else if(asil_deger5 !== 5'bxxxxx)begin 
                            if(asil_deger5[4] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger5;
                                durum = 34;
                            end else begin
                                // negatif / 0 la basliyor     
                                durum = 31;
                            end
                        end
                        
                        else if(asil_deger6 !== 6'bxxxxxx)begin 
                            if(asil_deger6[5] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger6;
                                durum = 34;
                            end else begin
                                // negatif / 0 la basliyor     
                                durum = 31;
                            end
                        end
                        
                        else if(asil_deger7 !== 7'bxxxxxxx)begin 
                            if(asil_deger7[6] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger7;
                                durum = 34;
                            end else begin
                                // negatif / 0 la basliyor
                                durum = 31;
                            end
                        end
                        
                        else if(asil_deger8 !== 8'bxxxxxxxx)begin 
                            if(asil_deger8[7] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger8;
                                durum = 34;
                            end else begin
                                // negatif / 0 la basliyor     
                                durum = 31;
                            end
                        end
                        
                        else if(asil_deger9 !== 9'bxxxxxxxxx)begin 
                            if(asil_deger9[8] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger9;
                                durum = 34;
                            end else begin
                                // negatif / 0 la basliyor     
                                durum = 31;
                            end
                        end
                        
                        else if(asil_deger10 !== 10'bxxxxxxxxxx)begin 
                            if(asil_deger10[9] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger10;
                                durum = 34;
                            end else begin
                                // negatif / 0 la basliyor   
                                durum = 31;
                            end
                        end else begin
                            
                        end
                       
                    end
                    
                    31:begin
                        if(asil_deger1 !== 1'bx)begin
                            // negatif / 0 la basliyor     
                            if(i < 1)begin // 010 geldi 
                                if(asil_deger1[i] == 0) begin
                                    asil_deger1[i] = 1;
                                end else begin
                                    asil_deger1[i] = 0;
                                end
                                i = i + 1;
                            end else begin 
                                ram_deger1 = asil_deger1; 
                                durum = 32;
                            end
                        end
                        
                        else if(asil_deger2 !== 2'bxx)begin
                            // negatif / 0 la basliyor     
                            if(i < 2)begin // 010 geldi 
                                if(asil_deger2[i] == 0) begin
                                    asil_deger2[i] = 1;
                                end else begin
                                    asil_deger2[i] = 0;
                                end
                                i = i + 1;
                            end else begin 
                                ram_deger1 = asil_deger2; 
                                durum = 32;
                            end
                        end
                        
                        else if(asil_deger3 !== 3'bxxx)begin 
                            // negatif / 0 la basliyor                                
                            // 010 => 101 => 00000101 => 11111011 => -5
                            // sayinin tersini aliyoruz
                            if(i < 3)begin // 010 geldi 
                                if(asil_deger3[i] == 0) begin
                                    asil_deger3[i] = 1;
                                end else begin
                                    asil_deger3[i] = 0;
                                end
                                i = i + 1;
                            end else begin // 101 oldu 
                                ram_deger1 = asil_deger3;  // 00000101
                                durum = 32; // 2ye tümleyen alma 
                            end
                        end
                        
                        else if(asil_deger4 !== 4'bxxxx)begin 
                            // negatif / 0 la basliyor     
                            if(i < 4)begin // 010 geldi 
                                if(asil_deger4[i] == 0) begin
                                    asil_deger4[i] = 1;
                                end else begin
                                    asil_deger4[i] = 0;
                                end
                                i = i + 1;
                            end else begin 
                                ram_deger1 = asil_deger4;
                                durum = 32;
                            end
                        end
                        
                        else if(asil_deger5 !== 5'bxxxxx)begin 
                            // negatif / 0 la basliyor     
                            if(i < 5)begin // 010 geldi 
                                if(asil_deger5[i] == 0) begin
                                    asil_deger5[i] = 1;
                                end else begin
                                    asil_deger5[i] = 0;
                                end
                                i = i + 1;
                            end else begin 
                                ram_deger1 = asil_deger5;
                                durum = 32;
                            end
                        end
                        
                        else if(asil_deger6 !== 6'bxxxxxx)begin 
                            // negatif / 0 la basliyor     
                            if(i < 6)begin // 010 geldi 
                                if(asil_deger6[i] == 0) begin
                                    asil_deger6[i] = 1;
                                end else begin
                                    asil_deger6[i] = 0;
                                end
                                i = i + 1;
                            end else begin 
                                ram_deger1 = asil_deger6;
                                durum = 32;
                            end
                        end
                        
                        else if(asil_deger7 !== 7'bxxxxxxx)begin 
                           // negatif / 0 la basliyor     
                           if(i < 7)begin // 010 geldi 
                               if(asil_deger7[i] == 0) begin
                                   asil_deger7[i] = 1;
                               end else begin
                                   asil_deger7[i] = 0;
                               end
                               i = i + 1;
                           end else begin 
                               ram_deger1 = asil_deger7;
                               durum = 32;
                           end
                        end
                        
                        else if(asil_deger8 !== 8'bxxxxxxxx)begin 
                            // negatif / 0 la basliyor     
                            if(i < 8)begin // 010 geldi 
                                if(asil_deger8[i] == 0) begin
                                    asil_deger8[i] = 1;
                                end else begin
                                    asil_deger8[i] = 0;
                                end
                                i = i + 1;
                            end else begin 
                                ram_deger1 = asil_deger8;
                                durum = 32;
                            end
                        end
                        
                        else if(asil_deger9 !== 9'bxxxxxxxxx)begin
                            // negatif / 0 la basliyor     
                            if(i < 9)begin // 010 geldi 
                                if(asil_deger9[i] == 0) begin
                                    asil_deger9[i] = 1;
                                end else begin
                                    asil_deger9[i] = 0;
                                end
                                i = i + 1;
                            end else begin 
                                ram_deger1 = asil_deger9;
                                durum = 32;
                            end
                        end
                        
                        else if(asil_deger10 !== 10'bxxxxxxxxxx)begin
                            // negatif / 0 la basliyor     
                            if(i < 10)begin // 010 geldi 
                                if(asil_deger10[i] == 0) begin
                                    asil_deger10[i] = 1;
                                end else begin
                                    asil_deger10[i] = 0;
                                end
                                i = i + 1;
                            end else begin 
                                ram_deger1 = asil_deger10;
                                durum = 32;
                            end
                        end
                        else begin
                        end
                    end
                    32:begin
                        // 2 ye tümleme yapılacak // 00000101 / j = 0;
                        i = 0; 
                        if(ram_deger1[j] !== 1)begin 
                            j = j + 1; // ilk 1e ulaşana kadar 
                        end else begin
                            j = j + 1;
                            durum = 33;
                        end
                    end
                    33:begin
                        // ilk 1 i buldu // 00000101 / j = 1;
                        if(j<11)begin
                            // 0ları 1, 1leri 0 yap
                            if(ram_deger1[j] == 0)begin
                                ram_deger1[j] = 1;  
                                j = j + 1; // 2 / 4 / 5 / 6  / 7 => 11111011 => -5 
                                durum = 33;
                            end else begin
                                ram_deger1[j] = 0;
                                j = j + 1;  // 3
                                durum = 33;
                            end
                        end else begin
                            // 11111011 => -5 // ram e yazilacak asil sayiyi elde ettik 
                            durum = 34;
                        end
                    end
                        
                    34:begin
                        if(eob_kontrol !== 1) begin
                            ram_deger_asil = ram_deger1;
                            durum = 35;
                        end else begin
                            // EOB ye ulasildi
                            kaydirma1 = kaydirma1 + 4;
                            durum = 35;
                        end
                    end
                    
                    35:begin
                        encoded_veri_cikti = encoded_veri_i << kaydirma1; // eob yi de sildik
                        kaydirma1_deger <=  kaydirma1;
                        eob_kontrol_oku <= eob_kontrol;
                        cikis_sifir_deger <= cikis_sifir;
                        durum <= 36;
                    end
                    
                    
                    36:begin
                        // BITTI / HERHANGI BIR SONUC ELDE EDILMEZSE
                        
                        i = 0;
                        j = 0;
                        durum = 0;
                        gec = 0;
                        sayac = 0;
                        
                        kaydirma <= 0;
                        kaydirma1 <= 0;
                        eob_kontrol <= 1'bx;
                        // encoded_veri_cikti= 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
                        encoded_veri_deger <= 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
                        
                        asil_deger1 <= 1'bx; 
                        asil_deger2 <= 2'bxx; 
                        asil_deger3 <= 3'bxxx; 
                        asil_deger4 <= 4'bxxxx; 
                        asil_deger5 <= 5'bxxxxx; 
                        asil_deger6 <= 6'bxxxxxx;
                        asil_deger7 <= 7'bxxxxxxx; 
                        asil_deger8 <= 8'bxxxxxxxx; 
                        asil_deger9 <= 9'bxxxxxxxxx; 
                        asil_deger10 <= 10'bxxxxxxxxxx;
                        
                        ac_deger1 <= 1'bx;        
                        ac_deger2 <= 2'bxx;       
                        ac_deger3 <= 3'bxxx;      
                        ac_deger4 <= 4'bxxxx;     
                        ac_deger5 <= 5'bxxxxx;    
                        ac_deger6 <= 6'bxxxxxx;   
                        ac_deger7 <= 7'bxxxxxxx;  
                        ac_deger8 <= 8'bxxxxxxxx; 
                        ac_deger9 <= 9'bxxxxxxxxx;
                        ac_deger10 <= 10'bxxxxxxxxxx;
                        ac_deger11 <= 11'bxxxxxxxxxxx;
                        ac_deger12 <= 12'bxxxxxxxxxxxx;
                        ac_deger13 <= 13'bxxxxxxxxxxxxx;
                        ac_deger14 <= 14'bxxxxxxxxxxxxxx;
                        ac_deger15 <= 15'bxxxxxxxxxxxxxxx;
                        ac_deger16 <= 16'bxxxxxxxxxxxxxxxx;
                    end
                endcase
            end else begin
                i = 0;
                j = 0;
                durum = 0;
                gec = 0;
                sayac = 0;
                
                asil_deger1 = 1'bx; 
                asil_deger2 = 2'bxx; 
                asil_deger3 = 3'bxxx; 
                asil_deger4 = 4'bxxxx; 
                asil_deger5 = 5'bxxxxx; 
                asil_deger6 = 6'bxxxxxx;
                asil_deger7 = 7'bxxxxxxx; 
                asil_deger8 = 8'bxxxxxxxx; 
                asil_deger9 = 9'bxxxxxxxxx; 
                asil_deger10 = 10'bxxxxxxxxxx;
                
                
                ac_deger1 = 1'bx;        
                ac_deger2 = 2'bxx;       
                ac_deger3 = 3'bxxx;      
                ac_deger4 = 4'bxxxx;     
                ac_deger5 = 5'bxxxxx;    
                ac_deger6 = 6'bxxxxxx;   
                ac_deger7 = 7'bxxxxxxx;  
                ac_deger8 = 8'bxxxxxxxx; 
                ac_deger9 = 9'bxxxxxxxxx;
                ac_deger10 = 10'bxxxxxxxxxx;
                ac_deger11 = 11'bxxxxxxxxxxx;
                ac_deger12 = 12'bxxxxxxxxxxxx;
                ac_deger13 = 13'bxxxxxxxxxxxxx;
                ac_deger14 = 14'bxxxxxxxxxxxxxx;
                ac_deger15 = 15'bxxxxxxxxxxxxxxx;
                ac_deger16 = 16'bxxxxxxxxxxxxxxxx;
                
                
            end
        end
    end
    
    // ----------------------------------------
    // rotate shift sonucu kesmek istedigimiz veriyi elde ediyoruz  // max 16 olcak galiba?(ac_deger den dolayı)
    
    rotate_left #(.kaydir(1)) rotate_left1(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r1),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger1) // bu dc nin girişi, ac nin  girişi veya ram e yazılacak sayi olacak
    );
    rotate_left #(.kaydir(2)) rotate_left2(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r2),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger2)
    );
    rotate_left #(.kaydir(3)) rotate_left3(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r3),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger3)
    );
    
    rotate_left #(.kaydir(4)) rotate_left4(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r4),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger4)
    );
    rotate_left #(.kaydir(5)) rotate_left5(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r5),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger5)
    );
    rotate_left #(.kaydir(6)) rotate_left6(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r6),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger6)
    );
    rotate_left #(.kaydir(7)) rotate_left7(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r7),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger7)
    );
    rotate_left #(.kaydir(8)) rotate_left8(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r8),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger8)
    );
    rotate_left #(.kaydir(9)) rotate_left9(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r9),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger9)
    );
    
    rotate_left #(.kaydir(10)) rotate_left10(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r10),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger10)
    );
    rotate_left #(.kaydir(11)) rotate_left11(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r11),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger11)
    );
    rotate_left #(.kaydir(12)) rotate_left12(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r12),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger12)
    );
    rotate_left #(.kaydir(13)) rotate_left13(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r13),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger13)
    );
    rotate_left #(.kaydir(14)) rotate_left14(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r14),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger14)
    );
    rotate_left #(.kaydir(15)) rotate_left15(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r15),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger15)
    );
    rotate_left #(.kaydir(16)) rotate_left16(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r16),
        .sayi_i(sayi_r),          
        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger16)
    );
    
    
endmodule
