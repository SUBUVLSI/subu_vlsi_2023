`timescale 100ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.01.2023 16:31:34
// Design Name: 
// Module Name: inverse_top
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

// verýyý alt module yanlýs gonderýyor 
// sadece 1 kez alt modulden verý okuyabýlýyor

module decode_tb(
    input clk_i,rst_i,en_i,
    output reg son
    );
    
    reg [3:0] durum = 0;
    integer sayac = 0, gec = 0;
    
    
    parameter mem_satir = 2405;
    reg [31:0] mem [0:mem_satir]; // bitstream
    
    initial begin
        $readmemb("D:\\vivado\\bytearray_32bit.txt",mem);  
    end
    
    // ENCODED VERI ICIN RAM
    integer encoded_satir = 0;
    reg [12:0] addr_encoded_veri; // ramin satýr sayýsý bilinmiyor / 2^x = mem_satir
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
                        in_encoded <= mem[ind]; //yazacaðý veri zaten 8 bit direkt tek satýra aktanýr
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
                    
                    // VERIYI YANLIs GONDERIYOR 
                    4:begin
                        if(gec <= 2)begin
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
                            if(indis < 2)begin 
                                // ikinci 32 bit e ozel 
                                durum <= 4;
                            end else begin
                                gec <= 0;
                                durum <= 5;
                            end
                        end
                    end 
                    
                    // 4. VERIYI CEKEMIYOR / DATA DEGISMIYOR // DURUM 4 E GITMIYOR
                    5:begin
                        // decode alt modülünden yeni veri icin sinyal bekleniyor
                        if(data_gonderme_ok == 1)begin // BU SINYAL DEGISMIYOR 
                            durum <= 4;
                        end
                        // 64 lük veri decode edildi konvolüsyona gondermek icin ram e gidiyor 
                        else if(decode_edildi == 1)begin 
                            if(gec < 1)begin    // alt modülden ramdeki ilk veriyi okumak için
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
                        end else begin
                            satir_son_ram <= 0;
                            durum <= 8;
                        end
                    end 
                    
                    
                    8:begin
                        // 981427390
                        addr_decoded_veri <= 0; 
                        son = 1;
                    end 
                    
                endcase
            end
        end
        
    end
    
    
    
      integer j,f;
    
     initial begin 
        #77000
        f=$fopen("D:\\vivado\\cikti.txt","w"); 
      end
        initial begin
              #991427390 // 981427390
              for (j = 0; j<max_row; j=j+1) 
                  $fwrite(f,"%d\n",cikti_mem[j]); 
              #991457390 // 999125384
              $fclose(f);
        end
        

    
    // 32 bitlik ram / 2405 satýr // 13
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
        .decode_et_o(decode_edildi),
        .bufferr(buffer),
        .dataa(data),
        .decode_durum_o(decode_durum),
        .cikk(cik),
        .encoded_resim_o(encoded_resim_deger),
        .eob_deger_o(eob_deger),
        .say_o(say_kontrol),
        .say_kontrol_o(say_kontrol_fark),
        .sag_sol_fark_o(sag_sol_fark),
        .encoded_top(encoded_top),
        .dc_deger(dc_deger),
        .dc_deg_onceki(dc_deg_onceki),
        .ac_deger(ac_deger),
        .satir_oku(satir_oku),
        .ondeki_sifir_say(ondeki_sifir_say)
        
    );
    
    // 8 bitlik ram / 76800 satýr
    ram#(.V(8),.S(76800),.A(17)) decoded_ram(
        .clk_i(clk_i),
        .en_i(en_decoded),
        .we_i(we_decoded),
        .address_i(addr_decoded_veri),
        .data_i(in_decoded),
        .data_o(out_decoded)
    );
    
 
endmodule




