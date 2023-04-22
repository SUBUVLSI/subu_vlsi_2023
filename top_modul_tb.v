
`timescale 100ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2023 21:06:03
// Design Name: 
// Module Name: top_modul
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


module top_modul(
    input clk_i, rst_i,en_i,
    input [15:0] en_gorev_i,
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
//    reg [7:0] mem [0:max_row-1];
    reg [31:0] mem1 [0:255];
//    initial begin
//        $readmemb("D:\\vivado\\asil_resim.txt",mem);  
//    end
    initial begin
        $readmemb("D:\\vivado\\histogram_table.txt",mem1);  
    end
    
    integer ind = 0, indis = 0;

    // GOREV 5
    reg veri_al;
    wire islem_bitti, veri_gonder;
    wire veri_gonder1, veri_gonder2, veri_gonder3, veri_gonder4, veri_gonder5, veri_gonder6;
    wire veri_al1, veri_al2, veri_al3, veri_al4, veri_al5, veri_al6;
    wire veri_al_his;
    reg en_gorev1, en_gorev2, en_gorev3, en_gorev4, en_gorev5, en_gorev6;
    reg [7:0] veri_i_gorev;
    wire [7:0] veri_o_gorev;
    reg [31:0] veri_histogram;
    wire islem_bitti1, islem_bitti2, islem_bitti3, islem_bitti4, islem_bitti5, islem_bitti6;
    wire [31:0] veri_o_gorev4;
    
    reg [7:0] cikti_mem [0:max_row-1]; // decode
    reg [7:0] cikti_mem1 [0:max_row-1]; // gorev_cikti
    reg [7:0] cikti_mem2 [0:max_row-1]; // yerlesmis decode
    reg [31:0] cikti_mem3 [0:255];

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
            
              
              
    // DECODE ICIN // 
    parameter mem_satir = 2405;  // 2405
    reg [31:0] mem [0:mem_satir]; // bitstream
    
    initial begin
        $readmemb("D:\\vivado\\bytearray_32bit.txt",mem);  
    end
    
    // ENCODED VERI ICIN RAM
    integer encoded_satir = 0;
    reg [12:0] addr_encoded_veri; // ramin satır sayısı bilinmiyor / 2^x = mem_satir
    reg we_encoded , en_encoded;
    reg [31:0] in_encoded;
    wire [31:0] out_encoded;
    
    
    
    
    // DECODE 
    reg en_decode;     
    reg [31:0] data_encode;
    wire [7:0] data_decode;
    wire data_gonderme_ok;
    wire decode_edildi;
    
    // DECODE VERI ICIN RAM
    reg [16:0] addr_decoded_veri; // 76800 tane veri 
    reg we_decoded , en_decoded;
    reg [7:0] in_decoded;
    wire [7:0] out_decoded;
    integer satir_son_ram = 0;
    
    
    reg [31:0] veri;
    
    reg [7:0] decode_veri [63:0];
    integer satir = 0;
    
    parameter cikti_mem_satir = 76799;
//    reg [7:0] cikti_mem[0:cikti_mem_satir]; // cikti
    
    
    // konvolusyon icin
    parameter 
        YERLESTIR1 = 39,
        YERLESTIR2 = 40,
        YERLESTIR3 = 41,
        YERLESTIR4 = 42,
        YERLESTIR5 = 43,
        YERLESTIR6 = 44,
        YERLESTIR7 = 45,
        YERLESTIR8 = 46;
    
    parameter
        DECODE0     = 28,
        DECODE1     = 29,
        DECODE2     = 30,
        DECODE3     = 31,
        DECODE4     = 32,
        DECODE5     = 33,
        DECODE6     = 34,
        DECODE7     = 35,
        DECODE8     = 36,
        DECODE_SON  = 37;
        
        
                
    reg [7:0] konv [0:max_row-1];
    reg [7:0] ram_out [0:max_row-1];
    
    integer i = 0, o = 0, k = 0, l = 0;
    reg bitis = 0;
    
    always@(posedge clk_i)begin
        if(rst_i)begin
        end else begin
            if(en_i)begin
                sayac <= sayac + 1;
                case(durum)
                    // VERILERI RAM E YAZMA
                    
                    DECODE0:begin
                        durum <= DECODE1;
                    end 
                    DECODE1:begin 
                        if(ind <= mem_satir)begin 
                            en_encoded <= 1;
                            we_encoded <= 1;
                            addr_encoded_veri <= ind;
                            durum <= DECODE2;
                        end else begin
                            //addr_encoded_veri = 0;
                            ind = 0;
                            durum = DECODE3;
                        end
                    end 
                    DECODE2:begin
                        in_encoded <= mem[ind]; //yazacağı veri zaten 8 bit direkt tek satıra aktanır
                        ind <= ind + 1;  // bir sonraki clockta artacak
                        durum <= DECODE1;
                    end 
                    DECODE3:begin
                        addr_encoded_veri <= indis;
                        en_encoded <= 1;  
                        we_encoded <= 0;
                        
                        durum <= DECODE4;
                    end 
                    
                    
                    DECODE4:begin
                        if(gec <= 2)begin // 2
                            gec <= gec + 1;
                            en_encoded <= 1;  
                            we_encoded <= 0;
                            addr_encoded_veri <= indis;
                            en_decode <= 1;
                            data_encode <= out_encoded;
                        end else begin 
                            gec <= 0;
                            indis <= indis + 1;
                            satir <= 0;
                            durum <= DECODE5;
                        end
                    end 
                    
                    DECODE5:begin
                        if(indis < 2)begin 
                            // ikinci 32 bit e ozel 
                            durum <= DECODE4;
                        end else begin
                            gec <= 0;
                            durum <= DECODE6;
                        end
                    end 
                    
                    // 4. VERIYI CEKEMIYOR / DATA DEGISMIYOR // DURUM 4 E GITMIYOR
                    DECODE6:begin // 5
                        // decode alt modülünden yeni veri icin sinyal bekleniyor
                        if(data_gonderme_ok == 1)begin // BU SINYAL DEGISMIYOR 
                            durum <= DECODE4;
                        end
                        
                        
                        // 64 lük veri decode edildi konvolüsyona gondermek icin ram e gidiyor 
                        else if(decode_edildi == 1)begin 
                            if(gec < 0)begin    // alt modülden ramdeki ilk veriyi okumak için
                                gec <= gec + 1;
                            end else begin
                              
                              addr_decoded_veri <= satir_son_ram; //satir;
                              durum <= DECODE7; // 6
                            end
                        end
                        // ISLEM SONLANIR 
                        else if(satir_son_ram == max_row)begin
                            durum <= DECODE_SON;
                        end else begin
                        end
                    end
                    
                    DECODE7:begin
                        if(satir_son_ram < max_row)begin
                            durum <= DECODE8; // 10
                        end else begin
                            satir_son_ram <= 0;
                            durum <= DECODE_SON;
                        end
                    end 
                    
                    DECODE8:begin
                        if(satir < 64)begin
                            en_decoded = 1;
                            we_decoded = 1; // yazma 
                            decode_veri[satir] <= data_decode;
                            cikti_mem[satir_son_ram] <= data_decode;
                            in_decoded <= data_decode; // satir_son_ram; 
                            satir <= satir + 1; 
                            satir_son_ram <= satir_son_ram + 1;
                            durum <= DECODE6;
                        end else begin
                            satir <= 0;
                            durum <= DECODE6;
                        end
                    end
                    
                    DECODE_SON:begin
                        // 981427390
                       
                        addr_decoded_veri <= 0; 
                        durum <= YERLESTIR1;
                        indis <= 0;
                    end 
                    
                    YERLESTIR1:begin
                        if(indis <= max_row)begin
                            addr_decoded_veri <= indis;
                            //konv[indis] <= out_decoded;
                            konv[indis] <= cikti_mem[indis];
                            indis <= indis + 1;
                        end else begin
                            durum <= YERLESTIR2;
                        end 
                    end 
                    
                    YERLESTIR2:begin
                        ram_out[o] <= konv[i]; 
                        ram_out[o+1] <= konv[i+1];
                        ram_out[o+2] <= konv[i+2];
                        ram_out[o+3] <= konv[i+3];
                        ram_out[o+4] <= konv[i+4];
                        ram_out[o+5] <= konv[i+5];
                        ram_out[o+6] <= konv[i+6];
                        ram_out[o+7] <= konv[i+7];
     
                        ram_out[o+320] <= konv[i+8];
                        ram_out[o+321] <= konv[i+9];
                        ram_out[o+322] <= konv[i+10];
                        ram_out[o+323] <= konv[i+11];
                        ram_out[o+324] <= konv[i+12];
                        ram_out[o+325] <= konv[i+13];
                        ram_out[o+326] <= konv[i+14];
                        ram_out[o+327] <= konv[i+15];         
                                          
                        ram_out[o+640] <= konv[i+16];
                        ram_out[o+641] <= konv[i+17];
                        ram_out[o+642] <= konv[i+18];
                        ram_out[o+643] <= konv[i+19];
                        ram_out[o+644] <= konv[i+20];
                        ram_out[o+645] <= konv[i+21];
                        ram_out[o+646] <= konv[i+22];
                        ram_out[o+647] <= konv[i+23];                       
     
                        ram_out[o+960] <= konv[i+24];
                        ram_out[o+961] <= konv[i+25];
                        ram_out[o+962] <= konv[i+26];
                        ram_out[o+963] <= konv[i+27];
                        ram_out[o+964] <= konv[i+28];
                        ram_out[o+965] <= konv[i+29];
                        ram_out[o+966] <= konv[i+30];
                        ram_out[o+967] <= konv[i+31];                 
     
                        ram_out[o+1280] <= konv[i+32];
                        ram_out[o+1281] <= konv[i+33];
                        ram_out[o+1282] <= konv[i+34];
                        ram_out[o+1283] <= konv[i+35];
                        ram_out[o+1284] <= konv[i+36];
                        ram_out[o+1285] <= konv[i+37];
                        ram_out[o+1286] <= konv[i+38];
                        ram_out[o+1287] <= konv[i+39];                    
     
                        ram_out[o+1600] <= konv[i+40];
                        ram_out[o+1601] <= konv[i+41];
                        ram_out[o+1602] <= konv[i+42];
                        ram_out[o+1603] <= konv[i+43];
                        ram_out[o+1604] <= konv[i+44];
                        ram_out[o+1605] <= konv[i+45];
                        ram_out[o+1606] <= konv[i+46];
                        ram_out[o+1607] <= konv[i+47];            
     
                        ram_out[o+1920] <= konv[i+48];
                        ram_out[o+1921] <= konv[i+49];
                        ram_out[o+1922] <= konv[i+50];
                        ram_out[o+1923] <= konv[i+51];
                        ram_out[o+1924] <= konv[i+52];
                        ram_out[o+1925] <= konv[i+53];
                        ram_out[o+1926] <= konv[i+54];
                        ram_out[o+1927] <= konv[i+55];            
      
                        ram_out[o+2240] <= konv[i+56];
                        ram_out[o+2241] <= konv[i+57];
                        ram_out[o+2242] <= konv[i+58];
                        ram_out[o+2243] <= konv[i+59];
                        ram_out[o+2244] <= konv[i+60];
                        ram_out[o+2245] <= konv[i+61];
                        ram_out[o+2246] <= konv[i+62];
                        ram_out[o+2247] <= konv[i+63];
                        
                        durum <= YERLESTIR3;
                    end
                    
                    YERLESTIR3:begin
                        //320x240 matrisinde sütunda gezme
                        if(k<39)begin
                            o<=o+8;
                            i<=i+64;
                            k<=k+1;
                            durum <= YERLESTIR2;
                        end else begin
                            durum <= YERLESTIR4;
                        end
                    end
                    
                    YERLESTIR4:begin
                        //320x240 matrisinde sat?rda gezme
                        if(l<30) begin
                            o<=o+2248;
                            i<=i+64;
                            l<=l+1;
                            k<=0;
                            durum <= YERLESTIR2;         
                        end else begin
                            durum <= YERLESTIR5;
                        end
                    end
                    
                    YERLESTIR5:begin
                        ind <= 0;
                        gec <= 0;
                        bitis <= 1; 
                        durum <= YERLESTIR6;
                    end
                    YERLESTIR6:begin
                        en_ram1 = 1;
                        we_ram1 = 1;
                        addr_ram1 <= ind;
                        durum = YERLESTIR7;
                    end 
                    
                    YERLESTIR7:begin
                        if(ind < max_row)begin
                            if(gec < 1)begin
                                gec <= gec + 1;
                                cikti_mem2[ind] <= ram_out[ind];
                                data_i_ram1 <= ram_out[ind]; // mem[ind];
                            end else begin
                                gec <= 0;
                                ind <= ind + 1;
                                durum <= YERLESTIR6;
                            end 
                        end else begin
                            addr_ram1 <= 0;
                            ind <= 0;
                            durum <= 2;
                        end
                    end 
                    
                    // DECODE CIKTISINI RAM E YAZMA 
                    
                    2:begin
                        if(en_gorev_i == 16'ha040)begin
                            ind <= 0;
                            durum <= 3;
                        end else begin
                            ind <= 0;
                            en_ram1 = 1;
                            we_ram1 = 0;
                            addr_ram1 <= 0;
                            durum <= 5;
                        end
                    end 
                    
                    3:begin
                        en_ram_htable = 1;
                        we_ram_htable = 1;
                        addr_ram_htable <= ind;
                        durum = 4;
                    end 
                    
                    // HISTOGRAM RAM E YAZMA 
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
                        en_ram1 = 1;
                        we_ram1 = 0; // okuma
                        addr_ram1 = 0;
                        addr_ram_htable <= 0;
                        if(en_gorev_i == 16'ha060)begin // gorev6
                            en_gorev6 <= 1;
                            veri_al <= veri_al6;
                            durum <= VERI_GONDER_GOREV1;
                        end 
                         else if(en_gorev_i == 16'hA010)begin // gorev4
                            en_gorev1 <= 1;
                            veri_al <= veri_al1;
                            durum <= VERI_GONDER_GOREV1;
                        end
                        else if(en_gorev_i == 16'hA020)begin // gorev4
                            en_gorev2 <= 1;
                            veri_al <= veri_al2;
                            durum <= VERI_GONDER_GOREV1;
                        end
                        else if(en_gorev_i == 16'hA030)begin // gorev4
                            en_gorev3 <= 1;
                            veri_al <= veri_al3;
                            durum <= VERI_GONDER_GOREV1;
                        end
                        else if(en_gorev_i == 16'hA040)begin // gorev4
                            en_gorev4 <= 1;
                            veri_al <= veri_al4;
                            durum <= VERI_GONDER_GOREV1;
                        end
                        else if(en_gorev_i == 16'hA050)begin // gorev5
                            en_gorev5 <= 1;
                            veri_al <= veri_al5;
                            durum <= VERI_GONDER_HIS1;
                        end else begin
                            bit <= 1;
                        end 
                        
                        
                    end 
                    
                    
                    // HISTOGRAM ALT MODULE GONDER // GOREV5 ICIN
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
                    
                    // ASIL VERI ALT MODULE GONDER // DIGER GOREVLER ICIN
                    
                    VERI_GONDER_GOREV1:begin
                        if(veri_al == 1 && ind < max_row)begin
                            durum <= VERI_GONDER_GOREV2;
                        end else begin
                            ind <= 0;
                            en_ram2 = 1;
                            we_ram2 = 1;
                            addr_ram2 = 0;
                            durum <= VERI_AL_GOREV1;
                        end
                    end 
                    VERI_GONDER_GOREV2:begin
                        durum <= VERI_GONDER_GOREV3;
                    end 
                    VERI_GONDER_GOREV3:begin
                        if(en_gorev_i == 16'ha060)begin // gorev6
                            if(gec <11)begin 
                               gec <= gec + 1;
                               en_ram1 = 1;
                               we_ram1 = 0; // okuma
                               veri_i_gorev <= data_o_ram1;
                            end else begin
                               ind <= ind + 1;
                               gec <= 0;
                               durum <= VERI_GONDER_GOREV4;
                            end 
                        end else begin // gorev4
                            if(gec < 4)begin  // 3
                                gec <= gec + 1;
                                en_ram1 = 1;
                                we_ram1 = 0; // okuma
                                veri_i_gorev <= data_o_ram1;
                            end else begin
                                ind <= ind + 1;
                                gec <= 0;
                                durum <= VERI_GONDER_GOREV4;
                            end
                        end 
                    end
                    VERI_GONDER_GOREV4:begin
                        addr_ram1 <= ind;
                        durum <= VERI_GONDER_GOREV2;
                    end
                    
                     // ALT MODULDEN AL
                    VERI_AL_GOREV1:begin
                        if((islem_bitti6 == 1 && veri_gonder6 == 1) && (islem_bitti1 == 1 && veri_gonder1 == 1) && (islem_bitti3 == 1 && veri_gonder3 == 1))begin
                            durum <= VERI_AL_GOREV2;
                        end else begin
                            bit <= 1;
                        end 
                    end
                    
                    VERI_AL_GOREV2:begin
                        if(en_gorev_i == 16'hA040 && indis < 256)begin // gorev4
                            durum <= VERI_AL_GOREV3;
                        end 
                        else if(en_gorev_i == 16'hA060 && indis < max_row)begin
                            durum <= VERI_AL_GOREV3;
                        end else begin
                            //indis <= 0;
                            ind <= 0;
                            en_ram2 = 1;
                            we_ram2 = 0; // okuma
                            addr_ram2 = ind; 
                            en_ram_htable = 0;
                            we_ram_htable = 0; // okuma
                            addr_ram_htable = ind; 
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
                        if(en_gorev_i == 16'hA060)begin // gorev6
                            if(gec < 8)begin  
                                gec <= gec + 1;
                                en_ram2 = 1;
                                we_ram2 = 1; // yazma
                                cikti_mem[indis] <= veri_o_gorev;
                                data_i_ram2 <= veri_o_gorev;
                            end else begin
                                gec <= 0;
                                indis <= indis + 1;
                                durum <= VERI_AL_GOREV6;
                            end
                        end else begin // gorev5 / gorev4
                            if(gec < 2)begin   
                                gec <= gec + 1;
                                en_ram2 = 1;
                                we_ram2 = 1; // yazma
                                cikti_mem[indis] <= veri_o_gorev;
                                data_i_ram2 <= veri_o_gorev;
                                cikti_mem1[indis] <= veri_o_gorev4;
                                data_i_ram_htable <= veri_o_gorev4;
                            end else begin
                                gec <= 0;
                                indis <= indis + 1;
                                durum <= VERI_AL_GOREV6;
                            end
                        end
                    end
                    
                    VERI_AL_GOREV5:begin
                        if(gec < 2)begin   //8
                            gec <= gec + 1;
                            en_ram2 = 1;
                            we_ram2 = 1; // yazma
                            cikti_mem1[indis] <= veri_o_gorev;
                            data_i_ram2 <= veri_o_gorev;
                            cikti_mem1[indis] <= veri_o_gorev4;
                            data_i_ram_htable <= veri_o_gorev4;
                        end else begin
                            gec <= 0;
                            indis <= indis + 1;
                            durum <= VERI_AL_GOREV6;
                        end
                    end 
                    
                    VERI_AL_GOREV6:begin
                        addr_ram2 <= indis;
                        addr_ram_htable <= indis;
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
    
    integer m,n;
    
     initial begin 
        #77000
        n=$fopen("D:\\vivado\\decode_cikti.txt","w"); 
      end
        initial begin
              #331427390 // 1088571711
              for (m = 0; m<max_row; m=m+1) 
                  $fwrite(n,"%d\n",cikti_mem2[m]); 
              #331427390 // 
              $fclose(n);
        end
    
     integer x,y;
    
     initial begin 
        #77000
        y=$fopen("D:\\vivado\\düzenli_decode_cikti.txt","w"); 
      end
        initial begin
              #1019427390 // 1088571711
              for (x = 0; x<max_row; x=x+1) 
                  $fwrite(y,"%d\n",cikti_mem2[x]); 
              #1019657390 // 
              $fclose(y);
        end
    
    integer j,f;
    /*
     initial begin 
        #7700
        f=$fopen("D:\\vivado\\gorev4_cikti.txt","w"); 
      end
        initial begin
              #1020657390 // #3434496
              for (j = 0; j<256; j=j+1) 
                  $fwrite(f,"%b\n",cikti_mem[j]); 
              #1020657490 // #3439496
              $fclose(f);
        end
    */
    initial begin 
        #7700
        f=$fopen("D:\\vivado\\gorev_cikti.txt","w"); 
      end
        initial begin
              #1020657390
              for (j = 0; j<max_row; j=j+1) 
                  $fwrite(f,"%d\n",cikti_mem1[j]); 
              #1020657490
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
    
    decode DECODE(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_decode),
        .encoded_i(data_encode),
        .sonuc_o(data_gonderme_ok),
        .decoded_o(data_decode),
        .decode_et_o(decode_edildi));
        
    gorev1 GOREV1(                                                                                           
    .clk_i(clk_i),                                                                                               
    .rst_i(rst_i),                                                                                               
    .en_i(en_gorev1),                                                                                            
    .veri_i(veri_i_gorev),                                                                                      
    .veri_o(veri_o_gorev),                                                                                      
    .veri_al_o(veri_al1),                                                                                         
    .veri_gonder_o(veri_gonder1),                                                                                 
    .islem_bitti_o(islem_bitti1));  
    
    gorev2 GOREV2(                                                                                           
    .clk_i(clk_i),                                                                                               
    .rst_i(rst_i),                                                                                               
    .en_i(en_gorev2),                                                                                            
    .veri_i(veri_i_gorev),                                                                                      
    .veri_o(veri_o_gorev),                                                                                      
    .veri_al_o(veri_al2),                                                                                         
    .veri_gonder_o(veri_gonder2),                                                                                 
    .islem_bitti_o(islem_bitti2));
    
    gorev3 GOREV3(                                                                                                                                                              
    .clk_i(clk_i),                                                                                                                                                                  
    .rst_i(rst_i),                                                                                                                                                                  
    .en_i(en_gorev3),                                                                                                                                                               
    .veri_i(veri_i_gorev),                                                                                                                                                         
    .veri_o(veri_o_gorev),                                                                                                                                                         
    .veri_al_o(veri_al3),                                                                                                                                                            
    .veri_gonder_o(veri_gonder3),                                                                                                                                                    
    .islem_bitti_o(islem_bitti3));  
    
    gorev4 gorev4_htable(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_gorev4),
    .veri_i(veri_i_gorev),
    .veri_o(veri_o_gorev4),
    .veri_al_o(veri_al4),   
    .veri_gonder_o(veri_gonder4),
    .islem_bitti_o(islem_bitti4));
    
    gorev5 gorev5_histogram_esit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_gorev5),
    .veri_i(veri_i_gorev),
    .veri_o(veri_o_gorev),
    .veri_al_o(veri_al5),  
    .veri_al_his_o(veri_al_his),
    .veri_histogram_i(veri_histogram), 
    .veri_gonder_o(veri_gonder5),
    .islem_bitti_o(islem_bitti5));
    

    gorev6 GOREV6(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_gorev6),
    .veri_i(veri_i_gorev),
    .veri_o(veri_o_gorev),
    .veri_al_o(veri_al6),   
    .veri_gonder_o(veri_gonder6),
    .islem_bitti_o(islem_bitti6));
    
    
    // 8 bitlik ram / 76800 satır
    ram#(.V(8),.S(76800),.A(17)) RAM2(
        .clk_i(clk_i),
        .en_i(en_ram2),
        .we_i(we_ram2),
        .address_i(addr_ram2),
        .data_i(data_i_ram2),
        .data_o(data_o_ram2)
    );
    
    // DECODE
    // 32 bitlik ram / 2405 satır // 13
    ram#(.V(32),.S(mem_satir),.A(13)) encoded_ram(
        .clk_i(clk_i),
        .en_i(en_encoded),
        .we_i(we_encoded),
        .address_i(addr_encoded_veri),
        .data_i(in_encoded),
        .data_o(out_encoded)
    );
    
   
    
        
    // 8 bitlik ram / 76800 satır
    ram#(.V(8),.S(76800),.A(17)) decoded_ram(
        .clk_i(clk_i),
        .en_i(en_decoded),
        .we_i(we_decoded),
        .address_i(addr_decoded_veri),
        .data_i(in_decoded),
        .data_o(out_decoded)
    );
endmodule
