`timescale 100ns / 1ps                                                                       


module gorev2_top_tb(
    
    input clk_i, rst_i,en_i,
    output reg [7:0] son_o
    );  
    reg [4:0] durum = 0;
    integer sayac = 0, gec = 0;   
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
    
    
    
    parameter deger = 76800;
    reg [7:0] mem [0:deger-1];
    initial begin
        //1.clk'ta çalışacak. dosya okunacak
        //binary olarak kaydedecek resmi
        //veriler tamponda yani tamamı tek seferde alındı
        $readmemb("D:/verilog/g_pixel_values.txt",mem);   
    end
    
    integer ind = 0, indis = 0;
    wire veri_gonder, veri_al;
    reg en_gorev2;
    reg [7:0] veri_i_gorev2;
    wire [7:0] veri_o_gorev2;
    wire islem_bitti;
    wire [5:0] durum_oku;
    wire [16:0] indis_kontrol;
    
    reg [7:0] cikti_mem [0:deger-1];
    //reg [7:0] cikti [0:63];
    
    

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
                        if(ind < deger)begin
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
                        en_gorev2 <= 1;
                        durum <= 3;
                    end 
                    
                    // ALT MODULE GONDER
                    3:begin
                        if(en_gorev2==1)begin
                            if(veri_al == 1)begin
                                if(ind < deger)begin
                                    if(gec < 2)begin
                                        gec <= gec + 1;
                                        veri_i_gorev2 <= data_o_ram1;
                                    end else begin
                                        ind <= ind + 1;
                                        gec <= 0;
                                        durum <= 4;
                                    end 
                                end else begin
                                    ind <= 0;
                                    en_ram2 = 1;
                                    we_ram2 = 1;
                                    addr_ram2 = 0;
                                    durum <= 5;
                                end
                            end else begin
                                ind <= 0;
                                en_ram2 = 1;
                                we_ram2 = 1;
                                addr_ram2 = 0;
                                durum <= 5;
                            end
                       end else begin
                          ind <= 0;
                          en_ram2 = 1;
                          we_ram2 = 1;
                          addr_ram2 = 0;
                          durum <= 5;
                            
                            
                       end 
                    end 
                    
                    4:begin
                        addr_ram1 <= ind;
                        durum <= 3;
                    end
                    
                    5:begin
                        if(islem_bitti == 1)begin
                            if(veri_gonder == 1)begin
                                if(indis < deger)begin 
                                    if(indis < 1)begin
                                        if(gec < 4)begin  
                                        gec <= gec + 1;
                                        en_ram2 = 1;
                                        we_ram2 = 1; // okuma
                                        cikti_mem[indis] <= veri_o_gorev2;
                                        data_i_ram2 <= veri_o_gorev2;
                                    end else begin
                                        gec <= 0;
                                        indis <= indis + 1;
                                        durum <= 6;
                                    end
                                    end else begin
                                        if(gec < 2)begin  
                                            gec <= gec + 1;
                                            en_ram2 = 1;
                                            we_ram2 = 1; // okuma
                                            cikti_mem[indis] <= veri_o_gorev2;
                                            data_i_ram2 <= veri_o_gorev2;
                                        end else begin
                                            gec <= 0;
                                            indis <= indis + 1;
                                            durum <= 6;
                                        end
                                    end  
                                      
                                end else begin
                                    ind <= 0;
                                    en_ram2 = 0;
                                    we_ram2 = 0; // okuma
                                    addr_ram2 = ind; 
                                    durum <= 7;
                                end
                            end else begin
                            end 
                        end
                    end   
                    6:begin
                        addr_ram2 <= indis;
                        durum <= 5;
                    end
                    7:begin
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
        f=$fopen("D:/verilog/cikti.txt","w"); 
      end
        initial begin
              #20000000
              for (j = 0; j<deger; j=j+1) 
                  $fwrite(f,"%d\n",cikti_mem[j]); 
              #20000500
              $fclose(f);
        end
    
    
    
    
    // 8 bitlik ram / 76800 satır
    ram#(.V(8),.S(76800),.A(17)) RAM1(
        .clk_i(clk_i),
        .en_i(en_ram1),
        .we_i(we_ram1),
        .address_i(addr_ram1),
        .data_i(data_i_ram1),
        .data_o(data_o_ram1)
    );
    
    
    gorev_2 GOREV2( 
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_gorev2),
    .veri_i(veri_i_gorev2),
    .veri_o(veri_o_gorev2),
    .veri_al_o(veri_al),   
    .veri_gonder_o(veri_gonder),
    .islem_bitti_o(islem_bitti),
    .durum_oku_o(durum_oku),
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
