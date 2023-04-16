`timescale 1ns / 1ps

// max 11 kere shift rotate yapmamız lazım 
// bu modül ile veri rotate shift işlemine sokulur ve sonuc üzerinden istediğimiz uzunluktaki veri çekilmiş olur.

module rotate_left#(parameter kaydir=5)(
    input clk_i,rst_i,en_i,
    input [31:0] sayi_i,
    output [kaydir-1:0] cekilen_veri_o  // kaydırma sonucunda olusan verinin elde edilmesini istenen kismi // ac ve dc nin girişine bağlanmalı
    );
    (* KEEP = "true" *) reg [31:0] kaydirilmis_sayi_deger;
//     reg [31:0] kaydirilmis_sayi_deger;
    reg [31:0] sayi_deger;
    (* KEEP = "true" *) reg [kaydir-1:0] cekilen_veri_deger;
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
                            sayi_deger <= sayi_i;
                        end
                        else begin
                            durum <= 1;
                        end
                    end
                    1:begin
                        if(kaydir == 1)begin                                          
                            kaydirilmis_sayi_deger <= {sayi_deger[30:0],sayi_deger[31:31]};    
                            durum <= 2;
                        end                                                           
                        else if(kaydir == 2)begin                                     
                            kaydirilmis_sayi_deger <= {sayi_deger[29:0],sayi_deger[31:30]};    
                            durum <= 2;
                        end                                                           
                        else if(kaydir == 3)begin                                     
                            kaydirilmis_sayi_deger <= {sayi_deger[28:0],sayi_deger[31:29]};    
                            durum <= 2;
                        end                                                           
                        else if(kaydir == 4)begin                                     
                            kaydirilmis_sayi_deger <= {sayi_deger[27:0],sayi_deger[31:28]}; 
                            durum <= 2;   
                        end                                                           
                        else if(kaydir == 5)begin                                     
                            kaydirilmis_sayi_deger <= {sayi_deger[26:0],sayi_deger[31:27]};    
                            durum <= 2;
                        end                                                           
                        else if(kaydir == 6)begin                                     
                            kaydirilmis_sayi_deger <= {sayi_deger[25:0],sayi_deger[31:26]};
                            durum <= 2;    
                        end                                                           
                        else if(kaydir == 7)begin                                     
                            kaydirilmis_sayi_deger <= {sayi_deger[24:0],sayi_deger[31:25]};  
                            durum <= 2;  
                        end                                                           
                        else if(kaydir == 8)begin                                     
                            kaydirilmis_sayi_deger <= {sayi_deger[23:0],sayi_deger[31:24]};  
                            durum <= 2;  
                        end                                                           
                        else if(kaydir == 9)begin                                     
                            kaydirilmis_sayi_deger <= {sayi_deger[22:0],sayi_deger[31:23]};   
                            durum <= 2; 
                        end                                                           
                        else if(kaydir == 10)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[21:0],sayi_deger[31:22]};  
                            durum <= 2;  
                        end                                                           
                        else if(kaydir == 11)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[20:0],sayi_deger[31:21]};    
                            durum <= 2;
                        end 
                        else if(kaydir == 12)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[19:0],sayi_deger[31:20]};    
                            durum <= 2;
                        end
                        else if(kaydir == 13)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[18:0],sayi_deger[31:19]};    
                            durum <= 2;
                        end
                        else if(kaydir == 14)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[17:0],sayi_deger[31:18]};    
                            durum <= 2;
                        end
                        else if(kaydir == 15)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[16:0],sayi_deger[31:17]};    
                            durum <= 2;
                        end
                        else if(kaydir == 16)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[15:0],sayi_deger[31:16]};    
                            durum <= 2;
                        end 
                        else if(kaydir == 17)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[14:0],sayi_deger[31:15]};    
                            durum <= 2;
                        end
                        else if(kaydir == 18)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[13:0],sayi_deger[31:14]};    
                            durum <= 2;
                        end
                        else if(kaydir == 19)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[12:0],sayi_deger[31:13]};    
                            durum <= 2;
                        end
                        else if(kaydir == 20)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[11:0],sayi_deger[31:12]};    
                            durum <= 2;
                        end
                        else if(kaydir == 21)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[10:0],sayi_deger[31:11]};    
                            durum <= 2;
                        end
                        else if(kaydir == 22)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[9:0],sayi_deger[31:10]};    
                            durum <= 2;
                        end
                        else if(kaydir == 23)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[8:0],sayi_deger[31:9]};    
                            durum <= 2;
                        end
                        else if(kaydir == 24)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[7:0],sayi_deger[31:8]};    
                            durum <= 2;
                        end
                        else if(kaydir == 25)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[6:0],sayi_deger[31:7]};    
                            durum <= 2;
                        end
                        else if(kaydir == 26)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[5:0],sayi_deger[31:6]};    
                            durum <= 2;
                        end
                        else if(kaydir == 27)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[4:0],sayi_deger[31:5]};    
                            durum <= 2;
                        end
                        else if(kaydir == 28)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[3:0],sayi_deger[31:4]};    
                            durum <= 2;
                        end
                        else if(kaydir == 29)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[2:0],sayi_deger[31:3]};    
                            durum <= 2; // 00011111111111111111111111111111
                        end
                        else if(kaydir == 30)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[1:0],sayi_deger[31:2]};    
                            durum <= 2;
                        end
                        else if(kaydir == 31)begin                                    
                            kaydirilmis_sayi_deger <= {sayi_deger[0:0],sayi_deger[31:1]};    
                            durum <= 2;
                        end
                        else if(kaydir == 32)begin
                            kaydirilmis_sayi_deger <= sayi_deger; // 32 bit kaydırınca sayının kendisi alınır
                            durum <= 2; 
                        end
                        else begin                                                
                            kaydirilmis_sayi_deger <= 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;                     
                        end 
                    end
                    2:begin
                        cekilen_veri_deger <= kaydirilmis_sayi_deger[(kaydir-1):0];
                        durum <= 3;
                    end
                    3:begin
                        durum = 0;
                        sayac = 0;
                    end
                endcase
            end else begin
                durum = 0;
                sayac = 0;
            end
        end   
    end
endmodule

