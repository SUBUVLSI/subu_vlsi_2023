`timescale 100ns / 1ps

module histogram_esitleme(
        input clk

    );
    
    
    integer i = 0, sayac = 0, k = 0, m=0, x=1;
    reg [15:0] durum = 16'b0000000000000000;

    reg [19:0] histogram_out [0:255];
    reg [7:0] a;
    reg bitti = 0;

    parameter max_row = 76800;
    reg [7:0] mem [0:max_row-1];
    
    reg [19:0] c;
    reg [19:0] cdf [0:255];
    reg [19:0] cdf_min;
    reg son=0;
    reg signed [19:0] eq_hist [0:255];
    reg signed [19:0] sub [0:255] ;
    reg [19:0] sub_row;
    reg signed [19:0] div [0:255];
    integer y=0, z=0, t=0;


    
    initial begin
        $readmemb("C:\\Users\\aysim\\Desktop\\resim_pikselleri_binary.txt",mem);  
    end

    always @(posedge clk) begin
        sayac = sayac + 1;
        case(durum)
            0:begin
                if(i < 256) begin
                    histogram_out[i] <= 0;
                    i <= i + 1;
                end else begin
                    i <= 0;
                    durum = 1; 
                end
            end
            
            1:begin
                if(i < max_row) begin
                    a <= mem[i];
                    durum = 2;
                end else begin
                    durum = 3;
                end    
            end
            
            2:begin
                    histogram_out[a] <= histogram_out[a] + 1;
                    i <= i + 1;
                    durum = 1;
            end
            
            3:begin
                    bitti = 1;
                    durum=4;
            end
       
            4:begin
                if(k<256) begin
                   cdf[k] <= 0;
                   k <= k+1;
                end else begin
                  k<=1;
                  durum=5;
                end
            end
            5:begin
                cdf[0] <= histogram_out[0];
                durum = 6;
            
            end
            6:begin
                if(k<256)begin
                
                    if((histogram_out[k] != 0) && (x<256) )begin
                        c <= histogram_out[k];
                        
                        durum=7;
                    end else begin
                        k <= k+1;
                        durum=6;
                    end
                end else begin
                    durum=8;
                end
            
            end

             7:begin
              
                   cdf[x] <= cdf[x-1] + c;
                   k <= k+1;
                   x <= x+1;
                  durum = 6;
                end
             
             
             8:begin
                
                if(m<256) begin
                     if(cdf[m] != 0) begin
                          cdf_min <= cdf[m];
                          k <= 0;
                          durum = 9;
                     end else begin
                        m <= m+1;
                        durum=8;
                     end
                end
                
             end
 
             9:begin
                if(k<256) begin
                    sub[k] <= cdf[k] - cdf_min;
                    k <= k+1;
                end else begin
                    k<=0;
                    durum=10;
                end
             
             end
             10:begin
                if(k<256) begin
                    sub[k] <= sub[k] * 255;
                    k <= k+1;
                end else begin
                    k<=0;
                    durum=11;
                end
             end
             11:begin
                    sub_row <= max_row - cdf_min;
                    durum=12;
                
             end
             12:begin
                if (k<256) begin
                    div[k] <= sub[k] / sub_row;
                    k <= k+1;
                end else begin
                    k<=0;
                    durum=13;
                end        
             end
             13:begin
                if (k<256) begin
                     eq_hist[k] <= div[k];
                     k <= k+1;
                end else begin
                    durum=14;
                end
             end

             14:begin
                if(y<max_row) begin
                    if(z<256) begin
                        if(mem[y] == z) begin
                            mem[y-1] <= eq_hist[t];
                            t <= t+1;
                            y <= y+1;
                            z <= 0 ;
                         
                        end else begin
                            z <= z+1;
                        end
                    end else begin
                        z <=0;
                        y<=y+1;  
                    end
                end else begin
                
                    durum=15;
                
                end
             end
             15:begin
                son=1;
                
             end
          endcase
 
    end
    
    integer j,f;
    
     initial begin 
        #400000
        f=$fopen("C:\\Users\\aysim\\Desktop\\toplam.txt","w"); 
      end
        initial begin
              #406000
              for (j = 0; j<max_row; j=j+1) 
                  $fwrite(f,"%d\n",eq_hist[j]); 
              #406100
              $fclose(f);
        end

    
endmodule
    

