`timescale 100ns / 1ps



module gorev1_top
    #(
//        parameter c_clkfreq = 100000000,
//        parameter c_baudrate = 115200,
        parameter deger = 76800
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
    output reg      son_o
    );  
    reg [4:0] durum =0;
    reg [17:0] sayac = 0, gec = 0,ind = 0 , indis=0, i=0;  
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
    
    
    reg [17:0] ic_sayac=0;
    

    wire veri_gonder, veri_al;
    reg en_gorev1; 
    reg [7:0] veri_i_gorev1;
    wire [7:0] veri_o_gorev1;
    wire islem_bitti;
    wire bitti_g;
    wire [5:0] durum_oku;
    wire [16:0] indis_kontrol;
    
//    reg [7:0] cikti_mem [0:deger-1];
    
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
    reg [20:0] cntr = 0;
    
    ////////////////uart///////////////////////
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
//   wire uart_tx_o                          (uart_tx_o                       ) 
   wire UART_veri_gonderildi;
    
    
    always@(posedge clk_i)begin
        if(!rstn_i)begin
        end else begin
            if(en_i)begin
                sayac <= sayac + 1;
                case(durum)

                    
                     0:   begin
                              UART_Kontrol_Yazmaci_tx_Active  <= 1'b0;
                              UART_Veri_Yazma_Yazmaci_enable  <= 1'b0;
                              UART_Veri_Okuma_Yazmaci_enable  <= 1'b0;
                              UART_Kontrol_Yazmaci_rx_Active  <= 1'b0;
                              addr_ram1   <= 0;
                              indis       <= 0;
                              led_tx      <= 1'b0;
                              led_rx      <= 1'b0;
                              durum       <= 1;
                      end

                    1:  begin
                                
                                if(i_wenable) begin //switch
                                    UART_Kontrol_Yazmaci_rx_Active <= 1'b1; 
                                    UART_Veri_Okuma_Yazmaci_enable <= 1'b1;
                           
                                    if(UART_Veri_Okundu) begin
                                        en_ram1 <= 1'b1;
                                        we_ram1 <= 1'b1;
                                        UART_Veri_Okuma_Yazmaci_enable <= 1'b0;
                                        data_i_ram1  <= UART_Veri_Okuma_Yazmaci_rdata;
                                        addr_ram1    <= indis;
                                        indis        <= indis + 1;
                                    end 
                                    
                                    if(indis == deger) begin ///mem_satir+1 !UART_Durum_Yazmaci_rx_full && !UART_Durum_Yazmaci_rx_empty
                                         led_rx      <= 1'b1;
                                         UART_Kontrol_Yazmaci_rx_Active <= 1'b0;
                                         UART_Veri_Okuma_Yazmaci_enable <= 1'b0;
                                         led_tx      <= 1'b0;
                                         addr_ram1   <= ind;
                                         en_ram1     <= 1'b1;
                                         we_ram1     <= 1'b0;
                                         
                                         indis       <= 0;
                                         durum       <= 3;
                                         en_gorev1 <= 1;
                                     end 
                                end 
                        end
                    
                    // ALT MODULE GONDER
                    3:begin
                        // IFLERI AYIR
                        if(veri_al == 1 && ind < deger)begin
                            durum <= 4;
                        end else begin
                            ind <= 0;
                            en_ram2 = 1;
                            we_ram2 = 1;
                            addr_ram2 = 0;
                            durum <= 6;
                        end 
                    end 
                    
                    4:begin
                       if(gec <3)begin // 2
                           gec <= gec + 1;
                           veri_i_gorev1 <= data_o_ram1;
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
                             
                        end 
                    end
                    
                    7:begin
                        if(indis < deger)begin
                            durum <= 8;
                        end else begin
                            indis <= 0;
                            ind <= 0;
                            en_ram2 = 0;
                            we_ram2 = 0; // okuma
                            addr_ram2 = ind; 
                            
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
                        if(gec <6)begin  
                            gec <= gec + 1;
                            en_ram2 = 1;
                            we_ram2 = 1; // yazma
//                            cikti_mem[indis] <= veri_o_gorev3;
                            data_i_ram2 <= veri_o_gorev1;
                        end else begin
                            gec <= 0;
                            indis <= indis + 1;
                            durum <= 11;
                        end
                    end 
                    
                    10:begin
                        if(gec <3)begin  
                            gec <= gec + 1;
                            en_ram2 = 1;
                            we_ram2 = 1; // yazma
//                            cikti_mem[indis] <= veri_o_gorev3;
                            data_i_ram2 <= veri_o_gorev1;
                        end else begin
                            gec <= 0;
                            indis <= indis + 1;
                            durum <= 11;
                        end
                    end 
                    
                    11:begin
                        addr_ram2 <= indis;
                        durum <= 7;
                    end 
                    
                     
                    
                    
                    12: 
                    begin
                        led_rx      <= 1'b0;
                        led_tx      <= 1'b1;
                        if(i_renable) begin
                            en_ram2  <= 1'b1;
                            we_ram2  <= 1'b0;
                            addr_ram2   <= 0;
                            durum       <= 13;
                        end
                    end
            
                    13:
                    begin
                            
                            case (drm)
                            
                            0:  begin
                                    en_ram2 <= 1'b1;
                                    we_ram2 <= 1'b0;
                                    drm     <= 4'b0011;
                                end
                                
                            1:  begin
                                    if(cntr < deger+1) begin 
                                        UART_Kontrol_Yazmaci_tx_Active <= 1'b1;
                                        UART_Veri_Yazma_Yazmaci_enable <= 1'b1;
                                        UART_Veri_Yazma_Yazmaci_wdata   <= data_o_ram2;
                                        drm         <= 4'b0100;
                                        
                                    end else begin
                                        UART_Kontrol_Yazmaci_tx_Active <= 1'b0;
                                        UART_Veri_Yazma_Yazmaci_enable <= 1'b0;
//                                        i_Tx_start  <= 0;
                                        en_ram2     <= 1'b0;
                                        we_ram2     <= 1'b0;
                                        addr_ram2   <= 0;
                                        durum       <= 14;
                                        led_tx      <= 0;
                                    end
                                end    
                                    
                            2:  begin
//                                        i_Tx_start  <= 1'b0;
                                        cntr        <= cntr +1;  
                                        drm         <= 4'b0001;    
                                end  
                                
                            3:  begin
                                    
                                    drm <= 4'b0001;
                                    
                                end
                                
                            4:  begin
                                    UART_Veri_Yazma_Yazmaci_enable <= 1'b0;
                                    if(UART_veri_gonderildi) begin
                                        UART_Kontrol_Yazmaci_tx_Active <= 1'b0;
                                        addr_ram2   <= addr_ram2 + 1; 
                                        drm         <= 4'b0010;
                                   end 
                                end
                          endcase
                          
                    end
                    
                    14:begin
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
    
    
    gorev1 GOREV1(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_gorev1),
    .veri_i(veri_i_gorev1),
    .veri_o(veri_o_gorev1),
    .veri_al_o(veri_al),   
    .veri_gonder_o(veri_gonder),
    .islem_bitti_o(islem_bitti),
    .durum_oku_o(durum_oku),
    .bitti(bitti_g),
    .indis_kontrol(indis_kontrol));
    


    // 8 bitlik ram / 76800 satır
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
