`timescale 1ns / 1ps

module DC_deger#(parameter uzunluk=2)(
    input en_i, clk_i, //rst_i,
    input [uzunluk-1:0] giris_i,
    output [3:0] cikis_o // max 11 degeri cikar o da 4 bitle ifade edilebilir. ( bir sonraki sayi kaç bit olacak)
    );
    
    reg [3:0] cikis_deger,cikis_deger_ata;
    // reg [1:0] durum = 2'b00;
    
    assign cikis_o = cikis_deger;
    //  011 10 0010011   DC-MATRİSTEKİ 1. SATIR => 3 (4)7 (5)9  
    always@(posedge clk_i)begin
            if(en_i == 1) begin
                if(uzunluk==2)begin
                    if(giris_i == 2'b00)begin
                        cikis_deger = 0; // 0
                    end
                end
                
                else if(uzunluk == 3) begin
                    if(giris_i == 3'b010)begin
                        cikis_deger = 4'b0001; // 1
                    end
                    else if(giris_i == 3'b011)begin
                        cikis_deger = 4'b0010; // 2
                    end
                    else if(giris_i == 3'b100)begin
                        cikis_deger = 4'b0011; // 3
                    end
                    else if(giris_i == 3'b101)begin
                        cikis_deger = 4'b0100; // 4
                    end
                    else if(giris_i == 3'b110)begin
                        cikis_deger = 4'b0101; // 5
                    end 
                    else begin
                        cikis_deger = 4'bxxxx;
                    end
                end
                
                else if(uzunluk==4)begin
                    if(giris_i == 4'b1110)begin
                        cikis_deger = 4'b0110; // 6
                    end
                end
                
                else if(uzunluk==5)begin
                    if(giris_i == 5'b11110)begin
                        cikis_deger = 4'b0111; // 7
                    end
                end
                
                else if(uzunluk==6)begin
                    if(giris_i == 6'b111110)begin
                        cikis_deger = 4'b1000;  // 8
                    end
                end
                
                else if(uzunluk==7)begin
                    if(giris_i == 7'b1111110)begin
                        cikis_deger = 4'b1001;  // 9
                    end
                end
                
                else if(uzunluk==8)begin
                    if(giris_i ==8'b11111110)begin
                        cikis_deger = 4'b1010;  // 10
                    end
                end
                
                else if(uzunluk==9)begin
                    if(giris_i == 9'b111111110)begin
                        cikis_deger = 4'b1011;  // 11
                    end
                end
                
                else begin
                    cikis_deger = 4'bxxxx;
                end
            end
        end 
endmodule
