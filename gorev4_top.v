`timescale 100ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.02.2023 13:11:42
// Design Name: 
// Module Name: gorev4_top
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

module gorev4_top(
    
    input clk_i, rst_i,en_i,
    output reg  son_o
   

    );
    
    
    reg [0:4] durum = 0;
    integer sayac = 0, gec = 0;
    
    
    // RAM1
    reg en_ram1;
    reg we_ram1;
    reg [16:0] addr_ram1;
    reg [7:0] data_i_ram1;
    wire [7:0] data_o_ram1;
    
    // ram_htable
    reg en_ram_htable;
    reg we_ram_htable;
    reg [8:0] addr_ram_htable;
    reg [7:0] data_i_ram_htable;
    wire [31:0] data_o_ram_htable;
    
    
    
    parameter max_row = 76800;
    reg [7:0] mem [0:max_row-1];
    
    initial begin
        $readmemb("D:\\vivado\\asil_resim.txt",mem);  
    end
    
    integer ind = 0, indis = 0;
    wire veri_gonder, veri_al;
    reg en_gorev4;
    reg [7:0] veri_i_gorev4;
    wire [31:0] veri_o_gorev4;
    wire islem_bitti;
    wire [5:0] durum_oku;
    wire [16:0] indis_kontrol;
    
    reg [31:0] cikti_mem [0:255];

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
                        en_gorev4 <= 1;
                        durum <= 3;
                    end 
                    
                    // ALT MODULE GONDER
                    3:begin
                        if(veri_al == 1)begin
                            if(ind < max_row)begin
                                if(gec <2)begin // 2
                                    gec <= gec + 1;
                                    veri_i_gorev4 <= data_o_ram1;
                                end else begin
                                    ind <= ind + 1;
                                    gec <= 0;
                                    durum <= 4;
                                end 
                            end else begin
                                ind <= 0;
                                en_ram_htable = 1;
                                we_ram_htable = 1;
                                addr_ram_htable = 0;
                                durum <= 5;
                            end
                        end else begin
                            en_ram_htable = 1;
                            we_ram_htable = 1;
                            addr_ram_htable = 0;
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
                                if(indis < 256)begin 
                                    if(indis < 1)begin
                                        if(gec < 2)begin   //8
                                        gec <= gec + 1;
                                        en_ram_htable = 1;
                                        we_ram_htable = 1; // yazma
                                        cikti_mem[indis] <= veri_o_gorev4;
                                        data_i_ram_htable <= veri_o_gorev4;
                                    end else begin
                                        gec <= 0;
                                        indis <= indis + 1;
                                        durum <= 6;
                                    end
                                    end else begin
                                        if(gec < 2)begin  
                                            gec <= gec + 1;
                                            en_ram_htable = 1;
                                            we_ram_htable = 1; // yazma
                                            cikti_mem[indis] <= veri_o_gorev4;
                                            data_i_ram_htable <= veri_o_gorev4;
                                        end else begin
                                            gec <= 0;
                                            indis <= indis + 1;
                                            durum <= 6;
                                        end
                                    end  
                                      
                                end else begin
                                    //indis <= 0;
                                    ind <= 0;
                                    en_ram_htable = 0;
                                    we_ram_htable = 0; // okuma
                                    addr_ram_htable = ind; 
                                    durum <= 7;
                                end
                            end else begin
                            end 
                        end
                    end 
                    
                    6:begin
                        addr_ram_htable <= indis;
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
    /*
     initial begin 
        #7700
        f=$fopen("D:\\vivado\\gorev4_cikti.txt","w"); 
      end
        initial begin
              #3434496
              for (j = 0; j<256; j=j+1) 
                  $fwrite(f,"%b\n",cikti_mem[j]); 
              #3439496
              $fclose(f);
        end
    */
    initial begin 
        #7700
        f=$fopen("D:\\vivado\\gorev4_cikti.txt","w"); 
      end
        initial begin
              #1000000
              for (j = 0; j<256; j=j+1) 
                  $fwrite(f,"%b\n",cikti_mem[j]); 
              #1000100
              $fclose(f);
        end
    
    
    // 8 bitlik ram / 76800 sat�r
    ram#(.V(8),.S(76800),.A(17)) RAM1(
        .clk_i(clk_i),
        .en_i(en_ram1),
        .we_i(we_ram1),
        .address_i(addr_ram1),
        .data_i(data_i_ram1),
        .data_o(data_o_ram1)
    );
    
    
    gorev4_histogram_table gorev4_htable(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_gorev4),
    .veri_i(veri_i_gorev4),
    .veri_o(veri_o_gorev4),
    .veri_al_o(veri_al),   
    .veri_gonder_o(veri_gonder),
    .islem_bitti_o(islem_bitti));
    


    // 8 bitlik ram / 76800 sat�r
    ram#(.V(32),.S(256),.A(9)) RAM_HISTORGAM_TABLE(
        .clk_i(clk_i),
        .en_i(en_ram_htable),
        .we_i(we_ram_htable),
        .address_i(addr_ram_htable),
        .data_i(data_i_ram_htable),
        .data_o(data_o_ram_htable)
    );
endmodule
