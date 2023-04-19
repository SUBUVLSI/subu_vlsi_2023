`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2023 12:28:06
// Design Name: 
// Module Name: uart_ram
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


module uart_ram
    (
        
      input wire             clk_i, 
      input wire             rstn_i,
      input              uart_rx_i,
      input wire             i_wenable,
      input wire                i_renable,
      output reg             led_rx,
      output reg             led_tx,
      output wire uart_tx_o
    );
    
    
//      wire             clk_i                           ; 
//      wire             rstn_i                          ; 
      reg             UART_Kontrol_Yazmaci_rx_Active  ; // rx active when UART_Kontrol_Yazmaci_rx = 1 else discard the incoming serial data
      reg             UART_Veri_Okuma_Yazmaci_enable  ; // read enable  ilgili adres master taraindan gelince enable 1 oluyor ve veri okunuyor
//      reg             uart_rx_i                       ; // serial data in
      reg   [15:0]    baud_div = 16'b0000001101100101; // clkfreq/baudrate as input
      wire             UART_Durum_Yazmaci_rx_full      ; // indicates that fifo is full   
      wire             UART_Durum_Yazmaci_rx_empty     ; // indicates that fifo is empty
      wire     [7:0]    UART_Veri_Okuma_Yazmaci_rdata   ; // is read when the related address is true
      wire              UART_Veri_Okundu                ; 
    
    reg en_ram;
    reg we_ram;
    reg [16:0] addr_ram;
    reg [7:0] data_i_ram;
    wire [7:0]  data_o_ram;
    
    reg [2:0] durum = 0;
    reg [20:0] indis = 0;
    reg [2:0] drm = 0;
    
    
   
   reg UART_Kontrol_Yazmaci_tx_Active  ; // tx active when UART_Kontrol_Yazmaci_tx = 1 else do not send data to outside world
   reg UART_Veri_Yazma_Yazmaci_enable  ;// clkfreq/baudrate as input
   reg [7:0] UART_Veri_Yazma_Yazmaci_wdata; // fifo icine yazilacak olan veriler. UART_Kontrol_Yazmaci_tx_Active avtif oldugunda fifo icinden disari gidecek olan veri ayni zamanda
   wire UART_Durum_Yazmaci_tx_full; // indicates that fifo is full
   wire UART_Durum_Yazmaci_tx_empty; // indicates that fifo is empty
//   wire uart_tx_o                          (uart_tx_o                       ) 
   wire UART_veri_gonderildi;
   
    always @(posedge clk_i, negedge rstn_i) begin
        
        if(!rstn_i) begin
        
            addr_ram                        <= 0;
            data_i_ram                      <= 0;
            en_ram                          <= 0;
            we_ram                          <= 0;
            UART_Veri_Okuma_Yazmaci_enable  <= 0;
            UART_Kontrol_Yazmaci_rx_Active  <= 0;
            led_rx                          <= 0;
            led_tx                          <= 0;
            UART_Kontrol_Yazmaci_tx_Active  <= 1'b0;
            UART_Veri_Yazma_Yazmaci_enable  <= 1'b0;
            durum                           <= 0;
            drm                             <= 0;
            indis                           <= 0;
            
        end else begin
            
            case(durum)
                    0:begin
                        en_ram = 1;
                        we_ram = 1;
                        addr_ram <= 0;
                        durum = 1;
                        UART_Kontrol_Yazmaci_rx_Active <= 1'b1;
                    end 
                    
                    1:begin
                        if(i_wenable) begin //switch
                           UART_Veri_Okuma_Yazmaci_enable <= 1'b1;
                           
                           if(UART_Veri_Okundu && !UART_Durum_Yazmaci_rx_full && UART_Durum_Yazmaci_rx_empty) begin
                               en_ram <= 1'b1;
                               we_ram <= 1'b1;
                               data_i_ram  <= UART_Veri_Okuma_Yazmaci_rdata;
                               addr_ram    <= indis;
                               indis        <= indis + 1;
                           end 
                           
                           if(indis == 10) begin ///mem_satir+1
                                led_rx      <= 1'b1;
                                UART_Kontrol_Yazmaci_rx_Active <= 1'b0;
                                UART_Veri_Okuma_Yazmaci_enable <= 1'b0;
                                led_tx      <= 1'b0;
                                addr_ram   <= 0;
                                en_ram     <= 1'b1;
                                we_ram     <= 1'b0;
                                indis       <= 0;
                                durum       <= 2;
                            end 
                        end
                    end
                    
                    
            2: 
                begin
                    led_rx      <= 1'b0;
                    led_tx      <= 1'b1;
                    if(i_renable) begin
                        we_ram  <= 1'b0;
                        en_ram  <= 1'b1;
                        addr_ram   <= 0;
                        durum               <= 3;
                        
                    end
                end
            
            3:
                begin
                                case (drm)
                                
                                0:  begin
                                        we_ram          <= 1'b0;
                                        en_ram          <= 1'b1;
                                        drm                 <= 4'b0011;
                                        
                                    end
                                    
                                1:  begin
                                        if(addr_ram < 8) begin 
                                            UART_Kontrol_Yazmaci_tx_Active <= 1'b1;
                                            UART_Veri_Yazma_Yazmaci_enable <= 1'b1;
                                            UART_Veri_Yazma_Yazmaci_wdata   <= data_o_ram;
                                            drm         <= 4'b0100;
                                        end else begin
                                            UART_Kontrol_Yazmaci_tx_Active <= 1'b0;
                                            UART_Veri_Yazma_Yazmaci_enable <= 1'b0;
                                            en_ram          <= 1'b0;
//                                            we_ram          <= 1'b0;
                                            addr_ram   <= 0;
                                            durum               <= 4;
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
                                            addr_ram   <= addr_ram + 1; 
                                            drm     <= 4'b0010;
                                       end 
                                    end
                              endcase
                              
                        end                    
                 4: begin
                 
                 end   
                endcase
           end
        end
        
    uart_rx_top uart_rx(
      .clk_i                            (clk_i),
      .rstn_i                           (rstn_i),
      .UART_Kontrol_Yazmaci_rx_Active   (UART_Kontrol_Yazmaci_rx_Active), // rx active when UART_Kontrol_Yazmaci_rx = 1 else discard the incoming serial data
      .UART_Veri_Okuma_Yazmaci_enable   (UART_Veri_Okuma_Yazmaci_enable), // read enable  ilgili adres master taraindan gelince enable 1 oluyor ve veri okunuyor
      .uart_rx_i                        (uart_rx_i),  // serial data in
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
   .uart_tx_o                          (uart_tx_o                       ),  // serial data out
   .UART_veri_gonderildi                (UART_veri_gonderildi)
   );
  
  ram#(.V(8),.S(76800),.A(17)) RAM_test(
        .clk_i(clk_i),
        .en_i(en_ram),
        .we_i(we_ram),
        .address_i(addr_ram),
        .data_i(data_i_ram),
        .data_o(data_o_ram)
    );
    
endmodule








