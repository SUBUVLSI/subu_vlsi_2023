`timescale 100ns / 1ps


module inverse_top(
    input clk_i,rst_i,en_i,
    output reg son
    );
    
    reg [6:0] durum = 0;
    integer sayac = 0, gec = 0;
    
    
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
    
    
    
    
    integer ind = 0;
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
    
    integer indis = 0;
    reg [31:0] veri;
    
    reg [7:0] decode_veri [63:0];
    integer satir = 0;
    
    
    wire [31:0] buffer, data;
    wire [6:0] decode_durum;
    wire [31:0] encoded_resim_deger;
    wire [6:0] cik;
    wire [12:0] eob_deger;
    wire [6:0] say_kontrol;
    wire [6:0] say_kontrol_fark;
    wire [6:0] sag_sol_fark;
    wire [63:0] encoded_top;
    wire [10:0] dc_deger;
    wire [10:0] dc_deg_onceki;
    wire [10:0] ac_deger;
    wire [6:0] ondeki_sifir_say;
    reg [6:0] satir_oku = 0;
    
    parameter cikti_mem_satir = 76799;
    reg [7:0] cikti_mem[0:cikti_mem_satir]; // cikti
    parameter max_row = 76800;
    
    
    // konvolusyon icin
    parameter 
        YERLESTIR1 = 19,
        YERLESTIR2 = 20,
        YERLESTIR3 = 21,
        YERLESTIR4 = 22,
        YERLESTIR5 = 23,
        YERLESTIR6 = 24,
        YERLESTIR7 = 25,
        YERLESTIR8 = 26;
                
    reg [7:0] konv [0:max_row-1];
    reg [7:0] ram_out [0:max_row-1];
    
    integer i = 0, o = 0, k = 0, l = 0;
    reg bitis = 0;
    always@(posedge clk_i)begin
        if(rst_i)begin
        end else begin
            if(en_i == 1)begin
                sayac = sayac + 1;
                case(durum)
                 
                     0:begin
                        durum <= 1;
                    end 
                    1:begin 
                        if(ind <= mem_satir)begin 
                            en_encoded <= 1;
                            we_encoded <= 1;
                            addr_encoded_veri <= ind;
                            durum <= 2;
                        end else begin
                            //addr_encoded_veri = 0;
                            ind = 0;
                            durum = 3;
                        end
                    end 
                    2:begin
                        in_encoded <= mem[ind]; //yazacağı veri zaten 8 bit direkt tek satıra aktanır
                        ind <= ind + 1;  // bir sonraki clockta artacak
                        durum <= 1;
                    end 
                    3:begin
                        addr_encoded_veri <= indis;
                        en_encoded <= 1;  
                        we_encoded <= 0;
                        
                        durum <= 4;
                    end 
                    
                    /*
                    4:begin 
                        // addr_encoded_veri <= 4;
                        data_encode <= out_encoded;
                        
                    end 
                    */
                    
                    4:begin
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
                            durum <= 9;
                        end
                    end 
                    
                    9:begin
                        if(indis < 2)begin 
                            // ikinci 32 bit e ozel 
                            durum <= 4;
                        end else begin
                            gec <= 0;
                            durum <= 5;
                        end
                    end 
                    
                    5:begin
                        // decode alt modülünden yeni veri icin sinyal bekleniyor
                        if(data_gonderme_ok == 1)begin // BU SINYAL DEGISMIYOR 
                            durum <= 4;
                        end
                        

                        
                        // 64 lük veri decode edildi konvolüsyona gondermek icin ram e gidiyor 
                        else if(decode_edildi == 1)begin 
                            if(gec < 0)begin    // alt modülden ramdeki ilk veriyi okumak için
                                gec <= gec + 1;
                            end else begin
                              
                              addr_decoded_veri <= satir_son_ram; //satir;
                              durum <= 6;
                            end
                        end
                        // ISLEM SONLANIR 
                        else if(satir_son_ram == max_row)begin
                            durum <= 8;
                        end else begin
                        end
                    end
                    
                    6:begin
                        if(satir_son_ram < max_row)begin
                            durum <= 10;
                        end else begin
                            satir_son_ram <= 0;
                            durum <= 8;
                        end
                    end 
                    
                    10:begin
                        if(satir < 64)begin
                            en_decoded = 1;
                            we_decoded = 1; // yazma 
                            decode_veri[satir] <= data_decode;
                            cikti_mem[satir_son_ram] <= data_decode;
                            in_decoded <= data_decode; // satir_son_ram; 
                            satir <= satir + 1; 
                            satir_son_ram <= satir_son_ram + 1;
                            durum <= 5;
                        end else begin
                            satir <= 0;
                            durum <= 5;
                        end
                    end
                    
                    8:begin
                        // 981427390
                       
                        addr_decoded_veri <= 0; 
                        durum <= YERLESTIR1;
                        indis <= 0;
                        son = 1;
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
                        bitis <= 1; 
                    end
                    
                    YERLESTIR6:begin
                    end
                    
                    
                endcase
            end
        end
        
    end
    
    
    
      integer j,f;
    
     initial begin 
        #77000
        f=$fopen("D:\\vivado\\decode_cikti.txt","w"); 
      end
        initial begin
              #1001427390 // 981427390 // 991520589
              for (j = 0; j<max_row; j=j+1) 
                  $fwrite(f,"%d\n",cikti_mem[j]); 
              #1009457390 // 999125384
              $fclose(f);
        end
        
    integer x,y;
    
     initial begin 
        #77000
        y=$fopen("D:\\vivado\\düzenli_decode_cikti.txt","w"); 
      end
        initial begin
              #1019427390 // 1088571711
              for (x = 0; x<max_row; x=x+1) 
                  $fwrite(y,"%d\n",ram_out[x]); 
              #1019657390 // 
              $fclose(y);
        end
    
    // 32 bitlik ram / 2405 satır // 13
    ram#(.V(32),.S(mem_satir),.A(13)) encoded_ram(
        .clk_i(clk_i),
        .en_i(en_encoded),
        .we_i(we_encoded),
        .address_i(addr_encoded_veri),
        .data_i(in_encoded),
        .data_o(out_encoded)
    );
    
   
    decode DECODE(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_decode),
        .encoded_i(data_encode),
        .sonuc_o(data_gonderme_ok),
        .decoded_o(data_decode),
        .decode_et_o(decode_edildi)
        
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




