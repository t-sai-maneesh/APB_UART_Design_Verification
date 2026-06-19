module fifo16_8(clk_in,rstn,push,pop,data_in,data_out,full,empty,count);
	input clk_in,rstn,push,pop;
	input [7:0] data_in;
	output full,empty;
	output reg [4:0] count;
	output [7:0] data_out;

	reg [7:0] dout;
	reg [3:0] wr_ptr,rd_ptr;
	reg [7:0] fifo [15:0];
	
	integer i;

	always@(posedge clk_in)
	begin
		if(!rstn)
		begin
			for(i=0;i<16;i=i+1)
			begin
				fifo[i] <= 8'b0;
			end
			wr_ptr <= 4'b0;
			rd_ptr <= 4'b0;
			dout <= 8'b0;
			count <= 5'b0;
		end
		else if(push && pop)
		begin
			//count <= count;
			fifo[wr_ptr] <= data_in;
			dout <= fifo[rd_ptr];
			wr_ptr <= wr_ptr + 1'b1;
			rd_ptr <= rd_ptr + 1'b1;
		end
		else if(push && !full)
		begin
			fifo[wr_ptr] <= data_in;
			wr_ptr <= wr_ptr + 1'b1;
			count <= count + 1'b1;
		end
		else if(pop && !empty)
		begin
			dout <= fifo[rd_ptr];
			rd_ptr <= rd_ptr + 1'b1;
			count <= count - 1'b1;
		end
		else
		begin
			wr_ptr <= wr_ptr;
			rd_ptr <= rd_ptr;
		end
	end
	  assign data_out = dout;
     assign full=(count==5'd16)?1'b1:1'b0;
	  assign empty=(count==5'd0)?1'b1:1'b0;
	//assign full = ((wr_ptr[4] != rd_ptr[4]) && (wr_ptr[3:0] == rd_ptr[3:0]));
	//assign empty = ((wr_ptr == rd_ptr) );
endmodule






