module binnig
(
input clk,rst,
input [11:0] binning_str_data,
input binning_valid,
output binning_ready
);
parameter n = 8;
reg [11:0] str_data_reg;
wire [11:0] fifo_in[n-1:0];
wire [11:0] fifo_out[n-1:0];
reg  [n-1:0]fifo_wen;
reg  fifo_ren;
reg [2:0]stream_count;
reg [6:0]fifo_count[n-1:0];
reg pop_en[n-1:0];
reg rd_en;
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
    else begin
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
end    
generate
genvar u;
    for(u=0;u<8;u=u+1) begin
        assign fifo_in[u] = str_data_reg; 
        always@(posedge clk or negedge rst) begin
            if(!rst)
                fifo_count[u] <= 'd0;
            else begin
                if(fifo_wen[u]) begin
                    if(fifo_count[u] == 'd60) begin
                        fifo_count[u] <= 'd0;
                        pop_en[u] <= 1;
                    end
                    else 
                        fifo_count[u] <= fifo_count[u] +1;
                end
            end
        end    
                   
        fifo_generator fifo_stream2MM (
            .clk(clk),                  // input wire clk
            .srst(rst),                // input wire srst
            .din(fifo_in[u]),                  // input wire [11 : 0] din
            .wr_en(fifo_wen[u]),              // input wire wr_en
            .rd_en(rd_en),              // input wire rd_en
            .dout(fifo_out[u]),                // output wire [11 : 0] dout
            .full(),                // output wire full
            .empty(),              // output wire empty
            .wr_rst_busy(),  // output wire wr_rst_busy
            .rd_rst_busy()  // output wire rd_rst_busy
            );
        end
endgenerate
always@(posedge clk or negedge rst) begin
    if(!rst)
        rd_en <= 0;
    else if({pop_en[0],pop_en[1],pop_en[2],pop_en[3],pop_en[4],pop_en[5],pop_en[6],pop_en[7]}=='b11111111)
        rd_en <= 1;
end    
endmodule