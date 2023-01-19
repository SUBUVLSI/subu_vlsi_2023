`timescale 1ns / 1ps

// 32 bit cikisi var suan, 8 bite donusturulebilir
module fp_int_donusum(clk_i,rst_i,g1_i,c_o,en_i);
    input clk_i,rst_i,en_i;
    input  [31:0] g1_i;
    output signed [31:0] c_o;
    reg [31:0] s1;
    reg [22:0] s2;
    reg [23:0] s3;
    reg [31:0] s4;
    reg [31:0] s5cikis;
    reg [7:0] E1;
    reg [7:0] E2;
    reg [3:0] durum=4'b0000;
    integer x=0,k1,bias=32'b00000000010000000000000001111111;
    // x=> say�c�
    assign c_o = s5cikis;
    always@(posedge(clk_i))begin
    
        if(rst_i)begin
            s1=8'h00000000;
            durum=3'b00;
            
            k1=0;
            E1=0;
            E2=0;
        end else begin
            if(en_i == 1)begin
                x = x +1; // durum 5te sifirla
                case(durum)
                0:begin
                    if(x<=3) begin
                        s1=g1_i;
                    end else begin
                        durum=1;
                    end
                end
                1:begin
                    s2=s1[22:0];
                    s3={1'b1,s2};
                    durum=2;
                end
               
                2: begin
                    E1=s1[30:23];
                    E2=E1-bias;
                    durum=3;
                end 
               
                3: begin
                    k1=23-E2;
                    s4=s3>>k1;
                    durum=4;
                end
               
                4: begin
                    s5cikis=s4;
                    durum = 5;
                end
                5: begin
                    durum = 0;
                    s1=0;
                    s2=0;
                    s3=0;
                    s4=0; 
                    E1=0;       
                    E2=0;  
                    x = 0;
                end
                endcase
            end else begin
                durum = 0;
                s1=0;
                s2=0;
                s3=0;
                s4=0;
                E1=0;       
                E2=0;  
                x = 0;
            end
        end   
    end    
           
endmodule
