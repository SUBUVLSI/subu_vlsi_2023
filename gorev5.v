
`timescale 1ns / 1ps


module gorev5(
        input clk_i, rst_i,en_i,
        input [7:0] veri_i,
        input [31:0] veri_histogram_i,
        output veri_al_o,veri_al_his_o,veri_gonder_o,
        output [7:0] veri_o,
        output islem_bitti_o

    );
    
    parameter max_row = 76800;
    
    parameter 
            VERI_AL1_HIS = 18, VERI_AL2_HIS = 19, VERI_AL3_HIS = 20, ILK_VERI_HIS = 21, DIGER_VERILER_HIS = 22,
            VERI_AL1 = 24, VERI_AL2 = 25, VERI_AL3 = 26, ILK_VERI = 27 , DIGER_VERILER = 28, ISLEM =  29,
            VERI_GONDER1 = 31, VERI_GONDER2 = 32,VERI_GONDER3 = 33;
            
            
    reg [6:0] durum = VERI_AL1_HIS; // 5'b00000;
    integer i = 0, sayac = 0, k = 0, m = 0, p_ind = 0, l = 0, n = 0, s = 0, z = 0;
    reg son=0;
    
    reg [23:0] histogram_out [0:255]; 
    reg [23:0] cdf_reg;
    reg [23:0] cdf [0:255];
    reg [23:0] cdf_min; 
    reg signed [7:0] eq_hist [0:255];
    reg signed [7:0] son_deg;
    reg signed [28:0] sub [0:255] ;
    reg signed [28:0] sub_deg;
    reg [23:0] sub_row;
    reg [15:0] h_sub_row;
    reg signed [7:0] div [0:255];
    reg signed [7:0] div_deg;
    
//    reg signed [28:0] round [0:255];
    reg signed [28:0] round_deg;
//    reg signed [28:0] fark [0:255];
    reg signed [28:0] fark_deg;

    reg histogram_verisi_al = 1;
    assign veri_al_his_o = histogram_verisi_al;
    reg veri_al = 0;
    assign veri_al_o = veri_al; 
    
    integer ind = 0, gec = 0, indis = 0;
    reg islem_bitti = 0;
    assign islem_bitti_o = islem_bitti;
    
    reg veri_gonder;
    assign veri_gonder_o = veri_gonder;
    
    reg [7:0] veri_o_gorev5, veri;
    assign veri_o = veri_o_gorev5;
    
    // RAM yeni_mem
    reg en_ram_yeni;
    reg we_ram_yeni;
    reg [16:0] addr_ram_yeni;
    reg  [7:0] data_i_ram_yeni;
    wire [7:0] data_o_ram_yeni;
    
    always @(posedge clk_i) begin
        if(en_i == 1)begin
            sayac <= sayac + 1;
            case(durum)
                VERI_AL1_HIS:begin
                    if(histogram_verisi_al == 1 && indis < 256)begin
                        durum <= VERI_AL2_HIS;
                    end else begin
                         histogram_verisi_al <= 0;
                         indis <= 0;
                         ind <= 0;
                         durum <= 0;
                    end 
                end 
                VERI_AL2_HIS:begin
                    if(indis < 1)begin
                        durum <= ILK_VERI_HIS;
                    end else begin
                        durum <= DIGER_VERILER_HIS;
                    end 
                end
                ILK_VERI_HIS:begin
                    if(gec < 4)begin 
                        gec <= gec + 1;
                        histogram_out[i] <= veri_histogram_i[23:0];
                    end else begin
                        gec <= 0;
                        durum <= VERI_AL3_HIS;
                    end
                end 
                DIGER_VERILER_HIS:begin
                    if(gec < 2)begin 
                        gec <= gec + 1;
                        histogram_out[indis] <= veri_histogram_i[23:0];
                    end else begin
                        gec <= 0;
                        durum <= VERI_AL3_HIS;
                    end
                end
                
                VERI_AL3_HIS:begin
                    indis <= indis + 1;
                    durum <= VERI_AL1_HIS;
                end
                
                // GOREV5 ISLEMLER
                0:begin

                    durum <= 1;
                end
                1:begin
                    if(k < 256) begin
                       cdf[k] <= 0;
                       k <= k+1;
                    end else begin
                      k <= 1;
                      durum <= 2;
                    end
                end
                2:begin
                   cdf[0] <= histogram_out[0];
                    durum <= 3;
                
                end
               3:begin
                    if(k < 256) begin
                        cdf_reg <= histogram_out[k];
                        durum <= 4;
                    end else begin
                        k <= 0;
                        durum <= 5;
                    end
                
                end

                 4:begin
                       cdf[k] <= cdf[k-1] + cdf_reg;
                       k <= k+1;
                       durum <= 3;
                    end
                 
                 5:begin
                    
                    if(m < 256) begin
                         if(cdf[m] != 0) begin
                              cdf_min <= cdf[m];
                              k <= 0;
                              durum <= 6;
                         end else begin
                            m <= m+1;
                            durum <= 5;
                         end
                    end
                    
                 end

                 6:begin
                    if(l < 256) begin
                        sub[l] <= cdf[l] - cdf_min;                    
                        durum <= 7;
                    end else begin
                        l <= 0;
                        durum <= 8;
                    end
                 
                 end
                 
                 7:begin
                    if(sub[l] < 0) begin
                        sub[l] <= 0;
                        l <= l+1;
                        durum <= 6;
                    end else begin
                        l <= l+1;
                        durum <= 6;
                    end
                 end
                 
                 8:begin
                    if(n < 256) begin
                        sub[n] <= sub[n] * 255;
                        n <= n+1;
                    end else begin
                        n <= 0;
                        durum <= 9;
                    end
                 end
                 
                 9:begin
                        sub_row <= max_row - cdf_min;
                        durum <= 16; // 10
                 end
                 
                 16:begin
                    if (s < 256) begin
                        sub_deg <= sub[s];                 
                        durum <= 10;
                    end else begin
                        s <= 0;
                        durum <= 15;
//                        durum <= VERI_AL1;
                    end
                 end 
                 10:begin
                    div_deg <= sub_deg / sub_row;  
                    durum <= 11;
       
                 end
                 
                 11:begin
                        round_deg <= div_deg * sub_row;  
                        div[s] <= div_deg;                 
                        durum <= 12;
                 end
                 
                 12:begin
                        h_sub_row <= sub_row / 2;
                        durum <= 13;
                 end
                 
                 13:begin
                        fark_deg <= sub_deg - round_deg;
                        durum <= 14;                
                 end
                 
                 14:begin
                
                    if(fark_deg >= h_sub_row) begin
                        div[s] <= div[s] +1;
                        s <= s+1;
                        durum <= 16;
                    end else begin
                        s <= s+1;
                        durum <= 16;
                    end
                 end

                 
                 15:begin
                    if (z < 256) begin
                         eq_hist[z] <= div[z];
                         z <= z+1;
                    end else begin
                         veri_al <= 1;
                         durum <= VERI_AL1; //16;
                    end
                 end
                 
     
                VERI_AL1:begin
                        if(veri_al == 1 && indis < max_row)begin
                            durum <= VERI_AL2;
                        end else begin
                            veri_al <= 0;
                            indis <= 0;
                            ind <= 0;
                            islem_bitti <= 1;
                            veri_gonder <= 1;
                            durum <= VERI_GONDER1;
                        end 
                    end 
                    
                    VERI_AL2:begin
                        if(indis < 1)begin
                            durum <= ILK_VERI;
                        end else begin
                            durum <= DIGER_VERILER;
                        end 
                    end 
                    
                    ILK_VERI:begin
                        if(gec < 4)begin 
                            gec <= gec + 1;
                            veri <= veri_i;  // her cekilmede veri dataya aktarılacak
                        end else begin
                            gec <= 0;
                            addr_ram_yeni <= p_ind;
                            durum <= ISLEM;
                        end
                    end 
                    
                    DIGER_VERILER:begin
                        if(gec < 2)begin 
                            gec <= gec + 1;
                            veri <= veri_i;  // her cekilmede veri dataya aktarılacak
                        end else begin
                            gec <= 0;
                            addr_ram_yeni <= p_ind;
                            durum <= ISLEM;
                        end
                    end 
                    
                    VERI_AL3:begin
                        indis <= indis + 1;
                        p_ind <= p_ind + 1;
                        durum <= VERI_AL1;
                    end
                    
                ISLEM:begin
                    if(p_ind < max_row)begin
                        en_ram_yeni = 1; 
                        we_ram_yeni = 1; // yazma
                        data_i_ram_yeni <= eq_hist[veri];
                        durum <= VERI_AL3;
                    end else begin
                        veri_al <= 0;
                        indis <= 0;
                        ind <= 0;
                        islem_bitti <= 1;
                        veri_gonder <= 1;
                        durum <= VERI_GONDER1;
                    end 
                end
                
                // UST MODULE YAZMA
                VERI_GONDER1:begin
                    if(veri_gonder == 1 && ind < max_row)begin
                        addr_ram_yeni <= ind;
                        durum <= VERI_GONDER2;
                    end else begin
                        durum <= 17; // SON
                    end 
                end 
                VERI_GONDER2:begin
                    if(gec < 3) begin
                        gec <= gec + 1;
                          en_ram_yeni = 1; 
                          we_ram_yeni = 0; // okuma
                          veri_o_gorev5 <= data_o_ram_yeni;
                     end else begin
                        gec <= 0;
                        durum <= VERI_GONDER3;
                    end
                end 
                
                VERI_GONDER3:begin
                    ind <= ind + 1;
                    durum <= VERI_GONDER1; 
                end 
                 
               17:begin
                    son <= 1;            
               end
            endcase
       end else begin
            
       end
    end

        
   // 8 bitlik ram / 76800 satır
    ram#(.V(8),.S(76800),.A(17)) yeni(
        .clk_i(clk_i),
        .en_i(en_ram_yeni),
        .we_i(we_ram_yeni),
        .address_i(addr_ram_yeni),
        .data_i(data_i_ram_yeni),
        .data_o(data_o_ram_yeni)
    );
  
endmodule

