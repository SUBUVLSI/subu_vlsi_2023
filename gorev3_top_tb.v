`timescale 100ns / 1ps                                                                                                                                                                 
                                                                                                                                                                                    
module gorev3_top_tb(                                                                                                                                                               
    input clk_i, rst_i,en_i,                                                                                                                                                        
    output reg [7:0] son_o                                                                                                                                                          
    );                                                                                                                                                                              
    reg [4:0] durum =0;                                                                                                                                                             
    reg [17:0] sayac = 0, gec = 0,ind = 0 , indis=0, i=0;                                                                                                                           
    // RAM1                                                                                                                                                                         
    reg en_ram1;                                                                                                                                                                    
    reg we_ram1;                                                                                                                                                                    
    reg [16:0] addr_ram1;                                                                                                                                                           
    reg [7:0] data_i_ram1;                                                                                                                                                          
    wire [7:0] data_o_ram1;                                                                                                                                                         
                                                                                                                                                                                    
    // RAM2                                                                                                                                                                         
    reg en_ram2;                                                                                                                                                                    
    reg we_ram2;                                                                                                                                                                    
    reg [16:0] addr_ram2;                                                                                                                                                           
    reg [7:0] data_i_ram2;                                                                                                                                                          
    wire [7:0] data_o_ram2;                                                                                                                                                         
                                                                                                                                                                                    
                                                                                                                                                                                    
    reg [17:0] ic_sayac=0;                                                                                                                                                          
    parameter deger = 76800;                                                                                                                                                        
    reg [7:0] mem [0:deger-1];                                                                                                                                                      
    initial begin                                                                                                                                                                   
        $readmemb("D:/g_pixel_values.txt",mem);                                                                                                                                     
    end                                                                                                                                                                             
    wire veri_gonder, veri_al;                                                                                                                                                      
    reg en_gorev3;                                                                                                                                                                  
    reg [7:0] veri_i_gorev3;                                                                                                                                                        
    wire [7:0] veri_o_gorev3;                                                                                                                                                       
    wire islem_bitti;                                                                                                                                                               
    wire bitti_g;                                                                                                                                                                   
    wire [5:0] durum_oku;                                                                                                                                                           
    wire [16:0] indis_kontrol;                                                                                                                                                      
                                                                                                                                                                                    
    reg [7:0] cikti_mem [0:deger-1];                                                                                                                                                
                                                                                                                                                                                    
    always@(posedge clk_i)begin                                                                                                                                                     
        if(rst_i)begin                                                                                                                                                              
        end else begin                                                                                                                                                              
            if(en_i)begin                                                                                                                                                           
                sayac <= sayac + 1;                                                                                                                                                 
                case(durum)                                                                                                                                                         
                    0:begin                                                                                                                                                         
                        en_ram1 = 1;                                                                                                                                                
                        we_ram1 = 1;                                                                                                                                                
                        addr_ram1 <= ind;                                                                                                                                           
                        durum = 1;                                                                                                                                                  
                    end                                                                                                                                                             
                                                                                                                                                                                    
                    1:begin                                                                                                                                                         
                        if(ind <deger)begin                                                                                                                                         
                            if(gec < 1)begin                                                                                                                                        
                                gec <= gec + 1;                                                                                                                                     
                                data_i_ram1 <= mem[ind];                                                                                                                            
                            end else begin                                                                                                                                          
                                gec <= 0;                                                                                                                                           
                                ind <= ind + 1;                                                                                                                                     
                                durum <= 0;                                                                                                                                         
                            end                                                                                                                                                     
                        end else begin                                                                                                                                              
                            addr_ram1 <= 0;                                                                                                                                         
                            ind <= 0;                                                                                                                                               
                            durum <= 2;                                                                                                                                             
                        end                                                                                                                                                         
                    end                                                                                                                                                             
                                                                                                                                                                                    
                    2:begin                                                                                                                                                         
                        en_ram1 = 1;                                                                                                                                                
                        we_ram1 = 0;                                                                                                                                                
                        en_gorev3 <= 1;                                                                                                                                             
                        durum <= 3;                                                                                                                                                 
                    end                                                                                                                                                             
                                                                                                                                                                                    
                    // ALT MODULE GONDER                                                                                                                                            
                    3:begin                                                                                                                                                         
                        // IFLERI AYIR                                                                                                                                              
                        if(veri_al == 1 && ind < deger)begin                                                                                                                        
                            durum <= 4;                                                                                                                                             
                        end else begin                                                                                                                                              
                            ind <= 0;                                                                                                                                               
                            en_ram2 = 1;                                                                                                                                            
                            we_ram2 = 1;                                                                                                                                            
                            addr_ram2 = 0;                                                                                                                                          
                            durum <= 6;                                                                                                                                             
                        end                                                                                                                                                         
                    end                                                                                                                                                             
                                                                                                                                                                                    
                    4:begin                                                                                                                                                         
                       if(gec <3)begin // 2                                                                                                                                         
                           gec <= gec + 1;                                                                                                                                          
                           veri_i_gorev3 <= data_o_ram1;                                                                                                                            
                       end else begin                                                                                                                                               
                           ind <= ind + 1;                                                                                                                                          
                           gec <= 0;                                                                                                                                                
                           durum <= 5;                                                                                                                                              
                       end                                                                                                                                                          
                    end                                                                                                                                                             
                                                                                                                                                                                    
                    5:begin                                                                                                                                                         
                        addr_ram1 <= ind;                                                                                                                                           
                        durum <= 3;                                                                                                                                                 
                    end                                                                                                                                                             
                                                                                                                                                                                    
                    // ALT MODULDEN AL                                                                                                                                              
                    6:begin                                                                                                                                                         
                        if(islem_bitti == 1 && veri_gonder == 1)begin                                                                                                               
                            durum <= 7;                                                                                                                                             
                        end else begin                                                                                                                                              
                                                                                                                                                                                    
                        end                                                                                                                                                         
                    end                                                                                                                                                             
                                                                                                                                                                                    
                    7:begin                                                                                                                                                         
                        if(indis < deger)begin                                                                                                                                      
                            durum <= 8;                                                                                                                                             
                        end else begin                                                                                                                                              
                            indis <= 0;                                                                                                                                             
                            ind <= 0;                                                                                                                                               
                            en_ram2 = 0;                                                                                                                                            
                            we_ram2 = 0; // okuma                                                                                                                                   
                            addr_ram2 = ind;                                                                                                                                        
                                                                                                                                                                                    
                            durum <= 12;                                                                                                                                            
                        end                                                                                                                                                         
                                                                                                                                                                                    
                    end                                                                                                                                                             
                    8:begin                                                                                                                                                         
                        if(indis < 1)begin                                                                                                                                          
                            durum <= 9;                                                                                                                                             
                        end else begin                                                                                                                                              
                            durum <= 10;                                                                                                                                            
                        end                                                                                                                                                         
                    end                                                                                                                                                             
                                                                                                                                                                                    
                    9:begin                                                                                                                                                         
                        if(gec <6)begin                                                                                                                                             
                            gec <= gec + 1;                                                                                                                                         
                            en_ram2 = 1;                                                                                                                                            
                            we_ram2 = 1; // yazma                                                                                                                                   
                            cikti_mem[indis] <= veri_o_gorev3;                                                                                                                      
                            data_i_ram2 <= veri_o_gorev3;                                                                                                                           
                        end else begin                                                                                                                                              
                            gec <= 0;                                                                                                                                               
                            indis <= indis + 1;                                                                                                                                     
                            durum <= 11;                                                                                                                                            
                        end                                                                                                                                                         
                    end                                                                                                                                                             
                                                                                                                                                                                    
                    10:begin                                                                                                                                                        
                        if(gec <3)begin                                                                                                                                             
                            gec <= gec + 1;                                                                                                                                         
                            en_ram2 = 1;                                                                                                                                            
                            we_ram2 = 1; // yazma                                                                                                                                   
                            cikti_mem[indis] <= veri_o_gorev3;                                                                                                                      
                            data_i_ram2 <= veri_o_gorev3;                                                                                                                           
                        end else begin                                                                                                                                              
                            gec <= 0;                                                                                                                                               
                            indis <= indis + 1;                                                                                                                                     
                            durum <= 11;                                                                                                                                            
                        end                                                                                                                                                         
                    end                                                                                                                                                             
                                                                                                                                                                                    
                    11:begin                                                                                                                                                        
                        addr_ram2 <= indis;                                                                                                                                         
                        durum <= 7;                                                                                                                                                 
                    end                                                                                                                                                             
                                                                                                                                                                                    
                    12:begin                                                                                                                                                        
                        son_o <= 1;                                                                                                                                                 
                    end                                                                                                                                                             
                                                                                                                                                                                    
                                                                                                                                                                                    
                endcase                                                                                                                                                             
            end else begin                                                                                                                                                          
            end                                                                                                                                                                     
        end                                                                                                                                                                         
    end                                                                                                                                                                             
                                                                                                                                                                                    
                                                                                                                                                                                    
    integer j,f;                                                                                                                                                                    
                                                                                                                                                                                    
                                                                                                                                                                                    
     initial begin                                                                                                                                                                  
        #77000                                                                                                                                                                      
        f=$fopen("D:/gorev3_testb.txt","w");                                                                                                                                        
      end                                                                                                                                                                           
        initial begin                                                                                                                                                               
              #20000000                                                                                                                                                             
              for (j = 0; j<deger; j=j+1)                                                                                                                                           
                  $fwrite(f,"%d\n",cikti_mem[j]);                                                                                                                                   
              #20000500                                                                                                                                                             
              $fclose(f);                                                                                                                                                           
        end                                                                                                                                                                         
                                                                                                                                                                                    
                                                                                                                                                                                    
                                                                                                                                                                                    
                                                                                                                                                                                    
    // 8 bitlik ram / 76800 satır                                                                                                                                                   
    ram1#(.V(8),.S(76800),.A(17)) RAM1(                                                                                                                                             
        .clk_i(clk_i),                                                                                                                                                              
        .en_i(en_ram1),                                                                                                                                                             
        .we_i(we_ram1),                                                                                                                                                             
        .address_i(addr_ram1),                                                                                                                                                      
        .data_i(data_i_ram1),                                                                                                                                                       
        .data_o(data_o_ram1)                                                                                                                                                        
    );                                                                                                                                                                              
                                                                                                                                                                                    
                                                                                                                                                                                    
    gorev3 GOREV3(                                                                                                                                                              
    .clk_i(clk_i),                                                                                                                                                                  
    .rst_i(rst_i),                                                                                                                                                                  
    .en_i(en_gorev3),                                                                                                                                                               
    .veri_i(veri_i_gorev3),                                                                                                                                                         
    .veri_o(veri_o_gorev3),                                                                                                                                                         
    .veri_al_o(veri_al),                                                                                                                                                            
    .veri_gonder_o(veri_gonder),                                                                                                                                                    
    .islem_bitti_o(islem_bitti),                                                                                                                                                    
    .durum_oku_o(durum_oku),                                                                                                                                                        
    .bitti(bitti_g),                                                                                                                                                                
    .indis_kontrol(indis_kontrol));                                                                                                                                                 
                                                                                                                                                                                    
                                                                                                                                                                                    
                                                                                                                                                                                    
    // 8 bitlik ram / 76800 satır                                                                                                                                                   
    ram#(.V(8),.S(76800),.A(17)) RAM2(                                                                                                                                             
        .clk_i(clk_i),                                                                                                                                                              
        .en_i(en_ram2),                                                                                                                                                             
        .we_i(we_ram2),                                                                                                                                                             
        .address_i(addr_ram2),                                                                                                                                                      
        .data_i(data_i_ram2),                                                                                                                                                       
        .data_o(data_o_ram2)                                                                                                                                                        
    );                                                                                                                                                                              
endmodule
