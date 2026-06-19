module top;

	import uart_pkg::*;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	//clocks and reset for apb and uart agents
	bit clk1;	//100MHz APB -> UART_RTL
	bit clk2;	//50MHz  UART_RTL -> UART Agent
	bit presetn;

	always #5 clk1 = ~clk1;

	always #10 clk2 = ~clk2;

	initial 
	begin
		clk1 = 0;
		clk2 = 0;
		presetn = 0;
		#10;
		presetn = 1'b1;

		in0.presetn = 0;
		in0.psel = 0;
                in0.penable = 0;
		#10;
		in0.presetn = 1;

	end

	//Interface 
	apb_if in0(clk1);
	uart_if in1();

	//Baud Generator for UART
	localparam int clk_freq = 50_000_000;
	localparam int BAUD_RATE = 115200;
	localparam int SAMPLE = 16;
	
	localparam int DIVISOR = clk_freq/(BAUD_RATE * SAMPLE);

	int baud_cnt;

	always_ff@(posedge clk2 or negedge presetn)
	begin
		if(!presetn)
		begin
			baud_cnt <= 0;
			in1.baud_o <= 0;
		end
		else if(baud_cnt == DIVISOR - 1)
		begin
			baud_cnt <= 0;
			in1.baud_o <= 1'b1;
		end
		else 
		begin
			baud_cnt <= baud_cnt + 1'b1;
			in1.baud_o <= 1'b0;
		end
	end
			
	//DUT Instantiation
	uart_top dut1(.pclk(clk1),.presetn(in0.presetn),.paddr(in0.paddr),.pwdata(in0.pwdata),.prdata(in0.prdata),.pwrite(in0.pwrite),.penable(in0.penable),.psel(in0.psel),.pready(in0.pready),.irq(in0.irq),.pslverr(in0.pslverr),.txd(in1.rxd),.rxd(in1.txd));

	//Assertions Instatntiation
	uart_assertions assrt(.pclk(clk1),.presetn(in0.presetn),.paddr(in0.paddr),.pwdata(in0.pwdata),.prdata(in0.prdata),.pwrite(in0.pwrite),.penable(in0.penable),.psel(in0.psel),.pready(in0.pready),.irq(in0.irq),.pslverr(in0.pslverr),.txd(in1.rxd),.rxd(in1.txd));

	initial 
	begin

		`ifdef VCS
        	$fsdbDumpvars(0, top);
        	`endif

		uvm_config_db #(virtual apb_if)::set(null,"*","apb_if",in0);
		uvm_config_db #(virtual uart_if)::set(null,"*","uart_if",in1);

		run_test();
	end
endmodule
