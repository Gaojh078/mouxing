`timescale 1ns/1ps

//modification:del P2S part & add AXIS control signals
module top_module;

reg clk=0;
reg rst;
parameter periodHalf = 5;
parameter period = periodHalf*2;
parameter line_interval = 16;

initial begin
    forever begin
        #(periodHalf) clk = ~clk;
    end
end



localparam filename_lane_u1 ="D:/R2018b_win64/math/bin/lane_u1.bin";
integer fd1;
localparam per_lane_pic_width  = 244;   // 7808 div 32
localparam per_lane_pic_height = 4340;

reg [11:0] pixel_bytes_lane_u1=0;

//frame valid & line valid
reg fv_i=0,lv_i=0;
reg fv=0,lv=0;

//AXIS CTRL signals
reg [11:0] TDATA=0;
reg TVALID=0,TREADY=0,TLAST=0,TUSER=0;
reg TVALID_i=0,TREADY_i=1,TLAST_i=0,TUSER_i=0; //variables with suffix _i are used in initial block

always@(posedge clk) begin
    TDATA  <= pixel_bytes_lane_u1[11:0];
    lv     <= lv_i;
    fv     <= fv_i;
	TVALID <= TVALID_i;
	TLAST  <= TLAST_i;
	TUSER  <= TUSER_i;
	TREADY <= TREADY_i;
end


integer i,j;
initial begin
	fd1 = $fopen(filename_lane_u1,"rb");
	if(fd1 == 0) begin
		$display("$fopen failed");
        $stop;
    end
	
	#(period*100);
	fv_i  = 1;
	TUSER_i = 1;
	for(i=0;i<per_lane_pic_height;i=i+1)begin
		for(j=0;j<per_lane_pic_width;j=j+1)begin
			$fread(pixel_bytes_lane_u1,fd1);
			lv_i  = 1;
			if(j==0)
				TVALID_i = 1;
			else
				TVALID_i = TVALID_i;
			if(j == per_lane_pic_width-1)
				TLAST_i  = 1;
			#(period);
			TUSER_i = 0;
		end
		
		pixel_bytes_lane_u1 = 1'b0;
		TVALID_i = 0;
		TLAST_i  = 0;
		for(j=0;j<line_interval;j=j+1)begin
			lv_i  = 0;
			#(period);
		end
	end
	fv_i  = 0;


end
initial
begin
rst = 0;
#100
rst = 1;
end
binnig test
(
.clk(clk),
.rst(rst),
.binning_str_data(TDATA),
.binning_valid(TVALID)
);
endmodule
