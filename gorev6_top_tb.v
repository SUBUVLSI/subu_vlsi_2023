`timescale 100ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.02.2023 13:11:42
// Design Name: 
// Module Name: gorev6_top_tb
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

module gorev6_top_tb(
    
    input clk_i, rst_i,en_i,
    output reg [7:0] son_o
   

    );
    
    
    reg [0:4] durum = 0;
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
    
    
    
    parameter max_row = 76800;
    reg [7:0] mem [0:max_row-1];
    initial begin
        //1.clk'ta çalýþacak. dosya okunacak
        //binary olarak kaydedecek resmi
        //veriler tamponda yani tamamý tek seferde alýndý
        $readmemb("D:\\vivado\\asil_resim.txt",mem);  
    end
    
    integer ind = 0, indis = 0;
    wire veri_gonder, veri_al;
    reg en_gorev6;
    reg [7:0] veri_i_gorev6;
    wire [7:0] veri_o_gorev6;
    wire islem_bitti;
    wire [5:0] durum_oku;
    wire [16:0] indis_kontrol;
    
    reg [7:0] cikti_mem [0:max_row-1];
    reg [7:0] cikti [0:63];

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
                        if(ind < max_row)begin
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
                        en_gorev6 <= 1;
                        durum <= 3;
                    end 
                    
                    // ALT MODULE GONDER
                    3:begin
                        if(veri_al == 1)begin
                            if(ind < max_row)begin
                                if(gec < 2)begin
                                    gec <= gec + 1;
                                    veri_i_gorev6 <= data_o_ram1;
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
                                if(indis < max_row)begin 
                                    if(indis < 1)begin
                                        if(gec < 8)begin  
                                        gec <= gec + 1;
                                        en_ram2 = 1;
                                        we_ram2 = 0; // okuma
                                        cikti_mem[indis] <= veri_o_gorev6;
                                        data_i_ram2 <= veri_o_gorev6;
                                    end else begin
                                        gec <= 0;
                                        indis <= indis + 1;
                                        durum <= 6;
                                    end
                                    end else begin
                                        if(gec < 2)begin  
                                            gec <= gec + 1;
                                            en_ram2 = 1;
                                            we_ram2 = 0; // okuma
                                            cikti_mem[indis] <= veri_o_gorev6;
                                            data_i_ram2 <= veri_o_gorev6;
                                        end else begin
                                            gec <= 0;
                                            indis <= indis + 1;
                                            durum <= 6;
                                        end
                                    end  
                                      
                                end else begin
                                    //indis <= 0;
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
                    
                    /*
                    7:begin
                        if(ind < max_row)begin
                            cikti_mem[indis] <= data_o_ram2;
                            addr_ram2 <= ind;
                            ind <= ind + 1;
                            
                        end else begin
                            durum <= 8;
                        end
                    end
                    
                    8:begin
                        son_o <= 1;
                    end
                    */
                endcase
            end else begin 
            end
        end 
    end 
    
    
    integer j,f;
    
     initial begin 
        #7700
        f=$fopen("D:\\vivado\\gorev6_top_deneme.txt","w"); 
      end
        initial begin
              #4092556
              for (j = 0; j<max_row; j=j+1) 
                  $fwrite(f,"%d\n",cikti_mem[j]); 
              #4093556
              $fclose(f);
        end
    
    
    
    
    // 8 bitlik ram / 76800 satýr
    ram#(.V(8),.S(76800),.A(17)) RAM1(
        .clk_i(clk_i),
        .en_i(en_ram1),
        .we_i(we_ram1),
        .address_i(addr_ram1),
        .data_i(data_i_ram1),
        .data_o(data_o_ram1)
    );
    
    
    gorev_6 GOREV6(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_gorev6),
    .veri_i(veri_i_gorev6),
    .veri_o(veri_o_gorev6),
    .veri_al_o(veri_al),   
    .veri_gonder_o(veri_gonder),
    .islem_bitti_o(islem_bitti),
    .durum_oku_o(durum_oku),
    .indis_kontrol(indis_kontrol));
    


    // 8 bitlik ram / 76800 satýr
    ram#(.V(8),.S(76800),.A(17)) RAM2(
        .clk_i(clk_i),
        .en_i(en_ram2),
        .we_i(we_ram2),
        .address_i(addr_ram2),
        .data_i(data_i_ram2),
        .data_o(data_o_ram2)
    );
endmodule
