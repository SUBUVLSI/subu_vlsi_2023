`timescale 1ns / 1ps


module medyan(
    input clk,rst,
    input en_i,
    input [7:0]data_i0,
    input [7:0]data_i1,
    input [7:0]data_i2,
    input [7:0]data_i3,
    input [7:0]data_i4,
    input [7:0]data_i5,
    input [7:0]data_i6,
    input [7:0]data_i7,
    input [7:0]data_i8,
    output [7:0] data_o
    );
    
    reg [7:0] data_i_reg [0:8];
    reg [8:0] durum =0;
    integer sayac=0;
    integer g_sayac=0;
    
    always @(posedge clk) begin
        if(rst) begin
            sayac=0;
            g_sayac=0;
            durum=0;
        end else begin
            if(en_i==1) begin
                g_sayac=g_sayac+1;
                case(durum)
                    0:begin
                        if(sayac<3)begin
                            data_i_reg[0]=data_i0;
                            data_i_reg[1]=data_i1;
                            data_i_reg[2]=data_i2;
                            data_i_reg[3]=data_i3;
                            data_i_reg[4]=data_i4;
                            data_i_reg[5]=data_i5;
                            data_i_reg[6]=data_i6;
                            data_i_reg[7]=data_i7;
                            data_i_reg[8]=data_i8;
                            sayac=sayac+1;
                        end else begin
                            durum=1;
                            sayac=0;
                        end
                    end
                    1:begin
                        if(data_i_reg[0]>data_i_reg[1])begin
                            data_i_reg[0]<=data_i_reg[1];
                            data_i_reg[1]<=data_i_reg[0];
                            
                        end else begin
                            durum=2; 
                        end  
                    end
                    2:begin
                        if(data_i_reg[1]>data_i_reg[2])begin
                            data_i_reg[1]<=data_i_reg[2];
                            data_i_reg[2]<=data_i_reg[1];
                            durum=1;
                        end else begin
                            durum=3;   
                        end
                    end
                    3:begin
                        if(data_i_reg[2]>data_i_reg[3])begin
                            data_i_reg[2]<=data_i_reg[3];
                            data_i_reg[3]<=data_i_reg[2];
                            durum=2;
                        end else begin 
                            durum=4;
                        end
                    end
                    4:begin
                        if(data_i_reg[3]>data_i_reg[4])begin
                            data_i_reg[3]<=data_i_reg[4];
                            data_i_reg[4]<=data_i_reg[3];
                            durum=3;
                        end else begin
                            durum=5;
                        end
                    end
                    5:begin
                        if(data_i_reg[4]>data_i_reg[5])begin
                            data_i_reg[4]<=data_i_reg[5];
                            data_i_reg[5]<=data_i_reg[4];
                            durum=4;
                        end else begin
                            durum=6;
                        end
                    end
                    6:begin
                        if(data_i_reg[5]>data_i_reg[6])begin
                            data_i_reg[5]<=data_i_reg[6];
                            data_i_reg[6]<=data_i_reg[5];
                            durum=5;
                        end else begin
                            durum=7;
                        end
                    end
                    7:begin
                        if(data_i_reg[6]>data_i_reg[7])begin
                            data_i_reg[6]<=data_i_reg[7];
                            data_i_reg[7]<=data_i_reg[6];
                            durum=6;
                        
                        end else begin
                            durum=8;
                        end
                    end
                    8:begin
                        if(data_i_reg[7]>data_i_reg[8])begin
                            data_i_reg[7]<=data_i_reg[8];
                            data_i_reg[8]<=data_i_reg[7];
                            durum=7;
                        end else begin
                            durum=9;
                        end
                    end
                    9:begin
                        g_sayac=0;
                        data_i_reg[0]=0;
                        data_i_reg[1]=0;
                        data_i_reg[2]=0;
                        data_i_reg[3]=0;
                        data_i_reg[4]=0;
                        data_i_reg[5]=0;
                        data_i_reg[6]=0;
                        data_i_reg[7]=0;
                        data_i_reg[8]=0;
                        sayac=0;
                        
                    end
                endcase
            end else begin
                g_sayac=0;
                durum=0;
            end
        end
    end
    assign data_o=data_i_reg[4];
endmodule
