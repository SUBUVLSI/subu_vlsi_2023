`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.01.2023 15:21:44
// Design Name: 
// Module Name: AC_deger
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





/*
rotate alt modülü kullanılcak, ac, dc ve asil sayilari ram e yazdirabilmek için // ana_sayi ve n(kaç kez rotate) modüle gönderilmeli (max 11 tane modül olacak)
(rotate gönderilcek n sayısının değeri if yapılarında kontrol edilmelidir, bu kontrole göre ilgili modüller çalıştırılacak/ enable ucu ile) 
( toplam rotate etme sayısını sakla => çünkü son kısımda ana_sayi = kalanSayi00000000 şeklinde olacak. bu sıfırların sayısı bilinmeli / kalanSayi diğer 32 bit eklemeli NASIL? ) 
başlangıç biti hep 31 olması sağlanacak şekilde sola kaydırma işlemi olacak => bununun için shift left
1) dc,ac verisi için n = uzunluk => [n-1:0] olusan_sayi ya atanacak => bu da ram e yazılır ( n boyutlu veri çekilmiş olur)
2) uzunluk kadar shift left => yeni işleme sokulacak ana sayi
3) asil-sayi için n = cikis_deger (asil sayının uzunluğu) => [n-1:0] olusan_sayi2 ya atanacak => bu da ram e yazılır ( n boyutlu veri çekilmiş olur)
4) cikis_deger kadar shift left => yeni işleme sokulacak ana sayi

    // ac ve dc için // ac ve dc değer modüllerinden uzunluk, cikis_deger geleek 
    
    ana_sayi = 10100011010110010  // bitstream  // rotate modulune gidecek
    n = uzunluk; // rotate modulune gidecek  => 1010001 << n; // ana_sayi rotate left n defa çıktısı = x / rotate_modül_ciktisi oluşacak
    reg [n-1:0] olusan_sayi;
    olusan_sayi = rotate_modül_ciktisi; // ram e yazılacak / 10001101011001010 => rotate_edilmiş_ana_sayi(roate_ciktisi) , 10 => olusan_sayi
    // olusan_sayi ya göre ac,dc modülleri kullanılacak => cıktısı : cikis_deger asil sayi için kullanılacak
    
    ana_sayi = ana_sayi << uzunluk; // ana sayı uzunluk kadar shift left ile değişti // 100011010110010 00 // sona uzunluk kadar 0 ekledir.
    
    // asil sayi için
    ana_sayi = 10001101011001000  // bitstream  // rotate modulune gidecek // değişmiş olan ana_sayi üzerinden devam
    n = cikis_deger; // rotate modulune gidecek  => 1010001 << n; // ana_sayi rotate left n defa çıktısı = x / rotate_modül_ciktisi oluşacak
    reg [n-1:0] olusan_sayi2;
    olusan_sayi2 = rotate_modül_ciktisi; // ram e yazılacak// ac için önündeki 0 sayıları da eklenmeli
    
    ana_sayi = ana_sayi << cikis_deger; // ana sayı cikis_deger kadar shift left ile değişti
    
    // bu işlemler EOB ye ulaşılana kadar tekrarlanacak
    
*/




// AC nin başlangıç biti hep 31 olması sağlanacak şekilde sola kaydırma işlemi olacak / kaydirma_deger ile birlikte // asıl sayı çekilmeden önceki bitstream
// EOB = 0101 kontrol et , görünce 64 satırı tamamla 0 ekleyerek
module AC_deger#(parameter uzunluk=2)(
    
    input en_i, clk_i, // rst_i,
    input [uzunluk-1:0] giris_i,
    output [3:0] cikis_o, // max 11 değeri çıkar o da 4 bitle ifade edilebilir.(bir sonraki sayii kaç bit olacak
    output [3:0] cikis_sifir_sayisi_o // sifir sayisi max 15 olabilir o da 4 bitle ifade edilebilir. 
     // output [max:0] kaydirma_deger // max hesapla
    );
    localparam n = 0;
    reg [n-1:0] x;
    
    
    
    reg [3:0] cikis_deger,cikis_sifir;
    // reg [1:0] durum = 2'b00;
    
    assign cikis_o = cikis_deger;
    assign cikis_sifir_sayisi_o = cikis_sifir;
    
    // clk ekle 
    always@(posedge clk_i)begin
        if(en_i == 1)begin
        
            if(uzunluk == 2)begin
                if(giris_i == 2'b00)begin
                    cikis_sifir = 4'b0000; // 0
                    cikis_deger = 4'b0001; // 1
                    
                end 
                else if(giris_i == 2'b01)begin
                    cikis_sifir = 4'b0000; // 0
                    cikis_deger = 4'b0010; // 2
                end
                else begin
                    cikis_sifir = 4'bxxxx; // tanımsız
                    cikis_deger = 4'bxxx; // tanımsız
                end
            end
            
            else if(uzunluk == 3)begin
                if(giris_i == 3'b100) begin
                    cikis_sifir = 4'b0000; // 0
                    cikis_deger = 4'b0011; // 3   
                    // kaydirma_deger = 6 // uzunluk+bir sonraki sayi kaç bit ile ifade edilir 
                end
                else begin
                    cikis_sifir = 4'bxxxx; // tanımsız
                    cikis_deger = 4'bxxx; // tanımsız
                end
            end
            
            else if(uzunluk == 4)begin
                if(giris_i == 4'b1011) begin
                    cikis_sifir = 4'b0000; // 0
                    cikis_deger = 4'b0100; // 4
                end
                else if(giris_i == 4'b1100) begin
                    cikis_sifir = 4'b0001; // 1
                    cikis_deger = 4'b0001; // 1
                end 
                
                else if(giris_i == 4'b1010) begin  // eob ise bitti 
                    // komtrol değişkeni olmalı 
                end 
                
                else begin
                    cikis_sifir = 1'bx; // tanımsız
                    cikis_deger = 1'bx; // tanımsız
                end
            end
            
            else if(uzunluk == 5)begin
                if(giris_i == 5'b11010) begin
                    cikis_sifir = 4'b0000; // 0
                    cikis_deger = 4'b0101; // 5
                end
                else if(giris_i == 5'b11011) begin
                    cikis_sifir = 4'b0001; // 1
                    cikis_deger = 4'b0010; // 2
                end
                else if(giris_i == 5'b11100) begin
                    cikis_sifir = 4'b0010; // 2
                    cikis_deger = 4'b0001; // 1
                end
                else begin
                    cikis_sifir = 1'bx; // tanımsız
                    cikis_deger = 1'bx; // tanımsız
                end
            end
            
            else if(uzunluk == 6) begin
                if(giris_i == 6'b111010)begin
                    cikis_sifir = 4'b0011; // 3
                    cikis_deger = 4'b0001; // 1
                end
                else if(giris_i == 6'b111011)begin
                    cikis_sifir = 4'b0100; // 4
                    cikis_deger = 4'b0001; // 1
                end
                else begin
                    cikis_sifir = 1'bx; // tanımsız
                    cikis_deger = 1'bx; // tanımsız
                end
            end
            
            else if(uzunluk == 7)begin
                if(giris_i == 7'b1111000)begin
                    cikis_sifir = 4'b0000; // 0
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 7'b1111001)begin
                    cikis_sifir = 4'b0001; // 1
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 7'b1111010)begin
                    cikis_sifir = 4'b0101; // 5
                    cikis_deger = 4'b0001; // 1
                end
                else if(giris_i == 7'b1111011)begin
                    cikis_sifir = 4'b0110; // 6
                    cikis_deger = 4'b0001; // 1
                end
                
            end
            
            else if(uzunluk == 8)begin
                if(giris_i == 8'b11111000)begin
                    cikis_sifir = 4'b0000; // 0
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i== 8'b11111001)begin
                    cikis_sifir = 4'b0010; // 2
                    cikis_deger = 4'b0010; // 2
                end
                else if(giris_i== 8'b11111010)begin
                    cikis_sifir = 4'b0111; // 7
                    cikis_deger = 4'b0001; // 1
                end
            end
            
            else if(uzunluk == 9)begin
                if(giris_i == 9'b111110110)begin
                    cikis_sifir = 4'b0001; // 1
                    cikis_deger = 4'b0100; // 4
                end
                else if(giris_i == 9'b111110111)begin
                    cikis_sifir = 4'b0011; // 3
                    cikis_deger = 4'b0010; // 2
                end
                else if(giris_i == 9'b111111000)begin
                    cikis_sifir = 4'b0001; // 1
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 9'b111111001)begin
                    cikis_sifir = 4'b0001; // 1
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 9'b111111010)begin
                    cikis_sifir = 4'b0001; // 1
                    cikis_deger = 4'b1010; // 10
                end
            end
            
            else if(uzunluk == 10)begin
                if(giris_i == 10'b1111110110)begin
                    cikis_sifir = 4'b0000; // 0
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 10'b1111110111)begin
                    cikis_sifir = 4'b0010; // 2
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 10'b1111111000)begin
                    cikis_sifir = 4'b0100; // 4
                    cikis_deger = 4'b0010; // 2
                end
                else if(giris_i == 10'b1111111010)begin
                    cikis_sifir = 4'b1100; // 12
                    cikis_deger = 4'b0001; // 1
                end
                
            end
            
            else if(uzunluk == 11)begin
                if(giris_i == 11'b11111110110)begin
                    cikis_sifir = 4'b0001; // 1
                    cikis_deger = 4'b0101; // 5
                end
                else if(giris_i == 11'b11111110111)begin
                    cikis_sifir = 4'b0101; // 5
                    cikis_deger = 4'b0010; // 2
                end
                else if(giris_i == 11'b11111111000)begin
                    cikis_sifir = 4'b1101; // 13
                    cikis_deger = 4'b0001; // 1
                end
            end
            
            else if(uzunluk == 12)begin
                if(giris_i == 12'b111111110100)begin
                    cikis_sifir = 4'b0010; // 2
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 12'b111111110101)begin
                    cikis_sifir = 4'b0011; // 3
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 12'b111111110110)begin
                    cikis_sifir = 4'b0110; // 6
                    cikis_deger = 4'b0010; // 2
                end
                else if(giris_i == 12'b111111110111)begin
                    cikis_sifir = 4'b0111; // 7
                    cikis_deger = 4'b0010; // 2
                end
            end
            
            else if(uzunluk == 15) begin
                if(giris_i == 15'b111111111000000)begin
                    cikis_sifir = 4'b1000; // 8
                    cikis_deger = 4'b0010; // 2
                end else begin
                    
                end
            end
            
            else if(uzunluk == 16) begin
                if(giris_i == 16'b1111111110000100)begin
                    cikis_sifir = 4'b0001; // 1
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 16'b1111111110000101)begin
                    cikis_sifir = 4'b0001; // 1
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i == 16'b1111111110000110)begin
                    cikis_sifir = 4'b0001; // 1
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 16'b1111111110000111)begin
                    cikis_sifir = 4'b0001; // 1
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 16'b1111111110001000)begin
                    cikis_sifir = 4'b0001; // 1
                    cikis_deger = 4'b1010; // 10
                end
                
                else if(giris_i == 16'b1111111110001001)begin
                    cikis_sifir = 4'b0010; // 2
                    cikis_deger = 4'b0101; // 5
                end
                
                else if(giris_i == 16'b1111111110001010)begin
                    cikis_sifir = 4'b0010; // 2
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 16'b1111111110001011)begin
                    cikis_sifir = 4'b0010; // 2
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i == 16'b1111111110001100)begin
                    cikis_sifir = 4'b0010; // 2
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 16'b1111111110001101)begin
                    cikis_sifir = 4'b0010; // 2
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 16'b1111111110001110)begin
                    cikis_sifir = 4'b0010; // 2
                    cikis_deger = 4'b1010; // 10
                end
                
                else if(giris_i == 16'b1111111110001111)begin
                    cikis_sifir = 4'b0011; // 3
                    cikis_deger = 4'b0100; // 4
                end
                else if(giris_i == 16'b1111111110010000)begin
                    cikis_sifir = 4'b0011; // 3
                    cikis_deger = 4'b0101; // 5
                end
                else if(giris_i == 16'b1111111110010001)begin
                    cikis_sifir = 4'b0011; // 3
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 16'b1111111110010010)begin
                    cikis_sifir = 4'b0011; // 3
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i == 16'b1111111110010011)begin
                    cikis_sifir = 4'b0011; // 3
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 16'b1111111110010100)begin
                    cikis_sifir = 4'b0011; // 3
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 16'b1111111110010101)begin
                    cikis_sifir = 4'b0011; // 3
                    cikis_deger = 4'b1010; // 10
                end
                
                else if(giris_i == 16'b1111111110010110)begin
                    cikis_sifir = 4'b0100; // 4
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 16'b1111111110010111)begin
                    cikis_sifir = 4'b0100; // 4
                    cikis_deger = 4'b0100; // 4
                end
                else if(giris_i == 16'b1111111110011000)begin
                    cikis_sifir = 4'b0100; // 4
                    cikis_deger = 4'b0101; // 5
                end
                else if(giris_i == 16'b1111111110011001)begin
                    cikis_sifir = 4'b0100; // 4
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 16'b1111111110011010)begin
                    cikis_sifir = 4'b0100; // 4
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i == 16'b1111111110011011)begin
                    cikis_sifir = 4'b0100; // 4
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 16'b1111111110011100)begin
                    cikis_sifir = 4'b0100; // 4
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 16'b1111111110011101)begin
                    cikis_sifir = 4'b0100; // 4
                    cikis_deger = 4'b1010; // 10
                end
                
                else if(giris_i == 16'b1111111110011110)begin
                    cikis_sifir = 4'b0101; // 5
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 16'b1111111110011111)begin
                    cikis_sifir = 4'b0101; // 5
                    cikis_deger = 4'b0100; // 4
                end
                else if(giris_i == 16'b1111111110100000)begin
                    cikis_sifir = 4'b0101; // 5
                    cikis_deger = 4'b0101; // 5
                end
                else if(giris_i == 16'b1111111110100001)begin
                    cikis_sifir = 4'b0101; // 5
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 16'b1111111110100010)begin
                    cikis_sifir = 4'b0101; // 5
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i == 16'b1111111110100011)begin
                    cikis_sifir = 4'b0101; // 5
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 16'b1111111110100100)begin
                    cikis_sifir = 4'b0101; // 5
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 16'b1111111110100101)begin
                    cikis_sifir = 4'b0101; // 5
                    cikis_deger = 4'b1010; // 10
                end
                
                else if(giris_i == 16'b1111111110100110)begin
                    cikis_sifir = 4'b0110; // 6
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 16'b1111111110100111)begin
                    cikis_sifir = 4'b0110; // 6
                    cikis_deger = 4'b0100; // 4
                end
                else if(giris_i == 16'b1111111110101000)begin
                    cikis_sifir = 4'b0110; // 6
                    cikis_deger = 4'b0101; // 5
                end
                else if(giris_i == 16'b1111111110101001)begin
                    cikis_sifir = 4'b0110; // 6
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 16'b1111111110101010)begin
                    cikis_sifir = 4'b0110; // 6
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i == 16'b1111111110101011)begin
                    cikis_sifir = 4'b0110; // 6
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 16'b1111111110101100)begin
                    cikis_sifir = 4'b0110; // 6
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 16'b1111111110101101)begin
                    cikis_sifir = 4'b0110; // 6
                    cikis_deger = 4'b1010; // 10
                end
                
                else if(giris_i == 16'b1111111110101110)begin
                    cikis_sifir = 4'b0111; // 7
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 16'b1111111110101111)begin
                    cikis_sifir = 4'b0111; // 7
                    cikis_deger = 4'b0100; // 4
                end
                else if(giris_i == 16'b1111111110110000)begin
                    cikis_sifir = 4'b0111; // 7
                    cikis_deger = 4'b0101; // 5
                end
                else if(giris_i == 16'b1111111110110001)begin
                    cikis_sifir = 4'b0111; // 7
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 16'b1111111110110010)begin
                    cikis_sifir = 4'b0111; // 7
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i == 16'b1111111110110011)begin
                    cikis_sifir = 4'b0111; // 7
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 16'b1111111110110100)begin
                    cikis_sifir = 4'b0111; // 7
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 16'b1111111110110101)begin
                    cikis_sifir = 4'b0111; // 7
                    cikis_deger = 4'b1010; // 10
                end
                
                else if(giris_i == 16'b1111111110110110)begin
                    cikis_sifir = 4'b1000; // 8
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 16'b1111111110110111)begin
                    cikis_sifir = 4'b1000; // 8
                    cikis_deger = 4'b0100; // 4
                end
                else if(giris_i == 16'b1111111110111000)begin
                    cikis_sifir = 4'b1000; // 8
                    cikis_deger = 4'b0101; // 5
                end
                else if(giris_i == 16'b1111111110111001)begin
                    cikis_sifir = 4'b1000; // 8
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 16'b1111111110111010)begin
                    cikis_sifir = 4'b1000; // 8
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i == 16'b1111111110111011)begin
                    cikis_sifir = 4'b1000; // 8
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 16'b1111111110111100)begin
                    cikis_sifir = 4'b1000; // 8
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 16'b1111111110111101)begin
                    cikis_sifir = 4'b1000; // 8
                    cikis_deger = 4'b1010; // 10
                end
                
                else if(giris_i == 16'b1111111110111110)begin
                    cikis_sifir = 4'b1001; // 9
                    cikis_deger = 4'b0010; // 2
                end
                else if(giris_i == 16'b1111111110111111)begin
                    cikis_sifir = 4'b1001; // 9
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 16'b1111111111000000)begin
                    cikis_sifir = 4'b1001; // 9
                    cikis_deger = 4'b0100; // 4
                end
                else if(giris_i == 16'b1111111111000001)begin
                    cikis_sifir = 4'b1001; // 9
                    cikis_deger = 4'b0101; // 5
                end
                else if(giris_i == 16'b1111111111000010)begin
                    cikis_sifir = 4'b1001; // 9
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 16'b1111111111000011)begin
                    cikis_sifir = 4'b1001; // 9
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i == 16'b1111111111000100)begin
                    cikis_sifir = 4'b1001; // 9
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 16'b1111111111000101)begin
                    cikis_sifir = 4'b1001; // 9
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 16'b1111111111000110)begin
                    cikis_sifir = 4'b1001; // 9
                    cikis_deger = 4'b1010; // 10
                end
                
                else if(giris_i == 16'b1111111111000111)begin
                    cikis_sifir = 4'b1010; // 10
                    cikis_deger = 4'b0010; // 2
                end
                else if(giris_i == 16'b1111111111001000)begin
                    cikis_sifir = 4'b1010; // 10
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 16'b1111111111001001)begin
                    cikis_sifir = 4'b1010; // 10
                    cikis_deger = 4'b0100; // 4
                end
                else if(giris_i == 16'b1111111111001010)begin
                    cikis_sifir = 4'b1010; // 10
                    cikis_deger = 4'b0101; // 5
                end
                else if(giris_i == 16'b1111111111001011)begin
                    cikis_sifir = 4'b1010; // 10
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 16'b1111111111001100)begin
                    cikis_sifir = 4'b1010; // 10
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i == 16'b1111111111001101)begin
                    cikis_sifir = 4'b1010; // 10
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 16'b1111111111001110)begin
                    cikis_sifir = 4'b1010; // 10
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 16'b1111111111001111)begin
                    cikis_sifir = 4'b1010; // 10
                    cikis_deger = 4'b1010; // 10
                end
                
                else if(giris_i == 16'b1111111111010000)begin
                    cikis_sifir = 4'b1011; // 11
                    cikis_deger = 4'b0010; // 2
                end
                else if(giris_i == 16'b1111111111010001)begin
                    cikis_sifir = 4'b1011; // 11
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 16'b1111111111010010)begin
                    cikis_sifir = 4'b1011; // 11
                    cikis_deger = 4'b0100; // 4
                end
                else if(giris_i == 16'b1111111111010011)begin
                    cikis_sifir = 4'b1011; // 11
                    cikis_deger = 4'b0101; // 5
                end
                else if(giris_i == 16'b1111111111010100)begin
                    cikis_sifir = 4'b1011; // 11
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 16'b1111111111010101)begin
                    cikis_sifir = 4'b1011; // 11
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i == 16'b1111111111010110)begin
                    cikis_sifir = 4'b1011; // 11
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 16'b1111111111010111)begin
                    cikis_sifir = 4'b1011; // 11
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 16'b1111111111011000)begin
                    cikis_sifir = 4'b1011; // 11
                    cikis_deger = 4'b1010; // 10
                end
                
                else if(giris_i == 16'b1111111111011001)begin
                    cikis_sifir = 4'b1100; // 12
                    cikis_deger = 4'b0010; // 2
                end
                else if(giris_i == 16'b1111111111011010)begin
                    cikis_sifir = 4'b1100; // 12
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 16'b1111111111011011)begin
                    cikis_sifir = 4'b1100; // 12
                    cikis_deger = 4'b0100; // 4
                end
                else if(giris_i == 16'b1111111111011100)begin
                    cikis_sifir = 4'b1100; // 12
                    cikis_deger = 4'b0101; // 5
                end
                else if(giris_i == 16'b1111111111011101)begin
                    cikis_sifir = 4'b1100; // 12
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 16'b1111111111011110)begin
                    cikis_sifir = 4'b1100; // 12
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i == 16'b1111111111011111)begin
                    cikis_sifir = 4'b1100; // 12
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 16'b1111111111100000)begin
                    cikis_sifir = 4'b1100; // 12
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 16'b1111111111100001)begin
                    cikis_sifir = 4'b1100; // 12
                    cikis_deger = 4'b1010; // 10
                end
                
                else if(giris_i == 16'b1111111111100010)begin
                    cikis_sifir = 4'b1101; // 13
                    cikis_deger = 4'b0010; // 2
                end
                else if(giris_i == 16'b1111111111100011)begin
                    cikis_sifir = 4'b1101; // 13
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 16'b1111111111100100)begin
                    cikis_sifir = 4'b1101; // 13
                    cikis_deger = 4'b0100; // 4
                end
                else if(giris_i == 16'b1111111111100101)begin
                    cikis_sifir = 4'b1101; // 13
                    cikis_deger = 4'b0101; // 5
                end
                else if(giris_i == 16'b1111111111100110)begin
                    cikis_sifir = 4'b1101; // 13
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 16'b1111111111100111)begin
                    cikis_sifir = 4'b1101; // 13
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i == 16'b1111111111101000)begin
                    cikis_sifir = 4'b1101; // 13
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 16'b1111111111101001)begin
                    cikis_sifir = 4'b1101; // 13
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 16'b1111111111101010)begin
                    cikis_sifir = 4'b1101; // 13
                    cikis_deger = 4'b1010; // 10
                end
                
                else if(giris_i == 16'b1111111111101011)begin
                    cikis_sifir = 4'b1110; // 14
                    cikis_deger = 4'b0001; // 1
                end
                else if(giris_i == 16'b1111111111101100)begin
                    cikis_sifir = 4'b1110; // 14
                    cikis_deger = 4'b0010; // 2
                end
                else if(giris_i == 16'b1111111111101101)begin
                    cikis_sifir = 4'b1110; // 14
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 16'b1111111111101110)begin
                    cikis_sifir = 4'b1110; // 14
                    cikis_deger = 4'b0100; // 4
                end
                else if(giris_i == 16'b1111111111101111)begin
                    cikis_sifir = 4'b1110; // 14
                    cikis_deger = 4'b0101; // 5
                end
                else if(giris_i == 16'b1111111111110000)begin
                    cikis_sifir = 4'b1110; // 14
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 16'b1111111111110001)begin
                    cikis_sifir = 4'b1110; // 14
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i == 16'b1111111111110010)begin
                    cikis_sifir = 4'b1110; // 14
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 16'b1111111111110011)begin
                    cikis_sifir = 4'b1110; // 14
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 16'b1111111111110100)begin
                    cikis_sifir = 4'b1110; // 14
                    cikis_deger = 4'b1010; // 10
                end
                
                else if(giris_i == 16'b1111111111110101)begin
                    cikis_sifir = 4'b1111; // 15
                    cikis_deger = 4'b0001; // 1
                end
                else if(giris_i == 16'b1111111111110110)begin
                    cikis_sifir = 4'b1111; // 15
                    cikis_deger = 4'b0010; // 2
                end
                else if(giris_i == 16'b1111111111110111)begin
                    cikis_sifir = 4'b1111; // 15
                    cikis_deger = 4'b0011; // 3
                end
                else if(giris_i == 16'b1111111111111000)begin
                    cikis_sifir = 4'b1111; // 15
                    cikis_deger = 4'b0100; // 4
                end
                else if(giris_i == 16'b1111111111111001)begin
                    cikis_sifir = 4'b1111; // 15
                    cikis_deger = 4'b0101; // 5
                end
                else if(giris_i == 16'b1111111111111010)begin
                    cikis_sifir = 4'b1111; // 15
                    cikis_deger = 4'b0110; // 6
                end
                else if(giris_i == 16'b1111111111111011)begin
                    cikis_sifir = 4'b1111; // 15
                    cikis_deger = 4'b0111; // 7
                end
                else if(giris_i == 16'b1111111111111100)begin
                    cikis_sifir = 4'b1111; // 15
                    cikis_deger = 4'b1000; // 8
                end
                else if(giris_i == 16'b1111111111111101)begin
                    cikis_sifir = 4'b1111; // 15
                    cikis_deger = 4'b1001; // 9
                end
                else if(giris_i == 16'b1111111111111110)begin
                    cikis_sifir = 4'b1111; // 15
                    cikis_deger = 4'b1010; // 10
                end
                
            end
            
        end
    end
endmodule
