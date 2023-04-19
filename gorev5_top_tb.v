`timescale 100ns / 1ps

module gorev5_top(
    
    input clk_i, rst_i,en_i,
    output reg  son_o
    );
    
    reg [6:0] durum = 0;
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
    
    // ram_htable
    reg en_ram_htable;
    reg we_ram_htable;
    reg [8:0] addr_ram_htable;
    reg [31:0] data_i_ram_htable;
    wire [31:0] data_o_ram_htable;
    
    
    
    parameter max_row = 76800;
    reg [7:0] mem [0:max_row-1];
    reg [31:0] mem1 [0:255];
    initial begin
        $readmemb("D:\\vivado\\asil_resim.txt",mem);  
    end
    initial begin
        $readmemb("D:\\vivado\\histogram_table.txt",mem1);  
    end
    
    integer ind = 0, indis = 0;
    
    // GOREV 5
    wire veri_gonder, veri_al;
    wire veri_al_his;
    reg en_gorev5;
    reg [7:0] veri_i_gorev5;
    reg [31:0] veri_histogram;
    wire [7:0] veri_o_gorev5;
    wire islem_bitti;
    
    reg [7:0] cikti_mem [0:max_row-1];

    reg bit = 0;
    
    parameter 
            VERI_GONDER_HIS1 = 8, 
            VERI_GONDER_HIS2 = 9,
            VERI_GONDER_HIS3 = 10,
            VERI_GONDER_GOREV1 = 11, 
            VERI_GONDER_GOREV2 = 12, 
            VERI_GONDER_GOREV3 = 13,
            VERI_GONDER_GOREV4 = 14,
            VERI_AL_GOREV1 = 15, 
            VERI_AL_GOREV2 = 16, 
            VERI_AL_GOREV3 = 17, 
            VERI_AL_GOREV4 = 18, 
            VERI_AL_GOREV5 = 19, 
            VERI_AL_GOREV6 = 20;
            
              
    always@(posedge clk_i)begin
        if(rst_i)begin
        end else begin
            if(en_i)begin
                sayac <= sayac + 1;
                case(durum)
                
                    // VERILERI RAM E YAZMA
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
                        ind <= 0;
                        durum <= 3;
                    end 
                    
                    3:begin
                        en_ram_htable = 1;
                        we_ram_htable = 1;
                        addr_ram_htable <= ind;
                        durum = 4;
                    end 
                    
                    4:begin
                        if(ind < 256)begin
                            if(gec < 1)begin
                                gec <= gec + 1;
                                data_i_ram_htable <= mem1[ind];
                            end else begin
                                gec <= 0;
                                ind <= ind + 1;
                                durum <= 3;
                            end 
                        end else begin
                            addr_ram1 <= 0;
                            ind <= 0;
                            durum <= 5;
                        end
                    end 
                    
                    5:begin
                        en_ram_htable = 1;
                        we_ram_htable = 0;
                        en_gorev5 <= 1;
                        addr_ram_htable <= 0;
                        durum <= VERI_GONDER_HIS1;
                    end 
                    
                    
                    // HISTOGRAM ALT MODULE GONDER
                    VERI_GONDER_HIS1:begin
                        if(veri_al_his == 1 && ind < 256)begin
                            durum <= VERI_GONDER_HIS2;
                        end else begin
                            ind <= 0;
//                            en_ram1 = 1;
//                            we_ram1 = 0; // okuma
                            addr_ram1 = 0;
                            durum <= VERI_GONDER_GOREV1;
                        end
                    end      
                    VERI_GONDER_HIS2:begin
                        if(gec < 3)begin  // 3
                            gec <= gec + 1;
                            veri_histogram <= data_o_ram_htable;
                        end else begin
                            ind <= ind + 1;
                            gec <= 0;
                            durum <= VERI_GONDER_HIS3;
                        end
                    end 
                    
                    VERI_GONDER_HIS3:begin
                        addr_ram_htable <= ind;
                        durum <= VERI_GONDER_HIS1;
                    end
                    
                    // ASIL VERI ALT MODULE GONDER
                    
                    VERI_GONDER_GOREV1:begin
                        if(veri_al == 1)begin
                            durum <= VERI_GONDER_GOREV2;
                        end else begin
                            ind <= 0;
                        end
                    end 
                    VERI_GONDER_GOREV2:begin
                        if(ind < max_row)begin
                            durum <= VERI_GONDER_GOREV3;
                        end else begin
                            ind <= 0;
                            en_ram2 = 1;
                            we_ram2 = 1;
                            addr_ram2 = 0;
                            durum <= VERI_AL_GOREV1;
                        end 
                    end 
                    VERI_GONDER_GOREV3:begin
                        if(gec < 4)begin  // 3
                            gec <= gec + 1;
                            en_ram1 = 1;
                            we_ram1 = 0; // okuma
                            veri_i_gorev5 <= data_o_ram1;
                        end else begin
                            ind <= ind + 1;
                            gec <= 0;
                            durum <= VERI_GONDER_GOREV4;
                        end
                    end
                    VERI_GONDER_GOREV4:begin
                        addr_ram1 <= ind;
                        durum <= VERI_GONDER_GOREV2;
                    end
                    
                     // ALT MODULDEN AL
                    VERI_AL_GOREV1:begin
                        if(islem_bitti == 1 && veri_gonder == 1)begin
                            durum <= VERI_AL_GOREV2;
                        end else begin
                            bit <= 1;
                        end 
                    end
                    
                    VERI_AL_GOREV2:begin
                        if(indis < max_row)begin
                            durum <= VERI_AL_GOREV3;
                        end else begin
                            //indis <= 0;
                            ind <= 0;
                            en_ram2 = 1;
                            we_ram2 = 0; // okuma
                            addr_ram2 = ind; 
                            durum <= 21;
                        end 
                    end 
                    
                    VERI_AL_GOREV3:begin
                        if(indis < 1)begin
                            durum <= VERI_AL_GOREV4;
                        end else begin
                            durum <= VERI_AL_GOREV5;
                        end 
                    end 
                    
                    VERI_AL_GOREV4:begin
                        if(gec < 2)begin   //8
                            gec <= gec + 1;
                            en_ram2 = 1;
                            we_ram2 = 1; // yazma
                            cikti_mem[indis] <= veri_o_gorev5;
                            data_i_ram2 <= veri_o_gorev5;
                        end else begin
                            gec <= 0;
                            indis <= indis + 1;
                            durum <= VERI_AL_GOREV6;
                        end
                    end
                    
                    VERI_AL_GOREV5:begin
                        if(gec < 2)begin  
                            gec <= gec + 1;
                            en_ram2 = 1;
                            we_ram2 = 1; // yazma
                            cikti_mem[indis] <= veri_o_gorev5;
                            data_i_ram2 <= veri_o_gorev5;
                        end else begin
                            gec <= 0;
                            indis <= indis + 1;
                            durum <= VERI_AL_GOREV6;
                        end
                    end 
                    
                    VERI_AL_GOREV6:begin
                        addr_ram2 <= indis;
                        durum <= VERI_AL_GOREV2;
                    end 
                    
                    21:begin
                        son_o <= 1;
                    end 
                    
                    
                endcase
            end else begin 
            end
        end 
    end 
    
    
    integer j,f;
   
    initial begin 
        #7700
        f=$fopen("D:\\vivado\\gorev5_cikti.txt","w"); 
      end
        initial begin
              #1534212
              for (j = 0; j<max_row; j=j+1) 
                  $fwrite(f,"%d\n",cikti_mem[j]); 
              #1534712
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
    
    // 8 bitlik ram / 76800 satır
    ram#(.V(32),.S(256),.A(9)) RAM_HISTORGAM_TABLE(
        .clk_i(clk_i),
        .en_i(en_ram_htable),
        .we_i(we_ram_htable),
        .address_i(addr_ram_htable),
        .data_i(data_i_ram_htable),
        .data_o(data_o_ram_htable)
    );
    
    gorev5 gorev5_histogram_esit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_gorev5),
    .veri_i(veri_i_gorev5),
    .veri_o(veri_o_gorev5),
    .veri_al_o(veri_al),  
    .veri_al_his_o(veri_al_his),
    .veri_histogram_i(veri_histogram), 
    .veri_gonder_o(veri_gonder),
    .islem_bitti_o(islem_bitti));
    


    
    
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
