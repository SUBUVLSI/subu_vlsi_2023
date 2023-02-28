`timescale 100ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.02.2023 13:51:58
// Design Name: 
// Module Name: conv_8x8
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


`timescale 100ns / 1ps

module conv_8x8(
    input clk_i, rst_i,en_i,
    input [7:0] veri_i,
    output veri_al_o,
    output veri_gonder_o,
    output [7:0] veri_o,
    output s_o);

    parameter maxRow=76800;
    reg[7:0] mem[0:maxRow-1];
    reg [7:0] ram_out[0:maxRow-1];
    reg [7:0] ram_in[0:maxRow-1];
    
    parameter VERI_AL1 = 20, VERI_AL2 = 21, VERI_GONDER1 = 22, VERI_GONDER2 = 23;
    reg [5:0] durum = VERI_AL1;
    reg [7:0] px=0;
    integer ind=0,indis = 0, gec = 0;
    integer i=0,o=0,k=0,l=0, bitis=0,sayac=0;
    //l: görüntü matrisinde satir (l=30 adet sat?r)
    //k: her bir sat?rdaki 8x8 lik matris sayisi? (l=40 blok) 
    //görüntü 320 satir x 240 sütundan olusmakta    
    
    /*            
    initial begin
      $readmemb("D:\\vivado\\resim_conv_i.txt",mem);
    end
    
    integer h,f;
    
     initial begin 
        #88100
        f=$fopen("D:\\vivado\\resim_conv_o.txt","w"); //  ?C:/Users/korze/Downloads/asil_resim_degerleri.txt
     end
        
     initial begin        
        #88200
        for (h = 0; h < maxRow; h=h+1) 
            $fwrite(f,"%d\n",ram_out[h]); 
        #88700
        $fclose(f);
     end
     */
    reg veri_al = 1;   
    reg veri_gonder = 0;
    assign veri_al_o = veri_al;
    assign veri_gonder_o = veri_gonder;
    reg [5:0] durum_oku;
    //assign durum_oku_o = durum_oku;
    //assign indis_kontrol = indis;
    reg [7:0] veri_o_konv;
    assign veri_o = veri_o_konv;
    always @(posedge clk_i) begin
    if(rst_i) begin

    end
    else begin
        if(en_i == 1)begin
            sayac=sayac+1;
            case (durum)
            
            VERI_AL1:begin
                durum_oku <= durum;
                if(veri_al == 1)begin
                    if(indis < maxRow)begin     
                        if(indis < 1)begin
                            if(gec < 4)begin 
                                gec <= gec + 1;
                                mem[indis] <= veri_i;  // her cekilmede veri dataya aktarılacak
                                // veri_kontrol <= veri_i;
                            end else begin
                                gec <= 0;
                                durum <= VERI_AL2;
                            end 
                        end else begin
                            if(gec < 2)begin 
                                gec <= gec + 1;
                                mem[indis] <= veri_i;  // her cekilmede veri dataya aktarılacak
                                // veri_kontrol <= veri_i;
                            end else begin
                                gec <= 0;
                                durum <= VERI_AL2;
                            end  
                        end
                    end else begin
                        veri_al <= 0;
                        indis <= 0;
                        ind <= 0;
                        durum <= 0;
                    end
                end else begin
                end 
            end 
            
            VERI_AL2:begin
                durum_oku <= durum;
                indis <= indis + 1;
                durum <= VERI_AL1;
            end 
                        
            0: begin
                if(ind<maxRow)begin 
                     px=mem[ind];
                     ram_in[ind]=px;
                     ind=ind+1;
                end
                else begin
                    ind <= 0;
                    durum<=1;
                end
               end
            1: begin         
                ram_out[o] <= ram_in[i];
                ram_out[o+1] <= ram_in[i+1];
                ram_out[o+2] <= ram_in[i+2];
                ram_out[o+3] <= ram_in[i+3];
                ram_out[o+4] <= ram_in[i+4];
                ram_out[o+5] <= ram_in[i+5];
                ram_out[o+6] <= ram_in[i+6];
                ram_out[o+7] <= ram_in[i+7];
     
                ram_out[o+320] <= ram_in[i+8];
                ram_out[o+321] <= ram_in[i+9];
                ram_out[o+322] <= ram_in[i+10];
                ram_out[o+323] <= ram_in[i+11];
                ram_out[o+324] <= ram_in[i+12];
                ram_out[o+325] <= ram_in[i+13];
                ram_out[o+326] <= ram_in[i+14];
                ram_out[o+327] <= ram_in[i+15];         
     
                ram_out[o+640] <= ram_in[i+16];
                ram_out[o+641] <= ram_in[i+17];
                ram_out[o+642] <= ram_in[i+18];
                ram_out[o+643] <= ram_in[i+19];
                ram_out[o+644] <= ram_in[i+20];
                ram_out[o+645] <= ram_in[i+21];
                ram_out[o+646] <= ram_in[i+22];
                ram_out[o+647] <= ram_in[i+23];                       
     
                ram_out[o+960] <= ram_in[i+24];
                ram_out[o+961] <= ram_in[i+25];
                ram_out[o+962] <= ram_in[i+26];
                ram_out[o+963] <= ram_in[i+27];
                ram_out[o+964] <= ram_in[i+28];
                ram_out[o+965] <= ram_in[i+29];
                ram_out[o+966] <= ram_in[i+30];
                ram_out[o+967] <= ram_in[i+31];                 
     
                ram_out[o+1280] <= ram_in[i+32];
                ram_out[o+1281] <= ram_in[i+33];
                ram_out[o+1282] <= ram_in[i+34];
                ram_out[o+1283] <= ram_in[i+35];
                ram_out[o+1284] <= ram_in[i+36];
                ram_out[o+1285] <= ram_in[i+37];
                ram_out[o+1286] <= ram_in[i+38];
                ram_out[o+1287] <= ram_in[i+39];                    
     
                ram_out[o+1600] <= ram_in[i+40];
                ram_out[o+1601] <= ram_in[i+41];
                ram_out[o+1602] <= ram_in[i+42];
                ram_out[o+1603] <= ram_in[i+43];
                ram_out[o+1604] <= ram_in[i+44];
                ram_out[o+1605] <= ram_in[i+45];
                ram_out[o+1606] <= ram_in[i+46];
                ram_out[o+1607] <= ram_in[i+47];            
     
                ram_out[o+1920] <= ram_in[i+48];
                ram_out[o+1921] <= ram_in[i+49];
                ram_out[o+1922] <= ram_in[i+50];
                ram_out[o+1923] <= ram_in[i+51];
                ram_out[o+1924] <= ram_in[i+52];
                ram_out[o+1925] <= ram_in[i+53];
                ram_out[o+1926] <= ram_in[i+54];
                ram_out[o+1927] <= ram_in[i+55];            
      
                ram_out[o+2240] <= ram_in[i+56];
                ram_out[o+2241] <= ram_in[i+57];
                ram_out[o+2242] <= ram_in[i+58];
                ram_out[o+2243] <= ram_in[i+59];
                ram_out[o+2244] <= ram_in[i+60];
                ram_out[o+2245] <= ram_in[i+61];
                ram_out[o+2246] <= ram_in[i+62];
                ram_out[o+2247] <= ram_in[i+63];
                
                durum <= 2;
             
            end
            
            2: begin
                //320x240 matrisinde sütunda gezme
                if(k<39)begin
                    o<=o+8;
                    i<=i+64;
                    k<=k+1;
                    durum <= 1;
                end else begin
                    durum <= 3;
                end
            end
            
            3: begin
                //320x240 matrisinde sat?rda gezme
                if(l<30) begin
                    o<=o+2248;
                    i<=i+64;
                    l<=l+1;
                    k<=0;
                    durum <= 1;         
                end else begin
                    durum <= 4;
                end
            end
            
            4: begin
                ind <= 0;
                bitis <= 1; 
                veri_gonder <= 1;
                durum <= VERI_GONDER1;
            end
            
            // UST MODULE YAZMA
            VERI_GONDER1:begin
                durum_oku <= durum;
                if(veri_gonder == 1)begin
                    if(ind < maxRow)begin
                        if(gec < 2)begin
                            gec <= gec + 1;
                            veri_o_konv <= ram_out[ind];
                        end else begin
                            gec <= 0;
                            durum <= VERI_GONDER2;
                        end 
                    end else begin
                    end
                end else begin
                    durum <= 13;
                end 
            end
            
            VERI_GONDER2:begin
                durum_oku <= durum;
                ind <= ind + 1;
                durum <= VERI_GONDER1;
            end
        endcase
    end else begin
    end
 end
end
  assign s_o=bitis;
endmodule

