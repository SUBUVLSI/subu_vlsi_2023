`timescale 100ns / 1ps
module histogram_table(
    input clk_i, rst_i, en_i
    );

integer i=0, sayac=0;
reg [6:0] durum = 6'b000000;
reg [23:0] histogram_out [0:255] ;
reg [31:0] data_out [0:255] ;
reg [7:0] data_indeks [0:255] ;
reg [7:0] a;
reg bitti=0;
parameter max_row = 76800;
reg [7:0] mem [0:max_row-1];

reg [8:0] k = 0, m = 0;

    initial begin
        $readmemb("D:\\vivado\\asil_resim.txt",mem);  // txtden çekilen resim piksel değerleri
    end 

    always @(posedge clk_i) begin
        if(rst_i)begin
        end else begin
            if(en_i == 1)begin
                sayac=sayac+1;
                case(durum)
                    0:begin                  
                        if(i<256) begin
                           histogram_out[i] <= 0;
                           i<=i+1;
                        end else begin
                          i<=0;
                          durum<=1; end
                    end
                    
                    1:begin                     
                       if(i<max_row) begin
                          a<=mem[i];
                          durum<=2;
                       end else begin
                          durum<=3;                         
                       end      
                    end
                    
                    2:begin
                          histogram_out[a] <= histogram_out[a] + 1;
                          i<=i+1;
                          durum<=1;
                     end
                     3:begin
                        if(k < 256) begin
                            data_indeks[k] <= k;
                            k <= k+1;
                        end else begin
                            durum<=4;
                        end
                     end
                     4:begin
                          if(m<256) begin
                            data_out[m] = {data_indeks[m], histogram_out[m]};
                            m <= m+1;
                          end else begin
                            durum<=5;
                          end
                     end

                     
                    5:begin
                            bitti=1;
                     end
                endcase
            end
        end
    end
    
    
    integer j,f;
    
     initial begin 
        #150000
         f=$fopen("D:\\vivado\\histogram_table.txt","w");  // txt ye yazılan histogram tablosu değerleri
      end
        initial begin
              #200000
              for (j = 0; j<256; j=j+1) 
                  $fwrite(f,"%b\n",data_out[j]); 
              #200100
              $fclose(f);
        end
        


endmodule
