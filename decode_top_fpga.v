`timescale 1ns / 1ps

module decode_top
    #(
        c_clkfreq    = 100_000_000,
        c_baudrate   = 115_200,
        parameter mem_satir = 2405,
        parameter max_row = 76800,
        parameter cikti_mem_satir = 76799
    )
    (
    input clk_i,rst_i,en_i,
    input   wire    i_Rx_Serial,
    input   wire    i_wenable,
    input   wire    i_renable,
//        input   wire    veri_1,
    output  wire    o_Tx_Serial,   
    output  reg     led_tx,
    output  reg     led_rx
    //output reg son
    );
    
    reg [5:0] durum = 0;
//    integer sayac = 0;
    integer gec = 0;
    
   
    
    // ENCODED VERI ICIN RAM
    integer encoded_satir = 0;
    reg [11:0] addr_encoded_veri; // ramin satır sayısı bilinmiyor / 2^x = mem_satir
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
    
    //tx
    reg         i_Tx_start;
    reg [7:0]   i_Tx_Byte = 0;
    wire        o_Tx_Done;
    wire        o_Tx_Active;
    
    //rx
    wire        o_Rx_done;
    wire [7:0]  o_Rx_Byte;   

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
    
    
    
    
    
    reg [31:0] databuffer = 0;
//    reg [20:0] indis = 0;
    reg [20:0] counter = 0;
    reg [4:0] state = 4'b0000; 
//    reg [5:0] durum = 6'b000000;
    reg [3:0] drm = 4'b0000;
    reg [31:0] shift_reg = 0;
    reg [3:0] buffer_segment = 0;
//    reg [31:0] data_reg = 0;
    reg [20:0] cntr = 0;
    
    
    
    // ENODED RESIM RAM
    reg [1:0] addr_res_veri = 0; // 76800 tane veri  [3:0] / 4
    reg we_res , en_res;
//    reg [63:0] in_res;
//    wire [63:0] out_res;
    reg [31:0] in_res;
    wire [31:0] out_res;
    
    wire [7:0] durum_oku;
    wire [63:0] encoded_resim;
    
    wire [10:0] asil_deger_dc_al;
    wire [31:0] encoded_veri_i_ac;
//    reg [63:0] data_reg = 0;
    reg [31:0] data_reg = 0;
//    reg [63:0] shift_reg2 = 0;
    reg [31:0] shift_reg2 = 0;
    reg [3:0] buffer_segment2 = 0;
    
      // kuantalam onuc ram icin
      
    reg en_ram_htable;
    reg we_ram_htable;
    reg [5:0] addr_ram_htable;
    reg [31:0] data_i_ram_htable;
    wire [31:0] data_o_ram_htable;
    
    wire [31:0] kuantalama_cikti;
    wire [31:0]  kuantalama_cikti1, kuantalama_cikti2;
    
    always@(posedge clk_i)begin
        if(rst_i)begin
        end else begin
            if(en_i == 1)begin
//                sayac = sayac + 1;
                case(durum)
                                        
                    0: 
                    begin
                        led_tx <= 1'b0;
                        led_rx <= 1'b0;
                        durum <= 1;
                    end

                   1:
                    begin
                
                        if(i_wenable) begin
                        
                           we_encoded <= 1'b1; 
                           en_encoded <= 1'b1;
                           
                                case (drm)
                                                   
                                     0:  begin
                                             if(o_Rx_done) begin 
                                             
                                                 databuffer      <= {shift_reg[31:8],o_Rx_Byte};
                                                 buffer_segment  <= buffer_segment + 1;
                                                 drm           <= 4'b0001;
                                                 
                                             end
                                         end
                                         
                                     1:  begin
                                        
                                        if(buffer_segment == 4) begin
                                            shift_reg                  <= 0;
                                            buffer_segment        <= 0;
                                            in_encoded              <= databuffer;
                                            addr_encoded_veri   <= indis;
                                            indis                        <= indis + 1;
                                            counter                    <= counter +1;
                                        end else begin
                                           shift_reg <= databuffer << 8 ;
                                        end
                                        
                                        if(counter == mem_satir) begin ///mem_satir+1
                                           led_rx                      <= 1'b1;
                                           led_tx                      <= 1'b0;
                                           addr_encoded_veri   <= ind;
                                           shift_reg                  <= 0;
                                           en_encoded             <= 1;  
                                           we_encoded            <= 0;
                                           buffer_segment       <= 0;
                                           indis <= 0;
                                           durum                       <= 4;
                                        end else begin
                                               drm <= 4'b0000;
                                        end
                                     end
                                                   
                                endcase
                                
                        end     
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
                        
//                    
                        
                        // 64 lük veri decode edildi konvolüsyona gondermek icin ram e gidiyor 
                        else if(decode_edildi == 1)begin 
                            if(gec < 1)begin    // alt modülden ramdeki ilk veriyi okumak için
                                gec <= gec + 1;
                                
                            end else begin
                              addr_ram_htable <= satir_son_ram;
                              addr_decoded_veri <= satir_son_ram; //satir;
                              durum <= 6;
                            end
                        end
                        // ISLEM SONLANIR 
                        else if(satir_son_ram == max_row)begin // max_row
                            durum <= 16;
                        end else begin
                        end
                    end
                    
                    6:begin
                        if(satir_son_ram < max_row)begin // 63
                            durum <= 10;
                        end else begin
                            satir_son_ram <= 0;
                            durum <= 16;
                        end
                    end 
                    
                    10:begin
                        if(satir < 64)begin
                            en_decoded = 1;
                            we_decoded = 1; // yazma 
                            decode_veri[satir] <= data_decode;
//                      
                            in_decoded <= data_decode; // satir_son_ram; 
                            satir <= satir + 1; 
                            satir_son_ram <= satir_son_ram + 1;
                            durum <= 5;
                        end else begin
                            satir <= 0;
                            durum <= 5;
                        end
                    end
                    
                    16: begin
                        led_tx <= 1'b1;
                        if(i_renable) begin
                            we_decoded  <= 1'b0;
                            en_decoded  <= 1'b1;
                            addr_decoded_veri   <= 0;
                            durum               <= 17;
                        end
                    end
             
                  
            17:
                begin
                        
                        case (drm)
                        
                        0:  begin
                                we_decoded          <= 1'b0;
                                en_decoded          <= 1'b1;
                                
                                drm                 <= 4'b0011;
                            end
                            
                        1:  begin
                                if(cntr < max_row) begin // 64
                                    i_Tx_start  <= 1'b1;
                                    i_Tx_Byte   <= out_decoded;
                                    drm         <= 4'b0100;
                                    
                                end else begin
                                    i_Tx_start          <= 0;
                                    en_decoded          <= 1'b0;
                                    we_decoded          <= 1'b0;
                                    addr_decoded_veri   <= 0;
                                    durum               <= 0;
                                    led_tx              <= 0;
                                end
                            end    
                                
                        2:  begin
                                    i_Tx_start          <= 1'b0;  
                                    cntr                <= cntr +1;  
                                    drm                 <= 4'b0001;    
                            end  
                            
                        3:  begin
                                drm <= 4'b0001;
                            end
                            
                        4:  begin
                                i_Tx_start <= 0;
                                if(o_Tx_Done) begin
                                    addr_decoded_veri   <= addr_decoded_veri + 1; 
                                    drm     <= 4'b0010;
                               end 
                            end
                            
                      endcase
                      
                    end
                    
                   
                endcase
            end
        end
        
    end
    
    
    


    
    // 32 bitlik ram / 2405 satır // 13
    ram#(.V(32),.S(mem_satir),.A(12)) encoded_ram(
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
        .durum_oku_o(durum_oku),
        .encoded_resim_o(encoded_resim),
        .asil_deger_dc_al_o(asil_deger_dc_al),
//        .encoded_veri_i_ac_o(encoded_veri_i_ac),
        .kuantalama_cikti_o(kuantalama_cikti),
        .kuantalama_cikti1_o(kuantalama_cikti1),
        .kuantalama_cikti2_o(kuantalama_cikti2)
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
    
    uart_tx_t 
    #(
        .c_clkfreq  (c_clkfreq),
        .c_baudrate (c_baudrate)
    )
    uart_tx_ram
    (
        .i_clk         (clk_i),
        .i_Tx_start    (i_Tx_start),	
        .i_Tx_Byte     (i_Tx_Byte),
        .o_Tx_Active   (o_Tx_Active),		
        .o_Tx_Serial   (o_Tx_Serial),   
        .o_Tx_Done     (o_Tx_Done)
    );

    uart_rx_t
    #(   
        .c_clkfreq   (c_clkfreq),
        .c_baudrate  (c_baudrate)     
    )
    uart_rx_ram
    (
        .i_clk          (clk_i),
        .i_Rx_Serial    (i_Rx_Serial),    	
        .o_Rx_done      (o_Rx_done),		
        .o_Rx_Byte 		(o_Rx_Byte)
    );
    
    // 8 bitlik ram / 76800 satır
    ram#(.V(32),.S(2),.A(2)) encoded_resim_ram(
        .clk_i(clk_i),
        .en_i(en_res),
        .we_i(we_res),
        .address_i(addr_res_veri),
        .data_i(in_res),
        .data_o(out_res)
    );
    
    
    // kuantlama sonucu icin
    
    // 8 bitlik ram / 76800 satır
    ram#(.V(32),.S(64),.A(6)) RAM_HISTORGAM_TABLE(
        .clk_i(clk_i),
        .en_i(en_ram_htable),
        .we_i(we_ram_htable),
        .address_i(addr_ram_htable),
        .data_i(data_i_ram_htable),
        .data_o(data_o_ram_htable)
    );
    
endmodule
