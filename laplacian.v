`timescale 1ns / 1ps


module laplacian ( 
    input       clk_i,rst_i,
    input       en_i,
    input [7:0] data_i_0 , 
    input [7:0] data_i_1 ,
    input [7:0] data_i_2 ,
    input [7:0] data_i_3 ,
    input [7:0] data_i_4 ,
    input [7:0] data_i_5 ,
    input [7:0] data_i_6 ,
    input [7:0] data_i_7 ,
    input [7:0] data_i_8 ,
    output[8:0] data_o 
     );
    
    reg signed [17:0] mult_data [0:8]; 
    reg signed [17:0] mult_data_reg [0:8]; 
    reg signed [17:0] sum_data = 0 ;  
    reg signed [17:0] sum_data2 = 0 ;
    reg signed [8:0]  data_i_reg [0:8];
    reg signed [8:0] kernel_gaussian [0:8];
    //reg signed [8:0] deger [0:8];
    integer sayac = 0;
    reg [4:0] durum = 0 ;
    integer i = 0 ; 
    integer g_sayac = 0;

    initial
    begin
       kernel_gaussian[0] = 9'b111111111 ;
       kernel_gaussian[1] = 9'b111111111 ; 
       kernel_gaussian[2] = 9'b111111111 ;
       kernel_gaussian[3] = 9'b111111111 ;
       kernel_gaussian[4] = 9'b000001000 ;
       kernel_gaussian[5] = 9'b111111111 ;
       kernel_gaussian[6] = 9'b111111111 ; 
       kernel_gaussian[7] = 9'b111111111 ;
       kernel_gaussian[8] = 9'b111111111 ;
    end

    always @ (posedge clk_i) begin  
        if(rst_i) begin 
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
                    mult_data[i] <= kernel_gaussian[i] * data_i_reg[i];
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
                    mult_data_reg [i] = mult_data [i];
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
                     sum_data <= sum_data+ mult_data_reg[i];
                     sayac = sayac+1;
                     i = i + 1;
                     durum=3;
                  end
                else begin
                   durum=4;
                end
               end
               
               4:begin
                    sum_data2 <=sum_data2 + sum_data;
                    durum=5;
               end
               5:begin //e�er 0dan k���kse 0 a ei�tle 255den b�y�kse 255e e�itle
                    if(sum_data2<0)begin
                        sum_data2 =0;
                    end
                    if(sum_data2>255) begin
                        sum_data2 =255;
                    end
                    else begin
                        sum_data2 =sum_data2;
                    end
                    durum=6;
               end
               6:begin
                    i=0;
                    sayac=0;
                    sum_data2=0;
                    sum_data=0;
                    mult_data [0]=0;
                    mult_data [1]=0;
                    mult_data [2]=0;
                    mult_data [3]=0;
                    mult_data [4]=0;
                    mult_data [5]=0;
                    mult_data [6]=0;
                    mult_data [7]=0;
                    mult_data [8]=0; 
                    mult_data_reg[0]=0;
                    mult_data_reg[1]=0;
                    mult_data_reg[2]=0;
                    mult_data_reg[3]=0;
                    mult_data_reg[4]=0;
                    mult_data_reg[5]=0;
                    mult_data_reg[6]=0;
                    mult_data_reg[7]=0;
                    mult_data_reg[8]=0;
                    data_i_reg[0]=0;
                    data_i_reg[1]=0;
                    data_i_reg[2]=0;
                    data_i_reg[3]=0;
                    data_i_reg[4]=0;
                    data_i_reg[5]=0;
                    data_i_reg[6]=0;
                    data_i_reg[7]=0;
                    data_i_reg[8]=0;
                    g_sayac=0;
                    durum=0;
               end
            endcase
           end
        end
     end
            assign data_o = sum_data2;
endmodule
