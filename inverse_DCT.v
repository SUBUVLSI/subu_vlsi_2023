`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2023 20:28:36
// Design Name: 
// Module Name: inverse_DCT
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


module inverse_DCT(
    input clk_i,rst_i,en_i
    );
    
    
    reg signed [10:0] mem[0:63];
    
    // GENEL
    integer ind = 0, sayac = 0,gec = 0; // ind => tampondan çekmede kullanýlýr
    reg [5:0] durum = 0;
    
    // ram1 // 11 bitlik 
    reg we_ram1, en_ram1; 
    reg [5:0] addr_ram1;
    reg signed [10:0] data_in_ram1;
    wire signed [10:0] data_out_ram1;
    reg signed [10:0] data;
    
    
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
     
    reg signed [31:0] ram_sonuc_oku;
    
    initial begin
        //1.clk'ta çalýþacak. dosya okunacak
        //binary olarak kaydedecek resmi
        //veriler tamponda yani tamamý tek seferde alýndý
        $readmemb("D:\\vivado\\inverse_kuantalama_gir.txt",mem);  
    end
    
    always@(posedge clk_i)begin 
        if(rst_i)begin
        end else begin
            if(en_i == 1) begin
                sayac = sayac + 1;
                case(durum)
                    0:begin
                        if(sayac<=3)begin
                            we_ram1 <= 1;
                            en_ram1 <= 1;
                        end else begin
                            durum = 1;
                        end
                    end
                    
                    1:begin
                        // fifodakileri (inverse zigzagtan gelenleri) ram al
                        if(ind<64)begin 
                            addr_ram1 <= ind;
                            durum = 2;
                        end else begin
                            ind = 0;
                            en_ram1 <= 1;
                            we_ram1 <= 0; // okuma yapýcak
                            rd_rom_k <= 1;
                            durum=3;  // burda 5 ram1 okuma
                        end
                    end
                    
                    2:begin
                        data_in_ram1 <= mem[ind]; //yazacaðý veri zaten 11 bit direkt tek satýra aktanýr
                        ind <= ind+1;  // bir sonraki clockta artacak
                        durum = 1;
                    end
                    
                    // INVERSE KUANTALAMA
                    3:begin
                        if(satir_k < 64)begin
                            addr_ram1 <= satir_k;
                            addr_rom_k <= satir_k; 
                            durum = 4; // integer carpmaya
                        end else begin
                            satir_k = 0; 
                            durum = 7; // integer carpma bitti / INVERSE DCT ye
                        end
                    end
                    
                    4:begin
                        if(gec<4)begin
                            gec <= gec + 1;
                        end else begin
                            gec <= 0;
                            // ram1 ve kuantalam romundan degerleri aldik
                            data_out_ram1_deger = data_out_ram1;
                            data_out_rom_k_deger = data_out_rom_k;
                            durum = 5;
                         end
                    end
                    /*
                    5:begin
                        addr_ram1 <= ;
                        durum = 6;
                    end
                    
                    6:begin
                        data_out_ram1_deger <= data_out_ram1;
                    end
                    */
                    
                    5:begin
                        // rd_rom_k <= 0; // bunlar yukarýda açýlýyor ama burda aktif olmaay devam etsin
                        // we_ram1 <= 0;
                        // en_ram1 <= 0;
                        // signed olarak verileri integer carpacagýz ve bunu 32 bitlik bi kuantalama_sonucu_ram e yazýcaz tekrardan 
                        int_carp_k <= data_out_ram1_deger * data_out_rom_k_deger;
                        durum = 6;
                    end
                    6:begin
                        // kuantalama_sonucu_ram e yazma 
                        kuantalama_sonucu_ram[satir_k] <= int_carp_k;
                        satir_k <= satir_k + 1;
                        durum = 3;
                    end
                    
                    /*
                    7:begin
                        kuantalama_sonucu_ram_oku <= kuantalama_sonucu_ram[10];
                    end
                    */
                    
                    // INVERSE DCT 
                    // FP DONUSUM
                    // elimizdeki verileri floating pointe donusturmemiz lazým
                    7:begin
                        if(satir_fp < 64) begin
                            en_int_fp <= 1;
                            int_fp_in <= kuantalama_sonucu_ram[satir_fp];
                            durum = 8;
                        end else begin
                            we_ram_fp <= 0;
                            en_ram_fp <= 0; 
                            satir_fp = 0;
                            durum = 10; 
                        end
                        
                    end
                    
                    8:begin
                        if(gec < 45) begin // 42 saykýl
                            gec = gec + 1;
                        end else begin
                            int_fp_deger <= int_fp_out;
                            en_int_fp <= 0;
                            we_ram_fp <= 1;
                            en_ram_fp <= 1;
                            addr_ram_fp <= satir_fp;
                            gec = 0;
                            durum = 9;
                        end
                    end
                    
                    9:begin
                        data_in_ram_fp <= int_fp_deger;
                        satir_fp <= satir_fp + 1;
                        durum = 7; // 10 : kontrol icin
                    end
                    
                    /*
                    10:begin
                        //fp oku kontrol
                        we_ram_fp <= 0;
                        en_ram_fp <= 1;
                        durum = 11;
                    end
                    
                    11:begin
                        addr_ram_fp <= 21;
                        durum = 12;
                    end
                    12:begin
                        data_out_ram_fp_deger <= data_out_ram_fp;
                    end
                    */
                    // -------------------------------------------- KONTROL EDÝLDÝ ÜSTTEKÝLER
                    
                    // FP CARPMA / COS ROM
                    // floatin point carpma / int_fp_donus ile cos ayrýk degerleri ile fp carpým
                    10:begin
                        if(cos_rom_say < 4097)begin
                            if(satir_cos < 64)begin
                                en_ram_fp <= 1; 
                                we_ram_fp <= 0; // okuma yapacak
                                addr_ram_fp <= satir_cos;
                                rd_rom_cos <= 1;
                                addr_rom_cos <= cos_rom_say;// bu 64ten fazla
                                rd_rom_t <= 1;
                                addr_rom_t <= satir_cos;
                                durum = 11;
                            end else begin
                                satir_cos <= 0;
                                en_ram_sonuc1 <= 1;
                                we_ram_sonuc1 <= 0; // okuma
                                durum = 16; // sonuc1 ram satýrlarý toplanýr
                            end
                        end else begin
                            satir_sonuc2 = 0;
                            durum = 21;
                        end
                    end
                    
                    11:begin
                        if(gec<4)begin
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            fp_carp_gir1 <= data_out_ram_fp;
                            fp_carp_gir2 <= data_out_rom_cos;
                            en_carp = 1;
                            durum = 12;
                        end
                        
                    end
                    12:begin
                        if(gec < 80)begin
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            fp_carp_ata <= fp_carp_cik;
                            en_carp <= 0;
                            durum = 13;
                        end
                    end
                    // FP CARPMA / T ROM
                    13:begin
                        // t matrisi ile carpma
                        if(gec<4)begin
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            fp_carp_gir1 <= fp_carp_ata;
                            fp_carp_gir2 <= data_out_rom_t;
                            en_carp <= 1;
                            durum = 14;
                        end
                         
                    end
                    
                    14:begin
                        if(gec < 80)begin
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            fp_carp_ata <= fp_carp_cik;
                            en_carp <= 0;
                            en_ram_sonuc1 <= 1;
                            we_ram_sonuc1 <= 1; // yazma
                            addr_ram_sonuc1 <= satir_cos;
                            durum = 15;
                        end
                    end
                    15:begin
                        data_in_ram_sonuc1 <= fp_carp_ata;
                        satir_cos = satir_cos + 1;
                        cos_rom_say = cos_rom_say + 1;
                        durum = 10;
                    end
                    
                    // BUTUN RAM SATIRLARI TOPLANMALI  / sonra 128 eklenmeli 
                    // FP TOPLAMA
                    16:begin
                        if(satir_sonuc1 < 64)begin
                            addr_ram_sonuc1 <= satir_sonuc1;
                            durum = 17;
                        end else begin
                            satir_sonuc1 = 0;
                            en_ram_sonuc1 <= 0;
                            we_ram_sonuc1 <= 0; // aktif deðil
                            // ram_toplam degeri bir ram e yazýlacak
                            durum = 20;
                        end
                    end
                    17:begin
                        if(gec < 3)begin
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            fp_topla_gir1 <= ram_toplam;
                            fp_topla_gir2 <= data_out_ram_sonuc1;
                            en_topla <= 1;
                            durum = 18;
                        end
                    end
                    18:begin
                        if(gec < 16)begin
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            fp_topla_ata <= fp_topla_cik;
                            en_topla <= 0;
                            durum =  19; 
                        end
                    end
                    
                    19:begin
                        ram_toplam <= fp_topla_ata; // bu calýþmazsa baþka deðiþken kullan ram degerlerini toplamak için
                        satir_sonuc1 <= satir_sonuc1 + 1;
                        durum = 16;
                    end
                    
                    20:begin
                        // ram_toplam sonuc2 ramine yazýlacak
                        if(satir_sonuc2 < 64)begin
                            toplam1_sonucu_ram[satir_sonuc2] <= ram_toplam;
                            satir_sonuc2 <= satir_sonuc2 + 1;
                            // 2. cos degerlerine
                            ram_toplam <= 0;
                            durum = 10;
                        end else begin
                        // 128 ile toplamaya
                        satir_sonuc2 = 0;
                        durum = 21;
                        end
                    end
                    
                    21:begin    
                        if(satir_sonuc2 < 64)begin
                            fp_topla_gir1 <= 32'b01000011000000000000000000000000;   // 128 ile toplar   
                            fp_topla_gir2 <= toplam1_sonucu_ram[satir_sonuc2];   
                            en_topla <= 1;
                            durum = 22;                          
                        end else begin 
                            // integer donusume
                            satir_sonuc2 = 0; 
                            durum = 24;
                        end
                    end
                    
                    22:begin
                        if(gec < 16)begin
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            fp_topla_ata <= fp_topla_cik;
                            en_topla <= 0;
                            durum =  23; 
                        end
                    end
                    
                    23:begin
                        toplam2_sonucu_ram[satir_sonuc2] <= fp_topla_ata;
                        satir_sonuc2 = satir_sonuc2 + 1;
                        durum = 21;
                    end
    
                    24:begin
                        // INTEGER A DONUSUM 
                        if(sonuc_satir < 64)begin
                            fp_int_in <= toplam2_sonucu_ram[sonuc_satir];
                            en_fp_int <= 1;
                            durum = 25;
                        end else begin
                            sonuc_satir = 0;
                            en_ram_sonuc = 0;         
                            we_ram_sonuc = 0; // modül pasif
                            durum = 27;
                        end
                    end
                    
                    25:begin
                        if(gec < 9)begin
                            gec = gec + 1;
                        end else begin
                            gec = 0;
                            fp_int_ata <= fp_int_out;
                            en_fp_int = 0;
                            addr_ram_sonuc <= sonuc_satir;
                            en_ram_sonuc = 1;
                            we_ram_sonuc = 1; // yazma
                            durum = 26;
                        end
                    end
                    
                    26:begin
                        sonuc_ram[sonuc_satir] <= fp_int_ata;
                        data_in_ram_sonuc <= fp_int_ata;
                        sonuc_satir = sonuc_satir + 1; 
                        durum = 24;
                    end
                    
                    27:begin
                        // SON / RAM OKU
                    end
    
                endcase 
                
            end else begin
            end
        end
    end
    
    
    // 10 bitlik ram / 8x8= 64 satýr
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
