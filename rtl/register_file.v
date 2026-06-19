module register_file(pclk,presetn,psel,pwrite,penable,paddr,pwdata,tx_fifo_count,tx_fifo_empty,tx_fifo_full,tx_busy,rx_data_out,rx_idle,rx_overrun,parity_error,framing_error,break_error,time_out,rx_fifo_count,rx_fifo_empty,rx_fifo_full,push_rx_fifo,prdata,pslverr,lcr,tx_fifo_we,tx_enable,rx_enable,rx_fifo_re,pready,loopback,irq,baud_o);
	input pclk,presetn,psel,pwrite,penable,tx_fifo_empty,tx_fifo_full,tx_busy,rx_idle,rx_overrun,parity_error,framing_error,break_error,time_out,rx_fifo_empty,rx_fifo_full,push_rx_fifo;
	input [7:0] paddr,pwdata,rx_data_out;
   	input [4:0] tx_fifo_count,rx_fifo_count;
	output reg [7:0] prdata;
	output reg [7:0] lcr;
	output reg irq,pslverr,tx_fifo_we,rx_fifo_re;
	output pready,rx_enable,tx_enable,loopback,baud_o;

	//registers & wires
	reg [7:0] fcr,lsr;
	reg [3:0] ier,iir;
	reg [4:0] mcr;
	reg enable,last_tx_fifo_empty,rx_int,tx_int,ls_int,start_dlc;
	wire we,re;
	wire rx_fifo_overflow;
	reg [15:0] dlc,divisor;

	//APB Master Controller
	localparam IDLE = 2'b00,
		  SETUP = 2'b01,
		  ACCESS = 2'b10;

	reg [1:0] state,next_state;

	always@(posedge pclk)
	begin
		if(!presetn)
			state <= IDLE;
		else 
			state <= next_state;
	end

	always@(*)
	begin
		next_state = IDLE;
		case(state)
				IDLE: begin
				if(psel == 1'b1 && penable == 1'b0)
					next_state = SETUP;
				else 
					next_state = IDLE;
			      end

			SETUP: begin
				if(psel == 1'b1 && penable == 1'b1)
					next_state = ACCESS;
				else 
					next_state = IDLE;
			       end

			ACCESS: begin
				if(psel == 1'b1 && penable == 1'b1)
					next_state = ACCESS;
				else if(psel == 1'b1 && penable == 1'b0)
					next_state = SETUP;
				else 
					next_state = IDLE;
			       end
		endcase
 	end		

	//LCR Register
	always@(posedge pclk)
	begin
		if(!presetn)
			lcr <= 8'b0;
		else if(we && paddr == 8'h0c)
			lcr <= pwdata;
		else
			lcr <= lcr;
	end

	//FCR Register
 	always@(posedge pclk)
	begin
		if(!presetn)
			fcr <= 8'b0;
		else if(we && paddr == 8'h08)
			fcr <= pwdata;
		else
			fcr <= fcr;
	end

	//LSR Register
	always@(posedge pclk)
	begin
		if(!presetn)
			lsr <= 8'b0;
		else if(re && paddr == 8'h14)
			lsr <= 8'b0;
	//	else if(re)
		//	lsr <= {(parity_error|framing_error|break_error),(tx_fifo_empty&tx_busy),tx_fifo_empty,break_error,framing_error,parity_error,rx_overrun,rx_fifo_empty};
		else if(rx_fifo_empty)
			lsr[0] <= 1'b1;
		else if(rx_overrun)
			lsr[1] <= 1'b1;
		else if(parity_error)
			lsr[2] <= 1'b1;
		else if(framing_error)
			lsr[3] <= 1'b1;
		else if(break_error)
			lsr[4] <= 1'b1;
		else if(tx_fifo_empty)
			lsr[5] <= 1'b1;
		else if((tx_fifo_empty&tx_busy))
			lsr[6] <= 1'b1;
		else if((parity_error|framing_error|break_error))
			lsr[7] <= 1'b1;
		else
			lsr <= lsr;
	end

	//IER Register
	always@(posedge pclk)
	begin
		if(!presetn)
			ier <= 4'b0;
		else if(we && paddr == 8'h04)
			ier <= pwdata[3:0];
		else
			ier <= ier;
	end
	
	//MCR Register
	always @(posedge pclk) begin
		if (!presetn)
			mcr <= 8'd0;
		else if (we && paddr == 8'h10)
			mcr <= pwdata[4:0];
	end


	//rx_fifo_re
	always@(posedge pclk)
	begin
		if(!presetn)
			rx_fifo_re <= 1'b0;
		else if(rx_fifo_re)
			rx_fifo_re <= 1'b0;
		else if(re && paddr == 8'h0)
			rx_fifo_re <= 1'b1;
		else
			rx_fifo_re <= rx_fifo_re;
	end

	//tx_fifo_we
	always@(posedge pclk)
	begin
		if(!presetn)
			tx_fifo_we <= 1'b0;
		else if(we && paddr == 8'h0)
			tx_fifo_we <= 1'b1;
		else
			tx_fifo_we <= 1'b0;
	end

	//last_tx_fifo_empty
	always@(posedge pclk)
	begin
		if(!presetn)
			last_tx_fifo_empty <= 1'b0;
		else 
			last_tx_fifo_empty <= tx_fifo_empty;
	end

	//IRQ
	always@(posedge pclk)
	begin
		if(!presetn)
			irq <= 1'b0;
		else if(re && paddr == 8'h8)
			irq <= 1'b0;
		else
			irq <= (time_out || (ier[0] && rx_int) || (ier[1] && tx_int) || (ier[2] && ls_int));
	end

	//rx_int
	always@(posedge pclk)
	begin
		if(!presetn)
			rx_int <= 1'b0;
		else
		begin
		case(fcr[7:6])
			2'b00: rx_int <= (rx_fifo_count >= 5'd1);
		   	2'b01: rx_int <= (rx_fifo_count >= 5'd4);
			2'b10: rx_int <= (rx_fifo_count >= 5'd8);
			2'b11: rx_int <= (rx_fifo_count >= 5'd14);
			default: rx_int <= rx_int;
		endcase
		end
	end	

	//tx_int
	always@(posedge pclk)
	begin
		if(!presetn)
			tx_int <= 1'b0;
		else if(re && paddr == 8'h08 && prdata[3:0] == 4'd2)
			tx_int <= 1'b0;
		else
			tx_int <= (tx_int || ((tx_fifo_empty && !last_tx_fifo_empty) && !tx_fifo_full));
	end

	//ls_int
	always@(posedge pclk)
	begin
		if(!presetn)
			ls_int <= 1'b0;
		else if(re && paddr == 8'h14)
			ls_int <= 1'b0;
	//	else if(re)
		//	ls_int <= (|{break_error,framing_error,parity_error,rx_overrun,rx_fifo_overflow});
		else
			ls_int <= |(lsr[4:1]);
	end

	//Baud Rate generator
	always@(posedge pclk)
	begin
		if(!presetn)
			enable <= 1'b0;
		else if((|divisor) && ~(|dlc))
			enable <= 1'b1;
		else
			enable <= 1'b0;
	end

	always@(posedge pclk)
	begin
		if(!presetn)
			dlc <= 16'b0;
		else 
		begin
		if((~|divisor) || start_dlc || !(|dlc))
			dlc <= divisor-1'b1;
		else
			dlc <= dlc - 1'b1;
		end
	end

	always@(posedge pclk)
	begin
		if(!presetn)
			start_dlc <= 1'b0;
		else if(we && paddr == 8'h1c)
			start_dlc <= 1'b1; 
		else
			start_dlc <= 1'b0;
	end

	always@(posedge pclk)
	begin
		if(!presetn)
			divisor <= 16'b0;
		else if(we)
		begin
		 if(paddr == 8'h1c)
			 divisor[7:0] <= pwdata;
		 if(paddr == 8'h20)
			 divisor[15:8] <= pwdata;
		end
	end

	//IIR
	always@(posedge pclk)
	begin
		if(!presetn)
			iir <= 4'b0;
		else if(ls_int && ier[2])
			iir <= 4'h6;
		else if(rx_int && ier[0])
			iir <= 4'h4;
		else if(time_out)
			iir <= 4'hc;
		else if(tx_int && ier[1])
			iir <= 4'h4;
		else 
			iir <= 4'h1;
	end
	
	//PRDATA
	always@(*)
	begin
	pslverr = 1'b0;
	prdata = 8'b0;
		case(paddr)
			8'h0: prdata = rx_data_out;
			8'h4: prdata = {4'b0,ier};
			8'h8: prdata = {4'h0,iir};
			8'hc: prdata = lcr;
			8'h10: prdata = {3'h0,mcr==0};
			8'h14: prdata = lsr;
			8'h1c: prdata = divisor[7:0];
			8'h20: prdata = divisor[15:8];
			default: pslverr = 1'b1;
		endcase
	end

	assign we = ((state == ACCESS) && pwrite);
	assign re = ((state == ACCESS) && ~pwrite);
	assign pready = (state == ACCESS);
	assign rx_enable = enable;
	assign tx_enable = enable;
	assign baud_o = enable;
	assign rx_fifo_overflow = rx_fifo_full & push_rx_fifo;
	assign loopback = mcr[4];

endmodule
