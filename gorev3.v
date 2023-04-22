`timescale 100ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.02.2023 15:17:46
// Design Name: 
// Module Name: gorev3
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

module gorev3(
    input clk_i,  
    input rst_i,
    input en_i,
    input [7:0] veri_i,
    output veri_al_o,
    output veri_gonder_o,
    output [7:0] veri_o,
    output islem_bitti_o,
    output [5:0] durum_oku_o,
    output bitti,
    output [16:0] indis_kontrol
);

// median alt modül
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
  wire sonuc_done_m;
    
    median median(
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
    reg [7:0] veri_o_gorev3;
    assign veri_o = veri_o_gorev3;
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

  parameter deger1=76800;
  parameter deger2=75684;
  reg [7:0] core_ram_out[0:8];
  reg [7:0] durum=0;



  integer ind=0,ram1_ind=0;
  reg[17:0] ind_m=0;
  integer ram2_ind=0;
  integer g_sayac=0;
  integer sayac=0; 
  integer ic_sayac=0;
  integer gec=0;

always @(posedge clk_i) begin 
    if(rst_i) begin
        g_sayac<=0;
        en_m<=0;
    end else begin
      if(en_i==1)begin
         g_sayac<=g_sayac+1;
         case(durum)
            0:begin
                durum_oku <= durum;
                if(veri_al == 1 && indis<deger1)begin
                    durum<=1;
                end else begin
                    veri_al<=0;
                    en_ram1<=0;
                    ind<=0;
                    gec<=0;
                    ind_m<=0;
                    indis<=0;
                    ram1_ind<=0;
                    addr_ram2<=0;
                    addr_ram1<=0;
                    durum<=25;// konvolüsyona git.
                end
            end
   
            1:begin
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
             25:begin
               en_ram2<=1;
               we_ram2<=1;
               if(ram2_ind<321)begin
                   data_i_ram2<= 8'b00000000;
                   ram2_ind<=ram2_ind+1;
                   durum<=26;                           
               end else begin
                   //ram2_ind<=ram2_ind+1;
                   //addr_ram2<=0;               
                   //en_ram2 <= 0;                
                   addr_ram1<=0;                                     
                   durum <= 4;
                   
               end
             end
             26:begin
               addr_ram2 <=ram2_ind;
               durum<=25;
             end
             4:begin
                durum_oku<=durum;
                if(ram1_ind <75922)begin  
                    addr_ram2<=ram2_ind;                                             
                    durum <= 5;           
                end else begin
                
                    addr_ram2<=ram2_ind;
                    indis<=0;                 
                    durum<=33; 
                end
             end
             5:begin //konvolüsyon
                durum_oku<=durum;
                addr_ram1<=ind_m;
                if(gec<=5)begin
                     gec <= gec + 1;
                     en_ram1 <= 1;
                     we_ram1 <= 0;
                     core_ram_out[0] <= data_o_ram1; 
                 end else begin
                     gec<=0;
                     durum<=6;
                 end
             end
             6:begin
                 durum_oku<=durum;
                 addr_ram1 <= ind_m+1;
                 if(gec <=3)begin
                     gec <= gec + 1;
                     en_ram1 <= 1;
                     we_ram1 <= 0;
                     core_ram_out[1]<= data_o_ram1;
                  end else begin
                      gec <= 0;
                      durum<=7;
                  end
               end
                            
               7:begin
                  durum_oku<=durum;
                  addr_ram1 <= ind_m+2;
                  if(gec <=3)begin
                       gec <= gec + 1;
                       en_ram1 <= 1;
                       we_ram1 <= 0;
                       core_ram_out[2] <= data_o_ram1;
                   end else begin
                        gec <= 0;
                        durum<=8;
                   end
               end
                            
               8:begin
                   durum_oku<=durum;
                   addr_ram1 <= ind_m+320;
                   if(gec <=3)begin
                        gec <= gec + 1;
                        en_ram1 <= 1;
                        we_ram1 <= 0;
                        core_ram_out[3]<= data_o_ram1;
                    end else begin
                         gec <= 0;
                         durum<=9;
                    end
               end
               9:begin
                 durum_oku<=durum;
                 addr_ram1 <= ind_m+321;
                 if(gec <=3)begin
                     gec <= gec + 1;
                     en_ram1 <= 1;
                     we_ram1 <= 0;
                     core_ram_out[4] <= data_o_ram1;
                 end else begin
                     gec <= 0;
                     durum<=10;
                 end
               end
               10:begin
                   durum_oku<=durum;
                   addr_ram1 <= ind_m+322;
                       if(gec <=3)begin
                       gec <= gec + 1;
                       en_ram1<= 1;
                       we_ram1 <= 0;
                       core_ram_out[5] <= data_o_ram1;
                   end else begin
                       gec <= 0;
                       durum<=11;
                   end
               end
               11:begin
                   durum_oku<=durum;
                   addr_ram1 <= ind_m+640;
                   if(gec <=3)begin
                       gec <= gec + 1;
                       en_ram1 <= 1;
                       we_ram1 <= 0;
                       core_ram_out[6] <= data_o_ram1;
                   end else begin
                       gec <= 0;
                       durum<=12;
                   end
               end
               12:begin
                   durum_oku<=durum;
                   addr_ram1 <= ind_m+641;
                   if(gec <=3)begin
                       gec <= gec + 1;
                       en_ram1 <= 1;
                       we_ram1 <= 0;
                       core_ram_out[7]<= data_o_ram1;
                   end else begin
                       gec <= 0;
                       durum<=13;
                   end
               end 
               
               13:begin
                   durum_oku<=durum;
                   addr_ram1 <= ind_m+642;
                   if(gec <=3)begin
                       gec <= gec + 1;
                       en_ram1 <= 1;
                       we_ram1<= 0;
                       core_ram_out[8] <= data_o_ram1;
                   end else begin
                       gec <= 0;
                       en_m<=1;
                       durum<=14;
                   end
               end
               14:begin
                 durum_oku<=durum;
                 if(en_m==1 && sayac<77)begin
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
                     sayac<=0;
                     durum<=15;          
                 end                        
               end 
               15:begin
                durum_oku<=durum;
                if(ic_sayac<238)begin
                    durum<=16;
                end else begin
                    ind<=0;
                    ic_sayac<=0;
                    veri_gonder<=1;
                    islem_bitti_g<=1;
                    durum<=21;         
                end
               end
               16:begin
                    durum_oku<=durum;
                    if(ind<318)begin
                        durum<=17;
                    end else begin
                        durum<=19;
                    end
               end
               17:begin
                   durum_oku<=durum;
                   en_ram2=1;
                   we_ram2=1;
                   data_i_ram2<=data_o_m;                   
                   //ind_m<=ind_m+1;
                   //ind<=ind+1;
                   //en_m<=0;
                   //indis<=indis+1; 
                   //ram1_ind<=ram1_ind+1;
                   durum<=18;                            
               end
               18:begin
                    durum_oku<=durum;
                    ind_m<=ind_m+1;
                    ind<=ind+1;
                    en_m<=0;
                    ram1_ind<=ram1_ind+1;
                    ram2_ind<=ram2_ind+1;
                    durum<=4;
               end
               //19:begin
               //    addr_ram2<=ram2_ind;
               //    durum<=4;
               //end
               19:begin
                   durum_oku<=durum;
                   en_ram2=1;
                   we_ram2=1;
                   data_i_ram2<=0;                   
                   durum<=30;   
               end
               30:begin
                  if(gec<3)begin
                    gec<=gec+1;
                    ram2_ind<=ram2_ind+1;
                    durum<=31;
                  end else begin
                    gec<=0;
                    durum<=32;
                  end
               end
               31:begin
                    addr_ram2<=ram2_ind;
                    durum<=19;
               end
               32:begin
                 durum_oku<=durum;
                 ind_m<=ind_m+2;
                 ram1_ind<=ram1_ind+1;
                 ic_sayac<=ic_sayac+1;
                 ram2_ind<=ram2_ind+1;
                 en_m<=0;
                 ind<=0;
                 durum<=4;
               end  
               33:begin
                 en_ram2<=1;
                 we_ram2<=1;
                 if(indis<321)begin
                     indis<=indis+1;
                     data_i_ram2<= 8'b00000000;
                     ram2_ind<=ram2_ind+1;
                     durum<=34;                           
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
                    ind_m<=0;  
                    gec<=0;
                    ic_sayac<=0;
                    veri_gonder<=1;
                    islem_bitti_g<=1;
                    addr_ram2<=0;
                    en_ram1<=0;   
                    en_ram2<=0;          
                    ind<=0;
                    indis<=0;                                    
                    durum <= 21;
                     
                 end
               end
               34:begin
                 addr_ram2 <=ram2_ind;
                 durum<=33;
               end
               21:begin
                 durum_oku<=durum;
                 if(veri_gonder == 1 && ind<deger1)begin
                     addr_ram2<=ind;
                     durum<=22;
                 end else begin
                     durum<=24;
                 end
               end  
               22:begin
                 durum_oku<=durum;
                 if(gec < 4)begin
                     gec <= gec + 1;
                     en_ram2<=1;
                     we_ram2<=0;
                     //addr_ram2<=ind;
                     veri_o_gorev3 <= data_o_ram2;                                  
                 end else begin
                     gec <= 0;                 
                     durum <=23;
                 end                        
               end
               23:begin
                 durum_oku <= durum;
                 ind <= ind + 1;
                 durum <=21;
               end  
               24:begin
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
    ram#(.V(8),.S(76800),.A(17)) RAM1_ALT(
        .clk_i(clk_i),
        .en_i(en_ram2),
        .we_i(we_ram2),
        .address_i(addr_ram2),
        .data_i(data_i_ram2),
        .data_o(data_o_ram2)
    );
      // 8 bitlik ram / 75684 satır
    ram#(.V(8),.S(76800),.A(17)) RAM2_ALT(
        .clk_i(clk_i),
        .en_i(en_ram1),
        .we_i(we_ram1),
        .address_i(addr_ram1),
        .data_i(data_i_ram1),
        .data_o(data_o_ram1)
    );
         
endmodule           

                
          
