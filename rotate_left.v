`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.01.2023 13:36:52
// Design Name: 
// Module Name: rotate_left
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

// max 11 kere shift rotate yapmamýz lazým 
// bu modül ile veri rotate shift iþlemine sokulur ve sonuc üzerinden istediðimiz uzunluktaki veri çekilmiþ olur.

module rotate_left#(parameter kaydir=5)(
    input clk_i,rst_i,en_i,
    input [31:0] sayi_i,
    output [31:0] kaydirilmis_sayi_o,
    output [kaydir-1:0] cekilen_veri_o  // kaydýrma sonucunda olusan verinin elde edilmesini istenen kismi // ac ve dc nin giriþine baðlanmalý
    );
    reg [31:0] kaydirilmis_sayi_deger;
    reg [31:0] sayi_deger;
    reg [kaydir-1:0] cekilen_veri_deger;
    assign cekilen_veri_o = cekilen_veri_deger;
    integer sayac = 0;
    reg [3:0] durum = 0;
    always@(posedge clk_i)begin
        if(rst_i)begin 
        end else begin
            if(en_i == 1)begin
                sayac = sayac + 1;
                case(durum)
                    0:begin 
                        if(sayac<=3)begin  // 3 clk beklettik
                            sayi_deger = sayi_i;
                        end
                        else begin
                            durum = 1;
                        end
                    end
                    1:begin
                        if(kaydir == 1)begin                                          
                            kaydirilmis_sayi_deger = {sayi_deger[30:0],sayi_deger[31:31]};    
                            durum = 2;
                        end                                                           
                        else if(kaydir == 2)begin                                     
                            kaydirilmis_sayi_deger = {sayi_deger[29:0],sayi_deger[31:30]};    
                            durum = 2;
                        end                                                           
                        else if(kaydir == 3)begin                                     
                            kaydirilmis_sayi_deger = {sayi_deger[28:0],sayi_deger[31:29]};    
                            durum = 2;
                        end                                                           
                        else if(kaydir == 4)begin                                     
                            kaydirilmis_sayi_deger = {sayi_deger[27:0],sayi_deger[31:28]}; 
                            durum = 2;   
                        end                                                           
                        else if(kaydir == 5)begin                                     
                            kaydirilmis_sayi_deger = {sayi_deger[26:0],sayi_deger[31:27]};    
                            durum = 2;
                        end                                                           
                        else if(kaydir == 6)begin                                     
                            kaydirilmis_sayi_deger = {sayi_deger[25:0],sayi_deger[31:26]};
                            durum = 2;    
                        end                                                           
                        else if(kaydir == 7)begin                                     
                            kaydirilmis_sayi_deger = {sayi_deger[24:0],sayi_deger[31:25]};  
                            durum = 2;  
                        end                                                           
                        else if(kaydir == 8)begin                                     
                            kaydirilmis_sayi_deger = {sayi_deger[23:0],sayi_deger[31:24]};  
                            durum = 2;  
                        end                                                           
                        else if(kaydir == 9)begin                                     
                            kaydirilmis_sayi_deger = {sayi_deger[22:0],sayi_deger[31:23]};   
                            durum = 2; 
                        end                                                           
                        else if(kaydir == 10)begin                                    
                            kaydirilmis_sayi_deger = {sayi_deger[21:0],sayi_deger[31:22]};  
                            durum = 2;  
                        end                                                           
                        else if(kaydir == 11)begin                                    
                            kaydirilmis_sayi_deger = {sayi_deger[20:0],sayi_deger[31:21]};    
                            durum = 2;
                        end 
                        else if(kaydir == 12)begin                                    
                            kaydirilmis_sayi_deger = {sayi_deger[19:0],sayi_deger[31:20]};    
                            durum = 2;
                        end
                        else if(kaydir == 13)begin                                    
                            kaydirilmis_sayi_deger = {sayi_deger[18:0],sayi_deger[31:19]};    
                            durum = 2;
                        end
                        else if(kaydir == 14)begin                                    
                            kaydirilmis_sayi_deger = {sayi_deger[17:0],sayi_deger[31:18]};    
                            durum = 2;
                        end
                        else if(kaydir == 15)begin                                    
                            kaydirilmis_sayi_deger = {sayi_deger[16:0],sayi_deger[31:17]};    
                            durum = 2;
                        end
                        else if(kaydir == 16)begin                                    
                            kaydirilmis_sayi_deger = {sayi_deger[15:0],sayi_deger[31:16]};    
                            durum = 2;
                        end else begin                                                
                            kaydirilmis_sayi_deger = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;                     
                        end 
                    end
                    2:begin
                        cekilen_veri_deger = kaydirilmis_sayi_deger;
                        durum = 3;
                    end
                    3:begin
                        durum = 0;
                        sayac = 0;
                        // kaydirilmis_sayi_deger = 0;
                        // cekilen_veri_deger = 0;
                        // sayi_deger = 0;
                    end
                endcase
            end else begin
                durum = 0;
                sayac = 0;
            end
        end   
    end
endmodule
