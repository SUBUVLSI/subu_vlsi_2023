`timescale 100ns / 1ps

    module gorev_2(
    input clk_i, 
    input rst_i,
    input en_i,
    input [7:0] veri_i,
    output veri_al_o,
    output veri_gonder_o,
    output [7:0] veri_o,
    output islem_bitti_o,
    output [5:0] durum_oku_o,
    output [16:0] indis_kontrol
    
    );
        
    reg veri_al = 1;   
    reg veri_gonder = 0;
    //reg [7:0] veri_i_r;
    assign veri_al_o = veri_al;
   // assign veri_i = veri_i_r;
    assign veri_gonder_o = veri_gonder;
    reg [5:0] durum_oku;
    assign durum_oku_o = durum_oku;
    integer indis=0;
    assign indis_kontrol = indis;
    reg  [7:0] veri_o_gorev2;
    assign veri_o = veri_o_gorev2;
    
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
    
   gauss2 gauss(
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
    
    // laplacian alt bağlantıları
     reg en_l;
     reg [7:0] data_i0_l  ;
     reg [7:0] data_i1_l  ;
     reg [7:0] data_i2_l  ;
     reg [7:0] data_i3_l  ;
     reg [7:0] data_i4_l  ;
     reg [7:0] data_i5_l  ;
     reg [7:0] data_i6_l  ;
     reg [7:0] data_i7_l  ;
     reg [7:0] data_i8_l  ;
     wire [8:0] data_o_l;
     wire sonuc_done_l;
     
     laplacian1 laplacian( 
        .data_i_0(data_i0_l) ,
        .data_i_1(data_i1_l) , 
        .data_i_2(data_i2_l) ,
        .data_i_3(data_i3_l) ,
        .data_i_4(data_i4_l) ,
        .data_i_5(data_i5_l) ,
        .data_i_6(data_i6_l) ,
        .data_i_7(data_i7_l) ,
        .data_i_8(data_i8_l) ,
        .clk_i_l(clk_i),
        .rst_i_l(rst_i),
        .en_i_l(en_l),
        .data_o(data_o_l),
        .sonuc_done(sonuc_done_l)
     );
   parameter deger=76800;
   parameter deger1=75684;
   parameter deger2=74576;
   
   reg [7:0] mem [0:deger-1]; 
   reg [7:0] array [0:deger-1];
   reg [7:0] array_1 [0:deger1-1];
   reg [7:0] array_2 [0:deger2-1];
   reg [7:0] array_3 [0:deger-1];
   reg [7:0] array_4 [0:deger-1];
   reg [7:0] core_ram_out[0:8];
   reg islem_bitti;
   assign islem_bitti_o = islem_bitti;
   reg [7:0] durum=0;
   reg [7:0] sum_pixel=0;
   reg [7:0] sum_pixel1=0;
   reg [8:0] sum_pixel2=0;
   integer ind=0, ind_g=0, ind_l=0;
   integer array_ind=0, array1_ind=0, array2_ind=0, array3_ind=0,array4_ind=0;
   integer g_sayac=0;
   integer gec=0;
   integer sayac=0;
   integer ic_sayac=0;
   integer i;
    initial begin
      #76800
       for (i = 0; i < 76800; i = i + 1) begin
          array_3[i] = 0;  
       end    
    end
   always@(posedge clk_i)begin
        if(rst_i)begin
            g_sayac<=0;
            en_g<=0;
        end else begin
            if(en_i==1)begin
                g_sayac<=g_sayac+1;
                case(durum)
                    0:begin
                        durum_oku <= durum;
                        if(veri_al == 1)begin
                            if(indis < deger)begin  
                                if(indis < 1)begin
                                    if(gec < 4)begin 
                                        gec <= gec + 1;
                                        mem[indis] <= veri_i;  // her cekilmede veri dataya aktarılacak
                                        // veri_kontrol <= veri_i;
                                    end else begin
                                        gec <= 0;
                                        durum <= 1;
                                    end
                                end else begin
                                    if(gec < 2)begin 
                                        gec <= gec + 1;
                                        mem[indis] <= veri_i;  // her cekilmede veri dataya aktarılacak
                                        // veri_kontrol <= veri_i;
                                    end else begin
                                        gec <= 0;
                                        durum <= 1;
                                    end
                                end
                               
                            end else begin
                                veri_al <= 0;
                                indis <= 0;
                                durum <= 2;
                            end
                        end else begin
                        end 
                    end 
                    1:begin
                        durum_oku <= durum;
                        indis <= indis + 1;
                        durum <= 0;
                    end
 
                    2:begin
                        durum_oku <= durum;
                        if(array_ind<deger)begin // 76800 değer aktarılıyor
                            array[array_ind]<=mem[array_ind];
                            array_ind<=array_ind+1;
                        end else begin
                            array_ind<=0;
                            durum<=3;
                        end
                    end  
                    3:begin
                        durum_oku <= durum;
                        if(sayac<2)begin // 3x3 değerler alınıyor
                             core_ram_out[0] <= mem[ind_g]; 
                             core_ram_out[1] <= mem[ind_g+1];
                             core_ram_out[2] <= mem[ind_g+2];
                             core_ram_out[3] <= mem[ind_g+320];
                             core_ram_out[4] <= mem[ind_g+321];
                             core_ram_out[5] <= mem[ind_g+322];
                             core_ram_out[6] <= mem[ind_g+640];
                             core_ram_out[7] <= mem[ind_g+641];
                             core_ram_out[8] <= mem[ind_g+642];
                             sayac=sayac+1;   
                        end else begin
                            sayac<=0;
                            en_g<=1;
                            durum<=4;
                        end
                    end
                    4:begin
                        durum_oku <= durum;
                        if(en_g)begin // gauss yapılıyor. 75684 değer çıkıyor
                            if(sayac<37)begin
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
                                durum<=5;
                           end 
                        end else begin
                            durum<=13;
                            sayac<=0;
                        end
                    end
                    5:begin // çıkan değerler dizi1 in içine atılıyor. dizi1 75684.
                        if(array1_ind<deger1)begin
                            durum_oku <= durum;
                            if(ind<318)begin
                                if(sonuc_done_g)begin
                                    array_1[array1_ind]<=data_o_g;
                                    array1_ind<=array1_ind+1;
                                    ind_g<=ind_g+1;
                                    ind<=ind+1;
                                    en_g<=0;
                                    durum<=3;
                                end else begin
                                    
                                end
                            end else begin
                                ind_g<=ind_g+2;
                                ind<=0;
                                durum<=3;
                            end
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
                            array1_ind<=0;
                            ind_g<=0;
                            ind<=0; 
                            durum<=6;
                        end   
                       
                    end 
                    6:begin 
                        durum_oku <= durum;
                             if(sayac<2)begin // 3x3 değerler alınıyor
                             core_ram_out[0] <= array_1[ind_l]; 
                             core_ram_out[1] <= array_1[ind_l+1];
                             core_ram_out[2] <= array_1[ind_l+2];
                             core_ram_out[3] <= array_1[ind_l+318];
                             core_ram_out[4] <= array_1[ind_l+319];
                             core_ram_out[5] <= array_1[ind_l+320];
                             core_ram_out[6] <= array_1[ind_l+636];
                             core_ram_out[7] <= array_1[ind_l+637];
                             core_ram_out[8] <= array_1[ind_l+638];
                             sayac=sayac+1;   
                        end else begin
                            sayac<=0;
                            en_l<=1;
                            durum<=7;
                        end  
                    end
                    7:begin
                        durum_oku <= durum;
                         if(en_l)begin 
                             if(sayac<36)begin // laplacian işlemine sokuyor
                               data_i0_l <= core_ram_out[0]  ;
                               data_i1_l <= core_ram_out[1]  ;
                               data_i2_l <= core_ram_out[2]  ;
                               data_i3_l <= core_ram_out[3]  ; 
                               data_i4_l <= core_ram_out[4]  ;
                               data_i5_l <= core_ram_out[5]  ;
                               data_i6_l <= core_ram_out[6]  ;
                               data_i7_l <= core_ram_out[7]  ;
                               data_i8_l <= core_ram_out[8]  ;
                               sayac=sayac+1; 
                             end else begin
                                   sayac=0;
                                   durum=8;
                             end
                         end else begin
                             durum=13;
                         end
                    end
                    8:begin 
                        durum_oku <= durum;
                        if(array2_ind<deger2)begin
                            if(ind<316)begin
                                if(sonuc_done_l)begin
                                    array_2[array2_ind]<=data_o_l;
                                    array2_ind<=array2_ind+1;
                                    ind_l<=ind_l+1;
                                    ind<=ind+1;
                                    en_l<=0;
                                    durum<=6;
                                end else begin
                                       
                                end
                            end else begin
                                ind_l<=ind_l+2;
                                ind<=0;
                                durum<=6;
                            end
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
                            array1_ind<=0;
                            array2_ind<=0;
                            array3_ind<=0;
                            ic_sayac<=0;
                            ind_g<=0;
                            ind_l<=0;
                            ind<=0; 
                            durum<=9;
                        end   
                    end

                    9:begin
                       durum_oku <= durum;
                           if(ic_sayac<236)begin
                               if(ind<316)begin
                                  array_3[array3_ind+642]<=array_2[array2_ind];
                                  ind<=ind+1;
                                  array3_ind<=array3_ind+1;
                                  array2_ind<=array2_ind+1;
                               end else begin
                                   ind<=0;
                                   ic_sayac<=ic_sayac+1;
                                   durum<=10;
                               end
                           end else begin
                            ic_sayac<=0;     
                            array2_ind<=0;  
                            sayac<=0; 
                            ind<=0; 
                            array_ind=0; 
                            gec<=0;        
                            array3_ind<=0;  
                            array4_ind<=0; 
                            durum<=11;        
                            
                           end
                    end
                    10:begin 
                      durum_oku <= durum;
                       if(ind<4)begin
                           ind<=ind+1;
                           array3_ind<=array3_ind+1;
                       end else begin
                           ind<=0;
                           durum<=9;
                       end
                    end
                    11:begin
                        durum_oku <= durum;
                            if(sayac<76800)begin
                                sum_pixel<=array_3[ind];     
                                sum_pixel1<=array[array_ind];
                                durum<=12;
                            end else begin
                                durum<=16;
                            end
                    end
             
                    12:begin 
                        durum_oku <= durum;
                        sum_pixel2<=sum_pixel1+sum_pixel;
                        durum<=13;
                    end
                    
                   13:begin
                        durum_oku <= durum;
                       if(sum_pixel2>255)begin
                           sum_pixel2<=255;
            
                          durum<=14;
                       end else begin
                           durum<=15;
                       end
                   end
                   14:begin 
                        durum_oku <= durum;
                        array_4[array4_ind]<=sum_pixel2[7:0]; 
                        ind<=ind+1;
                        array_ind<=array_ind+1;
                        array4_ind<=array4_ind+1;
                        sayac<=sayac+1;
                        durum<=11;
                   end
             
                    15:begin
                        array_4[array4_ind]<=sum_pixel2;
                        ind<=ind+1;
                        array_ind<=array_ind+1;
                        array4_ind<=array4_ind+1;
                        sayac<=sayac+1;
                        durum<=11;
                    end   
               
                    16:begin
                        durum_oku <= durum;
                        ind<=0;
                        array3_ind<=0;
                        sayac<=0;
                        array_ind<=0;
                        ic_sayac<=0;
                        array2_ind<=0;
                        ind_g<=0;
                        array_ind<=0;  
                        islem_bitti <= 1;
                        veri_gonder <= 1;
                        durum <=17;   
                    end
                     // UST MODULE YAZMA
                    17:begin
                        durum_oku <= durum;
                        if(veri_gonder == 1)begin
                            if(ind < deger)begin
                                if(gec < 2)begin
                                    gec <= gec + 1;
                                    veri_o_gorev2 <= array_4[ind];
                                end else begin
                                    gec <= 0;
                                    durum <=18;
                                end 
                            end else begin
                            end
                        end else begin
                            durum <= 19;
                        end 
                    end
                    
                    18:begin
                        durum_oku <= durum;
                        ind <= ind + 1;
                        durum <=17;
                    end
                endcase
        end else begin
            g_sayac<=0;
            durum<=0;
        end
     end
   end 
    
endmodule
