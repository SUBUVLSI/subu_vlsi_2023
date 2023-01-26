`timescale 1ns / 1ps

//16-bitte b=16,32-bitte b=32,64-bitte b=64 
 //16-bitte e=5,32-bitte e=8,64-bitte e=11  
//16-bitte m=10,32-bitte m=23,64-bitte m=52 
module fp_toplama#(parameter b=32, e=8, m=23)(
    
    input clk_i,rst_i,en_i,
    input [b-1:0] g1_i,g2_i,
    output [b-1:0] toplam_o);
    
    integer gec = 0;
    reg [m+1:0] B; 
    reg [m:0] C;               
    reg t_sign;                      
    reg [m:0] Nxm;
    reg [m:0] Nym;
    reg [b-1:0] x,y;
    integer ex_x,ex_y;
    reg [b-2:m] sonus;
    reg[m-1:0] sonmantis;
    reg [b-1:0] Ntoplam;
    integer Nus;
    integer tpsus;
    reg [3:0] durum = 3'b000;
    integer uscikarmax=0;
    integer uscikarmay=0;
    wire [m:0] x_mantissa = {1'b1,g1_i[m-1:0]};
    wire [m:0] y_mantissa = {1'b1,g2_i[m-1:0]};
    integer sayac= 0;
    reg [b-1:0]sonuc;
    
    assign toplam_o = sonuc;
    
    
    // BIR SAYI NEGAATIFSE
    reg s_A, s_B, sign;
    reg [b-2:m] e_A, e_B, exp_fark, exp;
    reg [m:0] m_A, m_B; // 24 bit 1 bit ile birleştirildiğinde 
    reg [m:0] man;
    reg [b-1:0] fark_o;
    reg [m+1:0] man_s; // 25 bit 
    reg elde;
    
    always @(posedge(clk_i))begin
        if(rst_i)begin
            durum = 2'b00;
            x=32'd0;
            y=32'd0;
        end
        else begin
            if(en_i == 1) begin
                sayac = sayac + 1;
                case(durum)
                    0:begin //sayılar karşılaştırılarak sign bitine karar verilir
                       if(sayac<=3)begin    
                           if(gec < 2)begin
                                gec = gec + 1;
                           end else begin
                               gec = 0;
                               if(g1_i == 0 || g2_i == 0)begin
                                    durum = 12;
                               end else begin 
                                    x=g1_i;
                                    y=g2_i;
                                    ex_x=x[b-2:m];
                                    ex_y=y[b-2:m];
                                    
                                     if(x[b-1]== y[b-1])begin
                                         t_sign = x[b-1];
                                     end
                                     else if(g1_i[b-1] != g2_i[b-1]) begin
                                            if(g1_i[b-2:m] > g2_i[b-2:m])begin
                                                sign = g1_i[b-1];
                                                durum = 3;
                                            end 
                                            else if(g2_i[b-2:m] > g1_i[b-2:m])begin
                                                sign = g2_i[b-1];
                                                durum = 3;
                                            end else begin
                                                if(g1_i[m-1:0] > g2_i[m-1:0])begin
                                                    sign = g1_i[b-1];
                                                    durum = 3;
                                                end 
                                                if(g2_i[m-1:0] > g1_i[m-1:0])begin
                                                    sign = g2_i[b-1];
                                                    durum = 3;
                                                 end
                                           end
                                     end
                               end
                            end   
                       end else begin
                            durum=1;
                       end
                    end
                    1:begin  //üsler karşılaştırılarak mantissalar ayarlanır
                       x=g1_i;
                       y=g2_i;
                        if(ex_x==ex_y)begin
                            Nus=ex_x; 
                            Nym[m:0] = y_mantissa;
                            Nxm[m:0] = x_mantissa;    
                        end
                        else if(ex_x>ex_y)begin
                                uscikarmax=ex_x-ex_y;
                                Nus = ex_y+ uscikarmax;
                                Nym[m:0] = y_mantissa >> uscikarmax; 
                                Nxm[m:0] = x_mantissa;
                                
                        end
                        else begin
                                uscikarmay=ex_y-ex_x;
                                Nus = ex_x+ uscikarmay;
                                Nxm[m:0] = x_mantissa >> uscikarmay;
                                Nym[m:0] = y_mantissa;
                              
                                
                        end
                        durum = 2;
                        
                    end 
                    2:begin // mantissalar toplanıp toplam mantis bulunur ve üs kaydırılır
                       x=g1_i;
                       y=g2_i;       
                        if(x[b-1]==y[b-1])begin
                            B=Nxm[m:0]+Nym[m:0];
                            if(B==B[m+1:0])begin
                                sonmantis = B[m:1];
                                tpsus = Nus + 1;  
                            end
                            if(B==B[m:0])begin
                                sonmantis = B[m:0];
                                tpsus =Nus; 
                            end
                            durum=12;
                        end else begin
                        end          
                    end
                    
                    3:begin
                        if(g1_i[31] == 1)begin
                            x = {1'b0,g1_i[30:0]};
                        end 
                        else if(g2_i[31] == 1)begin
                            y = {1'b0,g2_i[30:0]};
                        end 
                        durum = 4;
                    end
                    
                    4:begin
                        s_A = x [b-1];
                        s_B = y [b-1];
                        e_A = x [b-2:m];
                        e_B = y [b-2:m];
                        m_A = {1'b1, x[m-1:0]};
                        m_B = {1'b1, y[m-1:0]};
                        durum = 5;
                    end
                    
                    5:begin
                        if (e_A > e_B) begin
                            exp_fark = e_A - e_B; 
                            e_B = e_B + exp_fark;
                            m_B = m_B >> exp_fark;
                            exp = e_A+1;
                            durum = 8;
                       end else begin
                            durum = 6;
                       end
                    end
                    
                    6:begin
                        if(e_A < e_B) begin
                           exp_fark = e_B - e_A;
                           e_A = e_A + exp_fark;
                           m_A = m_A >> exp_fark;
                           exp = e_B+1; 
                           durum = 9;
                          end 
                        else begin
                            durum = 7;
                        end 
                    end
                    
                    7:begin
                        if(m_A >= m_B) begin // büyük eşit olması gerekli
                              exp = e_A+1;
                              durum = 8;
                        end
                        else begin
                           exp = e_B+1;
                           durum = 9;
                        end        
                    end
                    
                    8:begin
                        {elde,man} = m_A - m_B;
                        man_s = {elde,man};
                        durum = 10;
                    end
                    
                    9:begin
                        {elde,man} = m_B - m_A;
                        man_s = {elde,man};
                        durum = 10;
                    end
                    
                    10:begin
                        if (man_s[m+1] == 0) begin
                              man_s = man_s << 1;
                              exp = exp - 1'b1;
                              durum = 10;
                              end      
                              else 
                                            
                        durum = 11;
                    end 
                    
                    11:begin
                        sonuc = {sign, exp, man_s[m:1]};
                        durum = 13;
                    end
                    
                    // normal sayı
                    12:begin  //sonuc aktarılır.
                       if(g1_i== 0 || g2_i == 0)begin
                            if(g1_i == 0 && g2_i !== 0)begin
                                sonuc = g2_i;
                                durum = 13;
                            end 
                            else if(g1_i !== 0 && g2_i == 0)begin
                                sonuc = g1_i;
                                durum = 13;
                            end else begin
                                sonuc = 0;
                                durum = 13;
                            end
                       end else begin 
                            x=g1_i;
                            y=g2_i;
                            sonuc = {t_sign,tpsus[e-1:0],sonmantis[m-1:0]};  
                            durum = 13;
                       end
                    end   
                    13:begin 
                        x = 0;
                        y = 0;
                        ex_x = 0;
                        ex_y = 0;
                        uscikarmax = 0;
                        uscikarmay = 0;
                        Nus = 0;
                        Ntoplam = 0;
                        sonmantis = 0;
                        B = 0;
                        C = 0;
                        Nxm = 0;
                        Nym = 0;
                        sonus = 0;
                        t_sign = 0;
                        tpsus = 0;
                        durum = 0;
                        sayac = 0;
                        
                        s_A = 0;
                        s_B = 0;
                        e_A = 0;
                        e_B = 0;
                        m_A = 0;
                        m_B = 0;
                    end
                   
                endcase
            end else begin
                x = 0;
                y = 0;
                ex_x = 0;
                ex_y = 0;
                uscikarmax = 0;
                uscikarmay = 0;
                Nus = 0;
                Ntoplam = 0;
                sonmantis = 0;
                B = 0;
                C = 0;
                Nxm = 0;
                Nym = 0;
                sonus = 0;
                t_sign = 0;
                tpsus = 0;
                durum = 0;
                sayac = 0;
            end
        end
    end
endmodule
