class uart_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(uart_scoreboard)

	env_config m_cfg;

	uvm_tlm_analysis_fifo#(apb_xtn) fifo_h_w;
	uvm_tlm_analysis_fifo#(uart_xtn) fifo_h_r;

	apb_xtn uart1;
	uart_xtn uart2;

	apb_xtn cov_data1;
	uart_xtn cov_data2;

	int thr_size,rbr_size;

	covergroup apb_signals_cov;
		option.per_instance = 1;

		ADDRESS: coverpoint cov_data1.paddr {bins add = {[0:255]};}
		WR_EN: coverpoint cov_data1.pwrite {bins rd = {0};
						    bins wr = {1};}
	endgroup

	covergroup apb_lcr_cov;
		option.per_instance = 1;
		
		CHAR_SIZE: coverpoint cov_data1.lcr[1:0] {bins five = {2'b00};
							 bins six  = {2'b01};
							 bins seven = {2'b10};
							 bins eight = {2'b11};}	
		STOP: coverpoint cov_data1.lcr[2] {bins stop1 = {1'b0};
						   bins stop2 = {1'b1};}
		PARITY_EN: coverpoint cov_data1.lcr[3] {bins disble = {0};	
						     bins enable = {1};}
		PARITY: coverpoint cov_data1.lcr[4] {bins odd = {0};	
						     bins even = {1};}
	endgroup

	covergroup apb_ier_cov;
		option.per_instance = 1;
	
		RCVD_INT: coverpoint cov_data1.ier[0] {bins dis = {0};
						       bins en = {1};}
		THRE_INT: coverpoint cov_data1.ier[1] {bins dis = {0};
						       bins en = {1};}
		LSR_INT: coverpoint cov_data1.ier[2] {bins dis = {0};
						       bins en = {1};}
	//	IER_RST: coverpoint cov_data1.ier[3] {bins dis = {0};
	//					       bins en = {1};}
	endgroup

	covergroup apb_fcr_cov;
		option.per_instance = 1;
		
		RFIFO: coverpoint cov_data1.fcr[1] {bins dis = {0};
						    bins clr = {1};}
		TFIFO: coverpoint cov_data1.fcr[2] {bins dis = {0};
						    bins clr = {1};}
		TRG_LVL: coverpoint cov_data1.fcr[7:6] {bins one = {2'b00};
						    	bins four = {2'b01};
							bins eight = {2'b10};
							bins fourteen = {2'b11};}
	endgroup

	
	covergroup apb_mcr_cov;
		option.per_instance = 1;
		
		LB: coverpoint cov_data1.mcr[4] {bins dis = {0};
						 bins en = {1};}
	endgroup

	covergroup apb_iir_cov;
		option.per_instance = 1;
		
		IIR: coverpoint cov_data1.iir[3:1] {bins lsr = {3'b011};
						    bins rdf = {3'b010};}
						   // bins ti_o = {3'b110};}
	endgroup

	covergroup apb_lsr_cov;
		option.per_instance = 1;
		
		DATA_READY: coverpoint cov_data1.lsr[0] {bins fifoempty = {0};
						         bins datarcvd = {1};}
		OVER_RUN: coverpoint cov_data1.lsr[1] {bins nooverrun = {0};
						       bins overrun = {1};}
		PARITY_ERR: coverpoint cov_data1.lsr[2] {bins noparityerr = {0};
						         bins parityerr = {1};}
		FRAME_ERR: coverpoint cov_data1.lsr[3] {bins noframeerr = {0};
						        bins frameerr = {1};}
		BREAK_INT: coverpoint cov_data1.lsr[4] {bins nobreakint = {0};
						        bins breakint = {1};}
	endgroup


	//methods
	extern function new(string name = "uart_scoreboard", uvm_component parent);
	extern task run_phase(uvm_phase phase);
	extern function void check_phase(uvm_phase phase);
endclass

//Constructor New
function uart_scoreboard::new(string name = "uart_scoreboard", uvm_component parent);
	super.new(name,parent);
	apb_signals_cov = new();
	apb_lcr_cov = new();
	apb_ier_cov = new();
	apb_fcr_cov = new();
	apb_mcr_cov = new();
	apb_iir_cov = new();
	apb_lsr_cov = new();
	fifo_h_w = new("fifo_h_w",this);
	fifo_h_r = new("fifo_h_r",this);
endfunction

//Run phase
task uart_scoreboard::run_phase(uvm_phase phase);
	forever
		fork
		begin
			fifo_h_w.get(uart1);
			uart1.print();
			thr_size = uart1.thr.size;
			rbr_size = uart1.rbr.size;
			$display("@@%d",thr_size);
			$display("@@%d",rbr_size);
			`uvm_info("UART_SCOREBOARD",$sformatf("Printing from Scoreboard of uart1 \n %s",uart1.sprint),UVM_LOW)
		
			cov_data1 = uart1;
			apb_signals_cov.sample();
			apb_lcr_cov.sample();
			apb_ier_cov.sample();
			apb_fcr_cov.sample();
			apb_mcr_cov.sample();
			apb_iir_cov.sample();
			apb_lsr_cov.sample();
		end
		
		begin
			fifo_h_r.get(uart2);
			uart2.print();
			cov_data2 = uart2;
			`uvm_info("UART_SCOREBOARD",$sformatf("Printing from Scoreboard of uart2 \n %s",uart2.sprint),UVM_LOW)
		end
		join
endtask

//Check phase
function void uart_scoreboard::check_phase(uvm_phase phase);
	if(uart1.ier[3:0] == 3'b001)
	begin
		if(uart1.mcr[4] == 1'b0)
		begin
			if(((uart1.thr.size() == 1) && (uart1.rbr.size() == 0)) || ((uart1.thr.size() == 0) && (uart1.rbr.size() == 1)))
			begin
				if((uart1.thr[0] == uart2.rxd) || (uart1.rbr[0] == uart2.txd))
					`uvm_info("UART_SCOREBOARD","Half_Duplex Comparison Passed",UVM_LOW)
				else
					`uvm_info("UART_SCOREBOARD","Half_Duplex Comparison failed",UVM_LOW)
			end
			else
			begin
				if((uart1.thr[0] == uart2.rxd) && (uart1.rbr[0] == uart2.txd))
					`uvm_info("UART_SCOREBOARD","Full_Duplex Comparison Passed",UVM_LOW)
				else
					`uvm_info("UART_SCOREBOARD","Full_Duplex Comparison failed",UVM_LOW)	
			end
		end
		else
		begin
			if(uart1.thr == uart1.rbr)
				`uvm_info("SCOREBOARD","LoopBack comparision Passed",UVM_LOW)
			else
				`uvm_info("SCOREBOARD","LoopBack comparision Failed",UVM_LOW)
		end
	end
	
	if(uart1.ier == 8'd5)
	begin
	if(uart1.iir[3:1] == 3)
	begin
		if(uart1.lsr[1] == 1)
			`uvm_info("SCOREBOARD","In Scoreboard Overrun error",UVM_LOW)	
		if(uart1.lsr[2] == 1)
			`uvm_info("SCOREBOARD","In Scoreboard Parity error",UVM_LOW)	
		if(uart1.lsr[3] == 1)
			`uvm_info("SCOREBOARD","In Scoreboard Framing error",UVM_LOW)	
		if(uart1.lsr[4] == 1)
			`uvm_info("SCOREBOARD","In Scoreboard Break Interrupt error",UVM_LOW)	
	end
	end

	if(uart1.iir[3:1] == 3'b110)
		`uvm_info("SCOREBOARD","In Scoreboard Timeout error",UVM_LOW)
	if(uart1.iir[3:1] == 3'b001)
		`uvm_info("SCOREBOARD","In Scoreboard THR Empty error",UVM_LOW)
endfunction
