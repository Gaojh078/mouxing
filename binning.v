module binnig
(
input clk,rst,
input [11:0] binning_str_data,
input binning_valid,
output binning_ready
);
parameter n = 8;
reg [11:0] str_data_reg = 'd0;
wire prog_full_all;
reg prog_full_all_reg,prog_full_all_reg2;
wire [11:0] fifo_in[n-1:0];
wire [11:0] fifo_out[n-1:0];
reg  [n-1:0]fifo_wen;
reg  fifo_ren = 0;
reg [2:0]stream_count = 0;
reg [6:0]fifo_count[n-1:0];
reg pop_en[n-1:0];
wire rd_en;
wire [n-1:0]prog_full;
assign binning_ready = 1;
always@(posedge clk or negedge rst)
begin
    if(!rst)
        str_data_reg <= str_data_reg;
    else
    begin
        if(binning_valid && binning_ready)
        begin
             str_data_reg <= binning_str_data;
             stream_count <= stream_count + 1;
        end
        else
             str_data_reg <= str_data_reg;
    end
end

always@(posedge clk or negedge rst) begin
    if(!rst)
        fifo_wen <= 'd0;
    else if(binning_valid && binning_ready)begin
        case(stream_count)
        3'd0:fifo_wen <= 'b00000001;
        3'd1:fifo_wen <= 'b00000010;
        3'd2:fifo_wen <= 'b00000100;
        3'd3:fifo_wen <= 'b00001000;
        3'd4:fifo_wen <= 'b00010000;
        3'd5:fifo_wen <= 'b00100000;
        3'd6:fifo_wen <= 'b01000000;
        3'd7:fifo_wen <= 'b10000000;
        default:fifo_wen <= 'd0;
        endcase
    end
    else
    fifo_wen <= 'd0;
end    
generate
genvar u;
    for(u=0;u<8;u=u+1) begin
   //     assign fifo_in[u] = str_data_reg; 
        always@(posedge clk or negedge rst) begin
            if(!rst)
                fifo_count[u] <= 'd0;
            else begin
                if(fifo_wen[u]) begin
                    if(fifo_count[u] == 'd60) begin
                        fifo_count[u] <= 'd0;
                        pop_en[u] <= 1;
                    end
                    else begin
                        fifo_count[u] <= fifo_count[u] +1;
                        pop_en[u] <= 0;
                    end
                end
            end
        end    
                   
        fifo_generator fifo_stream2MM (
            .clk(clk),                  // input wire clk
            .srst(!rst),                // input wire srst
            .din(str_data_reg),                  // input wire [11 : 0] din
            .wr_en(fifo_wen[u]),              // input wire wr_en
            .rd_en(rd_en),              // input wire rd_en
            .dout(fifo_out[u]),                // output wire [11 : 0] dout
            .full(),                // output wire full
            .empty(),          
            .prog_full(prog_full[u]),    // output wire empty
            .wr_rst_busy(),  // output wire wr_rst_busy
            .rd_rst_busy()  // output wire rd_rst_busy
            );
        end
endgenerate
assign prog_full_all = &prog_full;  
assign rd_en = ~prog_full_all_reg & prog_full_all;
always@(posedge clk or negedge rst) begin
    if(!rst)
        prog_full_all_reg <= 0;
    else begin
        prog_full_all_reg <= prog_full_all;
        
    //    prog_full_all_reg2 <= prog_full_all_reg;
    end
end
//always@(posedge clk or negedge rst) begin
//    if(!rst)
//        rd_en <= 0;
//    else if(prog_full_all_reg==0 && prog_full_all == 1)
//        rd_en <= 1;
//    else
//        rd_en <= 0;
//end
   
endmodule