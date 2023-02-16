`timescale 100ns / 1ps
module median_test(
  input clk_i, rst_i,
  output s,
  output [7:0] okunan_veri


  reg en_m; 
  reg [7:0] data_i0_m ;
  reg [7:0] data_i1_m ;
  reg [7:0] data_i2_m ;
  reg [7:0] data_i3_m ;
  reg [7:0] data_i4_m ;     
  reg [7:0] data_i5_m ;
  reg [7:0] data_i6_m ;
  reg [7:0] data_i7_m ;
  reg [7:0] data_i8_m ;
  wire [7:0] data_o_m ;

  
  parameter deger1=76800;
  parameter deger2=75684;
  reg [7:0] mem[0:deger1-1]; //ilk piksel deðeri için 76800
  reg [7:0] ram[0:deger1-1]; //ilk pikseþ deðeri için 76800
  reg [7:0] ram1[0:deger2-1]; //gauss yaptýk 75684
  reg [7:0] ram2[0:deger1-1];
  wire sonuc_done_m;

  reg [7:0] core_ram_out[0:8];
  reg [10:0] durum=0;

  integer ind=0,ram1_ind=0,ind_m=0,ram2_ind=0;
  integer ram_ind=0;
  integer g_sayac=0;
  integer sayac=0; 
  integer ic_sayac=0;
  

    medyan medyan(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i_0(data_i0_m) ,
        .data_i_1(data_i1_m) ,
        .data_i_2(data_i2_m) ,
        .data_i_3(data_i3_m) ,
        .data_i_4(data_i4_m) ,
        .data_i_5(data_i5_m) ,
        .data_i_6(data_i6_m) ,
        .data_i_7(data_i7_m) ,
        .data_i_8(data_i8_m) , 
        .data_o  (data_o_m),
        .en_i(en_m),
        .sonuc_done(sonuc_done_m)
        );

  integer j,f;
  initial begin
    $readmemb("D:/pixel_values.txt",mem);    
  end
  initial begin 
    #77000
    f=$fopen("D:/median_test.txt","w");
  end
  initial begin
        #6400000
        for (j = 0; j<deger1; j=j+1) 
            $fwrite(f,"%d\n",ram2[j]); 
        #6400500
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
                    ind_m<=0;
                    durum<=2;
                end
            end


            2:begin
                     if(sayac<2)begin // 3x3 lük deðerleri alýyor
                        core_ram_out[0] <= ram[ind_m]; 
                        core_ram_out[1] <= ram[ind_m+1];
                        core_ram_out[2] <= ram[ind_m+2];
                        core_ram_out[3] <= ram[ind_m+320];
                        core_ram_out[4] <= ram[ind_m+321];
                        core_ram_out[5] <= ram[ind_m+322];
                        core_ram_out[6] <= ram[ind_m+640];
                        core_ram_out[7] <= ram[ind_m+641];
                        core_ram_out[8] <= ram[ind_m+642];
                        sayac=sayac+1;
                        
                      end else begin
                        sayac=0;
                        en_m=1;
                        durum=3;
                      end
            end 
            3:begin // gauss yapýyor
                if(en_m==1)begin 
                    if(sayac<77)begin // gauss iþlemine sokuyor
                  
                        data_i0_m <= core_ram_out[0]  ;
                        data_i1_m <= core_ram_out[1]  ;
                        data_i2_m <= core_ram_out[2]  ;
                        data_i3_m <= core_ram_out[3]  ; 
                        data_i4_m <= core_ram_out[4]  ;
                        data_i5_m <= core_ram_out[5]  ;
                        data_i6_m <= core_ram_out[6]  ;
                        data_i7_m <= core_ram_out[7]  ;
                        data_i8_m <= core_ram_out[8]  ;
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
                       if(sonuc_done_m==1)begin
                           ram1[ram1_ind]<=data_o_m; //deðerleri diziye yazýyor
                           ram1_ind<=ram1_ind+1;
                           ind_m<=ind_m+1;
                           ind<=ind+1;
                           en_m<=0;
                           durum<=2;
                       end else begin
                           
                       end
                   end else begin
                       ind_m<=ind_m+2;
                       ind<=0;
                       durum<=2;
                   end
               end else begin   
                   ram2_ind<=0;
                   ic_sayac<=0;
                   ram1_ind<=0;
                   ind_m<=0;
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
                   ram2[sayac+321]<=0;
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
              

                
          
           
