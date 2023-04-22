`timescale 1ns / 1ps


module inverse_DC(
    input clk_i,rst_i, en_i,
    input [31:0] encoded_veri_i, // 10000111110110111010110100101111
    output [31:0] encoded_veri_o,
//    output [10:0] dc_deger_o,
    output [10:0] asil_deger_o,
    output [4:0] sagdaki_sifir_sayisi_o // max 20 olabilir
    );
    
    reg [10:0] ram_deger0; // dc_deger ciktisi, signed olarak 9 bit yeter
    reg [10:0] ram_deger1; // asil sayi ciktisi, signed olarak 11 bit yeter 
    reg [10:0] ram_deger_asil; // asil sayi ciktisi, signed olarak 11 bit yeter / ram e yazılacak
    reg [31:0] encoded_veri_cikti; // kaydirmalar sonucu kalan encoded_veri cikti
    integer kaydirma = 0,kaydirma1 = 0,kaydirma1_deger; 
    // kaydirma = ilk kaydirma / kaydirma1 = toplam kaydirma => bunla beraber encoded_veri_i ne kadar kaydirilmis olacak o kontrol edilir ve sağ tafata biriken 0 sayisi kontrol edilmiş olur
    
    assign sagdaki_sifir_sayisi_o = kaydirma1_deger; // sagdaki 0 ların sayisi
    assign encoded_veri_o = encoded_veri_cikti;
//    assign dc_deger_o = ram_deger0;
    assign asil_deger_o = ram_deger_asil;
    
    // genel degiskenler
    reg [31:0] encoded_veri_deger; // bu shift left işlemi haric degismeyecek
    reg [5:0] durum = 0;
    integer sayac = 0, gec = 0;
    integer i = 0; // sayinin tersini almada kullanilir
    integer j = 0; // ram_deger1 in 2 ye tümleyenini almak icin // ram_deger_asil olusturmak
    
    
    // rotate_shift icin 
    reg en_r1,en_r2,en_r3,en_r4,en_r5,en_r6,en_r7,en_r8,en_r9,en_r10,en_r11; // enable / dc_icin max 9 bit kaydrılabilir / cikis_deger icin max 11 olur
    reg [31:0] sayi_r; // rotate shift giris
    
    // ara degiskenler bit uzunluguna göre degisir max 11 // rotate shiftten cikip , dc_deger e girer
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
    
    // DC DEGERI ICIN
    // cikis 
    reg [3:0] cikis_deger; // cikti
    // giris // max 9 bit
    reg [0:0] dc_deger1; // 1 bitlik
    reg [1:0] dc_deger2; // 2 bitlik
    reg [2:0] dc_deger3; // 3 bitlik
    reg [3:0] dc_deger4; // 4 bitlik
    reg [4:0] dc_deger5; // 5 bitlik
    reg [5:0] dc_deger6; // 6 bitlik
    reg [6:0] dc_deger7; // 7 bitlik
    reg [7:0] dc_deger8; // 8 bitlik
    reg [8:0] dc_deger9; // 9 bitlik
    
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
    reg [10:0] asil_deger11; // 11 bitlik
    
    always@(posedge clk_i)begin
        if(rst_i)begin
        end else begin
            if(en_i == 1)begin
                sayac = sayac + 1;
                case(durum)
                    0:begin
                        if(sayac<=3)begin  // 3 clk beklettik
                            encoded_veri_deger = encoded_veri_i; // veriyi aldık 
                        end 
                        else begin
                            durum = 1;
                        end
                    end
                    1:begin
                        // şimdi parçalamak için rotate shift e göndermemiz lazım 
                        sayi_r = encoded_veri_deger;
                        en_r2 = 1; // ilk iki biti shift rotate ile kaydırıp alcaz 
                        durum = 2;
                    end
                    // 2 bitlik dc_deger var mı? yoksa 3 bitlik kontrol
                    2:begin 
                        // ilk 2 biti shift rotate ile kaydırıp alcaz dc_deger icin
                        // 2 bitlik kaydirma
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger2 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin
                                // 2 bitlik sayi elde edersek / 2 bitlik kaydırma sonucu
                                // en_dc2 = 1; // dc_deger modül aktif / uzunluk = 2
                                dc_deger2 <= ara_deger2;
                                kaydirma = 2; // 2 kez bit kaydirildi rotate shift ile
                                durum  = 3; // 2 bitlik ara_deger2 , dc deger kontrolüne gider  
                            end else begin 
                                en_r2 = 0; // kaydir = 2
                                en_r3 = 1; // kaydir = 3
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 5; // kontrol sonucu bir veri elde edilmezse => 3 bitlik kontrole gidilir         
                            end
                        end
                    end
                    
                    // GENEL DC KONTROL
                    3:begin
                        // 2 BITLIK
                        if(kaydirma==2)begin // uzunluk 2 bit
                            if(dc_deger2 == 2'b00)begin
                                cikis_deger = 2'b00; // 0 // bir sonraki sayi kaç bitle ifade edilir
                                ram_deger0 = 0; // ramin ilk satırına dc_degeri yazilir
                                durum = 4; // geldigi yerden 2 sonraki yere / 2+2 = 4 / 2->4
                            end
                            else begin
                                cikis_deger = 4'bxxx; // tanımsız
                                en_r2 = 0; // kaydir = 2
                                en_r3 = 1; // kaydir = 3
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 5; // kontrol sonucu bir veri elde edilmezse => 3 bitlik kontrole gidilir   
                            end
                        end
                        // 3 BITLIK
                        else if(kaydirma == 3) begin // 3 bit uzunluk
                            if(dc_deger3 == 3'b010)begin
                                cikis_deger = 4'b0001; // 1 // bir sonraki sayi kaç bitle ifade edilir
                                ram_deger0 = 3'b010; // ramin ilk satırına dc_degeri yazilir
                                durum = 6; // geldigi yerden bir sonraki yere / 5->6
                            end
                            else if(dc_deger3 == 3'b011)begin
                                cikis_deger = 4'b0010; // 2
                                ram_deger0 = 3'b011; // ramin ilk satırına dc_degeri yazilir
                                durum = 6; // geldigi yerden bir sonraki yere
                            end
                            else if(dc_deger3 == 3'b100)begin
                                cikis_deger = 4'b0011; // 3
                                ram_deger0 = 3'b100; // ramin ilk satırına dc_degeri yazilir
                                durum = 6; // geldigi yerden bir sonraki yere
                            end
                            else if(dc_deger3 == 3'b101)begin
                                cikis_deger = 4'b0100; // 4
                                ram_deger0 = 3'b101; // ramin ilk satırına dc_degeri yazilir
                                durum = 6; // geldigi yerden bir sonraki yere
                            end
                            else if(dc_deger3 == 3'b110)begin
                                cikis_deger = 4'b0101; // 5
                                ram_deger0 = 3'b110; // ramin ilk satırına dc_degeri yazilir
                                durum = 6; // geldigi yerden bir sonraki yere
                            end 
                            else begin
                                cikis_deger = 4'bxxxx;
                                // dc_deger tablosunda yok
                                // 4 bitlik kontrole gider
                                en_r3 = 0; // kaydir = 2
                                en_r4 = 1; // kaydir = 3
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 8; // kontrol sonucu bir veri elde edilmezse => 4 bitlik kontrole gidilir 
                            end
                        end
                        
                        // 4 BITLIK
                        else if(kaydirma==4)begin
                            if(dc_deger4 == 4'b1110)begin
                                cikis_deger = 4'b0110; // 6
                                ram_deger0 = 4'b1110;
                                durum = 9; // geldigi yerden bir sonraki yere / 8->9
                            end else begin
                                // 5 bitlik kontrole gider
                                en_r4 = 0; // kaydir = 2
                                en_r5 = 1; // kaydir = 3
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 10; // kontrol sonucu bir veri elde edilmezse => 5 bitlik kontrole gidilir 
                            end
                        end
                       
                       // 5 BITLIK
                        else if(kaydirma == 5)begin
                            if(dc_deger5 == 5'b11110)begin
                                cikis_deger = 4'b0111; // 7
                                ram_deger0 = 5'b11110;
                                durum = 11; // geldigi yerden bir sonraki yere / 10->11
                            end else begin
                                // 6 bitlik kontrole gider
                                en_r5 = 0; // kaydir = 2
                                en_r6 = 1; // kaydir = 3
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 12; // kontrol sonucu bir veri elde edilmezse => 6 bitlik kontrole gidilir 
                            end
                        end
                        
                        // 6 BITLIK
                        else if(kaydirma==6)begin
                            if(dc_deger6 == 6'b111110)begin
                                cikis_deger = 4'b1000;  // 8
                                ram_deger0 = 6'b111110;
                                durum = 13; // geldigi yerden bir sonraki yere / 12->13
                            end else begin
                                // 6 bitlik kontrole gider
                                en_r6 = 0; // kaydir = 2
                                en_r7 = 1; // kaydir = 3
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 14; // kontrol sonucu bir veri elde edilmezse => 7 bitlik kontrole gidilir 
                            end
                        end
                        // 7 BITLIK
                        else if(kaydirma == 7)begin
                            if(dc_deger7 == 7'b1111110)begin
                                cikis_deger = 4'b1001;  // 9
                                ram_deger0 = 7'b1111110;
                                durum = 15; // geldigi yerden bir sonraki yere / 14->15
                            end else begin
                                // 7 bitlik kontrole gider
                                en_r6 = 0; // kaydir = 2
                                en_r7 = 1; // kaydir = 3
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 16; // kontrol sonucu bir veri elde edilmezse => 8 bitlik kontrole gidilir 
                            end
                        end
                        
                        // 8 BITLIK
                        else if(kaydirma == 8)begin
                            if(dc_deger8 ==8'b11111110)begin
                                cikis_deger = 4'b1010;  // 10
                                ram_deger0 = 7'b1111110;
                                durum = 17; // geldigi yerden bir sonraki yere / 16->17
                            end else begin
                                // 8 bitlik kontrole gider
                                en_r7 = 0; // kaydir = 2
                                en_r8 = 1; // kaydir = 3
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 18; // kontrol sonucu bir veri elde edilmezse => 9 bitlik kontrole gidilir 
                            end
                        end
                        
                        // 9 BITLIK 
                        else if(kaydirma == 9)begin
                            if(dc_deger9 == 9'b111111110)begin
                                cikis_deger = 4'b1011;  // 11
                                ram_deger0 = 9'b111111110;
                                durum = 19; // geldigi yerden bir sonraki yere / 18->19
                            end else begin
                                // 8 bitlik kontrole gider
                                en_r8 = 0; // kaydir = 2
                                en_r9 = 1; // kaydir = 3
                                gec = 0;
                                sayi_r <= encoded_veri_deger;
                                durum = 25; // kontrol sonucu bir veri elde edilmezse => BITTI
                            end
                        end
                        else begin
                            cikis_deger = 4'bxxxx;
                            durum = 25; // kontrol sonucu bir veri elde edilmezse => BITTI
                        end
                    end
                    
                    4:begin
                        if(cikis_deger !== 4'bxxxx)begin  // hepsi 4 bitlik / dc_deger tablosunda yok
                            // dc_deger tablosunda var
                            ram_deger1 <= 11'b00000000000; 
                            kaydirma1 <= kaydirma;
                            durum = 24; // son duruma gidecek / dc_deger ve asil sayi bulundu ac_deger e geçilir / KONTROL YAP
                      end else begin 
                            // dc_deger tablosunda yok
                            sayi_r <= encoded_veri_deger;
                            en_r3 = 1;
                            durum = 5; // 3 bitlik konrole gider
                        end
                    end
                    
                    
                    5:begin
                        // 3 BİTLİK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger3 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // DC_deger tabosunda var
                                dc_deger3 <= ara_deger3;
                                // sayi_r <= encoded_veri_deger << 3;  / durum 3 e al
                                // encoded_veri_deger  asil sayi icin 3 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 3; // 3 kez bit kaydirildi rotate shift ile
                                en_r3 = 0;
                                durum  = 3; // 3 bitlik ara_deger3 dc deger kontrolüne gider 
                            end else begin // 3 bitlik sayi elde edemezsek
                                en_r3 = 0;
                            end
                        end
                    end
                    
                    6 :begin
                        // dc_deger tablosunda var
                        sayi_r <= encoded_veri_deger << 3; // 3 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b0001)begin                                                                           
                            // 1 bit rotate shift islemi                                                            
                            en_r1 = 1;                                                                              
                            durum = 7;                                                                              
                        end                                                                                         
                        else if(cikis_deger == 4'b0010)begin                                                        
                            // 2 bit rotate shift islemi                                                            
                            en_r2 = 1;                                                                              
                            durum = 7;                                                                              
                        end                                                                                         
                        else if(cikis_deger == 4'b0011)begin                                                       
                            // 3 bit rotate shift islemi                                                            
                            en_r3 = 1;                                                                              
                            durum = 7;                                                                              
                        end                                                                                        
                        else if(cikis_deger == 4'b0100)begin                                                       
                            // 4 bit rotate shift islemi                                                            
                            en_r4 = 1;                                                                              
                            durum = 7;                                                                              
                        end                                                                                         
                        else if(cikis_deger == 4'b0101)begin                                                     
                            // 5 bit rotate shift islemi                                                            
                            en_r5 = 1;                                                                              
                            durum = 7;                                                                              
                        end 
                    end   
                    
                    // GENEL KULLANILABILIR (HER SAYIDA BİT KONTROLÜ ICIN) // ASIL SAYIYI ALMAK ICIN // MAX 11 bit olur 
                    7:begin
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
                                durum = 20; // son durum
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
                                durum = 20;
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
                                durum = 20;
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
                                durum = 20;
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
                                durum = 20;
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
                                durum = 20;
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
                                durum = 20;
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
                                durum = 20;
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
                                durum = 20;
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
                                durum = 20;
                            end
                        end
                        else if(en_r11 == 1)begin
                            // 11 bitlik kaydirma
                            if(gec < 7)begin 
                                gec = gec + 1;
                            end else begin
                                asil_deger11 <= ara_deger11; // asil sayi => ramin ikinci satırına yazılacak
                                en_r11 = 0;
                                kaydirma1 = kaydirma + 11; // 11 bit daha kaydirildi rotate shift ile
                                gec = 0;
                                durum = 20;
                            end
                        end
                    end
                    
                    8:begin
                        // 4 BİTLİK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger4 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // DC_deger tabosunda var
                                dc_deger4 <= ara_deger4;
                                // encoded_veri_deger  asil sayi icin 3 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 4; // 4 kez bit kaydirildi rotate shift ile
                                en_r4 = 0;
                                durum  = 3; // 4 bitlik ara_deger4 dc deger kontrolüne gider 
                            end else begin // 4 bitlik sayi elde edemezsek
                                en_r4 = 0;
                            end
                        end
                    end
                    
                    9:begin
                        // dc_deger tablosunda var
                        sayi_r <= encoded_veri_deger << 4; // 4 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b0110)begin                                                           
                            // 6 bit rotate shift islemi                                                            
                            en_r6 = 1;                                                                              
                            durum = 7;                                                                              
                        end else begin
                        end
                    end
                    10:begin
                        // 5 BITLIK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger5 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // DC_deger tabosunda var
                                dc_deger5 <= ara_deger5;
                                // encoded_veri_deger  asil sayi icin 3 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 5; // 5 kez bit kaydirildi rotate shift ile
                                en_r5 = 0;
                                durum  = 3; // 5 bitlik ara_deger5 dc deger kontrolüne gider 
                            end else begin // 5 bitlik sayi elde edemezsek
                                en_r5 = 0;
                            end
                        end
                    end
                    
                    11:begin
                        sayi_r <= encoded_veri_deger << 5; // 5 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b0111)begin                              
                            // 7 bit rotate shift islemi                                                            
                            en_r7 = 1;                                                                              
                            durum = 7;                                                                              
                        end else begin
                        end
                    end
                    
                    12:begin
                        // 6 BITLIK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger6 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // DC_deger tabosunda var
                                dc_deger6 <= ara_deger6;
                                // encoded_veri_deger  asil sayi icin 3 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 6; // 6 kez bit kaydirildi rotate shift ile
                                en_r6 = 0;
                                durum  = 3; // 6 bitlik ara_deger6 dc deger kontrolüne gider 
                            end else begin // 6 bitlik sayi elde edemezsek
                                en_r6 = 0;
                            end
                        end
                    end
                    13:begin
                        sayi_r <= encoded_veri_deger << 6; // 6 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b1000)begin                              
                            // 8 bit rotate shift islemi                                                            
                            en_r8 = 1;                                                                              
                            durum = 7;                                                                              
                        end else begin
                        end
                    end
                    
                    14:begin
                        // 7 BITLIK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger7 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // DC_deger tabosunda var
                                dc_deger7 <= ara_deger7;
                                // encoded_veri_deger  asil sayi icin 3 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 7; // 7 kez bit kaydirildi rotate shift ile
                                en_r7 = 0;
                                durum  = 3; // 7 bitlik ara_deger7 dc deger kontrolüne gider 
                            end else begin // 7 bitlik sayi elde edemezsek
                                en_r7 = 0;
                            end
                        end
                    end
                    15:begin
                        sayi_r <= encoded_veri_deger << 7; // 7 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b1001)begin                              
                            // 9 bit rotate shift islemi                                                            
                            en_r9 = 1;                                                                              
                            durum = 7;                                                                              
                        end else begin
                        end
                    end
                    
                    16:begin
                        // 8 BITLIK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger8 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // DC_deger tabosunda var
                                dc_deger8 <= ara_deger8;
                                // encoded_veri_deger  asil sayi icin 3 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 8; // 8 kez bit kaydirildi rotate shift ile
                                en_r8 = 0;
                                durum  = 3; // 8 bitlik ara_deger8 dc deger kontrolüne gider 
                            end else begin // 8 bitlik sayi elde edemezsek
                                en_r8 = 0;
                            end
                        end
                    end
                    17:begin
                         sayi_r <= encoded_veri_deger << 8; // 8 kez kaydırlmış oldu                                                                                  
                         if(cikis_deger == 4'b1010)begin                               
                             // 9 bit rotate shift islemi                                                            
                             en_r10 = 1;                                                                              
                             durum = 7;                                                                              
                         end else begin
                         end
                    end
                    
                    18:begin
                        // 9 BITLIK KONTROL
                        if(gec < 7)begin 
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            if(ara_deger9 !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)begin 
                                // DC_deger tabosunda var
                                dc_deger9 <= ara_deger9;
                                // encoded_veri_deger  asil sayi icin 3 kez shift left => rotate shifte gönderilecek yeni veri
                                kaydirma = 9; // 9 kez bit kaydirildi rotate shift ile
                                en_r8 = 0;
                                durum  = 3; // 9 bitlik ara_deger9 dc deger kontrolüne gider 
                            end else begin // // 9 bitlik sayi elde edemezsek
                                en_r9 = 0;
                            end
                        end
                    end
                    19:begin
                        sayi_r <= encoded_veri_deger << 9; // 9 kez kaydırlmış oldu                                                                                  
                        if(cikis_deger == 4'b1011)begin       // 1011                        
                            // 9 bit rotate shift islemi                                                            
                            en_r11 = 1;                                                                              
                            durum = 7;                                                                              
                        end else begin
                        end
                    end
                    
                    20:begin
                    
                        encoded_veri_cikti = encoded_veri_i << kaydirma1; // ac_degerler icin kalan encoded sayimiz
                    
                        // asil sayi kontrol edilecek , 0 ile basliyorsa tersini alıp eksilisini al
                        // 1 ile başlıyorsa aynısını yaz
                        if(asil_deger1 !== 1'bx)begin
                            if(asil_deger1 == 1) begin
                                // pozitif 
                                ram_deger1 = asil_deger1;
                                durum = 24;
                            end else begin
                                // negatif / 0 la basliyor       
                                durum = 21; // 2ye tümleyen alma 
                            end
                        end
                        
                        else if(asil_deger2 !== 2'bxx)begin 
                            if(asil_deger2[1] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger2;
                                durum = 24;
                            end else begin
                                // negatif / 0 la basliyor       
                                durum = 21; // 2ye tümleyen alma 
                            end
                        end
                        
                        else if(asil_deger3 !== 3'bxxx)begin 
                            if(asil_deger3[2] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger3;
                                durum = 24;
                            end else begin
                                // negatif / 0 la basliyor   
                                durum = 21; // 2ye tümleyen alma 
                            end
                        end
                        
                        else if(asil_deger4 !== 4'bxxxx)begin 
                            if(asil_deger4[3] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger4;
                                durum = 24;
                            end else begin
                                // negatif / 0 la basliyor     
                                durum = 21;
                            end
                        end
                        
                        else if(asil_deger5 !== 5'bxxxxx)begin 
                            if(asil_deger5[4] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger5;
                                durum = 24;
                            end else begin
                                // negatif / 0 la basliyor     
                                durum = 21;
                            end
                        end
                        
                        else if(asil_deger6 !== 6'bxxxxxx)begin 
                            if(asil_deger6[5] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger6;
                                durum = 24;
                            end else begin
                                // negatif / 0 la basliyor     
                                durum = 21;
                            end
                        end
                        
                        else if(asil_deger7 !== 7'bxxxxxxx)begin 
                            if(asil_deger7[6] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger7;
                                durum = 24;
                            end else begin
                                // negatif / 0 la basliyor
                                durum = 21;
                            end
                        end
                        
                        else if(asil_deger8 !== 8'bxxxxxxxx)begin 
                            if(asil_deger8[7] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger8;
                                durum = 24;
                            end else begin
                                // negatif / 0 la basliyor     
                                durum = 21;
                            end
                        end
                        
                        else if(asil_deger9 !== 9'bxxxxxxxxx)begin 
                            if(asil_deger9[8] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger9;
                                durum = 24;
                            end else begin
                                // negatif / 0 la basliyor     
                                durum = 21;
                            end
                        end
                        
                        else if(asil_deger10 !== 10'bxxxxxxxxxx)begin 
                            if(asil_deger10[9] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger10;
                                durum = 24;
                            end else begin
                                // negatif / 0 la basliyor   
                                durum = 21;
                            end
                        end
                        
                        else if(asil_deger11 !== 11'bxxxxxxxxxxx)begin 
                            if(asil_deger11[10] == 1) begin
                                // pozitif
                                ram_deger1 = asil_deger11;
                                durum = 24;
                            end else begin
                                // negatif / 0 la basliyor  
                                durum = 21;
                            end
                        end else begin
                            
                        end
                        
                    end
                    21:begin 
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
                                durum = 22;
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
                                durum = 22;
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
                                ram_deger1 = asil_deger3;  // 00000000101
                                durum = 22; // 2ye tümleyen alma 
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
                                durum = 22;
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
                                durum = 22;
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
                                durum = 22;
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
                               durum = 22;
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
                                durum = 22;
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
                                durum = 22;
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
                                durum = 22;
                            end
                        end
                        
                        else if(asil_deger11 !== 11'bxxxxxxxxxxx)begin 
                            // negatif / 0 la basliyor     
                            if(i < 11)begin // 010 geldi 
                                if(asil_deger11[i] == 0) begin
                                    asil_deger11[i] = 1;
                                end else begin
                                    asil_deger11[i] = 0;
                                end
                                i = i + 1;
                            end else begin 
                                ram_deger1 = asil_deger11;
                                durum = 22;
                            end
                        end
                        
                    end
                    
                    22:begin
                        // 2 ye tümleme yapılacak // 00000101 / j = 0; / ilk 1 i bulma
                        i = 0; 
                        if(ram_deger1[j] !== 1)begin 
                            j = j + 1; // ilk 1e ulaşana kadar 
                        end else begin
                            j = j + 1;
                            durum = 23;
                        end
                    end
                    23:begin
                        // ilk 1 i buldu // 0000000101 / j = 1; / 1111111011
                        if(j<11)begin 
                            // 0ları 1, 1leri 0 yap
                            if(ram_deger1[j] == 0)begin
                                ram_deger1[j] = 1;  
                                j = j + 1; // 2 / 4 / 5 / 6  / 7 => 1111111011 => -5 
                                durum = 23;
                            end else begin
                                ram_deger1[j] = 0;
                                j = j + 1;  // 3
                                durum = 23;
                            end
                        end else begin
                            // 11111011 => -5 // ram e yazilacak asil sayiyi elde ettik 
                            durum = 24;
                        end
                    end
                    24:begin
                        ram_deger_asil <= ram_deger1;
                        kaydirma1_deger <=  kaydirma1;
                        durum = 25;
                    end
                    25:begin
                        // BITTI / HERHANGI BIR SONUC ELDE EDILMEZSE
                        
                        i = 0;
                        j = 0;
                        durum = 0;
                        gec = 0;
                        sayac = 0;
                        
                        kaydirma = 0;
                        kaydirma1 = 0;
                        
                        // encoded_veri_cikti= 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
                        encoded_veri_deger = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
                        
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
                        asil_deger11 = 11'bxxxxxxxxxxx;
                        
                        dc_deger1 = 1'bx;        
                        dc_deger2 = 2'bxx;       
                        dc_deger3 = 3'bxxx;      
                        dc_deger4 = 4'bxxxx;     
                        dc_deger5 = 5'bxxxxx;    
                        dc_deger6 = 6'bxxxxxx;   
                        dc_deger7 = 7'bxxxxxxx;  
                        dc_deger8 = 8'bxxxxxxxx; 
                        dc_deger9 = 9'bxxxxxxxxx;
                        
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
                asil_deger11 = 11'bxxxxxxxxxxx;
                
                dc_deger1 = 1'bx;        
                dc_deger2 = 2'bxx;       
                dc_deger3 = 3'bxxx;      
                dc_deger4 = 4'bxxxx;     
                dc_deger5 = 5'bxxxxx;    
                dc_deger6 = 6'bxxxxxx;   
                dc_deger7 = 7'bxxxxxxx;  
                dc_deger8 = 8'bxxxxxxxx; 
                dc_deger9 = 9'bxxxxxxxxx;
                
                ram_deger1 = 11'bxxxxxxxxxxx;
                ram_deger_asil = 11'bxxxxxxxxxxx;
                ram_deger0  = 11'bxxxxxxxxxxx;
                encoded_veri_cikti = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
                
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
//        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger1) // bu dc nin girişi, ac nin  girişi veya ram e yazılacak sayi olacak
    );
    rotate_left #(.kaydir(2)) rotate_left2(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r2),
        .sayi_i(sayi_r),          
//        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger2)
    );
    rotate_left #(.kaydir(3)) rotate_left3(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r3),
        .sayi_i(sayi_r),          
//        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger3)
    );
    
    rotate_left #(.kaydir(4)) rotate_left4(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r4),
        .sayi_i(sayi_r),          
//        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger4)
    );
    rotate_left #(.kaydir(5)) rotate_left5(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r5),
        .sayi_i(sayi_r),          
//        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger5)
    );
    rotate_left #(.kaydir(6)) rotate_left6(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r6),
        .sayi_i(sayi_r),          
//        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger6)
    );
    rotate_left #(.kaydir(7)) rotate_left7(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r7),
        .sayi_i(sayi_r),          
//        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger7)
    );
    rotate_left #(.kaydir(8)) rotate_left8(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r8),
        .sayi_i(sayi_r),          
//        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger8)
    );
    rotate_left #(.kaydir(9)) rotate_left9(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r9),
        .sayi_i(sayi_r),          
//        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger9)
    );
    rotate_left #(.kaydir(10)) rotate_left10(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r10),
        .sayi_i(sayi_r),          
//        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger10)
    );
    rotate_left #(.kaydir(11)) rotate_left11(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_r11),
        .sayi_i(sayi_r),          
//        .kaydirilmis_sayi_o(),
        .cekilen_veri_o(ara_deger11)
    );
    
    // ----------------------------------------
endmodule
