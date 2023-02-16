`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.01.2023 13:31:35
// Design Name: 
// Module Name: decode
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


module decode(
    input clk_i,rst_i,en_i,
    input [31:0] encoded_i,
    output sonuc_o,
    output [7:0] decoded_o,
    output decode_et_o,
    output [31:0] bufferr, dataa,
    output [6:0] decode_durum_o,
    output [6:0] cikk,
    output [31:0] encoded_resim_o,
    output [12:0] eob_deger_o,
    output [6:0] say_o,
    output [6:0] say_kontrol_o,
    output [6:0] sag_sol_fark_o,
    output [63:0] encoded_top,
    output [10:0] dc_deger,
    output [10:0] dc_deg_onceki,
    output [10:0] ac_deger,
    input [6:0] satir_oku,
    output [6:0] ondeki_sifir_say
    );
    
    
    
    integer sayac = 0, gec = 0;
    reg [6:0] durum = 0;
    reg data_gonderme_ok = 1;
    assign sonuc_o = data_gonderme_ok;
    
    integer indis_say = 0;
    reg [6:0] decode_durum;
    assign decode_durum_o = decode_durum;
    reg [7:0] decoded;
    reg decode_et;
    assign decode_et_o = decode_et;
    assign decoded_o = decoded;
    
    reg [5:0] sonraki_durum = 1;
    
    // ENCODED VERI ICIN RAM
    integer encoded_satir = 0;
    reg [9:0] addr_encoded_veri; // ramin satýr sayýsý bilinmiyor 
    reg we_encoded , en_encoded;
    reg [31:0] in_encoded;
    wire [31:0] out_encoded;
    
    // VERI CEKME ICIN DEGISKENLER
    reg [31:0] buffer, data, ara_deger;
    reg [63:0] encoded_resim;
    integer cnt = 0; // ne kadar veri kullandýk
    integer say = 0; // 32 bit bitti mi? 
    integer say_kontrol = 32;
    integer sag_sol_kaydir = 0;
    integer eob_arttir = 0; // 1200 tane olunca bütün iþlemler bitecek 
    reg [31:0] encoded_resim_deger; // isleme sokulan
    
    // inverse huffman çýktýlarýný saklamak için
    reg [10:0] RAM_inv_zigzag [63:0]; // 11 bitlik 64 satýrlýk ram //BU INVERSE KUANTALAMAYA GIDECEK
    integer ind = 0;
    reg [10:0] RAM_dc_ac [63:0]; // 11 bitlik 64 satýrlýk ram
    
    integer ram_satir = 0;
    integer ram_satir_ekle = 0; // ac asil sayidan önce gelecek 0 sayisi kontrolü / ram_satir üzerine eklenecek
    
    // DC ICIN
    // DC
    reg en_dc;
    reg [31:0] encoded_veri_i_dc;  
    wire [31:0] encoded_veri_o_dc;                                                                       
    wire [10:0] dc_deger_dc;      // rame yazilmayacak                                                                      
    wire [10:0] asil_deger_dc;                                                                          
    wire [4:0] sagdaki_sifir_sayisi_dc; // max 20 olabilir 
    
    reg [31:0] encoded_veri_o_dc_ata;                                                                       
    // reg [10:0] dc_deger_dc_ata;          // rame yazilmayacak                                                                  
    reg signed [10:0] asil_deger_dc_ata;       
    reg signed [10:0] asil_deger_dc_al = 0;                                                                   
    reg [4:0] sagdaki_sifir_sayisi_dc_ata; // max 20 olabilir 
    assign dc_deger = asil_deger_dc_al;
    assign dc_deg_onceki = asil_deger_dc_ata;
    
    
    // AC ICIN 
    // AC
    reg en_ac;
    reg [31:0] encoded_veri_i_ac;  
    wire [31:0] encoded_veri_o_ac;                                                                      
    wire [17:0] ac_deger_ac;   // rame yazilmayacak                                                                  
    wire [10:0] asil_deger_ac;      
    assign ac_deger = asil_deger_ac;                                                                    
    wire [4:0] sagdaki_sifir_sayisi_ac; // max 20 olabilir                                              
    wire [4:0] ondeki_sifir_sayisi_ac; // asil sayi onundeki 0 sayisi / ramde asil sayi onune yazilacak 
    wire eob_kontrol_ac; // bu 1 olursa ilk matris bitmiþ olur                                           
    assign ondeki_sifir_say = sagdaki_sifir_sayisi_ac;
    reg [31:0] encoded_veri_o_ac_ata;                                                                                           
    reg [10:0] asil_deger_ac_ata;                                                                          
    reg [4:0] sagdaki_sifir_sayisi_ac_ata; // max 20 olabilir                                              
    reg [4:0] ondeki_sifir_sayisi_ac_ata; // asil sayi onundeki 0 sayisi / ramde asil sayi onune yazilacak 
    reg eob_kontrol_ac_ata; // bu 1 olursa ilk matris bitmiþ olur 
    
    
    // INVERSE KUANTALAMA + DCT 
    
     // ram1 // 11 bitlik 
    reg we_ram1, en_ram1; 
    reg [5:0] addr_ram1;
    reg signed [10:0] data_in_ram1;
    wire signed [10:0] data_out_ram1;
    //reg signed [10:0] data;
    
    
    // INVERSE KUANTALAMA
    // kuantalama rom
    reg rd_rom_k;
    reg [5:0] addr_rom_k;
    wire signed [10:0] data_out_rom_k;
    integer satir_k = 0; // kuantalam romu satýrlarýný gezmek icin
    
    reg signed [31:0] kuantalama_sonucu_ram[0:63]; // kuantalam_sonucu 32 bitlik ram
    reg signed [31:0] kuantalama_sonucu_ram_oku;
    reg signed [10:0] data_out_ram1_deger;
    reg signed [10:0] data_out_rom_k_deger;
    reg signed [31:0] int_carp_k;
    
    // INVERSE DCT
    // ramfp // 32 bitlik // inverse kuantalama ciktisi , floating pointe donusturlup bu ram e yazilacak
    reg we_ram_fp, en_ram_fp;
    reg [5:0] addr_ram_fp;
    reg [31:0] data_in_ram_fp;
    wire [31:0] data_out_ram_fp;
    reg [31:0] data_out_ram_fp_deger;
    
    
    // integer -> fp ye donusum icin
    reg en_int_fp;
    reg [31:0] int_fp_in;
    wire [31:0] int_fp_out;
    integer satir_fp = 0;
    reg [31:0] int_fp_deger;
    
    // floatin point carpma / int_fp_donus ile cos ayrýk degerleri ile fp carpým
    reg en_carp;
    reg [31:0] fp_carp_gir1, fp_carp_gir2;
    wire [31:0] fp_carp_cik;
    reg [31:0] fp_carp_ata;
    
    // cos ayrýk deger rom 
    reg rd_rom_cos;
    reg [11:0] addr_rom_cos;
    wire signed [31:0] data_out_rom_cos;
    integer satir_cos = 0; // cos romu satýrlarýný gezmek icin
    integer cos_rom_say = 0; // 4096 olur max
    
    // T matris deger rom 
    reg rd_rom_t;
    reg [5:0] addr_rom_t;
    wire signed [31:0] data_out_rom_t;
    integer satir_t = 0; // T matris romu satýrlarýný gezmek icin
    
    // fp carpým sonuc1 icin
    reg we_ram_sonuc1, en_ram_sonuc1;
    reg [5:0] addr_ram_sonuc1;
    reg [31:0] data_in_ram_sonuc1;
    wire [31:0] data_out_ram_sonuc1;
    integer satir_sonuc1 = 0;
    
    // fp toplam icin
    reg [31:0] toplam1_sonucu_ram[0:63]; // ram_toplam sonucu / 128 eklemeden önce 
    reg [31:0] toplam2_sonucu_ram[0:63]; // 128 eklenmiþ
    integer satir_sonuc2 = 0;
    
    // floatin point toplama 
    reg en_topla;
    reg [31:0] fp_topla_gir1, fp_topla_gir2;
    wire [31:0] fp_topla_cik;
    reg [31:0] fp_topla_ata;
    
    reg [31:0] ram_toplam = 0; // ram satýrlarýný toplama
   
    // fp -> integer a donusum icin
    reg en_fp_int;
    reg [31:0] fp_int_in;
    wire [31:0] fp_int_out;
    reg signed [7:0] fp_int_ata;
    integer satir_int = 0;
    reg [31:0] fp_int_deger;
    
    reg [31:0] toplam_sonuc_deger, toplam_sonuc;
    
    // SONUC RAM
    // ram1 // 8 bitlik 
    reg we_ram_sonuc, en_ram_sonuc; 
    reg [5:0] addr_ram_sonuc;
    reg signed [7:0] data_in_ram_sonuc;
    wire signed [7:0] data_out_ram_sonuc;
    integer sonuc_satir = 0;
    
    reg [7:0] sonuc_ram[0:63]; // degerleri gormek icin
    
    assign bufferr = buffer;
    assign dataa = data;
    reg [6:0] cikti;
    assign cikk = cikti;
    assign encoded_resim_o = encoded_resim_deger;
    assign eob_deger_o = eob_arttir;
    
    assign say_o = say;
    assign say_kontrol_o = say_kontrol;
    assign encoded_top = encoded_resim;
    assign sag_sol_fark_o = sag_sol_kaydir;
    
    
    
    parameter 
        ILK_IKI_VERI_CEK = 0,
        DIGER_VERILERI_CEK = 63,
        
        INV_HUFFMAN_RUNLENGTH1 = 1,
        INV_HUFFMAN_RUNLENGTH2 = 2,
        INV_HUFFMAN_RUNLENGTH3 = 3,
        INV_HUFFMAN_RUNLENGTH4 = 4,
        INV_HUFFMAN_RUNLENGTH5 = 5,
        INV_HUFFMAN_RUNLENGTH6 = 6,
        
        YENI_VERI_KONTROL1 = 7,
        
        INV_HUFFMAN_RUNLENGTH7 = 8,
        INV_HUFFMAN_RUNLENGTH8 = 52,
        INV_HUFFMAN_RUNLENGTH9 = 53,
        INV_HUFFMAN_RUNLENGTH10 = 9,
        INV_HUFFMAN_RUNLENGTH11 = 54,
        INV_HUFFMAN_RUNLENGTH12 = 10,
        INV_HUFFMAN_RUNLENGTH13 = 11,
        INV_HUFFMAN_RUNLENGTH14 = 60,
        INV_HUFFMAN_RUNLENGTH15 = 12,
        
        YENI_VERI_KONTROL2 = 13,
        
        INV_HUFFMAN_RUNLENGTH16 = 14,
        INV_HUFFMAN_RUNLENGTH17 = 55,
        INV_HUFFMAN_RUNLENGTH18 = 56,
        INV_HUFFMAN_RUNLENGTH19 = 15,
        
        INV_ZIGZAG = 16,
        
        INV_KUANTALAMA1 = 17,
        INV_KUANTALAMA2 = 18,
        INV_KUANTALAMA3 = 19,
        INV_KUANTALAMA4 = 20,
        INV_KUANTALAMA5 = 21,
        INV_KUANTALAMA6 = 22,
        
        INV_DCT1  = 23,
        INV_DCT2  = 24,
        INV_DCT3  = 25,
        INV_DCT4  = 26,
        INV_DCT5  = 27,
        INV_DCT6  = 28,
        INV_DCT7  = 29,
        INV_DCT8  = 30,
        INV_DCT9  = 31,
        INV_DCT10 = 32,
        INV_DCT11 = 33,
        INV_DCT12 = 34,
        INV_DCT13 = 35,
        INV_DCT14 = 36,
        INV_DCT15 = 37,
        INV_DCT16 = 38,
        INV_DCT17 = 39,
        INV_DCT18 = 40,
        INV_DCT19 = 41,
        INV_DCT20 = 42,
        
        VERI_GONDER1 = 43,
        VERI_GONDER2 = 44,
        
        YENI_VERI_KONTROL3 = 46,
        
        INV_HUFFMAN_RUNLENGTH20 = 47,
        INV_HUFFMAN_RUNLENGTH21 = 48,
        INV_HUFFMAN_RUNLENGTH22 = 49;
        
    always@(posedge clk_i)begin
        if(rst_i)begin
        end else begin
            if(en_i == 1)begin
                sayac = sayac + 1;
                case(durum) 
                    ILK_IKI_VERI_CEK: // 0
                    begin
                        decode_durum <= durum;
                        // TOP MODULDEN VERIYI OKUMAK ICIN HEP BU MODLULE GELECEK
                        if(data_gonderme_ok == 1)begin
                           if(indis_say < 1)begin // ilk veriyi alip buffer a atar / sonraki verleri dataya 
                                if(gec < 1)begin
                                    gec <= gec + 1;
                                end else begin
                                    gec <= 0;
                                    buffer <= encoded_i; // buffer bir kez ekilecek 
                                    indis_say <= indis_say + 1;
                                end
                            end else begin
                                if(gec < 4)begin // ikinci veri için gec < 4 yap // bundan sonrakiler içi gec < 3 yap /AYR
                                    gec <= gec + 1;
                                end else begin
                                    gec <= 0;
                                    data <= encoded_i;  // her cekilmede veri dataya aktarýlacak
                                    indis_say <= indis_say + 1;
                                    data_gonderme_ok <= 0;
                                    durum <= sonraki_durum;
                                end
                            end
                            end 
                        else begin
                        end
                         
                    end
                    
                    
                    
                    // DIGER VERILERI ALMAK ICIN
                    DIGER_VERILERI_CEK:begin // 63
                        decode_durum <= durum;
                        if(data_gonderme_ok == 1)begin                            
                            if(gec < 3)begin // ikinci veri için gec < 4 yap // bundan sonrakiler içi gec < 3 yap /AYR
                                gec <= gec + 1;
                            end else begin
                                gec <= 0;
                                data <= encoded_i;  // her cekilmede veri dataya aktarýlacak
                                indis_say <= indis_say + 1;
                                data_gonderme_ok <= 0;
                                durum <= sonraki_durum;
                            end
                        end else begin
                        end
                    end 
                   
                    INV_HUFFMAN_RUNLENGTH1:begin //1
                        decode_durum <= durum;
                        encoded_resim <= {buffer,data};
                        durum <= 2;
                    end
                    
                    INV_HUFFMAN_RUNLENGTH2:begin // 2
                        decode_durum <= durum;
                        encoded_resim_deger <= encoded_resim[63:32];     
                        durum <= INV_HUFFMAN_RUNLENGTH3;      
                    end
                    
                    // DC KONTROL
                    INV_HUFFMAN_RUNLENGTH3:begin // 3
                        decode_durum <= durum;
                        // DC yazma 
                        encoded_veri_i_dc <= encoded_resim_deger;
                        en_dc <= 1;
                        durum <= INV_HUFFMAN_RUNLENGTH4; // DC deger kontrolü
                    end
                    
                    INV_HUFFMAN_RUNLENGTH4:begin // 4
                        decode_durum <= durum;
                        // DC okuma
                        if(gec < 250)begin 
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            en_dc <= 0;
                            encoded_veri_o_dc_ata <= encoded_veri_o_dc; 
                            asil_deger_dc_ata <= asil_deger_dc;
                            sagdaki_sifir_sayisi_dc_ata <= sagdaki_sifir_sayisi_dc;
                            durum <= INV_HUFFMAN_RUNLENGTH5;
                        end
                    end
                    
                    INV_HUFFMAN_RUNLENGTH5:
                    begin
                        decode_durum <= durum;
                        asil_deger_dc_al <= asil_deger_dc_al + asil_deger_dc_ata;
                        cnt <= sagdaki_sifir_sayisi_dc_ata;
                        durum <= INV_HUFFMAN_RUNLENGTH6;
                    end
                    
                    INV_HUFFMAN_RUNLENGTH6:
                    begin
                        decode_durum <= durum;
                        // array e yaz // RAM_dc_ac => bir array
                        RAM_dc_ac[0] <= asil_deger_dc_al ; // bir sonraki dc deðeri bir öncekiyle toplamý þeklinde olacak
                        ram_satir <= ram_satir + 1; // ilk satir doldu 
                        say <= say + cnt;
                        encoded_resim <= encoded_resim << cnt;
                        durum <= YENI_VERI_KONTROL1;
                    end
                   
                    YENI_VERI_KONTROL1:begin // 7
                        decode_durum <= durum;
                        if(say < say_kontrol)begin
                            durum <= INV_HUFFMAN_RUNLENGTH10;  // AC kontrole 
                        end else begin // yeni data gelmeli
                           data_gonderme_ok <= 1;
                           sag_sol_kaydir <= say - say_kontrol; 
                           buffer <= encoded_resim[63:32];  // shift right islemine sokulur
                           sonraki_durum <= INV_HUFFMAN_RUNLENGTH7; // veri cekildikten sonra bir sonraki duruma gececek 
                           durum <= DIGER_VERILERI_CEK;
                        end
                    end
                    
                    INV_HUFFMAN_RUNLENGTH7:begin // 8
                        decode_durum <= durum;
                        say <= say - 32;
                        buffer <= buffer >> sag_sol_kaydir; // tekrar sola kaydýrýlýr 
                        data_gonderme_ok <= 0;
                        durum <= INV_HUFFMAN_RUNLENGTH8;
                        
                    end
                    
                    INV_HUFFMAN_RUNLENGTH8:begin // 52
                        decode_durum <= durum;
                        encoded_resim <= {buffer,data};
                        durum <= INV_HUFFMAN_RUNLENGTH9;
                    end 
                  
                    INV_HUFFMAN_RUNLENGTH9:begin // 53
                        decode_durum <= durum;
                        encoded_resim <= encoded_resim << sag_sol_kaydir; // tekrar sola kaydýrýlýr 
                        durum <= INV_HUFFMAN_RUNLENGTH10; // AC kontrole 
                    end
                    
                    INV_HUFFMAN_RUNLENGTH10:begin // 9
                        decode_durum <= durum;
                        encoded_resim_deger <= encoded_resim[63:32];
                        durum <= INV_HUFFMAN_RUNLENGTH11;
                    end
                    INV_HUFFMAN_RUNLENGTH11:begin // 54
                        decode_durum <= durum;
                        encoded_veri_i_ac <= encoded_resim_deger;
                        en_ac <= 1;
                        durum <= INV_HUFFMAN_RUNLENGTH12;
                    end 
                    
                    // AC KONTROL
                    INV_HUFFMAN_RUNLENGTH12:begin // 10
                        decode_durum <= durum;
                        // AC okuma
                        if(gec < 320)begin 
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            en_ac <= 0;
                            encoded_veri_o_ac_ata <= encoded_veri_o_ac; // ac nin girisi olacak
                            asil_deger_ac_ata <= asil_deger_ac;
                            sagdaki_sifir_sayisi_ac_ata <= sagdaki_sifir_sayisi_ac;
                            ondeki_sifir_sayisi_ac_ata <= ondeki_sifir_sayisi_ac;
                            eob_kontrol_ac_ata <= eob_kontrol_ac;
                            durum <= INV_HUFFMAN_RUNLENGTH13;
                        end
                    end
                    
                    INV_HUFFMAN_RUNLENGTH13:begin // 11
                        decode_durum <= durum;
                        if(eob_kontrol_ac_ata !== 1)begin
                            durum <= INV_HUFFMAN_RUNLENGTH14;
                        end else begin
                            eob_arttir <= eob_arttir + 1; // 1200 olunca tüm iþlemler biter
                            ram_satir <= ram_satir + ram_satir_ekle; // ondeki_sifir_sayisi_ac_ata+1 kadar  satir doldu  // daha sonra kalan satýrlarý 0 la doldur 
                            durum <= INV_HUFFMAN_RUNLENGTH19;
                        end
                    end
                    
                    INV_HUFFMAN_RUNLENGTH14:begin  // 60
                         decode_durum <= durum;
                        if(ondeki_sifir_sayisi_ac_ata == 16)begin // ram_satir = 3 / ram_satir = 18
                            if(ram_satir_ekle < ondeki_sifir_sayisi_ac_ata) begin
                                RAM_dc_ac[ram_satir + ram_satir_ekle] <= 11'b00000000000; // ilgili satýra 0 yazýlýr
                                ram_satir_ekle <= ram_satir_ekle + 1;
                            end else begin
                                cnt <= sagdaki_sifir_sayisi_ac_ata;
                                durum <= INV_HUFFMAN_RUNLENGTH15;
                            end
                         end else begin
                            // devam
                            // ram e yaz  // ondeki_sifir_sayisi_ac_ata = 3  
                            if(ram_satir_ekle < ondeki_sifir_sayisi_ac_ata) begin
                                RAM_dc_ac[ram_satir+ram_satir_ekle] <= 11'b00000000000; // ilgili satýra 0 yazýlýr
                                ram_satir_ekle <= ram_satir_ekle + 1;
                            end else begin
                                RAM_dc_ac[ram_satir+ram_satir_ekle] <= asil_deger_ac_ata;
                                ram_satir_ekle <= ram_satir_ekle + 1;
                                cnt <= sagdaki_sifir_sayisi_ac_ata;
                                durum <= INV_HUFFMAN_RUNLENGTH15;
                            end 
                        end 
                    end 
                    
                    INV_HUFFMAN_RUNLENGTH15:begin // 12
                        decode_durum <= durum;
                        ram_satir <= ram_satir + ram_satir_ekle; // ondeki_sifir_sayisi_ac_ata+1 kadar  satir doldu 
                        say <= say + cnt;
                        encoded_resim <= encoded_resim << cnt;
                        durum <= YENI_VERI_KONTROL2;
                    end
                    
                    YENI_VERI_KONTROL2:begin // 13
                        decode_durum <= durum;
                        ram_satir_ekle = 0;
                        if(say < say_kontrol)begin
                            durum <= INV_HUFFMAN_RUNLENGTH10;  // AC kontrole 
                        end else begin // yeni data gelmeli
                           data_gonderme_ok <= 1; 
                           sag_sol_kaydir <= say - say_kontrol; 
                           buffer <= encoded_resim[63:32];  
                           sonraki_durum <= INV_HUFFMAN_RUNLENGTH16; // veri cekildikten sonra bir sonraki duruma gececek
                           durum <=  DIGER_VERILERI_CEK;
                        end
                       
                    end
                    
                    // HER CLOCKTA KAYDIRIR , KAYDIRMA DEGERÝ KADAR / KONTROL ET DÝÐER KISIMLARDA 
                    INV_HUFFMAN_RUNLENGTH16:begin // 14
                        decode_durum <= durum;
                        say <= say - 32;
                        buffer <= buffer >> sag_sol_kaydir; // saga kaydýrýlýr 
                        data_gonderme_ok <= 0;
                        durum <= INV_HUFFMAN_RUNLENGTH17;
                    end
                    
                    INV_HUFFMAN_RUNLENGTH17:begin // 55
                        decode_durum <= durum;
                        encoded_resim <= {buffer,data};
                        durum <= INV_HUFFMAN_RUNLENGTH18;
                    end 
                    INV_HUFFMAN_RUNLENGTH18:begin   // 56
                        decode_durum <= durum;
                        encoded_resim <= encoded_resim << sag_sol_kaydir; // tekrar sola kaydýrýlýr 
                        durum <= INV_HUFFMAN_RUNLENGTH10; // AC kontrole 
                    end 
                    
                    INV_HUFFMAN_RUNLENGTH19:begin // 15
                        decode_durum <= durum;
                        eob_kontrol_ac_ata <= 0;
                        if(eob_arttir <= 1200)begin
                            // kalan satýrlar sýfýrlanýr 
                            if(ram_satir < 64)begin
                                RAM_dc_ac[ram_satir] <= 11'b00000000000;
                                ram_satir <= ram_satir + 1;
                            end else begin
                                ram_satir <= 0;
                                cnt <= sagdaki_sifir_sayisi_ac_ata; // 4 tane daha kaymýþ olcak eob için 
                                durum <= INV_ZIGZAG;
                            end
                        end else begin
                            // bütün islemler biter
                        end
                    end
                    
                    INV_ZIGZAG:begin // 16
                        decode_durum <= durum;
                        // INVERSE ZIGZAG olacak 
                         
                        RAM_inv_zigzag[0]   <= RAM_dc_ac[0] ;
                        RAM_inv_zigzag[1]   <= RAM_dc_ac[1] ;
                        RAM_inv_zigzag[8]   <= RAM_dc_ac[2] ;
                        RAM_inv_zigzag[16]  <= RAM_dc_ac[3];
                        RAM_inv_zigzag[9]   <= RAM_dc_ac[4] ;
                        RAM_inv_zigzag[2]   <= RAM_dc_ac[5] ;
                        RAM_inv_zigzag[3]   <= RAM_dc_ac[6] ;
                        RAM_inv_zigzag[10]  <= RAM_dc_ac[7] ;
                        RAM_inv_zigzag[17]  <= RAM_dc_ac[8] ;
                        RAM_inv_zigzag[24]  <= RAM_dc_ac[9] ;
                        RAM_inv_zigzag[32]  <= RAM_dc_ac[10] ;
                        RAM_inv_zigzag[25]  <= RAM_dc_ac[11] ;
                        RAM_inv_zigzag[18]  <= RAM_dc_ac[12] ;
                        RAM_inv_zigzag[11]  <= RAM_dc_ac[13] ;
                        RAM_inv_zigzag[4]   <= RAM_dc_ac[14] ;
                        RAM_inv_zigzag[5]   <= RAM_dc_ac[15] ;
                        RAM_inv_zigzag[12]  <= RAM_dc_ac[16] ;
                        RAM_inv_zigzag[19]  <= RAM_dc_ac[17] ;
                        RAM_inv_zigzag[26]  <= RAM_dc_ac[18] ;
                        RAM_inv_zigzag[33]  <= RAM_dc_ac[19] ;
                        RAM_inv_zigzag[40]  <= RAM_dc_ac[20] ;
                        RAM_inv_zigzag[48]  <= RAM_dc_ac[21] ;
                        RAM_inv_zigzag[41]  <= RAM_dc_ac[22] ;
                        RAM_inv_zigzag[34]  <= RAM_dc_ac[23] ;
                        RAM_inv_zigzag[27]  <= RAM_dc_ac[24] ;
                        RAM_inv_zigzag[20]  <= RAM_dc_ac[25] ;
                        RAM_inv_zigzag[13]  <= RAM_dc_ac[26] ;
                        RAM_inv_zigzag[6]   <= RAM_dc_ac[27] ;
                        RAM_inv_zigzag[7]   <= RAM_dc_ac[28] ;
                        RAM_inv_zigzag[14]  <= RAM_dc_ac[29] ;
                        RAM_inv_zigzag[21]  <= RAM_dc_ac[30] ;
                        RAM_inv_zigzag[28]  <= RAM_dc_ac[31] ;
                        RAM_inv_zigzag[35]  <= RAM_dc_ac[32] ;
                        RAM_inv_zigzag[42]  <= RAM_dc_ac[33] ;
                        RAM_inv_zigzag[49]  <= RAM_dc_ac[34] ;
                        RAM_inv_zigzag[56]  <= RAM_dc_ac[35] ;
                        RAM_inv_zigzag[57]  <= RAM_dc_ac[36] ;
                        RAM_inv_zigzag[50]  <= RAM_dc_ac[37] ;
                        RAM_inv_zigzag[43]  <= RAM_dc_ac[38] ;
                        RAM_inv_zigzag[36]  <= RAM_dc_ac[39] ;
                        RAM_inv_zigzag[29]  <= RAM_dc_ac[40] ;
                        RAM_inv_zigzag[22]  <= RAM_dc_ac[41] ;
                        RAM_inv_zigzag[15]  <= RAM_dc_ac[42] ;
                        RAM_inv_zigzag[23]  <= RAM_dc_ac[43] ;
                        RAM_inv_zigzag[30]  <= RAM_dc_ac[44] ;
                        RAM_inv_zigzag[37]  <= RAM_dc_ac[45] ;
                        RAM_inv_zigzag[44]  <= RAM_dc_ac[46] ;
                        RAM_inv_zigzag[51]  <= RAM_dc_ac[47] ;
                        RAM_inv_zigzag[58]  <= RAM_dc_ac[48] ;
                        RAM_inv_zigzag[59]  <= RAM_dc_ac[49] ;
                        RAM_inv_zigzag[52]  <= RAM_dc_ac[50] ;
                        RAM_inv_zigzag[45]  <= RAM_dc_ac[51] ;
                        RAM_inv_zigzag[38]  <= RAM_dc_ac[52] ;
                        RAM_inv_zigzag[31]  <= RAM_dc_ac[53] ;
                        RAM_inv_zigzag[39]  <= RAM_dc_ac[54] ;
                        RAM_inv_zigzag[46]  <= RAM_dc_ac[55] ;
                        RAM_inv_zigzag[53]  <= RAM_dc_ac[56] ;
                        RAM_inv_zigzag[60]  <= RAM_dc_ac[57] ;
                        RAM_inv_zigzag[61]  <= RAM_dc_ac[58] ;
                        RAM_inv_zigzag[54]  <= RAM_dc_ac[59] ;
                        RAM_inv_zigzag[47]  <= RAM_dc_ac[60] ;
                        RAM_inv_zigzag[55]  <= RAM_dc_ac[61] ;
                        RAM_inv_zigzag[62]  <= RAM_dc_ac[62] ;
                        RAM_inv_zigzag[63]  <= RAM_dc_ac[63] ;
                            
                        encoded_resim <= encoded_resim << cnt; // 4 tane daha kaymýþ olcak eob için
                        say <= say + cnt;
                        // bu RAM_inv_zigzag arrayi dct iþlemine sokulacak
                        we_ram1 <= 1;
                        en_ram1 <= 1;
                        durum <= INV_KUANTALAMA1;
                    end
                    
                    // INVERSE KUANTALAM + DCT
                    INV_KUANTALAMA1:begin // 17
                        decode_durum <= durum;
                        // fifodakileri (inverse zigzagtan gelenleri) ram al
                        if(ind<64)begin 
                            addr_ram1 <= ind;
                            durum <= INV_KUANTALAMA2;
                        end else begin
                            cnt <= 0; 
                            ind <= 0;
                            en_ram1 <= 1;
                            we_ram1 <= 0; // okuma yapýcak
                            rd_rom_k <= 1;
                            durum <= INV_KUANTALAMA3;  
                        end
                    end 
                    
                    INV_KUANTALAMA2:begin // 18
                        decode_durum <= durum;
                        data_in_ram1 <= RAM_inv_zigzag[ind]; //yazacaðý veri zaten 11 bit direkt tek satýra aktanýr
                        ind <= ind+1;  // bir sonraki clockta artacak
                        durum <= INV_KUANTALAMA1;
                    end 
                    
                    // INVERSE KUANTALAMA
                    INV_KUANTALAMA3:begin // 19
                        decode_durum <= durum;
                        if(satir_k < 64)begin
                            addr_ram1 <= satir_k;
                            addr_rom_k <= satir_k; 
                            durum <= INV_KUANTALAMA4; // integer carpmaya
                        end else begin
                            satir_k <= 0; 
                            durum <= INV_DCT1; // integer carpma bitti / INVERSE DCT ye
                        end
                    end 
                    INV_KUANTALAMA4:begin // 20
                        decode_durum <= durum;
                        if(gec<4)begin
                            gec <= gec + 1;
                            // ram1 ve kuantalama romundan degerleri aldik
                            data_out_ram1_deger <= data_out_ram1;
                            data_out_rom_k_deger <= data_out_rom_k;
                        end else begin
                            gec <= 0;
                            durum <= INV_KUANTALAMA5;
                         end
                    end 
                    
                    INV_KUANTALAMA5:begin // 21
                        decode_durum <= durum;
                        if(gec < 1)begin
                            gec <= gec + 1;
                            int_carp_k <= data_out_ram1_deger * data_out_rom_k_deger;
                        end else begin
                            gec <= 0;
                            durum <= INV_KUANTALAMA6;
                        end
                    end 
                    
                    INV_KUANTALAMA6:begin // 22
                        decode_durum <= durum;
                        kuantalama_sonucu_ram[satir_k] <= int_carp_k;
                        satir_k <= satir_k + 1;
                        durum <= INV_KUANTALAMA3;
                    end
                    
                    
                    INV_DCT1:begin // 23
                        decode_durum <= durum;
                        if(satir_fp < 64) begin
                            en_int_fp <= 1;
                            int_fp_in <= kuantalama_sonucu_ram[satir_fp];
                            durum <= INV_DCT2;
                        end else begin
                            en_int_fp <= 0;
                            we_ram_fp <= 0;
                            en_ram_fp <= 0; 
                            satir_fp <= 0;
                            durum <= INV_DCT4; 
                        end
                    end
                    
                    INV_DCT2:begin   // 24
                        decode_durum <= durum;
                        if(gec < 45) begin // 42 saykýl
                            gec = gec + 1;
                        end else begin
                            int_fp_deger <= int_fp_out;
                            en_int_fp <= 0;
                            we_ram_fp <= 1;
                            en_ram_fp <= 1;
                            addr_ram_fp <= satir_fp;
                            gec <= 0;
                            durum <= INV_DCT3;
                        end
                    end 
                    INV_DCT3:begin // 25
                        decode_durum <= durum;
                        data_in_ram_fp <= int_fp_deger;
                        satir_fp <= satir_fp + 1;
                        durum <= INV_DCT1; 
                    end 
                    
                    // FP CARPMA / COS ROM
                    // floatin point carpma / int_fp_donus ile cos ayrýk degerleri ile fp carpým
                    
                    INV_DCT4:begin // 26
                        decode_durum <= durum;
                        if(cos_rom_say < 4097)begin // 4097
                            if(satir_cos < 64)begin
                                en_ram_fp <= 1; 
                                we_ram_fp <= 0; // okuma yapacak
                                addr_ram_fp <= satir_cos;
                                rd_rom_cos <= 1;
                                addr_rom_cos <= cos_rom_say;// bu 64ten fazla
                                rd_rom_t <= 1;
                                addr_rom_t <= satir_cos;
                                durum <= INV_DCT5;
                            end else begin
                                satir_cos <= 0;
                                en_ram_sonuc1 <= 1;
                                we_ram_sonuc1 <= 0; // okuma
                                en_carp <= 0;
                                durum <= INV_DCT10; // sonuc1 ram satýrlarý toplanýr
                            end
                        end else begin
                            satir_sonuc2 <= 0;
                            durum <= INV_DCT15;
                        end
                    end 
                    
                    INV_DCT5:begin // 27
                        decode_durum <= durum;
                        if(gec<4)begin
                            gec <= gec + 1;
                        end else begin
                            gec = 0;
                            fp_carp_gir1 <= data_out_ram_fp;
                            fp_carp_gir2 <= data_out_rom_cos;
                            en_carp <= 1;
                            durum <= INV_DCT6;
                        end
                    end 
                    
                    INV_DCT6:begin // 28
                        decode_durum <= durum;
                        if(gec < 80)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            fp_carp_ata <= fp_carp_cik;
                            en_carp <= 0;
                            durum <= INV_DCT7;
                        end
                    end
                    
                    // FP CARPMA / T ROM
                    INV_DCT7:begin // 29
                        decode_durum <= durum;
                        // t matrisi ile carpma
                        if(gec < 2)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            fp_carp_gir1 <= fp_carp_ata;
                            fp_carp_gir2 <= data_out_rom_t;
                            en_carp <= 1;
                            durum <= INV_DCT8;
                        end
                    end
                    
                    INV_DCT8:begin // 30
                        decode_durum <= durum;
                        if(gec < 80)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            fp_carp_ata <= fp_carp_cik;
                            en_carp <= 0;
                            en_ram_sonuc1 <= 1;
                            we_ram_sonuc1 <= 1; // yazma
                            addr_ram_sonuc1 <= satir_cos;
                            durum <= INV_DCT9; // 31 DUZENLE BUNDAN SONRASINI 
                        end
                    end 
                    
                    INV_DCT9:begin // 31
                        decode_durum <= durum;
                        data_in_ram_sonuc1 <= fp_carp_ata;
                        satir_cos <= satir_cos + 1;
                        cos_rom_say <= cos_rom_say + 1;
                        durum <= INV_DCT4;
                    end 
                    
                    // BUTUN RAM SATIRLARI TOPLANMALI  / sonra 128 eklenmeli 
                    // FP TOPLAMA
                    
                    INV_DCT10:begin   // 32
                        decode_durum <= durum; 
                        if(satir_sonuc1 < 64)begin
                            addr_ram_sonuc1 <= satir_sonuc1;
                            durum <= INV_DCT11;
                        end else begin
                            satir_sonuc1 <= 0;
                            en_topla <= 0;
                            // ram_toplam degeri bir ram e yazýlacak
                            durum <= INV_DCT14;
                        end
                    end
                    
                    INV_DCT11:begin // 33
                        decode_durum <= durum;
                        if(gec < 3)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            fp_topla_gir1 <= ram_toplam;
                            fp_topla_gir2 <= data_out_ram_sonuc1;
                            en_topla <= 1;
                            durum <= INV_DCT12;
                        end
                    end
                    
                    INV_DCT12:begin // 34
                        decode_durum <= durum;
                        if(gec < 16)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            fp_topla_ata <= fp_topla_cik;
                            en_topla <= 0;
                            durum <= INV_DCT13; 
                        end
                    end 
                     
                    INV_DCT13:begin // 35
                        decode_durum <= durum;
                        ram_toplam <= fp_topla_ata; // bu calýþmazsa baþka deðiþken kullan ram degerlerini toplamak için
                        satir_sonuc1 <= satir_sonuc1 + 1;
                        durum <= INV_DCT10;
                    end 
                    
                    INV_DCT14:begin // 36
                        decode_durum <= durum;
                    // ram_toplam sonuc2 ramine yazýlacak
                        if(satir_sonuc2 < 64)begin
                            toplam1_sonucu_ram[satir_sonuc2] <= ram_toplam;
                            satir_sonuc2 <= satir_sonuc2 + 1;
                            // 2. cos degerlerine
                            ram_toplam <= 0;
                            durum <= INV_DCT4;
                        end else begin
                        // 128 ile toplamaya
                        satir_sonuc2 <= 0;
                        durum <= INV_DCT15;
                        end
                    end  
                    
                    INV_DCT15:begin  // 37
                        cos_rom_say <= 0;
                        satir_cos <= 0;
                        decode_durum <= durum;   
                        if(satir_sonuc2 < 64)begin
                            fp_topla_gir1 <= 32'b01000011000000000000000000000000;   // 128 ile toplar   
                            fp_topla_gir2 <= toplam1_sonucu_ram[satir_sonuc2];   
                            en_topla <= 1;
                            durum <= INV_DCT16;                          
                        end else begin 
                            // integer donusume
                            satir_sonuc2 <= 0; 
                            en_topla <= 0;
                            durum <= INV_DCT18;
                        end
                    end 
                    
                    INV_DCT16:begin // 38
                        decode_durum <= durum;
                        if(gec < 16)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            fp_topla_ata <= fp_topla_cik;
                            en_topla <= 0;
                            durum <= INV_DCT17; 
                        end
                    end 
                    
                    INV_DCT17:begin // 39
                        decode_durum <= durum;
                        toplam2_sonucu_ram[satir_sonuc2] <= fp_topla_ata;
                        satir_sonuc2 <= satir_sonuc2 + 1;
                        durum <= INV_DCT15;
                    end 
                    
                    INV_DCT18:begin // 40
                        decode_durum <= durum;
                        // INTEGER A DONUSUM 
                        if(sonuc_satir < 64)begin
                            fp_int_in <= toplam2_sonucu_ram[sonuc_satir];
                            en_fp_int <= 1;
                            durum = INV_DCT19;
                        end else begin
                            en_fp_int <= 0;
                            sonuc_satir <= 0;
                            en_ram_sonuc <= 1;         
                            we_ram_sonuc <= 0; // okuma // modül pasif
                            addr_ram_sonuc <= 0;
                            durum <= VERI_GONDER1; // 45 OKUMA
                        end
                    end
                    
                    INV_DCT19:begin // 41
                        decode_durum <= durum;
                        if(gec < 9)begin
                            gec = gec + 1;
                        end else begin
                            gec <= 0;
                            fp_int_ata <= fp_int_out;
                            en_fp_int <= 0;
                            en_ram_sonuc <= 1;
                            we_ram_sonuc <= 1; // yazma
                            addr_ram_sonuc <= sonuc_satir;
                            durum <= INV_DCT20;
                        end
                    end
                    
                    INV_DCT20:begin // 42
                        decode_durum <= durum;
                        data_in_ram_sonuc <= fp_int_ata;
                        sonuc_ram[sonuc_satir] <= fp_int_ata;
                        sonuc_satir <= sonuc_satir + 1;
                        durum <= INV_DCT18;
                    end
                    /*
                    // RAMDEKI VERILER OKUMA
                    45:begin
                        decode_durum <= durum;
                        addr_ram_sonuc <= satir_oku; 
                        decoded<= data_out_ram_sonuc;;
                    end 
                    */
                    VERI_GONDER1:begin // 43
                        decode_durum <= durum;
                        if(sonuc_satir < 65)begin 
                            en_ram_sonuc <= 1;
                            we_ram_sonuc <= 0; // okuma
                            addr_ram_sonuc <= sonuc_satir; 
                            // sonuc_ram[sonuc_satir] <= 8'bxxxxxxxx; // sýfýrlamak icin verileri 
                            durum <= VERI_GONDER2;
                        end else begin
                            sonuc_satir <= 0;
                            decode_et <= 0; 
                            cikti <= 0;
                            durum <= YENI_VERI_KONTROL3;
                        end
                    end 
                    
                    VERI_GONDER2:begin // 44
                        decode_durum <= durum;
                        decoded <= data_out_ram_sonuc;
                        cikti <= sonuc_satir;
                        sonuc_satir <= sonuc_satir + 1; 
                        decode_et <= 1;
                        durum <= VERI_GONDER1;  
                    end
                    
                    
                    YENI_VERI_KONTROL3:begin  // 46
                        decode_durum <= durum;
                        if(say < say_kontrol)begin
                            durum <= INV_HUFFMAN_RUNLENGTH2;  // DC kontrole 
                        end else begin // yeni data gelmeli
                           data_gonderme_ok <= 1; 
                           sag_sol_kaydir <= say - say_kontrol; 
                           buffer <= encoded_resim[63:32];  
                           sonraki_durum <= INV_HUFFMAN_RUNLENGTH20; // veri cekildikten sonra bir sonraki duruma gececek 
                           durum <= DIGER_VERILERI_CEK;
                        end
                    end
                    
                    INV_HUFFMAN_RUNLENGTH20:begin // 47
                        decode_durum <= durum;
                        say <= say - 32;
                        buffer <= buffer >> sag_sol_kaydir; // tekrar sola kaydýrýlýr 
                        data_gonderme_ok <= 0;
                        durum <= INV_HUFFMAN_RUNLENGTH21;
                    end
                    
                    INV_HUFFMAN_RUNLENGTH21:begin // 48
                        decode_durum <= durum;
                        encoded_resim <= {buffer,data};
                        durum <= INV_HUFFMAN_RUNLENGTH22;
                    end 
                    
                    INV_HUFFMAN_RUNLENGTH22:begin // 49
                        decode_durum <= durum;
                        encoded_resim <= encoded_resim << sag_sol_kaydir; // tekrar sola kaydýrýlýr 
                        durum <= INV_HUFFMAN_RUNLENGTH2; // DC kontrole 
                    end 
                    
                endcase 
            end else begin
            end
        end
        
    end
    
    
    // INVERSE HUFFMAN + RUNLENGHT
    
    inverse_AC inverse_ac(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_ac),
        .encoded_veri_i(encoded_veri_i_ac),
        .ac_deger_o(ac_deger_ac),
        .asil_deger_o(asil_deger_ac),
        .encoded_veri_o(encoded_veri_o_ac),
        .sagdaki_sifir_sayisi_o(sagdaki_sifir_sayisi_ac),
        .ondeki_sifir_sayisi_o(ondeki_sifir_sayisi_ac),
        .eob_kontrol_o(eob_kontrol_ac)
    );
    
   
    inverse_DC inverse_dc(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_dc),
        .encoded_veri_i(encoded_veri_i_dc),
        .dc_deger_o(dc_deger_dc),
        .asil_deger_o(asil_deger_dc),
        .encoded_veri_o(encoded_veri_o_dc),
        .sagdaki_sifir_sayisi_o(sagdaki_sifir_sayisi_dc)
    );
    
    
    
    // INVERSE KUANTALAMA + DCT 
        // 11 bitlik ram / 8x8= 64 satýr
    ram#(.V(11),.S(64),.A(6)) ram1(
        .clk_i(clk_i),
        .en_i(en_ram1),
        .we_i(we_ram1),
        .address_i(addr_ram1),
        .data_i(data_in_ram1),
        .data_o(data_out_ram1)
    );
    
    kuantalama_rom rom_k(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .rd_i(rd_rom_k),
        .addr_i(addr_rom_k),
        .data_o(data_out_rom_k)
    );
    
    // integer -> fp ye donusum icin
    int_fp_donusum int_fp_donus(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_int_fp),
        .g1_i(int_fp_in),
        .c_o(int_fp_out)
    );
    
    // 32 bitlik floating point ram / 8x8= 64 satýr
    ram#(.V(32),.S(64),.A(6)) ramfp(
        .clk_i(clk_i),
        .en_i(en_ram_fp),
        .we_i(we_ram_fp),
        .address_i(addr_ram_fp),
        .data_i(data_in_ram_fp),
        .data_o(data_out_ram_fp)
    );
    
    // floating point çarpma 
    fp_carpma fp_carp(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_carp),
        .x1_i(fp_carp_gir1),
        .x2_i(fp_carp_gir2),
        .sonuc_o(fp_carp_cik)
        );
    
    
    // cos ayrýk degerler icin rom
    cos_rom cos_deger_rom(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .rd_i(rd_rom_cos),
        .addr_i(addr_rom_cos),
        .data_o(data_out_rom_cos)
    );
    
    // fp carpým sonucu1 icin // veri * cos matrisi * t matrisi
    ram#(.V(32),.S(64),.A(6)) ramfp_sonuc1(
        .clk_i(clk_i),
        .en_i(en_ram_sonuc1),
        .we_i(we_ram_sonuc1),
        .address_i(addr_ram_sonuc1),
        .data_i(data_in_ram_sonuc1),
        .data_o(data_out_ram_sonuc1)
    );
    
    
    // T matrisi degerler icin rom
    T_matris_rom T_deger_rom(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .rd_i(rd_rom_t),
        .addr_i(addr_rom_t),
        .data_o(data_out_rom_t)
    );
    
  
    
    // floating point toplama 
    fp_toplama#(.b(32),.e(8),.m(23)) fp_topla(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_topla),
        .g1_i(fp_topla_gir1),
        .g2_i(fp_topla_gir2),
        .toplam_o(fp_topla_cik)
        );
        
    
    
    // fp -> integer a donusum icin
    fp_int_donusum fp_int_donus(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_fp_int),
        .g1_i(fp_int_in),
        .c_o(fp_int_out)
    );
    
    // 8 bitlik ram / 8x8= 64 satýr
    ram#(.V(8),.S(64),.A(6)) ram_sonuc(
        .clk_i(clk_i),
        .en_i(en_ram_sonuc),
        .we_i(we_ram_sonuc),
        .address_i(addr_ram_sonuc),
        .data_i(data_in_ram_sonuc),
        .data_o(data_out_ram_sonuc)
    );
    
    
endmodule
