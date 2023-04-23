

`timescale 1ns / 1ps



module gorev6_top_fpga
    #(parameter max_row     = 76800,
                c_clkfreq   = 100_000_000,
                c_baudrate  = 115_200)
       (
        input   wire    clk_i,
        input   wire    rstn_i,
        input   wire    i_Rx_Serial,
        input   wire    i_wenable,
        input   wire    i_renable,
        input   wire    veri_1,
        output  wire    o_Tx_Serial,   
        output  reg     led_tx,
        output  reg     led_rx
        );
    
    //tx
    reg         i_Tx_start;
    reg [7:0]   i_Tx_Byte = 0;
    wire        o_Tx_Done;
    wire        o_Tx_Active;
    
    //rx
    wire        o_Rx_done;
    wire [7:0]  o_Rx_Byte; 
    
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
    
    integer ind = 0, indis = 0;
    wire veri_gonder, veri_al;
    reg en_gorev6;
    reg [7:0] veri_i_gorev6;
    wire [7:0] veri_o_gorev6;
    wire islem_bitti;
    wire [5:0] durum_oku;
    wire [16:0] indis_kontrol;
    
    //reg [7:0] cikti_mem [0:max_row-1];
    //reg [7:0] cikti [0:63];
    
    integer gec = 0;
    
    reg [20:0] cntr = 0;
    reg [3:0] drm = 4'b0000;
    reg [20:0] counter = 0;
    reg [9:0] state = 10'b00_0000_0000;
    
    /////uart_fifo/////////////////
    reg             UART_Kontrol_Yazmaci_rx_Active  ; // rx active when UART_Kontrol_Yazmaci_rx = 1 else discard the incoming serial data
    reg             UART_Veri_Okuma_Yazmaci_enable  ; // read enable  ilgili adres master taraindan gelince enable 1 oluyor ve veri okunuyor
//    reg             uart_rx_i                       ; // serial data in
    reg   [15:0]    baud_div = 16'b0000001101100101; // clkfreq/baudrate as input
    wire             UART_Durum_Yazmaci_rx_full      ; // indicates that fifo is full   
    wire             UART_Durum_Yazmaci_rx_empty     ; // indicates that fifo is empty
    wire     [7:0]    UART_Veri_Okuma_Yazmaci_rdata   ; // is read when the related address is true
    wire              UART_Veri_Okundu                ; 
    
    reg UART_Kontrol_Yazmaci_tx_Active  ; // tx active when UART_Kontrol_Yazmaci_tx = 1 else do not send data to outside world
    reg UART_Veri_Yazma_Yazmaci_enable  ;// clkfreq/baudrate as input
    reg [7:0] UART_Veri_Yazma_Yazmaci_wdata; // fifo icine yazilacak olan veriler. UART_Kontrol_Yazmaci_tx_Active avtif oldugunda fifo icinden disari gidecek olan veri ayni zamanda
    wire UART_Durum_Yazmaci_tx_full; // indicates that fifo is full
    wire UART_Durum_Yazmaci_tx_empty; // indicates that fifo is empty
//    wire uart_tx_o                          (uart_tx_o                       ) 
    wire UART_veri_gonderildi;
    
    localparam idle                 = 10'b00_0000_0000;
    localparam ram_write            = 10'b00_0000_0001;
    localparam ram_read             = 10'b00_0000_0010;
    localparam ram_transmit         = 10'b00_0000_0100;
    localparam altmodul_gonder_1    = 10'b00_0000_1000;
    localparam altmodul_gonder_2    = 10'b00_0001_1111;
    localparam altmodul_gonder_3    = 10'b00_0011_1111;
    localparam altmodul_al_1        = 10'b00_0010_0000;
    localparam altmodul_al_2        = 10'b00_0100_0000;
    localparam altmodul_al_3        = 10'b00_1000_0000;
    localparam altmodul_al_4        = 10'b00_1100_0000;
    localparam altmodul_al_5        = 10'b00_1010_0000;
    localparam altmodul_al_6        = 10'b00_1001_0000;
     
     
    always @(posedge (clk_i)) begin
        
        if(!rstn_i) begin
            
        end else begin
        
        
        case (state)

            idle:   begin
                        i_Tx_start  <= 0;
                        addr_ram1   <= 0;
                        indis       <= 0;
                        led_tx      <= 1'b0;
                        led_rx      <= 1'b0;
                        state       <= ram_write;
                        UART_Kontrol_Yazmaci_rx_Active <= 1'b1;
                end

            ram_write:  begin
                        
                        if(i_wenable) begin //switch
                           UART_Veri_Okuma_Yazmaci_enable <= 1'b1;
                           
                           if(UART_Veri_Okundu && !UART_Durum_Yazmaci_rx_full && UART_Durum_Yazmaci_rx_empty) begin
                               en_ram1 <= 1'b1;
                               we_ram1 <= 1'b1;
                               data_i_ram1  <= UART_Veri_Okuma_Yazmaci_rdata;
                               addr_ram1    <= indis;
                               indis        <= indis + 1;
                           end 
                           
                           if(indis == max_row) begin ///mem_satir+1
                                led_rx      <= 1'b1;
                                UART_Kontrol_Yazmaci_rx_Active <= 1'b0;
                                UART_Veri_Okuma_Yazmaci_enable <= 1'b0;
                                led_tx      <= 1'b0;
                                addr_ram1   <= 0;
                                en_ram1     <= 1'b1;
                                we_ram1     <= 1'b0;
                                indis       <= 0;
                                en_gorev6   <= 1'b1;
                                state       <= altmodul_gonder_1;
                            end 
                        end
                        
                end
            
            altmodul_gonder_1:begin
                // IFLERI AYIR
                if(veri_al == 1 && ind < max_row)begin
                    state <= altmodul_gonder_2; // 13;
                end else begin
                    ind <= 0;
                    en_ram2 = 1;
                    we_ram2 = 1;
                    addr_ram2 = 0;
                    state <= altmodul_al_1; // 14;
                end 
            end 
            
            altmodul_gonder_2:begin // 13
               if(gec <11)begin // 2
                   gec <= gec + 1;
                   veri_i_gorev6 <= data_o_ram1;
               end else begin
                   ind <= ind + 1;
                   gec <= 0;
                   state <= altmodul_gonder_3;
               end 
            end 
            
            altmodul_gonder_3:begin
                addr_ram1 <= ind;
                state <= altmodul_gonder_1;
            end
            /////////////////////////////////////////
            altmodul_al_1:begin // 14
                if(islem_bitti == 1 && veri_gonder == 1)begin
                    state <= altmodul_al_2; // 15
                end else begin
                     
                end 
            end
            
            altmodul_al_2:begin // 15
                if(indis < max_row)begin
                    state <= altmodul_al_3; // 16;
                end else begin
                    indis <= 0;
                    ind <= 0;
                    en_ram2 = 0;
                    we_ram2 = 0; // okuma
                    addr_ram2 = ind; 
                    
                    state <= ram_read;
                end
                
            end 
            altmodul_al_3:begin // 16
                if(indis < 1)begin
                    state <= altmodul_al_4; // 17; 
                end else begin
                    state <= altmodul_al_5; // 18;
                end
            end 
            
            altmodul_al_4:begin // 17
                if(gec < 8)begin  
                    gec <= gec + 1;
                    en_ram2 = 1;
                    we_ram2 = 1; // yazma
//                    cikti_mem[indis] <= veri_o_gorev6;
                    data_i_ram2 <= veri_o_gorev6;
                end else begin
                    gec <= 0;
                    indis <= indis + 1;
                    state <= altmodul_al_6; // 19;
                end
            end 
            
            altmodul_al_5:begin // 18
                if(gec < 2)begin  
                    gec <= gec + 1;
                    en_ram2 = 1;
                    we_ram2 = 1; // yazma
//                    cikti_mem[indis] <= veri_o_gorev6;
                    data_i_ram2 <= veri_o_gorev6;
                end else begin
                    gec <= 0;
                    indis <= indis + 1;
                    state <= altmodul_al_6; // 19;
                end
            end 
            
            altmodul_al_6:begin // 19
                addr_ram2 <= indis;
                state <= altmodul_al_2;
            end
            
            ram_read: 
                begin
                
                    led_rx      <= 1'b0;
                    led_tx      <= 1'b1;
                    if(i_renable) begin
                        we_ram2  <= 1'b0;
                        en_ram2  <= 1'b1;
                        addr_ram2   <= 0;
                        state       <= ram_transmit;
                        
                    end
                    
                end
            
            ram_transmit:
                begin
                        case (drm)
                                
                                0:  begin
                                        en_ram2 <= 1'b1;
                                        we_ram2 <= 1'b0;
                                        drm     <= 4'b0011;
                                        
                                    end
                                    
                                1:  begin
                                        if(indis <= max_row) begin 
                                            UART_Kontrol_Yazmaci_tx_Active <= 1'b1;
                                            UART_Veri_Yazma_Yazmaci_enable <= 1'b1;
                                            UART_Veri_Yazma_Yazmaci_wdata   <= data_o_ram2;
                                            drm         <= 4'b0100;
                                        end else begin
                                            UART_Kontrol_Yazmaci_tx_Active <= 1'b0;
                                            UART_Veri_Yazma_Yazmaci_enable <= 1'b0;
                                            en_ram2     <= 1'b0;
                                            we_ram2     <= 1'b0;
                                            addr_ram2   <= 0;
                                            state       <= idle;
                                            led_tx              <= 0;
                                        end
                                    end    
                                        
                                2:  begin
//                                       UART_Veri_Yazma_Yazmaci_enable <= 1'b0;
                                       indis                <= indis +1;  
                                       drm                 <= 4'b0001;    
                                    end  
                                    
                                3:  begin
//                                        UART_Veri_Yazma_Yazmaci_enable <= 1'b0;
                                        drm <= 4'b0001;
                                    end
                                    
                                4:  begin
                                        UART_Veri_Yazma_Yazmaci_enable <= 1'b0;
                                        if(UART_veri_gonderildi) begin
                                            UART_Kontrol_Yazmaci_tx_Active <= 1'b0;
                                            addr_ram2   <= addr_ram2 + 1;
                                            drm     <= 4'b0010;
                                       end 
                                    end
                              endcase
                              
                end
            default: state <= idle;
        endcase
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
    
    gorev6 GOREV6(
    .clk_i(clk_i),
    .rst_i(rstn_i),
    .en_i(en_gorev6),
    .veri_i(veri_i_gorev6),
    .veri_o(veri_o_gorev6),
    .veri_al_o(veri_al),   
    .veri_gonder_o(veri_gonder),
    .islem_bitti_o(islem_bitti)
    );
   
    
//     8 bitlik ram / 76800 satır
    ram#(.V(8),.S(76800),.A(17)) RAM2(
        .clk_i(clk_i),
        .en_i(en_ram2),
        .we_i(we_ram2),
        .address_i(addr_ram2),
        .data_i(data_i_ram2),
        .data_o(data_o_ram2)
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
