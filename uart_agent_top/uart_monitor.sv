class uart_monitor extends uvm_monitor;
	`uvm_component_utils(uart_monitor);

	virtual uart_if vif;
	uart_agt_config m_cfg;
	bit[7:0] lcr;

	uart_xtn rxtn,txtn;

	uvm_analysis_port#(uart_xtn) monitor_port;

	extern function new(string name = "uart_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
	extern task collect_data1();
endclass

//Constructor New
function uart_monitor::new(string name = "uart_monitor", uvm_component parent);
	super.new(name,parent);
	monitor_port = new("monitor_port",this);
endfunction

//Build Phase
function void uart_monitor::build_phase(uvm_phase phase);
	if(!uvm_config_db #(uart_agt_config)::get(this,"","uart_agt_config",m_cfg))
		`uvm_fatal("UVM_MONITOR","m_cfg didn't get, Have you set")

	if(!uvm_config_db #(bit[7:0])::get(this,"","bit[7:0]",lcr))
		`uvm_fatal("UART_DRIVER","lcr didn't get, Have yopu set")

	rxtn = uart_xtn::type_id::create("rxtn");
	txtn = uart_xtn::type_id::create("txtn");
endfunction

//Connect phase
function void uart_monitor::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction

//Run phase
task uart_monitor::run_phase(uvm_phase phase);
	vif.rxd = 1;
	vif.txd = 1;
	fork
		begin
			forever
			begin
				if(vif.rxd)
					`uvm_info("UART_MONITOR","below rxd if",UVM_LOW)
					wait(vif.rxd == 0)
					`uvm_info("UART_MONITOR","below rxd wait",UVM_LOW)
					collect_data();
			end
		end
		
		begin
			forever
			begin
				if(vif.txd)
					`uvm_info("UART_MONITOR","below txd if",UVM_LOW)
					wait(vif.txd == 0)
					`uvm_info("UART_MONITOR","below txd wait",UVM_LOW)
					collect_data1();
					rxtn.txd = txtn.txd;
			end
		end
	join
//	collect_data();
endtask

//Collect Data
task uart_monitor::collect_data();
	repeat(24)
	@(posedge vif.baud_o);
	rxtn.rxd[0] = vif.rxd;

	repeat(16)
	@(posedge vif.baud_o);
	rxtn.rxd[1] = vif.rxd;

	repeat(16)
	@(posedge vif.baud_o);
	rxtn.rxd[2] = vif.rxd;

	repeat(16)
	@(posedge vif.baud_o);
	rxtn.rxd[3] = vif.rxd;

	repeat(16)
	@(posedge vif.baud_o);

	case(lcr[1:0])
		2'b00: begin
			rxtn.rxd[4] = vif.rxd;
			repeat(16)
			@(posedge vif.baud_o);
		       end
			
		2'b01: begin
			rxtn.rxd[4] = vif.rxd;
			repeat(16)
			@(posedge vif.baud_o);
			rxtn.rxd[5] = vif.rxd;
			repeat(16)
			@(posedge vif.baud_o);
		       end
	
		2'b10: begin
			rxtn.rxd[4] = vif.rxd;
			repeat(16)
			@(posedge vif.baud_o);
			rxtn.rxd[5] = vif.rxd;
			repeat(16)
			@(posedge vif.baud_o);
			rxtn.rxd[6] = vif.rxd;
			repeat(16)
			@(posedge vif.baud_o);
		       end

		2'b11: begin
			rxtn.rxd[4] = vif.rxd;
			repeat(16)
			@(posedge vif.baud_o);
			rxtn.rxd[5] = vif.rxd;
			repeat(16)
			@(posedge vif.baud_o);
			rxtn.rxd[6] = vif.rxd;
			repeat(16)
			@(posedge vif.baud_o);
			rxtn.rxd[7] = vif.rxd;
			repeat(16)
			@(posedge vif.baud_o);
		       end
	endcase

	if(lcr[3])
	begin
		rxtn.parity = ^(vif.rxd);
		repeat(16)
		@(posedge vif.baud_o);
	end

//	rxtn.rxd = 1'b1;
	repeat(16)
	@(posedge vif.baud_o);

	`uvm_info("UART_MONITOR","Printing from UART Monitor",UVM_LOW)
	rxtn.print();

	monitor_port.write(rxtn);
endtask

//collect_data_txd
task uart_monitor::collect_data1();
	repeat(24)
	@(posedge vif.baud_o);
	txtn.txd[0] = vif.txd;

	repeat(16)
	@(posedge vif.baud_o);
	txtn.txd[1] = vif.txd;

	repeat(16)
	@(posedge vif.baud_o);
	txtn.txd[2] = vif.txd;

	repeat(16)
	@(posedge vif.baud_o);
	txtn.txd[3] = vif.txd;

	repeat(16)
	@(posedge vif.baud_o);

	case(lcr[1:0])
		2'b00: begin
			txtn.txd[4] = vif.txd;
			repeat(16)
			@(posedge vif.baud_o);
		       end
			
		2'b01: begin
			txtn.txd[4] = vif.txd;
			repeat(16)
			@(posedge vif.baud_o);
			txtn.txd[5] = vif.txd;
			repeat(16)
			@(posedge vif.baud_o);
		       end
	
		2'b10: begin
			txtn.txd[4] = vif.txd;
			repeat(16)
			@(posedge vif.baud_o);
			txtn.txd[5] = vif.txd;
			repeat(16)
			@(posedge vif.baud_o);
			txtn.txd[6] = vif.txd;
			repeat(16)
			@(posedge vif.baud_o);
		       end

		2'b11: begin
			txtn.txd[4] = vif.txd;
			repeat(16)
			@(posedge vif.baud_o);
			txtn.txd[5] = vif.txd;
			repeat(16)
			@(posedge vif.baud_o);
			txtn.txd[6] = vif.txd;
			repeat(16)
			@(posedge vif.baud_o);
			txtn.txd[7] = vif.txd;
			repeat(16)
			@(posedge vif.baud_o);
		       end
	endcase

	if(lcr[3])
	begin
		txtn.parity = ^(vif.txd);
		repeat(16)
		@(posedge vif.baud_o);
	end

//	txtn.txd = 1'b1;
	repeat(16)
	@(posedge vif.baud_o);

	`uvm_info("UART_MONITOR","Printing from UART Monitor",UVM_LOW)
	txtn.print();

	monitor_port.write(txtn);
endtask
