`timescale 1ns / 1ps


module sobel ( 
    input clk,rst,
    input en_i,
    input [7:0] data_i_0 , 
    input [7:0] data_i_1 ,
    input [7:0] data_i_2 ,
    input [7:0] data_i_3 ,
    input [7:0] data_i_4 ,
    input [7:0] data_i_5 ,
    input [7:0] data_i_6 ,
    input [7:0] data_i_7 ,
    input [7:0] data_i_8 ,
    output [8:0] data_o 
     );
    reg [7:0]  data_i_reg [0:8];
    reg signed [17:0] mult_data_x [0:8];
    reg signed [17:0] mult_data_x_reg [0:8]; 
    reg signed [17:0] sum_data_x = 0 ;  
    reg signed [17:0] sum_data_x_2 = 0 ;
    reg signed [17:0] mult_data_y [0:8];
    reg signed [17:0] mult_data_y_reg [0:8]; 
    reg signed [17:0] sum_data_y = 0 ;  
    reg signed [17:0] sum_data_y_2 = 0 ;
    reg signed [8:0] kernel_sobel_x [0:8];
    reg signed [8:0] kernel_sobel_y [0:8];
    reg signed [17:0] sonuc;
    reg signed [17:0] sonuc1;
    integer sayac = 0;
    reg [13:0] durum = 0 ;
    integer i = 0 ; 
    integer g_sayac=0;

    initial
    begin
       kernel_sobel_x[0] = 9'b111111111 ;
       kernel_sobel_x[1] = 9'b000000000 ; 
       kernel_sobel_x[2] = 9'b000000001 ;
       kernel_sobel_x[3] = 9'b111111110 ;
       kernel_sobel_x[4] = 9'b000000000 ;
       kernel_sobel_x[5] = 9'b000000010 ;
       kernel_sobel_x[6] = 9'b111111111 ; 
       kernel_sobel_x[7] = 9'b000000000 ;
       kernel_sobel_x[8] = 9'b000000001 ;
    end
   initial
   begin
       kernel_sobel_y[0] = 9'b111111111 ;
       kernel_sobel_y[1] = 9'b111111110 ; 
       kernel_sobel_y[2] = 9'b111111111 ;
       kernel_sobel_y[3] = 9'b000000000 ;
       kernel_sobel_y[4] = 9'b000000000 ;
       kernel_sobel_y[5] = 9'b000000000 ;
       kernel_sobel_y[6] = 9'b000000001 ; 
       kernel_sobel_y[7] = 9'b000000010 ;
       kernel_sobel_y[8] = 9'b000000001 ;
   end

    always @ (posedge clk) begin  
        if(rst) begin 
        sayac = 0;
        i = 0;
        
        end else begin
            if(en_i==1) begin
            g_sayac=g_sayac+1;
            case (durum)
                0:begin
                    if(sayac<3)begin
                        data_i_reg[0]=data_i_0;
                        data_i_reg[1]=data_i_1;
                        data_i_reg[2]=data_i_2;
                        data_i_reg[3]=data_i_3;
                        data_i_reg[4]=data_i_4;
                        data_i_reg[5]=data_i_5;
                        data_i_reg[6]=data_i_6;
                        data_i_reg[7]=data_i_7;
                        data_i_reg[8]=data_i_8;
                        sayac=sayac+1;
                          
                     end 
                     else begin
                        durum = 1;
                        sayac=0;
                     end                
                end
                1:begin
                    if(sayac<9)begin
                      mult_data_x[i] <= kernel_sobel_x[i] * data_i_reg[i];
                      sayac=sayac+1;
                      i=i+1;
                      durum=1;
                    end 
                    else begin
                       sayac=0;
                       i=0;
                       durum=2;
                    end
                end
                2:begin 
                    if(sayac<9)begin
                        mult_data_x_reg [i] = mult_data_x [i];
                        sayac = sayac+1 ;
                        i = i+1;
                        durum=2;
                    end
                    else begin
                        sayac = 0;
                        i=0;
                        durum=3;
                    end
                end
                3:begin
                    if(sayac<9)begin
                        sum_data_x <= sum_data_x + mult_data_x_reg[i];
                        sayac = sayac+1;
                        i = i + 1;
                        durum=3;
                    end else begin
                        durum=4;
                    end
                end
                
                4:begin
                    sum_data_x_2 <= sum_data_x_2 + sum_data_x;
                    durum=5;
                end
                5:begin //eğer 0dan küçükse 0 a eiştle 255den büyükse 255e eşitle
                    if(sum_data_x_2<0)begin
                        sum_data_x_2 =0;
                        i=0;
                        sayac=0;
                        durum=6;
                    end
                    if(sum_data_x_2>255) begin
                        sum_data_x_2 =255;
                        sayac=0;
                        i=0;
                        durum=6;
                    end
                    else begin
                        sum_data_x_2 =sum_data_x_2;
                        sayac=0;
                        i=0;
                        durum=6;
                    end
                end
                6:begin
                if(sayac<9)begin
                    mult_data_y[i] <= kernel_sobel_y[i] * data_i_reg[i];
                    sayac=sayac+1;
                    i=i+1;
                    durum=6;
                end 
                else begin
                    sayac=0;
                    i=0;
                    durum=7;
                    end
                end
                7:begin 
                    if(sayac<9)begin
                        mult_data_y_reg [i] = mult_data_y [i];
                        sayac = sayac+1 ;
                        i = i+1;
                        durum=7;
                    end
                    else begin
                        sayac = 0;
                        i=0;
                        durum=8;
                    end
                end
                8:begin
                    if(sayac<9)begin
                        sum_data_y <= sum_data_y + mult_data_y_reg[i];
                        sayac = sayac+1;
                        i = i + 1;
                        durum=8;
                    end
                    else begin
                        durum=9;
                    end
                end
                
                9:begin
                    sum_data_y_2 <= sum_data_y_2 + sum_data_y;
                    durum=10;
                end
                10:begin //eğer 0dan küçükse 0 a eiştle 255den büyükse 255e eşitle
                    if(sum_data_y_2<0)begin
                        sum_data_y_2 =0;
                    end
                    if(sum_data_y_2>255) begin
                        sum_data_y_2 =255;
                    end
                    else begin
                        sum_data_y_2 =sum_data_y_2;
                    end
                    durum=11;
                end
                11:begin
                    sonuc <= sum_data_y_2 | sum_data_x_2 ;
                    durum=12;
                end
                12:begin
                    sonuc1<=sonuc;
                    durum=13;
                end
                13:begin
                    if(sonuc1<0)begin
                        sonuc1=0;
                    end
                    if (sonuc1>255)begin
                        sonuc1=255;
                    end
                    else begin
                        sonuc1<=sonuc1;
                    end
                    durum=14;
                end
                14:begin
                    i=0;
                    sayac=0;
                    sum_data_x_2=0;
                    sum_data_x=0;
                    mult_data_x [0]=0;
                    mult_data_x [1]=0;
                    mult_data_x [2]=0;
                    mult_data_x [3]=0;
                    mult_data_x [4]=0;
                    mult_data_x [5]=0;
                    mult_data_x [6]=0;
                    mult_data_x [7]=0;
                    mult_data_x [8]=0; 
                    mult_data_x_reg[0]=0;
                    mult_data_x_reg[1]=0;
                    mult_data_x_reg[2]=0;
                    mult_data_x_reg[3]=0;
                    mult_data_x_reg[4]=0;
                    mult_data_x_reg[5]=0;
                    mult_data_x_reg[6]=0;
                    mult_data_x_reg[7]=0;
                    mult_data_x_reg[8]=0;
                    sum_data_y_2=0;
                    sum_data_y=0;
                    mult_data_y [0]=0;
                    mult_data_y [1]=0;
                    mult_data_y [2]=0;
                    mult_data_y [3]=0;
                    mult_data_y [4]=0;
                    mult_data_y [5]=0;
                    mult_data_y [6]=0;
                    mult_data_y [7]=0;
                    mult_data_y [8]=0; 
                    mult_data_y_reg[0]=0;
                    mult_data_y_reg[1]=0;
                    mult_data_y_reg[2]=0;
                    mult_data_y_reg[3]=0;
                    mult_data_y_reg[4]=0;
                    mult_data_y_reg[5]=0;
                    mult_data_y_reg[6]=0;
                    mult_data_y_reg[7]=0;
                    mult_data_y_reg[8]=0;
                    data_i_reg[0]=0;
                    data_i_reg[1]=0;
                    data_i_reg[2]=0;
                    data_i_reg[3]=0;
                    data_i_reg[4]=0;
                    data_i_reg[5]=0;
                    data_i_reg[6]=0;
                    data_i_reg[7]=0;
                    data_i_reg[8]=0;
                    sonuc=0;
                    sonuc1=0;
                    g_sayac=0;
                    durum=0;
                end
            endcase
        end else begin
            g_sayac=0;
            durum=0;
        end
     end
    end
    assign data_o = sonuc1 ;
endmodule