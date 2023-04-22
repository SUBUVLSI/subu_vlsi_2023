`timescale 100ns / 1ps

module gorev4_top_fpga
    
    #(
        parameter   max_row = 76800,
        c_clkfreq    = 100_000_000,
        c_baudrate   = 115_200
    )
    
    (
    input clk_i, rstn_i,en_i,
    input   wire    i_Rx_Serial,
    input   wire    i_wenable,
    input   wire    i_renable,
//    input   wire    veri_1,
    output  wire    o_Tx_Serial,   
    output  reg     led_tx,
    output  reg     led_rx,
    output reg  son_o

    );
    
    
    reg [0:4] durum = 0;
    integer sayac = 0, gec = 0;
    
    
    // RAM1
    reg en_ram1;
    reg we_ram1;
    reg [16:0] addr_ram1;
    reg [7:0] data_i_ram1;
    wire [7:0] data_o_ram1;
    
    // ram_htable
    reg en_ram_htable;
    reg we_ram_htable;
    reg [8:0] addr_ram_htable;
    reg [31:0] data_i_ram_htable;
    wire [31:0] data_o_ram_htable;
    
    //tx
    reg         i_Tx_start;
    reg [7:0]   i_Tx_Byte = 0;
    wire        o_Tx_Done;
    wire        o_Tx_Active;
    
    //rx
    wire        o_Rx_done;
    wire [7:0]  o_Rx_Byte;
    
    reg [20:0] counter = 0;
    reg [3:0] drm = 0;

    integer ind = 0, indis = 0;
    wire veri_gonder, veri_al;
    reg en_gorev4;
    reg [7:0] veri_i_gorev4;
    wire [31:0] veri_o_gorev4;
    wire islem_bitti;
    wire [5:0] durum_oku;
    wire [16:0] indis_kontrol;
    
    reg [31:0] cikti_mem [0:255];

    ///////////////////////////////////////
    reg [31:0] shift_reg = 0;
    reg [3:0] buffer_segment = 0;
    reg [31:0] data_reg = 0;
    reg [20:0] cntr = 0;
    
    reg bit = 0;
    
   reg UART_Kontrol_Yazmaci_tx_Active  ; // tx active when UART_Kontrol_Yazmaci_tx = 1 else do not send data to outside world
   reg UART_Veri_Yazma_Yazmaci_enable  ;// clkfreq/baudrate as input
   reg [7:0] UART_Veri_Yazma_Yazmaci_wdata; // fifo icine yazilacak olan veriler. UART_Kontrol_Yazmaci_tx_Active avtif oldugunda fifo icinden disari gidecek olan veri ayni zamanda
   wire UART_Durum_Yazmaci_tx_full; // indicates that fifo is full
   wire UART_Durum_Yazmaci_tx_empty; // indicates that fifo is empty
//   wire uart_tx_o                          (uart_tx_o                       ) 
   wire UART_veri_gonderildi;
    
    reg             UART_Kontrol_Yazmaci_rx_Active  ; // rx active when UART_Kontrol_Yazmaci_rx = 1 else discard the incoming serial data
    reg             UART_Veri_Okuma_Yazmaci_enable  ; // read enable  ilgili adres master taraindan gelince enable 1 oluyor ve veri okunuyor
//    reg             uart_rx_i                       ; // serial data in
    reg   [15:0]    baud_div = 16'b0000001101100101; // clkfreq/baudrate as input
    wire             UART_Durum_Yazmaci_rx_full      ; // indicates that fifo is full   
    wire             UART_Durum_Yazmaci_rx_empty     ; // indicates that fifo is empty
    wire     [7:0]    UART_Veri_Okuma_Yazmaci_rdata   ; // is read when the related address is true
    wire              UART_Veri_Okundu                ; 
    
    always@(posedge clk_i)begin
        if(!rstn_i)begin
        end else begin
            if(en_i)begin
                sayac <= sayac + 1;
                case(durum)
                    0:begin
                        en_ram1 = 1;
                        we_ram1 = 1;
                        addr_ram1 <= ind;
                        durum = 1;
                        UART_Kontrol_Yazmaci_rx_Active <= 1'b1;
                    end 
                    
                    1:begin
                        if(i_wenable) begin //switch
                            UART_Veri_Okuma_Yazmaci_enable <= 1'b1;
                           if(UART_Veri_Okundu) begin
                               en_ram1 <= 1'b1;
                               we_ram1 <= 1'b1;
                               data_i_ram1  <= UART_Veri_Okuma_Yazmaci_rdata;
                               UART_Veri_Okuma_Yazmaci_enable <= 1'b0;
                               addr_ram1    <= indis;
                               indis        <= indis + 1;
                               counter      <= counter +1;
                           end 
                           
                           if(counter == max_row) begin ///mem_satir+1
                                led_rx      <= 1'b1;
                                led_tx      <= 1'b0;
                                UART_Kontrol_Yazmaci_rx_Active <= 1'b0;
                                UART_Veri_Okuma_Yazmaci_enable <= 1'b0;
                                addr_ram1   <= ind;
                                en_ram1     <= 1'b1;
                                we_ram1     <= 1'b0;
                                indis       <= 0;
                                durum       <= 2;
                            end 
                        end
                    end
                    
                    2:begin
                        en_ram1 = 1;
                        we_ram1 = 0;
                        en_gorev4 <= 1;
                        durum <= 3;
                    end 
                    
                    // ALT MODULE GONDER
                    3:begin
                        if(veri_al == 1 && ind < max_row)begin
                            durum <= 4;
                        end else begin
                            ind <= 0;
                            en_ram_htable = 1;
                            we_ram_htable = 1;
                            addr_ram_htable = 0;
                            durum <= 6;
                        end
                    end 
                    4:begin
                        if(gec < 4)begin  // 3
                            gec <= gec + 1;
                            veri_i_gorev4 <= data_o_ram1;
                        end else begin
                            ind <= ind + 1;
                            gec <= 0;
                            durum <= 5;
                        end
                    end 
                    5:begin
                        addr_ram1 <= ind;
                        durum <= 3;
                    end
                    
                    
                    // ALT MODULDEN AL
                    6:begin
                        if(islem_bitti == 1 && veri_gonder == 1)begin
                            durum <= 7;
                        end else begin
                            bit <= 1;
                        end 
                    end
                    
                    7:begin
                        if(indis < 256)begin
                            durum <= 8;
                        end else begin
                            //indis <= 0;
                            ind <= 0;
                            en_ram_htable = 0;
                            we_ram_htable = 0; // okuma
                            addr_ram_htable = ind; 
                            durum <= 12;
                        end 
                    end 
                    
                    8:begin
                        if(indis < 1)begin
                            durum <= 9;
                        end else begin
                            durum <= 10;
                        end 
                    end 
                    
                    9:begin
                        if(gec < 2)begin   //8
                            gec <= gec + 1;
                            en_ram_htable = 1;
                            we_ram_htable = 1; // yazma
//                            cikti_mem[indis] <= veri_o_gorev4;
                            data_i_ram_htable <= veri_o_gorev4;
                        end else begin
                            gec <= 0;
                            indis <= indis + 1;
                            durum <= 11;
                        end
                    end
                    
                    10:begin
                        if(gec < 2)begin  
                            gec <= gec + 1;
                            en_ram_htable = 1;
                            we_ram_htable = 1; // yazma
//                            cikti_mem[indis] <= veri_o_gorev4;
                            data_i_ram_htable <= veri_o_gorev4;
                        end else begin
                            gec <= 0;
                            indis <= indis + 1;
                            durum <= 11;
                        end
                    end 
                    
                    11:begin
                        addr_ram_htable <= indis;
                        durum <= 7;
                    end
                    
                    12: begin
                        led_rx      <= 1'b0;
                        led_tx      <= 1'b1;
                        
                        if(i_renable) begin
                            
                            case(drm) 
                            
                            0:  begin
                                        we_ram_htable <= 1'b0; 
                                        en_ram_htable <= 1'b1;
                                        drm <= 4'b0100;
                                end
                                
                            4: begin
                                
                                data_reg <= data_o_ram_htable;
                                addr_ram_htable <= addr_ram_htable +1;
                                
                                drm <= 4'b0001;
                                
                            end
                            
                            1:  begin
                                    
                                    if(buffer_segment == 4) begin
                                            buffer_segment <= 0;
//                                            drm <= 4'b0010;
                                            if(cntr > 1024) begin
                                                UART_Kontrol_Yazmaci_tx_Active <= 1'b0;
                                                UART_Veri_Yazma_Yazmaci_enable <= 1'b0;
                                                drm <= 4'b0011;
                                            end else begin
                                                drm <= 4'b0000;
                                            end
                                    end else begin 
                                        cntr <= cntr +1;
                                        UART_Kontrol_Yazmaci_tx_Active <= 1'b1;
                                        UART_Veri_Yazma_Yazmaci_enable <= 1'b1;
                                        {UART_Veri_Yazma_Yazmaci_wdata,shift_reg[23:0]} <= data_reg;   
                                        drm = 4'b0010;
                                    end
                                  end   
                             
                             2: begin
                             
                                        UART_Veri_Yazma_Yazmaci_enable <= 1'b0;
                                      if(UART_veri_gonderildi) begin       
                                       
                                          buffer_segment <= buffer_segment +1;
                                          data_reg <= shift_reg << 8;
                                          
                                          drm <= 4'b0001;
                                      end
                                
                                end 
                             
                             3: begin
                                    
                                    led_tx <= 1'b1;
                                    durum <= 13;
                                end
                                    
                            endcase  
                            end
                    end
                    
                    13:begin
                        son_o <= 1;
                    end 
                    
                    
                endcase
            end else begin 
            end
        end 
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
    
    
    gorev4 gorev4_htable(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_gorev4),
    .veri_i(veri_i_gorev4),
    .veri_o(veri_o_gorev4),
    .veri_al_o(veri_al),   
    .veri_gonder_o(veri_gonder),
    .islem_bitti_o(islem_bitti));
    


    // 8 bitlik ram / 76800 satır
    ram#(.V(32),.S(256),.A(9)) RAM_HISTORGAM_TABLE(
        .clk_i(clk_i),
        .en_i(en_ram_htable),
        .we_i(we_ram_htable),
        .address_i(addr_ram_htable),
        .data_i(data_i_ram_htable),
        .data_o(data_o_ram_htable)
    );

    
    uart_rx_top uart_rx(
      .clk_i                            (clk_i),
      .rstn_i                           (rstn_i),
      .UART_Kontrol_Yazmaci_rx_Active   (UART_Kontrol_Yazmaci_rx_Active), // rx active when UART_Kontrol_Yazmaci_rx = 1 else discard the incoming serial data
      .UART_Veri_Okuma_Yazmaci_enable   (UART_Veri_Okuma_Yazmaci_enable), // read enable  ilgili adres master taraindan gelince enable 1 oluyor ve veri okunuyor
      .uart_rx_i                        (i_Rx_Serial),  // serial data in
      .baud_div                         (baud_div),   // clkfreq/baudrate as input
      .UART_Durum_Yazmaci_rx_full       (UART_Durum_Yazmaci_rx_full),    // indicates that fifo is full   
      .UART_Durum_Yazmaci_rx_empty      (UART_Durum_Yazmaci_rx_empty),     // indicates that fifo is empty
      .UART_Veri_Okuma_Yazmaci_rdata    (UART_Veri_Okuma_Yazmaci_rdata), // is read when the related address is true
      .UART_Veri_Okundu                 (UART_Veri_Okundu)
   );
  
  uart_tx_top uart_tx(
   .clk_i                              (clk_i                           ),
   .rstn_i                             (rstn_i                          ),
   .UART_Kontrol_Yazmaci_tx_Active     (UART_Kontrol_Yazmaci_tx_Active  ), // tx active when UART_Kontrol_Yazmaci_tx = 1 else do not send data to outside world
   .UART_Veri_Yazma_Yazmaci_enable     (UART_Veri_Yazma_Yazmaci_enable  ), // write enable  ilgili adres master taraindan gelince enable 1 oluyor ve veri buffer a yaziliyor
   .baud_div                           (baud_div                        ), // clkfreq/baudrate as input
   .UART_Veri_Yazma_Yazmaci_wdata      (UART_Veri_Yazma_Yazmaci_wdata   ), // fifo icine yazilacak olan veriler. UART_Kontrol_Yazmaci_tx_Active avtif oldugunda fifo icinden disari gidecek olan veri ayni zamanda
   .UART_Durum_Yazmaci_tx_full         (UART_Durum_Yazmaci_tx_full      ), // indicates that fifo is full
   .UART_Durum_Yazmaci_tx_empty        (UART_Durum_Yazmaci_tx_empty     ), // indicates that fifo is empty
   .uart_tx_o                          (o_Tx_Serial                       ),  // serial data out
   .UART_veri_gonderildi                (UART_veri_gonderildi)
   );
    
endmodule



