`timescale 100ns / 1ps

module gorev_1(
    input clk_i, 
    input rst_i,
    input en_i
    );
    //gauss alt ba�lant�lar�
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
    
   gauss_2 gauss(
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
    
    // sobel alt ba�lant�lar�
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
     wire [8:0] data_o_s;
     wire sonuc_done_s;
     
     sobel sobel(
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
   parameter deger=76800;
   parameter deger1=75684;
   parameter deger2=74576;
   reg [7:0] mem [0:deger-1]; 
   reg [7:0] array [0:deger-1];
   reg [7:0] array_1 [0:deger1-1];
   reg [7:0] array_2 [0:deger2-1];
   reg [7:0] array_3 [0:deger-1];
   reg [7:0] core_ram_out[0:8];
   reg [7:0] durum=0;
   integer ind=0, ind_g=0, ind_s=0;
   integer array_ind=0, array1_ind=0, array2_ind=0, array3_ind=0;
   integer g_sayac=0;
   integer sayac=0;
   integer ic_sayac=0;
   
    integer j,f;
    initial begin
      $readmemb("D:/g_pixel_values.txt",mem);      //76800
    end
    initial begin  
      #77000
      f=$fopen("D:/gorev_1.txt","w");  
    end
    initial begin
          #20000000
          for (j = 0; j<76800; j=j+1) 
              $fwrite(f,"%d\n",array_3[j]); //76800
          #20000500
          $fclose(f);
    end
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
            if(en_i)begin
                g_sayac<=g_sayac+1;
                case(durum)
                    0:begin
                        if(array_ind<deger)begin // 76800 de�er aktar�l�yor
                            array[array_ind]<=mem[array_ind];
                            array_ind<=array_ind+1;
                        end else begin
                            array_ind<=0;
                            durum<=1;
                        end
                    end  
                    1:begin
                        if(sayac<2)begin // 3x3 de�erler al�n�yor
                             core_ram_out[0] <= array[ind_g]; 
                             core_ram_out[1] <= array[ind_g+1];
                             core_ram_out[2] <= array[ind_g+2];
                             core_ram_out[3] <= array[ind_g+320];
                             core_ram_out[4] <= array[ind_g+321];
                             core_ram_out[5] <= array[ind_g+322];
                             core_ram_out[6] <= array[ind_g+640];
                             core_ram_out[7] <= array[ind_g+641];
                             core_ram_out[8] <= array[ind_g+642];
                             sayac=sayac+1;   
                        end else begin
                            sayac<=0;
                            en_g<=1;
                            durum<=2;
                        end
                    end
                    2:begin
                        if(en_g)begin // gauss yap�l�yor. 75684 de�er ��k�yor
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
                                durum<=3;
                           end 
                        end else begin
                            durum<=9; //en son duruma ba�la
                            sayac<=0;
                        end
                    end
                    3:begin // ��kan de�erler dizi1 in i�ine at�l�yor. dizi1 75684.
                        if(array1_ind<deger1)begin
                            if(ind<318)begin
                                if(sonuc_done_g)begin
                                    array_1[array1_ind]<=data_o_g;
                                    array1_ind<=array1_ind+1;
                                    ind_g<=ind_g+1;
                                    ind<=ind+1;
                                    en_g<=0;
                                    durum<=1;
                                end else begin
                                    
                                end
                            end else begin
                                ind_g<=ind_g+2;
                                ind<=0;
                                durum<=1;
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
                            durum<=4;
                        end   
                       
                    end 
                    4:begin 
                             if(sayac<2)begin // 3x3 de�erler al�n�yor
                             core_ram_out[0] <= array_1[ind_s]; 
                             core_ram_out[1] <= array_1[ind_s+1];
                             core_ram_out[2] <= array_1[ind_s+2];
                             core_ram_out[3] <= array_1[ind_s+318];
                             core_ram_out[4] <= array_1[ind_s+319];
                             core_ram_out[5] <= array_1[ind_s+320];
                             core_ram_out[6] <= array_1[ind_s+636];
                             core_ram_out[7] <= array_1[ind_s+637];
                             core_ram_out[8] <= array_1[ind_s+638];
                             sayac=sayac+1;   
                        end else begin
                            sayac<=0;
                            en_s<=1;
                            durum<=5;
                        end  
                    end
                    5:begin
                         if(en_s)begin 
                             if(sayac<71)begin // sobel i�lemine sokuyor
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
                                   sayac=0;
                                   durum=6;
                             end
                         end else begin
                             durum=9; // en son ��k��a ba�la
                         end
                    end
                    6:begin 
                        if(array2_ind<deger2)begin
                            if(ind<316)begin
                                if(sonuc_done_s)begin
                                    array_2[array2_ind]<=data_o_s;
                                    array2_ind<=array2_ind+1;
                                    ind_s<=ind_s+1;
                                    ind<=ind+1;
                                    en_s<=0; 
                                    durum<=4;
                                end else begin
                                       
                                end
                            end else begin
                                ind_s<=ind_s+2;
                                ind<=0;
                                durum<=4;
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
                            ind_s<=0;
                            ind<=0; 
                            durum<=7;
                        end   
                    end

                    7:begin
                       if(array3_ind<76800)begin
                           if(ic_sayac<236)begin
                               if(ind<316)begin
                                  array_3[array3_ind+642]<=array_2[array2_ind];
                                  ind<=ind+1;
                                  array3_ind<=array3_ind+1;
                                  array2_ind<=array2_ind+1;
                               end else begin
                                   ind<=0;
                                   ic_sayac<=ic_sayac+1;
                                   durum<=8;
                               end
                           end else begin
                          //ic_sayac<=0;     
                          //array2_ind<=0;   
                          //ind<=0;          
                          //array3_ind<=0;   
                          //durum<=9;        
                            
                           end
                     end else begin
                         ic_sayac<=0;
                         array2_ind<=0;
                         ind<=0;
                         array3_ind<=0;
                         durum<=9;
                     end
                    end
                    8:begin 
                       if(ind<4)begin
                           ind<=ind+1;
                           array3_ind<=array3_ind+1;
                       end else begin
                           ind<=0;
                           durum<=7;
                       end
                    end
                    9:begin
                        ind<=0;
                        array3_ind<=0;
                        sayac<=0;
                        ic_sayac<=0;
                        array2_ind<=0;
                        ind_g<=0;
                        array_ind<=0;    
                    end
                
                endcase
        end else begin
            g_sayac<=0;
            durum<=0;
        end
     end
   end 
    
endmodule  
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    