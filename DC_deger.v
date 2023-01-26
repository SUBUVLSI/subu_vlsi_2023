`timescale 1ns / 1ps

module DC_deger#(parameter uzunluk=2)(
    input en_i, clk_i, rst_i,
    input [uzunluk-1:0] giris_i,
    output [3:0] cikis_o // max 11 degeri cikar o da 4 bitle ifade edilebilir. ( bir sonraki sayi kaç bit olacak)
    // output [max:0] kaydirma_deger // max hesapla
    );
    
    reg [3:0] cikis_deger,cikis_deger_ata,cikis_degerr;
    integer sayac = 0;
    reg [3:0] durum = 0;
    reg [uzunluk-1:0] giris_deger;
    assign cikis_o = cikis_degerr;
    //  011 10 0010011   DC-MATRİSTEKİ 1. SATIR => 3 (4)7 (5)9  
    always@(posedge clk_i)begin
        if(rst_i)begin
        end else begin
            if(en_i == 1) begin
                sayac = sayac+1;
                case(durum)
                    0:begin
                        if(sayac<=3) begin
                            giris_deger = giris_i;
                        end
                        else begin
                            durum = 1;
                        end 
                    end
                    1:begin
                        if(uzunluk==2)begin                                                                    
                            if(giris_deger == 2'b00)begin                                                          
                                cikis_deger = 0; // 0                                                          
                                // kaydirma_deger = 3 // uzunluk+bir sonraki sayi kaç bit ile ifade edilir 
                                durum = 2;    
                            end else begin
                                cikis_deger = 4'bxxxx;   
                                durum = 2;
                            end                                                                             
                        end                                                                                      
                        else if(uzunluk == 3) begin                                                            
                            if(giris_deger == 3'b010)begin                                                         
                                cikis_deger = 4'b0001; // 1                                                    
                                durum = 2;   
                            end                                                                                
                            else if(giris_deger == 3'b011)begin                                                    
                                cikis_deger = 4'b0010; // 2 
                                durum = 2;                                                   
                            end                                                                                
                            else if(giris_deger == 3'b100)begin                                                    
                                cikis_deger = 4'b0011; // 3 
                                durum = 2;                                                   
                            end                                                                                
                            else if(giris_deger == 3'b101)begin                                                    
                                cikis_deger = 4'b0100; // 4  
                                durum = 2;                                                  
                            end                                                                                
                            else if(giris_deger == 3'b110)begin                                                    
                                cikis_deger = 4'b0101; // 5  
                                durum = 2;                                                  
                            end                                                                                
                            else begin                                                                         
                                cikis_deger = 4'bxxxx;   
                                durum = 2;                                                      
                            end                                                                                
                        end                                                                                    
                                                                                                               
                        else if(uzunluk==4)begin                                                               
                            if(giris_deger == 4'b1110)begin                                                        
                                cikis_deger = 4'b0110; // 6  
                                durum = 2;                                                  
                            end                                                                                
                        end                                                                                    
                                                                                                               
                        else if(uzunluk==5)begin                                                               
                            if(giris_deger == 5'b11110)begin                                                       
                                cikis_deger = 4'b0111; // 7   
                                durum = 2;                                                 
                            end                                                                                
                        end                                                                                    
                                                                                                               
                        else if(uzunluk==6)begin                                                               
                            if(giris_deger == 6'b111110)begin                                                      
                                cikis_deger = 4'b1000;  // 8 
                                durum = 2;                                                  
                            end                                                                                
                        end                                                                                    
                                                                                                               
                        else if(uzunluk==7)begin                                                               
                            if(giris_deger == 7'b1111110)begin                                                     
                                cikis_deger = 4'b1001;  // 9   
                                durum = 2;                                                
                            end                                                                                
                        end                                                                                    
                                                                                                               
                        else if(uzunluk==8)begin                                                               
                            if(giris_deger ==8'b11111110)begin                                                     
                                cikis_deger = 4'b1010;  // 10  
                                durum = 2;                                                
                            end                                                                                
                        end                                                                                    
                                                                                                               
                        else if(uzunluk==9)begin                                                               
                            if(giris_deger == 9'b111111110)begin                                                   
                                cikis_deger = 4'b1011;  // 11    
                                durum = 2;                                              
                            end                                                                                
                        end                                                                                    
                        else begin                                                                             
                            cikis_deger = 4'bxxxx;           
                            durum = 2;                                                  
                        end 
                    end
                    2:begin
                        cikis_degerr = cikis_deger;
                        durum = 3;
                    end
                    3:begin
                        durum <= 0;
                        sayac = 0;
                    end
                endcase     
            end else begin
            end
        end 
    end
endmodule
