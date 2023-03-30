`timescale 100ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.03.2023 12:15:40
// Design Name: 
// Module Name: histogram_esitleme
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


module histogram_esitleme(
        input clk_i, rest_i,en_i
    );
    
    parameter max_row = 76800;
    reg [4:0] durum = 5'b00000;
    
    integer i = 0, sayac = 0, k = 0, m = 0, p_ind = 0;
    reg son=0;
    
    reg [23:0] histogram [0:255];
    reg [23:0] histogram_out [0:255]; 
    reg [7:0] mem [0:max_row-1];
    reg [7:0] yeni_mem [0:max_row-1];
    reg [23:0] cdf_reg;
    reg [23:0] cdf [0:255];
    reg [23:0] cdf_min; 
    reg signed [7:0] eq_hist [0:255];
    reg signed [28:0] sub [0:255] ;
    reg [23:0] sub_row;
    reg [15:0] h_sub_row;
    reg signed [7:0] div [0:255];
    reg signed [28:0] round [0:255];
    reg signed [28:0] fark [0:255];
  
    initial begin
        $readmemb("D:\\vivado\\histogram_table.txt",histogram);  
    end
    initial begin
        $readmemb("D:\\vivado\\asil_resim.txt",mem);  
    end

    always @(posedge clk_i) begin
        if(en_i == 1)begin
            sayac <= sayac + 1;
            case(durum)
                0:begin
                    if( i < 256) begin
                        histogram_out[i] <= histogram[i][23:0];
                        i <= i+1;
                    end else begin
                        durum <= 1;
                    end
                end
                1:begin
                    if(k < 256) begin
                       cdf[k] <= 0;
                       k <= k+1;
                    end else begin
                      k <= 1;
                      durum <= 2;
                    end
                end
                2:begin
                   cdf[0] <= histogram_out[0];
                    durum <= 3;
                
                end
               3:begin
                    if(k < 256) begin
                        cdf_reg <= histogram_out[k];
                        durum <= 4;
                    end else begin
                     
                        durum <= 5;
                    end
                
                end

                 4:begin
                       cdf[k] <= cdf[k-1] + cdf_reg;
                       k <= k+1;
                       durum <= 3;
                    end
                 
                 5:begin
                    
                    if(m < 256) begin
                         if(cdf[m] != 0) begin
                              cdf_min <= cdf[m];
                              k <= 0;
                              durum <= 6;
                         end else begin
                            m <= m+1;
                            durum <= 5;
                         end
                    end
                    
                 end

                 6:begin
                    if(k < 256) begin
                        sub[k] <= cdf[k] - cdf_min;                    
                        durum <= 7;
                    end else begin
                        k <= 0;
                        durum <= 8;
                    end
                 
                 end
                 
                 7:begin
                    if(sub[k] < 0) begin
                        sub[k] <= 0;
                        k <= k+1;
                        durum <= 6;
                    end else begin
                        k <= k+1;
                        durum <= 6;
                    end
                 end
                 
                 8:begin
                    if(k < 256) begin
                        sub[k] <= sub[k] * 255;
                        k <= k+1;
                    end else begin
                        k <= 0;
                        durum <= 9;
                    end
                 end
                 
                 9:begin
                        sub_row <= max_row - cdf_min;
                        durum <= 10;
                 end
                 
                 10:begin
                    if (k < 256) begin
                        div[k] <= sub[k] / sub_row;                 
                        durum <= 11;
                    end else begin
                        k <= 0;
                        durum <= 15;
                    end        
                 end
                 
                 11:begin
                        round[k] <= div[k] * sub_row;                    
                        durum <= 12;
                 end
                 
                 12:begin
                        h_sub_row <= sub_row / 2;
                        durum <= 13;
                 end
                 
                 13:begin
                        fark[k] <= sub[k] - round[k];
                        durum <= 14;                
                 end
                 
                 14:begin
                    if(fark[k] >= h_sub_row) begin
                        div[k] <= div[k] +1;
                        k <= k+1;
                        durum <= 10;
                    end else begin
                        k <= k+1;
                        durum <= 10;
                    end
                 end
                 
                 15:begin
                    if (k < 256) begin
                         eq_hist[k] <= div[k];
                         k <= k+1;
                    end else begin
                        durum <= 16;
                    end
                 end

               16:begin
                    if(p_ind < max_row) begin       
                         yeni_mem[p_ind] <= eq_hist[mem[p_ind]];
                         p_ind <= p_ind+1;
                    end else begin
                        durum <= 17;
                    end
               end
  
               17:begin
                    son <= 1;            
               end
            endcase
        end else begin
        end
    end
    
    integer j,f;
    
     initial begin 
        #150000
        f=$fopen("D:\\vivado\\gorev5_cikti.txt","w"); 
      end
        initial begin
              #400000
              for (j = 0; j<max_row; j=j+1) 
                  $fwrite(f,"%d\n",yeni_mem[j]); 
              #490000
              $fclose(f);
        end
  
endmodule
