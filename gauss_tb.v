`timescale 100ns / 1ps
module gauss_test(
  input clk_i, rst_i,
  output s,
  output [7:0] okunan_veri

);

  reg en_g; 
  reg [7:0] data_i0_g  ;
  reg [7:0] data_i1_g  ;
  reg [7:0] data_i2_g  ;
  reg [7:0] data_i3_g  ;
  reg [7:0] data_i4_g  ;
  reg [7:0] data_i5_g  ;
  reg [7:0] data_i6_g  ;
  reg [7:0] data_i7_g  ;
  reg [7:0] data_i8_g  ;
  wire [7:0] data_o_g  ;
  
  
  parameter deger=77924;
  parameter deger1=76800;
  parameter deger2=75684;
  reg [7:0] mem[0:deger1-1]; //ilk piksel deðeri için 76800
  reg [7:0] ram[0:deger1-1]; //ilk pikseþ deðeri için 76800
  reg [7:0] ram2[0:deger1-1]; 
  reg [7:0] ram1[0:deger-1]; 

  reg [7:0] core_ram_out[0:8];
  reg [10:0] durum=0;
  wire sonuc_done_g;
  integer ind=0,ram1_ind=0,ind_g=0;
  integer ram_ind=0,ram2_ind=0;
  integer g_sayac=0;
  integer sayac=0;
  integer ic_sayac=0;
  



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

 integer j,f;
  initial begin
    $readmemb("D:/g_pixel_values.txt",mem);      //76800
  end
  initial begin  
    #77000
    f=$fopen("D:/gauss_test.txt","w"); 
  end
  initial begin
        #6300000
        for (j = 0; j<76800; j=j+1) 
            $fwrite(f,"%d\n",ram2[j]); //76800
        #6350000
        $fclose(f);
  end
  integer i;
  initial begin
    #76800
     for (i = 0; i < 76800; i = i + 1) begin
        ram2[i] = 0;
    
     end
    
   end

always @(posedge clk_i) begin 
    if(rst_i) begin
        sayac<=0;
        g_sayac<=0;
        ind<=0;
        
    end else begin
         g_sayac<=g_sayac+1;
         case(durum)
            0:begin
                durum<=1;
                 
            end
            1:begin 
                if(ind<deger1)begin // piksel deðerlerini diziye aktarýyor
                    ram[ind]<=mem[ind];
                    ind<=ind+1;
                end else begin
                    ind<=0;
                    ind_g<=0;
                    durum<=2;
                end
            end


            2:begin
                     if(sayac<2)begin // 3x3 lük deðerleri alýyor
                        core_ram_out[0] <= ram[ind_g]; 
                        core_ram_out[1] <= ram[ind_g+1];
                        core_ram_out[2] <= ram[ind_g+2];
                        core_ram_out[3] <= ram[ind_g+320];
                        core_ram_out[4] <= ram[ind_g+321];
                        core_ram_out[5] <= ram[ind_g+322];
                        core_ram_out[6] <= ram[ind_g+640];
                        core_ram_out[7] <= ram[ind_g+641];
                        core_ram_out[8] <= ram[ind_g+642];
                        sayac=sayac+1;
                        
                      end else begin
                        sayac=0;
                        en_g=1;
                        durum=3;
                      end
            end 
            3:begin // gauss yapýyor
                if(en_g==1)begin 
                    if(sayac<37)begin // gauss iþlemine sokuyor
                  
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
                        sayac=0; 
                        durum=4;  
                    end
                end else begin
                durum=7;
                end
            end 
            4:begin
               if(ram1_ind<75684)begin 
                   if(ind<318)begin
                       if(sonuc_done_g==1)begin
                           ram1[ram1_ind]<=data_o_g; //deðerleri diziye yazýyor
                           ram1_ind<=ram1_ind+1;
                           ind_g<=ind_g+1;
                           ind<=ind+1;
                           en_g<=0;
                           durum<=2;
                       end else begin
                           
                       end
                   end else begin
                       ind_g<=ind_g+2;
                       ind<=0;
                       durum<=2;
                   end
               end else begin   
                   ram2_ind<=0;
                   ic_sayac<=0;
                   ram1_ind<=0;
                   ind_g<=0;
                   sayac<=0;
                   ind<=0; 
                   durum<=5;
               end 
          
             end
            5:begin 
                if(sayac<76800)begin
                   if(ic_sayac<238)begin
                       if(ind<318)begin
                           ram2[sayac+321]<=ram1[ram2_ind];
                           ind<=ind+1;
                           ram2_ind<=ram2_ind+1;
                           sayac<=sayac+1;
                       end else begin
                            ind<=0;
                            ic_sayac<=ic_sayac+1;
                            durum<=6;
                       end
                   end else begin

                   end
                end else begin
                       ic_sayac<=0;
                       sayac<=0;
                       durum<=7; 
                end      
            end
            6:begin
                if(ind<2)begin
                   ind<=ind+1;
                   sayac<=sayac+1;
               end else begin
                   ind<=0;
                   
                   durum<=5;
               end
            end
             7:begin
                sayac<=0;
                ind<=0;
                ic_sayac<=0;
                ram_ind<=0;
                ram1_ind<=0;
                ram2_ind<=0;
                ind_m<=0; 
             end
             

        endcase
      end 
   end
endmodule           
          
             


          
        
                
                
         
