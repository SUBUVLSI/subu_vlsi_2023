`timescale 100ns / 1ps

module gorev1(
    input clk_i,  
    input rst_i,
    input en_i,
    input [7:0] veri_i,
    output veri_al_o,
    output veri_gonder_o,
    output [7:0] veri_o,
    output islem_bitti_o,
    output bitti,
    output [5:0] durum_oku_o,
    output [16:0] indis_kontrol
    );
    
    reg veri_al = 1;   
    reg veri_gonder = 0;
    reg bitti_g;
    reg islem_bitti_g=0;
    assign bitti=bitti_g;
    assign veri_al_o = veri_al;
    assign islem_bitti_o=islem_bitti_g;
    assign veri_gonder_o = veri_gonder;
    reg [5:0] durum_oku;
    assign durum_oku_o = durum_oku;
    reg [17:0] indis = 0;
    reg [7:0] data;
    assign indis_kontrol = indis;
    reg [7:0] veri_o_gorev1;
    assign veri_o = veri_o_gorev1;
    //gauss alt bağlantıları
    reg en_g;
    reg [7:0] data_i0_g;
    reg [7:0] data_i1_g;
    reg [7:0] data_i2_g;
    reg [7:0] data_i3_g;
    reg [7:0] data_i4_g;
    reg [7:0] data_i5_g;
    reg [7:0] data_i6_g;
    reg [7:0] data_i7_g;
    reg [7:0] data_i8_g;
    wire [7:0] data_o_g;
    wire sonuc_done_g;
    
   gauss1 gauss(
        .clk_i_g(clk_i),
        .rst_i_g(rst_i),
        .data_i_0(data_i0_g) ,
        .data_i_1(data_i1_g) ,
        .data_i_2(data_i2_g) ,
        .data_i_3(data_i3_g) ,
        .data_i_4(data_i4_g) ,
        .data_i_5(data_i5_g) ,
        .data_i_6(data_i6_g) ,
        .data_i_7(data_i7_g) ,
        .data_i_8(data_i8_g) ,
        .data_o  (data_o_g),
        .en_i_g(en_g),
        .sonuc_done(sonuc_done_g)
    );
    
    // sobel alt bağlantıları
     reg en_s;
     reg [7:0] data_i0_s  ;
     reg [7:0] data_i1_s  ;
     reg [7:0] data_i2_s  ;
     reg [7:0] data_i3_s  ;
     reg [7:0] data_i4_s  ;
     reg [7:0] data_i5_s  ;
     reg [7:0] data_i6_s  ;
     reg [7:0] data_i7_s  ;
     reg [7:0] data_i8_s  ;
     wire [7:0] data_o_s;
     wire sonuc_done_s;
     
     sobel1 sobel(
        .data_i_0(data_i0_s) ,
        .data_i_1(data_i1_s) , 
        .data_i_2(data_i2_s) ,
        .data_i_3(data_i3_s) ,
        .data_i_4(data_i4_s) ,
        .data_i_5(data_i5_s) ,
        .data_i_6(data_i6_s) ,
        .data_i_7(data_i7_s) ,
        .data_i_8(data_i8_s) ,
        .clk_i_s(clk_i),
        .rst_i_s(rst_i),
        .en_i(en_s),
        .data_o(data_o_s),
        .sonuc_done(sonuc_done_s)
     );
       // RAM1                
    reg en_ram1;           
    reg we_ram1;           
    reg [16:0] addr_ram1=0;  
    reg [7:0] data_i_ram1; 
    wire [7:0] data_o_ram1;
    
       // RAM2
    reg en_ram2;
    reg we_ram2;
    reg [16:0] addr_ram2=0;
    reg [7:0] data_i_ram2;
    wire [7:0] data_o_ram2;

   parameter deger=76800;
   parameter deger1=75684;
   parameter deger2=74576;
   reg [4:0] drm = 0;
   reg [7:0] core_ram_out[0:8]; //konv. için
   reg [9:0] durum =0;
   reg [17:0] ind=0, ind_g=0, ind_s=0;
   reg [17:0] ram1_ind=0, ram2_ind=0;
   reg [17:0] g_sayac=0;
   reg [17:0] gec=0;
   reg [17:0] sayac=0;
   reg [17:0] ic_sayac=0;
    
   always@(posedge clk_i)begin
        if(!rst_i)begin
            g_sayac<=0;
        end else begin
            if(en_i==1)begin
                g_sayac<=g_sayac+1;
                case(durum)
                    0:begin // üst modül ramden gelen veriler ram e yazılır
                        durum_oku <= durum;
                        if(veri_al == 1 && indis<deger)begin
                            durum<=1;
                        end else begin 
                            veri_al<=0;
                            en_ram1<=0;
                            ind<=0;
                            gec<=0;
                            ind_g<=0;
                            indis<=0;
                            ram2_ind<=0;
                            ram1_ind<=0;
                            addr_ram2<=0;
                            addr_ram1<=0;
                            durum<=4;// konvolüsyona git.
                        end 
                    end 
 
                    1:begin// ilk veriyi alıyor
                        durum_oku<=durum;
                        en_ram1<=1'b1;
                        we_ram1<=1'b1;
                        if(gec<2)begin
                            gec<=gec+1;
                            data_i_ram1<=veri_i;
                            //durum<=55;
                       end else begin  
                            gec<=0;                      
                            durum<=2;// indis arttır.
                       end 
                    end
                    2:begin
                        durum_oku<=durum;
                        indis<=indis+1;
                        durum<=3;
                   end
                   3:begin
                        durum_oku<=durum;
                        addr_ram1<=indis;
                        durum<=0;    
                    end

                    4:begin
                         durum_oku<=durum;
                         if(ic_sayac<238)begin
                             addr_ram2<=ram2_ind;  
                             durum<=5;
                         end else begin
                            core_ram_out[0]<=0;     
                            core_ram_out[1]<=0;     
                            core_ram_out[2]<=0;     
                            core_ram_out[3]<=0;     
                            core_ram_out[4]<=0;     
                            core_ram_out[5]<=0;     
                            core_ram_out[6]<=0;     
                            core_ram_out[7]<=0;     
                            core_ram_out[8]<=0;     
                            ram1_ind<=0;    
                            ram2_ind<=0;      
                            ind_g<=0;  
                            gec<=0;
                            addr_ram2<=0;
                            ic_sayac<=0;
                            en_ram1<=0;   
                            en_ram2<=0;          
                            ind<=0;
                            indis<=0;                                                              
                            addr_ram1<=0;                 
                            ic_sayac<=0;
//                            veri_gonder<=1;
//                            islem_bitti_g<=1;
                            durum<=20;         
                         end
                    end
                    5:begin
                         durum_oku<=durum;
                         if(ind<318)begin
                             durum<=6;
                         end else begin
                             gec<=0;
                             durum<=18;         
                         end
                    end
                    6:begin //konvolüsyon
                        durum_oku<=durum;
                        addr_ram1<=ind_g;
                        if(gec<=5)begin
                            gec <= gec + 1;
                            en_ram1 <= 1;
                            we_ram1 <= 0;
                            core_ram_out[0] <= data_o_ram1; 
                        end else begin
                            gec<=0;
                            durum<=7;
                        end
                    end
                    7:begin
                        durum_oku<=durum;
                        addr_ram1 <= ind_g+1;
                        if(gec <=3)begin
                            gec <= gec + 1;
                            en_ram1 <= 1;
                            we_ram1 <= 0;
                            core_ram_out[1]<= data_o_ram1;
                         end else begin
                             gec <= 0;
                             durum<=8;
                         end
                      end
                                   
                      8:begin
                         durum_oku<=durum;
                         addr_ram1 <= ind_g+2;
                         if(gec <=3)begin
                              gec <= gec + 1;
                              en_ram1 <= 1;
                              we_ram1 <= 0;
                              core_ram_out[2] <= data_o_ram1;
                          end else begin
                               gec <= 0;
                               durum<=9;
                          end
                      end
                                   
                      9:begin
                          durum_oku<=durum;
                          addr_ram1 <= ind_g+320;
                          if(gec <=3)begin
                               gec <= gec + 1;
                               en_ram1 <= 1;
                               we_ram1 <= 0;
                               core_ram_out[3]<= data_o_ram1;
                           end else begin
                                gec <= 0;
                                durum<=10;
                           end
                      end
                      10:begin
                        durum_oku<=durum;
                        addr_ram1 <= ind_g+321;
                        if(gec <=3)begin
                            gec <= gec + 1;
                            en_ram1 <= 1;
                            we_ram1 <= 0;
                            core_ram_out[4] <= data_o_ram1;
                        end else begin
                            gec <= 0;
                            durum<=11;
                        end
                      end
                      11:begin
                          durum_oku<=durum;
                          addr_ram1 <= ind_g+322;
                              if(gec <=3)begin
                              gec <= gec + 1;
                              en_ram1 <= 1;
                              we_ram1 <= 0;
                              core_ram_out[5] <= data_o_ram1;
                          end else begin
                              gec <= 0;
                              durum<=12;
                          end
                      end
                      12:begin
                          durum_oku<=durum;
                          addr_ram1 <= ind_g+640;
                          if(gec <=3)begin
                              gec <= gec + 1;
                              en_ram1 <= 1;
                              we_ram1 <= 0;
                              core_ram_out[6] <= data_o_ram1;
                          end else begin
                              gec <= 0;
                              durum<=13;
                          end
                      end
                      13:begin
                          durum_oku<=durum;
                          addr_ram1 <= ind_g+641;
                          if(gec <=3)begin
                              gec <= gec + 1;
                              en_ram1 <= 1;
                              we_ram1 <= 0;
                              core_ram_out[7]<= data_o_ram1;
                          end else begin
                              gec <= 0;
                              durum<=14;
                          end
                      end 
                      
                      14:begin
                          durum_oku<=durum;
                          addr_ram1 <= ind_g+642;
                          if(gec <=3)begin
                              gec <= gec + 1;
                              en_ram1 <= 1;
                              we_ram1 <= 0;
                              core_ram_out[8] <= data_o_ram1;
                          end else begin
                              gec <= 0;
                              en_g<=1;
                              durum<=15;
                          end
                      end
                      15:begin
                        durum_oku<=durum;
                        if(en_g==1 && sayac<27)begin
                            data_i0_g <= core_ram_out[0]  ; 
                            data_i1_g <= core_ram_out[1]  ; 
                            data_i2_g <= core_ram_out[2]  ; 
                            data_i3_g <= core_ram_out[3]  ;  
                            data_i4_g <= core_ram_out[4]  ; 
                            data_i5_g <= core_ram_out[5]  ; 
                            data_i6_g <= core_ram_out[6]  ; 
                            data_i7_g <= core_ram_out[7]  ; 
                            data_i8_g <= core_ram_out[8]  ; 
                            sayac=sayac+1;  
                        end else begin
                            sayac<=0;
                            durum<=16;          
                        end                        
                      end 
                      16:begin
                          if(gec<2)begin
                            durum_oku<=durum;
                            en_ram2 = 1;
                            we_ram2 = 1;
                            gec<=gec+1;
                            data_i_ram2<=data_o_g;                   
//                          durum<=17; 
                          end else begin 
                            gec<=0;
                            durum<=17;
                          end
                      end
                      17:begin                    
                        durum_oku<=durum;
                        ind_g<=ind_g+1;
                        ind<=ind+1;
                        en_g<=0;
//                        ram1_ind<=ram1_ind+1;
                        ram2_ind<=ram2_ind+1;
                        durum<=4;
                      end
                      18:begin
                        durum_oku<=durum;
                        ind_g<=ind_g+2;
                        ind<=0;
                        ic_sayac<=ic_sayac+1;
                        en_g<=0;
                        durum<=4;
                     end 
                     20:begin
                        durum_oku<=durum;
                        en_ram1<=1;
                        we_ram1<=1;
                        if(indis<642)begin
                            indis<=indis+1;
                            data_i_ram1<= 8'b00000000;
                            ram1_ind<=ram1_ind+1;
                            durum<=21;                           
                        end else begin 
                            indis<=0;  
                            ind_s<=0; 
                            en_ram2<=0;
                            we_ram2<=0; 
                            ram2_ind<=0;        
                            addr_ram2<=0;                                     
                            durum <= 22;
                            
                        end
                      end
                      21:begin
                        durum_oku<=durum;
                        addr_ram1 <=ram1_ind;
                        durum<=20;
                      end
                      22:begin
                        durum_oku<=durum;
                        if(ram2_ind<74812)begin   
                            addr_ram1<=ram1_ind;                                            
                            durum <= 24;
                        end else begin
      
                            indis<=0;
                            addr_ram1<=ram1_ind;            
                            durum<=46; 
                        end
                    end

                    24:begin //konvolüsyon
                        durum_oku<=durum;
                        addr_ram2<=ind_s;
                        if(gec<=5)begin
                            gec <= gec + 1;
                            en_ram2 <= 1;
                            we_ram2 <= 0;
                            core_ram_out[0] = data_o_ram2; 
                        end else begin
                            gec<=0;
                            durum<=25;
                        end
                    end
                    25:begin
                        durum_oku<=durum;
                        addr_ram2 <= ind_s+1;
                        if(gec <= 3)begin
                            gec <= gec + 1;
                            en_ram2 <= 1;
                            we_ram2 <= 0;
                            core_ram_out[1]<= data_o_ram2;
                         end else begin
                             gec <= 0;
                             durum<=26;
                         end
                      end
                                   
                      26:begin
                         durum_oku<=durum;
                         addr_ram2 <= ind_s+2;
                         if(gec <= 3)begin
                              gec <= gec + 1;
                              en_ram2 <= 1;
                              we_ram2 <= 0;
                              core_ram_out[2] <= data_o_ram2;
                          end else begin
                               gec <= 0;
                               durum<=27;
                          end
                      end
                                   
                      27:begin
                          durum_oku<=durum;
                          addr_ram2 <= ind_s+318;
                          if(gec <= 3)begin
                               gec <= gec + 1;
                               en_ram2 <= 1;
                               we_ram2 <= 0;
                               core_ram_out[3]<= data_o_ram2;
                           end else begin
                                gec <= 0;
                                durum<=28;
                           end
                      end
                      28:begin
                        durum_oku<=durum;
                        addr_ram2 <= ind_s+319;
                        if(gec <= 3)begin
                            gec <= gec + 1;
                            en_ram2 <= 1;
                            we_ram2 <= 0;
                            core_ram_out[4] <= data_o_ram2;
                        end else begin
                            gec <= 0;
                            durum<=29;
                        end
                      end
                      29:begin
                          durum_oku<=durum;
                          addr_ram2 <= ind_s+320;
                              if(gec <= 3)begin
                              gec <= gec + 1;
                              en_ram2 <= 1;
                              we_ram2 <= 0;
                              core_ram_out[5] <= data_o_ram2;
                          end else begin
                              gec <= 0;
                              durum<=30;
                          end
                      end
                      30:begin
                          durum_oku<=durum;
                          addr_ram2 <= ind_s+636;
                          if(gec <= 3)begin
                              gec <= gec + 1;
                              en_ram2 <= 1;
                              we_ram2 <= 0;
                              core_ram_out[6] <= data_o_ram2;
                          end else begin
                              gec <= 0;
                              durum<=31;
                          end
                      end
                      31:begin
                          durum_oku<=durum;
                          addr_ram2 <= ind_s+637;
                          if(gec <= 3)begin
                              gec <= gec + 1;
                              en_ram2 <= 1;
                              we_ram2 <= 0;
                              core_ram_out[7]<= data_o_ram2;
                          end else begin
                              gec <= 0;
                              durum<=32;
                          end
                      end 
                      
                      32:begin
                          durum_oku<=durum;
                          addr_ram2 <= ind_s+638;
                          if(gec <= 3)begin
                              gec <= gec + 1;
                              en_ram2 <= 1;
                              we_ram2 <= 0;
                              core_ram_out[8] <= data_o_ram2;
                          end else begin
                              gec <= 0;
                              en_s<=1;
                              durum<=33;
                          end
                      end
                      33:begin
                        durum_oku<=durum;
                        if(en_s==1 && sayac<75)begin
                            data_i0_s <= core_ram_out[0]  ; 
                            data_i1_s <= core_ram_out[1]  ; 
                            data_i2_s <= core_ram_out[2]  ; 
                            data_i3_s <= core_ram_out[3]  ;  
                            data_i4_s <= core_ram_out[4]  ; 
                            data_i5_s <= core_ram_out[5]  ; 
                            data_i6_s <= core_ram_out[6]  ; 
                            data_i7_s <= core_ram_out[7]  ; 
                            data_i8_s <= core_ram_out[8]  ; 
                            sayac=sayac+1;  
                        end else begin
                            sayac<=0;
                            durum<=60;          
                        end                        
                      end
                      60:begin
                            durum_oku<=durum;
                            if(ic_sayac<236)begin
                                durum<=61;
                            end else begin
                                ind<=0;
                                ic_sayac<=0;
                                veri_gonder<=1;
                                islem_bitti_g<=1;
                                durum<=21;         
                            end
                      end
                      61:begin                
                         durum_oku<=durum;
                         if(ind<316)begin
                             durum<=35;
                         end else begin
                             durum<=38;
                         end
     
                      end

                      
                      35:begin
                        durum_oku<=durum;
                            en_ram1=1;
                            we_ram1=1;
                            data_i_ram1<=data_o_s; 
                            durum<=37;//en son durum.
//                        end
                      end

                      37:begin
                         durum_oku<=durum;
                         ind_s<=ind_s+1;
                         ind<=ind+1;
                         en_s<=0;
                         ram1_ind<=ram1_ind+1;
                         ram2_ind<=ram2_ind+1;
                         durum<=22;
                      end  
                      38:begin
                         durum_oku<=durum;
                         en_ram1=1;
                         we_ram1=1;
                         data_i_ram1<=0;                   
                         durum<=39;   
                      end  
                      39:begin
                         if(gec<3)begin
                           gec<=gec+1;
                           ram1_ind<=ram1_ind+1;
                           durum<=40;
                         end else begin
                           gec<=0;
                           durum<=41;
                         end
                      end
                      40:begin
                           addr_ram1<=ram1_ind;
                           durum<=38;
                      end
                      41:begin
                        durum_oku<=durum;
                        ind_s<=ind_s+2;
                        ram1_ind<=ram1_ind+1;
                        ic_sayac<=ic_sayac+1;
                        ram2_ind<=ram2_ind+1;
                        en_s<=0;
                        ind<=0;
                        durum<=22;
                      end 
                                 
                      46:begin
                        en_ram1<=1;
                        we_ram1<=1;
                        if(indis<642)begin
                            indis<=indis+1;
//                            ram1_ind<=ram1_ind;
                            data_i_ram1<= 8'b00000000;
                            ram1_ind<=ram1_ind+1;
                            durum<=47;                           
                        end else begin
                           core_ram_out[0]<=0;     
                           core_ram_out[1]<=0;     
                           core_ram_out[2]<=0;     
                           core_ram_out[3]<=0;     
                           core_ram_out[4]<=0;     
                           core_ram_out[5]<=0;     
                           core_ram_out[6]<=0;     
                           core_ram_out[7]<=0;     
                           core_ram_out[8]<=0;     
                           ram2_ind<=0;  
                           ram1_ind<=0;        
                           ind_s<=0;  
                           gec<=0;
                           ic_sayac<=0;
                           veri_gonder<=1;
                           islem_bitti_g<=1;
                           addr_ram2<=0;
                           en_ram1<=0;   
                           en_ram2<=0;          
                           ind<=0;
                           indis<=0;                                    
                           durum <= 42;
                            
                        end
                      end
                      47:begin
                        addr_ram1 <=ram1_ind;
                        durum<=46;
                      end
                      42:begin
                        durum_oku<=durum;
                        if(veri_gonder == 1 && ind<deger)begin
                            addr_ram1<=ind;
                            durum<=43;
                        end else begin
                            durum<=45;
                        end
                      end  
                      43:begin
                        durum_oku<=durum;
                        if(gec < 4)begin
                            gec <= gec + 1;
                            en_ram1<=1;
                            we_ram1<=0;
                            //addr_ram2<=ind;
                            veri_o_gorev1 <= data_o_ram1;                                  
                        end else begin
                            gec <= 0;                 
                            durum <=44;
                        end                        
                      end
                      44:begin
                        durum_oku <= durum;
                        ind <= ind + 1;
                        durum <=42;
                      end  
                      45:begin
                        durum_oku<=durum;
                        bitti_g<=1;
                      end         
                   endcase
              end else begin
                g_sayac<=0;
                durum<=0;
              end  
           end
        end  
            // 8 bitlik ram / 76800 satır
    ram#(.V(8),.S(75684),.A(17)) RAM2_ALT(
        .clk_i(clk_i),
        .en_i(en_ram2),
        .we_i(we_ram2),
        .address_i(addr_ram2),
        .data_i(data_i_ram2),
        .data_o(data_o_ram2)
    );
      // 8 bitlik ram / 75684 satır
    ram#(.V(8),.S(76800),.A(17)) RAM1_ALT(
        .clk_i(clk_i),
        .en_i(en_ram1),
        .we_i(we_ram1),
        .address_i(addr_ram1),
        .data_i(data_i_ram1),
        .data_o(data_o_ram1)
    );
                
    endmodule
