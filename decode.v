`timescale 1ns / 1ps



module decode(
input clk_i,rst_i,en_i,
    input [31:0] encoded_i,
    output sonuc_o,
    output [7:0] decoded_o,
    output decode_et_o
//    output [7:0] durum_oku_o,
//    output [63:0] encoded_resim_o,
//    output [10:0] asil_deger_dc_al_o
    );
    
    integer sayac = 0, gec = 0;
    reg [7:0] durum = 0;
//    assign durum_oku_o = durum;
    reg data_gonderme_ok = 1;
    assign sonuc_o = data_gonderme_ok;
    
    integer indis_say = 0;
    reg [7:0] decoded;
    reg decode_et;
    assign decode_et_o = decode_et;
    assign decoded_o = decoded;
    
    reg [5:0] sonraki_durum = 1;
    
    // ENCODED VERI ICIN RAM
    integer encoded_satir = 0;
    reg [9:0] addr_encoded_veri; // ramin satır sayısı bilinmiyor 
    reg we_encoded , en_encoded;
    reg [31:0] in_encoded;
    wire [31:0] out_encoded;
    
    // VERI CEKME ICIN DEGISKENLER
    reg [31:0] buffer, data, ara_deger;
    reg [63:0] encoded_resim;
//    assign encoded_resim_o = encoded_resim;
    integer cnt = 0; // ne kadar veri kullandık
    integer say = 0; // 32 bit bitti mi? 
    integer say_kontrol = 32;
    integer sag_sol_kaydir = 0;
    integer eob_arttir = 0; // 1200 tane olunca bütün işlemler bitecek 
    reg [31:0] encoded_resim_deger; // isleme sokulan
    
    // inverse huffman çıktılarını saklamak için
    reg [10:0] RAM_inv_zigzag [63:0]; // 11 bitlik 64 satırlık ram //BU INVERSE KUANTALAMAYA GIDECEK
    integer ind = 0;
    reg [10:0] RAM_dc_ac [63:0]; // 11 bitlik 64 satırlık ram
    
    integer ram_satir = 0;
    integer ram_satir_ekle = 0; // ac asil sayidan önce gelecek 0 sayisi kontrolü / ram_satir üzerine eklenecek
    
    // DC ICIN
    // DC
    reg en_dc;
    reg [31:0] encoded_veri_i_dc;  
    wire [31:0] encoded_veri_o_dc;                                                                       
    wire [10:0] dc_deger_dc,ac_deger_ac;      // rame yazilmayacak                                                                      
    wire [10:0] asil_deger_dc;                                                                          
    wire [4:0] sagdaki_sifir_sayisi_dc; // max 20 olabilir 
    
    reg [31:0] encoded_veri_o_dc_ata;                                                                       
    // reg [10:0] dc_deger_dc_ata;          // rame yazilmayacak                                                                  
    reg signed [10:0] asil_deger_dc_ata;       
    reg signed [10:0] asil_deger_dc_al = 0;  
                                                                     
    reg [4:0] sagdaki_sifir_sayisi_dc_ata; // max 20 olabilir 
    
    
    // AC ICIN 
    // AC
    reg en_ac;
    reg [31:0] encoded_veri_i_ac;  
    wire [31:0] encoded_veri_o_ac;                                                                      
//    wire [15:0] ac_deger_ac;   // rame yazilmayacak                                                                  
    wire [10:0] asil_deger_ac;      
    wire [4:0] sagdaki_sifir_sayisi_ac; // max 20 olabilir                                              
    wire [4:0] ondeki_sifir_sayisi_ac; // asil sayi onundeki 0 sayisi / ramde asil sayi onune yazilacak 
    wire eob_kontrol_ac; // bu 1 olursa ilk matris bitmiş olur                                           
    
    reg [31:0] encoded_veri_o_ac_ata;                                                                                           
    reg [10:0] asil_deger_ac_ata;                                                                          
    reg [4:0] sagdaki_sifir_sayisi_ac_ata; // max 20 olabilir                                              
    reg [4:0] ondeki_sifir_sayisi_ac_ata; // asil sayi onundeki 0 sayisi / ramde asil sayi onune yazilacak 
    reg eob_kontrol_ac_ata; // bu 1 olursa ilk matris bitmiş olur 
    
    
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
    integer satir_k = 0; // kuantalam romu satırlarını gezmek icin
    
    reg signed [31:0] kuantalama_sonucu_ram[0:63]; // kuantalam_sonucu 32 bitlik ram
    reg signed [31:0] kuantalama_sonucu_ram_oku;
    reg signed [10:0] data_out_ram1_deger;
    reg signed [10:0] data_out_rom_k_deger;
    reg signed [21:0] int_carp_k;
    reg signed [21:0] int_carp;
    reg signed [31:0] carp_oku;
    integer z = 0; // 2ye tumleme icin
    
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
    
    // floatin point carpma / int_fp_donus ile cos ayrık degerleri ile fp carpım
    reg en_carp;
    reg [31:0] fp_carp_gir1, fp_carp_gir2;
    wire [31:0] fp_carp_cik;
    reg [31:0] fp_carp_ata;
    
    // cos ayrık deger rom 
    reg rd_rom_cos;
    reg [11:0] addr_rom_cos;
    wire signed [31:0] data_out_rom_cos;
    integer satir_cos = 0; // cos romu satırlarını gezmek icin
    integer cos_rom_say = 0; // 4096 olur max
    
    // T matris deger rom 
    reg rd_rom_t;
    reg [5:0] addr_rom_t;
    wire signed [31:0] data_out_rom_t;
    integer satir_t = 0; // T matris romu satırlarını gezmek icin
    
    // fp carpım sonuc1 icin
    reg we_ram_sonuc1, en_ram_sonuc1;
    reg [5:0] addr_ram_sonuc1;
    reg [31:0] data_in_ram_sonuc1;
    wire [31:0] data_out_ram_sonuc1;
    integer satir_sonuc1 = 0;
    
    // fp toplam icin
    reg [31:0] toplam1_sonucu_ram[0:63]; // ram_toplam sonucu / 128 eklemeden önce 
    reg [31:0] toplam2_sonucu_ram[0:63]; // 128 eklenmiş
    integer satir_sonuc2 = 0;
    
    // floatin point toplama 
    reg en_topla;
    reg [31:0] fp_topla_gir1, fp_topla_gir2;
    wire [31:0] fp_topla_cik;
    reg [31:0] fp_topla_ata;
    
    reg [31:0] ram_toplam = 0; // ram satırlarını toplama
   
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
    
    
    
    
    reg bit = 0;
    reg islemler_bitti = 0;
    
//    assign asil_deger_dc_al_o = asil_deger_dc_al;
    always@(posedge clk_i)begin
        if(rst_i)begin
        end else begin
            if(en_i == 1)begin
                sayac = sayac + 1;
                case(durum) 
                    0:begin
                        // TOP MODULDEN VERIYI OKUMAK ICIN HEP BU MODLULE GELECEK
                        if(data_gonderme_ok == 1)begin
                           durum <= 100;
                        end else begin
                            bit = 1;
                        end
                    end
                    
                    100:begin
                        if(indis_say < 1)begin // ilk veriyi alip buffer a atar / sonraki verleri dataya 
                            durum <= 101;
                        end else begin
                            durum <= 102;
                        end
                    end 
                    
                    101:begin
                        if(gec < 1)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0; 
                            buffer <= encoded_i; // buffer bir kez ekilecek 32'b10000111110110111010110100101110; // 32'b10000111110110111010110100101110; //
                            indis_say <= indis_say + 1;
                            durum <= 0;
                        end
                    end 
                    102:begin
                        if(gec < 4)begin // ikinci veri için gec < 4 yap // bundan sonrakiler içi gec < 3 yap /AYR
                            gec <= gec + 1;
                            data <= encoded_i;  // her cekilmede veri dataya aktarılacak 32'b01000000000110010001010010100101; //32'b01000000000110010001010010100101; //
                        end else begin
                            gec <= 0; 
                            indis_say <= indis_say + 1;
                            data_gonderme_ok <= 0;
                            durum <= sonraki_durum;
                        end
                    end
                    // DIGER VERILERI ALMAK ICIN
                    63:begin
                        if(data_gonderme_ok == 1)begin                            
                            durum <= 64;
                        end else begin
                            bit <= 0;
                        end
                    end 
                   
                    64:begin
                        if(gec < 2)begin // ikinci veri için gec < 4 yap // bundan sonrakiler içi gec < 3 yap /AYR
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            data <= encoded_i;  // her cekilmede veri dataya aktarılacak
                            indis_say <= indis_say + 1;
                            data_gonderme_ok <= 0;
                            durum <= sonraki_durum;
                        end
                    end 
                    
                    1:begin // 4
                        encoded_resim <= {buffer,data};
                        durum <= 2;
                    end
                    
                    2:begin
                        encoded_resim_deger <= encoded_resim[63:32];
                        durum <= 3;                       
                    end
                    
                    // DC KONTROL
                    3:begin
                        // DC yazma 
                        encoded_veri_i_dc <= encoded_resim_deger;
                        en_dc <= 1;
                        durum <= 4; // DC deger kontrolü
                    end
                    
                    4:begin
                        // DC okuma
                        if(gec < 250)begin 
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            en_dc <= 0;
                            encoded_veri_o_dc_ata <= encoded_veri_o_dc; 
                            asil_deger_dc_ata <= asil_deger_dc;
                            sagdaki_sifir_sayisi_dc_ata <= sagdaki_sifir_sayisi_dc;
                            durum <= 5;
                        end
                    end
                    
                    5:begin
                        asil_deger_dc_al <= asil_deger_dc_al + asil_deger_dc_ata;
                        cnt <= sagdaki_sifir_sayisi_dc_ata;
                        durum <= 6;
                    end
                    
                    6:begin
                        // array e yaz // RAM_dc_ac => bir array
                        RAM_dc_ac[0] <= asil_deger_dc_al ; // bir sonraki dc değeri bir öncekiyle toplamı şeklinde olacak
                        ram_satir <= ram_satir + 1; // ilk satir doldu 
                        say <= say + cnt;
                        encoded_resim <= encoded_resim << cnt;
                        durum <= 7;
                    end
                   
                    7:begin
                        if(say < say_kontrol)begin
                            durum <= 9;  // AC kontrole 
                        end else begin // yeni data gelmeli
                           data_gonderme_ok <= 1;
                           sag_sol_kaydir <= say - say_kontrol; 
                           buffer <= encoded_resim[63:32];  // shift right islemine sokulur
                           sonraki_durum <= 8; // veri cekildikten sonra bir sonraki duruma gececek 
                           durum <= 63;
                        end
                    end
                    
                    8:begin
                        say <= say - 32;
                        buffer <= buffer >> sag_sol_kaydir; // tekrar sola kaydırılır 
                        data_gonderme_ok <= 0;
                        durum <= 52;
                        
                    end
                    
                    52:begin
                        encoded_resim <= {buffer,data};
                        durum <= 53;
                    end 
                  
                    53:begin
                        encoded_resim <= encoded_resim << sag_sol_kaydir; // tekrar sola kaydırılır 
                        durum <= 9; // AC kontrole 
                    end
                    
                    9:begin
                        encoded_resim_deger <= encoded_resim[63:32];
                        durum <= 54;
                    end
                    54:begin
                        encoded_veri_i_ac <= encoded_resim_deger;
                        en_ac <= 1;
                        durum <= 10;
                    end 
                    
                    // AC KONTROL
                    10:begin // 14
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
                            durum <= 11;
                        end
                    end
                    
                    11:begin
                        if(eob_kontrol_ac_ata == 1)begin
                            eob_arttir <= eob_arttir + 1; // 1200 olunca tüm işlemler biter
                            ram_satir <= ram_satir + ram_satir_ekle; // ondeki_sifir_sayisi_ac_ata+1 kadar  satir doldu  // daha sonra kalan satırları 0 la doldur 
                            durum <= 15;
                            
                        end else begin
                            durum <= 60;
                        end
                    end
                    
                    60:begin   
                        if(ondeki_sifir_sayisi_ac_ata == 16)begin // ram_satir = 3 / ram_satir = 18
                            durum <= 104;
                         end else begin
                            durum <= 105;
                        end 
                    end 
                    
                    104:begin
                        if(ram_satir_ekle < ondeki_sifir_sayisi_ac_ata) begin
                            RAM_dc_ac[ram_satir + ram_satir_ekle] <= 11'b00000000000; // ilgili satıra 0 yazılır
                            ram_satir_ekle <= ram_satir_ekle + 1;
                        end else begin
                            cnt <= sagdaki_sifir_sayisi_ac_ata;
                            durum <= 12;
                        end
                    end 
                    105:begin
                        // devam
                        // ram e yaz  // ondeki_sifir_sayisi_ac_ata = 3  
                        if(ram_satir_ekle < ondeki_sifir_sayisi_ac_ata) begin
                            RAM_dc_ac[ram_satir+ram_satir_ekle] <= 11'b00000000000; // ilgili satıra 0 yazılır
                            ram_satir_ekle <= ram_satir_ekle + 1;
                        end else begin
                            RAM_dc_ac[ram_satir+ram_satir_ekle] <= asil_deger_ac_ata;
                            ram_satir_ekle <= ram_satir_ekle + 1;
                            cnt <= sagdaki_sifir_sayisi_ac_ata;
                            durum <= 12;
                        end 
                    end
                    12:begin
                        ram_satir <= ram_satir + ram_satir_ekle; // ondeki_sifir_sayisi_ac_ata+1 kadar  satir doldu 
                        say <= say + cnt;
                        encoded_resim <= encoded_resim << cnt;
                        durum <= 13;
                    end
                    
                    13:begin
                        ram_satir_ekle = 0;
                        if(say < say_kontrol)begin
                            durum <= 9;  // AC kontrole 
                        end else begin // yeni data gelmeli
                           data_gonderme_ok <= 1; 
                           sag_sol_kaydir <= say - say_kontrol; 
                           buffer <= encoded_resim[63:32];  
                           sonraki_durum <= 14; // veri cekildikten sonra bir sonraki duruma gececek
                           durum <=  63;
                        end
                       
                    end
                    // HER CLOCKTA KAYDIRIR , KAYDIRMA DEGERİ KADAR / KONTROL ET DİĞER KISIMLARDA 
                    14:begin
                        say <= say - 32;
                        buffer <= buffer >> sag_sol_kaydir; // saga kaydırılır 
                        data_gonderme_ok <= 0;
                        durum <= 55;
                    end
                    
                    55:begin
                        encoded_resim <= {buffer,data};
                        durum <= 56;
                    end 
                    56:begin    
                        encoded_resim <= encoded_resim << sag_sol_kaydir; // tekrar sola kaydırılır 
                        durum <= 9; // AC kontrole 
                    end 
                    
                    15:begin
                        eob_kontrol_ac_ata <= 0;
                        if(eob_arttir <= 1200)begin
                            durum <= 107;
                        end else begin
                            // bütün islemler biter
                            islemler_bitti <= 1;
                        end
                    end
                    
                    107:begin
                        // kalan satırlar sıfırlanır 
                        if(ram_satir < 64)begin
                            RAM_dc_ac[ram_satir] <= 11'b00000000000;
                            ram_satir <= ram_satir + 1;
                        end else begin
                            ram_satir <= 0;
                            cnt <= sagdaki_sifir_sayisi_ac_ata; // 4 tane daha kaymış olcak eob için 
                            durum <= 16;
                        end
                    end
                    16:begin
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
                            
                        encoded_resim <= encoded_resim << cnt; // 4 tane daha kaymış olcak eob için
                        say <= say + cnt;
                        // bu RAM_inv_zigzag arrayi dct işlemine sokulacak
                        we_ram1 <= 1;
                        en_ram1 <= 1;
                        durum <= 17;
                    end
                    
                    // INVERSE KUANTALAM + DCT
                    17:begin
                        // fifodakileri (inverse zigzagtan gelenleri) ram al
                        if(ind<64)begin 
                            addr_ram1 <= ind;
                            durum <= 18;
                        end else begin
                            cnt <= 0; 
                            ind <= 0;
                            en_ram1 <= 1;
                            we_ram1 <= 0; // okuma yapıcak
                            rd_rom_k <= 1;
                            durum <= 19;  
                        end
                    end 
                    
                    18:begin
                        data_in_ram1 <= RAM_inv_zigzag[ind]; //yazacağı veri zaten 11 bit direkt tek satıra aktanır
                        ind <= ind+1;  // bir sonraki clockta artacak
                        durum <= 17;
                    end 
                    
                    // INVERSE KUANTALAMA
                    19:begin
                        if(satir_k < 64)begin
                            addr_ram1 <= satir_k;
                            addr_rom_k <= satir_k; 
                            durum <= 20; // integer carpmaya
                        end else begin
                            satir_k <= 0; 
                            durum <= 23; // integer carpma bitti / INVERSE DCT ye
                        end
                    end 
                    20:begin
                        if(gec<4)begin
                            gec <= gec + 1;
                            // ram1 ve kuantalama romundan degerleri aldik
                            data_out_ram1_deger <= data_out_ram1;
                            data_out_rom_k_deger <= data_out_rom_k;
                        end else begin
                            gec <= 0;
                            durum <= 21;
                         end
                    end 
                    
                    21:begin
                        if(gec < 1)begin
                            gec <= gec + 1;
                            int_carp_k <= data_out_ram1_deger * data_out_rom_k_deger;
                        end else begin
                            gec <= 0;
                            durum <= 22;
                        end
                    end 
                    
                   
                    
                    22:begin
                        if(int_carp_k[21] == 1'b1)begin
                            // int_carp <= ~int_carp_k + 1'b1;
                            carp_oku <= {10'b1111111111,int_carp_k};
                            durum <= 108;
                        end else begin
                            carp_oku <= {10'b0000000000,int_carp_k};
                            durum <= 108;
                        end 
                    end
                   
                    108:begin
                        kuantalama_sonucu_ram[satir_k] <= carp_oku;
                        satir_k <= satir_k + 1;
                        durum <= 19;
                    end 
                    // ikiye tumleme bitti
                    
                    
                    23:begin
                        if(satir_fp < 64) begin
                            en_int_fp <= 1;
                            int_fp_in <= kuantalama_sonucu_ram[satir_fp];
                            durum <= 24;
                        end else begin
                            en_int_fp <= 0;
                            we_ram_fp <= 0;
                            en_ram_fp <= 0; 
                            satir_fp <= 0;
                            durum <= 26; 
                        end
                    end
                    
                    24:begin    
                        if(gec < 55) begin // 42 saykıl
                            gec = gec + 1;
                        end else begin
                            int_fp_deger <= int_fp_out;
                            en_int_fp <= 0;
                            we_ram_fp <= 1;
                            en_ram_fp <= 1;
                            addr_ram_fp <= satir_fp;
                            gec <= 0;
                            durum <= 25;
                        end
                    end 
                    25:begin 
                        data_in_ram_fp <= int_fp_deger;
                        satir_fp <= satir_fp + 1;
                        durum <= 23; 
                    end 
                    
                    // FP CARPMA / COS ROM
                    // floatin point carpma / int_fp_donus ile cos ayrık degerleri ile fp carpım
                    
                    26:begin
                        if(cos_rom_say < 4097)begin // 4097
                            durum <= 109;
                        end else begin
                            satir_sonuc2 <= 0;
                            durum <= 37;
                        end
                    end 
                    
                    109:begin
                        if(satir_cos < 64)begin
                            en_ram_fp <= 1; 
                            we_ram_fp <= 0; // okuma yapacak
                            addr_ram_fp <= satir_cos;
                            rd_rom_cos <= 1;
                            addr_rom_cos <= cos_rom_say;// bu 64ten fazla
                            rd_rom_t <= 1;
                            addr_rom_t <= satir_cos;
                            durum <= 27;
                        end else begin
                            satir_cos <= 0;
                            en_ram_sonuc1 <= 1;
                            we_ram_sonuc1 <= 0; // okuma
                            en_carp <= 0;
                            durum <= 32; // sonuc1 ram satırları toplanır
                        end
                    end
                    27:begin
                        if(gec<4)begin
                            gec <= gec + 1;
                        end else begin
                            gec = 0;
                            fp_carp_gir1 <= data_out_ram_fp;
                            fp_carp_gir2 <= data_out_rom_cos;
                            en_carp <= 1;
                            durum <= 28;
                        end
                    end 
                    
                    28:begin
                        if(gec < 85)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            fp_carp_ata <= fp_carp_cik;
                            en_carp <= 0;
                            durum <= 29;
                        end
                    end
                    
                    // FP CARPMA / T ROM
                    29:begin
                        // t matrisi ile carpma
                        if(gec < 2)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            fp_carp_gir1 <= fp_carp_ata;
                            fp_carp_gir2 <= data_out_rom_t;
                            en_carp <= 1;
                            durum <= 30;
                        end
                    end
                    
                    30:begin
                        if(gec < 80)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            fp_carp_ata <= fp_carp_cik;
                            en_carp <= 0;
                            en_ram_sonuc1 <= 1;
                            we_ram_sonuc1 <= 1; // yazma
                            addr_ram_sonuc1 <= satir_cos;
                            durum <= 31; // 31 DUZENLE BUNDAN SONRASINI 
                        end
                    end 
                    
                    31:begin
                        data_in_ram_sonuc1 <= fp_carp_ata;
                        satir_cos <= satir_cos + 1;
                        cos_rom_say <= cos_rom_say + 1;
                        durum <= 26;
                    end 
                    
                    // BUTUN RAM SATIRLARI TOPLANMALI  / sonra 128 eklenmeli 
                    // FP TOPLAMA
                    
                    32:begin   // 32 
                        if(satir_sonuc1 < 64)begin
                            addr_ram_sonuc1 <= satir_sonuc1;
                            durum <= 33;
                        end else begin
                            satir_sonuc1 <= 0;
                            en_topla <= 0;
                            // ram_toplam degeri bir ram e yazılacak
                            durum <= 36;
                        end
                    end
                    
                    33:begin
                        if(gec < 3)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            fp_topla_gir1 <= ram_toplam;
                            fp_topla_gir2 <= data_out_ram_sonuc1;
                            en_topla <= 1;
                            durum <= 34;
                        end
                    end
                    
                    34:begin
                        if(gec < 16)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            fp_topla_ata <= fp_topla_cik;
                            en_topla <= 0;
                            durum <=  35; 
                        end
                    end 
                    
                    35:begin
                        ram_toplam <= fp_topla_ata; 
                        satir_sonuc1 <= satir_sonuc1 + 1;
                        durum <= 32;
                    end 
                    
                    36:begin
                    // ram_toplam sonuc2 ramine yazılacak
                        if(satir_sonuc2 < 64)begin
                            toplam1_sonucu_ram[satir_sonuc2] <= ram_toplam;
                            satir_sonuc2 <= satir_sonuc2 + 1;
                            // 2. cos degerlerine
                            ram_toplam <= 0;
                            durum <= 26;
                        end else begin
                        // 128 ile toplamaya
                        satir_sonuc2 <= 0;
                        durum <= 37;
                        end
                    end  
                    
                    37:begin  
                        cos_rom_say <= 0;
                        satir_cos <= 0;
                        if(satir_sonuc2 < 64)begin
                            fp_topla_gir1 <= 32'b01000011000000000000000000000000;   // 128 ile toplar   
                            fp_topla_gir2 <= toplam1_sonucu_ram[satir_sonuc2];   
                            en_topla <= 1;
                            durum <= 38;                          
                        end else begin 
                            // integer donusume
                            satir_sonuc2 <= 0; 
                            en_topla <= 0;
                            durum <= 40;
                        end
                    end 
                    
                    38:begin
                        if(gec < 16)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            fp_topla_ata <= fp_topla_cik;
                            en_topla <= 0;
                            durum <= 39; 
                        end
                    end 
                    
                    39:begin
                        
                        if(fp_topla_ata > 32'b01000011011111110000000000000000)begin
                             toplam2_sonucu_ram[satir_sonuc2] <= 32'b01000011011111110000000000000000;
                             satir_sonuc2 <= satir_sonuc2 + 1;
                             durum <= 37;
                        end 
                        else if(fp_topla_ata < 32'b0000000000000000000000000000000) begin
                            toplam2_sonucu_ram[satir_sonuc2] <= 32'b0000000000000000000000000000000;
                            satir_sonuc2 <= satir_sonuc2 + 1;
                            durum <= 37;
                        end else begin
                          toplam2_sonucu_ram[satir_sonuc2] <= fp_topla_ata;
                          satir_sonuc2 <= satir_sonuc2 + 1;
                          durum <= 37;
                        end
                    end 
                    
                    40:begin 
                        // INTEGER A DONUSUM 
                        if(sonuc_satir < 64)begin
                            fp_int_in <= toplam2_sonucu_ram[sonuc_satir];
                            en_fp_int <= 1;
                            durum = 41;
                        end else begin
                            en_fp_int <= 0;
                            sonuc_satir <= 0;
                            en_ram_sonuc <= 1;         
                            we_ram_sonuc <= 0; // okuma // modül pasif
                            addr_ram_sonuc <= 0;
                            durum <= 43; // 45 OKUMA
                        end
                    end
                    
                    41:begin
                        if(gec < 15)begin
                            gec = gec + 1;
                        end else begin
                            gec <= 0;
                            fp_int_ata <= fp_int_out[7:0]; // DEGISTI
                            en_fp_int <= 0;
                            en_ram_sonuc <= 1;
                            we_ram_sonuc <= 1; // yazma
                            addr_ram_sonuc <= sonuc_satir;
                            durum <= 42;
                        end
                    end
                    
                    42:begin
                        data_in_ram_sonuc <= fp_int_ata;
                        //sonuc_ram[sonuc_satir] <= fp_int_ata;
                        sonuc_satir <= sonuc_satir + 1;
                        durum <= 40;
                    end
                    /*
                    // RAMDEKI VERILER OKUMA
                    45:begin
                        decode_durum <= durum;
                        addr_ram_sonuc <= satir_oku; 
                        decoded<= data_out_ram_sonuc;;
                    end 
                    */
                    43:begin
                        if(sonuc_satir < 65)begin 
                            en_ram_sonuc <= 1;
                            we_ram_sonuc <= 0; // okuma
                            addr_ram_sonuc <= sonuc_satir; 
                            // sonuc_ram[sonuc_satir] <= 8'bxxxxxxxx; // sıfırlamak icin verileri 
                            durum <= 44;
                        end else begin
                            sonuc_satir <= 0;
                            decode_et <= 0; // BUNU AŞAĞIYA AL YA DA GECİKME VER(64'e eşit ise)
                            durum <= 46;
                        end
                    end 
                    
                    44:begin
                        if(gec < 1)begin
                            gec <= gec +1;
                            decoded <= data_out_ram_sonuc;
                            //decoded <= sonuc_ram[sonuc_satir];
                        end else begin
                            gec <= 0;
                            sonuc_satir <= sonuc_satir + 1; 
                            decode_et <= 1;
                            durum <= 43;  // 45;
                        end
                    end
                    
                    
                    46:begin 
                        if(say < say_kontrol)begin
                            durum <= 2;  // DC kontrole 
                        end else begin // yeni data gelmeli
                           data_gonderme_ok <= 1; 
                           sag_sol_kaydir <= say - say_kontrol; 
                           buffer <= encoded_resim[63:32];  
                           sonraki_durum <= 47; // veri cekildikten sonra bir sonraki duruma gececek 
                           durum <= 63;
                        end
                    end
                    
                    47:begin
                        say <= say - 32;
                        buffer <= buffer >> sag_sol_kaydir; // tekrar sola kaydırılır 
                        data_gonderme_ok <= 0;
                        durum <= 48;
                    end
                    
                    48:begin
                        encoded_resim <= {buffer,data};
                        durum <= 49;
                    end 
                    
                    49:begin
                        encoded_resim <= encoded_resim << sag_sol_kaydir; // tekrar sola kaydırılır 
                        durum <= 2; // DC kontrole 
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
        // 11 bitlik ram / 8x8= 64 satır
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
    
    // 32 bitlik floating point ram / 8x8= 64 satır
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
    
    
    // cos ayrık degerler icin rom
    cos_rom cos_deger_rom(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .rd_i(rd_rom_cos),
        .addr_i(addr_rom_cos),
        .data_o(data_out_rom_cos)
    );
    
    // fp carpım sonucu1 icin // veri * cos matrisi * t matrisi
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
    
    // 8 bitlik ram / 8x8= 64 satır
    ram#(.V(8),.S(64),.A(6)) ram_sonuc(
        .clk_i(clk_i),
        .en_i(en_ram_sonuc),
        .we_i(we_ram_sonuc),
        .address_i(addr_ram_sonuc),
        .data_i(data_in_ram_sonuc),
        .data_o(data_out_ram_sonuc)
    );
    
    
endmodule
