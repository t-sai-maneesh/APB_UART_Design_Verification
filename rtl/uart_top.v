module uart_top(pclk,presetn,paddr,pwdata,pwrite,penable,psel,rxd,prdata,pready,pslverr,irq,txd,baud_o);
	input pclk,presetn,pwrite,penable,psel,rxd;
	input [7:0] paddr,pwdata;
	output pready,pslverr,irq,txd,baud_o;
	output [7:0] prdata;

	wire loopback;
	wire tx_busy,tx_fifo_we,tx_fifo_full,tx_enable,tx_fifo_empty;
	wire rx_idle,rx_fifo_empty,rx_enable,rx_fifo_full,rx_fifo_re,rx_overrun,parity_error,framing_error,break_error,time_out,push_rx_fifo;
	wire [7:0] lcr;
	wire [4:0] tx_fifo_count,rx_fifo_count;
	wire [7:0] rx_data_out;
	
	wire rxd_temp,txd_temp;

	transmitter_top Transmitter(.pclk(pclk),.presetn(presetn),.pwdata(pwdata),.tx_fifo_push(tx_fifo_we),.enable(tx_enable),.lcr(lcr),.tx_fifo_count(tx_fifo_count),.busy(tx_busy),.tx_fifo_full(tx_fifo_full),.tx_fifo_empty(tx_fifo_empty),.txd(txd_temp));

	reciever_top Reciever(.pclk(pclk),.presetn(presetn),.rxd(rxd_temp),.pop_rx_fifo(rx_fifo_re),.enable(rx_enable),.lcr(lcr),.rx_idle(rx_idle),.rx_fifo_empty(rx_fifo_empty),.rx_fifo_count(rx_fifo_count),.rx_fifo_out(rx_data_out),.rx_fifo_full(rx_fifo_full),.rx_overrun(rx_overrun),.parity_error(parity_error),.framing_error(framing_error),.break_error(break_error),.time_out(time_out),.push_rx_fifo(push_rx_fifo));

	register_file UART_Register(.pclk(pclk),.presetn(presetn),.psel(psel),.pwrite(pwrite),.penable(penable),.paddr(paddr),.pwdata(pwdata),.tx_fifo_count(tx_fifo_count),.tx_fifo_empty(tx_fifo_empty),.tx_fifo_full(tx_fifo_full),.tx_busy(tx_busy),.rx_data_out(rx_data_out),.rx_idle(rx_idle),.rx_overrun(rx_overrun),.parity_error(parity_error),.framing_error(framing_error),.break_error(break_error),.time_out(time_out),.rx_fifo_count(rx_fifo_count),.rx_fifo_empty(rx_fifo_empty),.rx_fifo_full(rx_fifo_full),.push_rx_fifo(push_rx_fifo),.prdata(prdata),.pslverr(pslverr),.lcr(lcr),.tx_fifo_we(tx_fifo_we),.tx_enable(tx_enable),.rx_enable(rx_enable),.rx_fifo_re(rx_fifo_re),.pready(pready),.loopback(loopback),.irq(irq),.baud_o(baud_o));

	//loopback
	assign rxd_temp = loopback? txd_temp:rxd;
	assign txd = loopback? 1'b1:txd_temp;

endmodule
