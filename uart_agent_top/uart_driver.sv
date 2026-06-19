class uart_driver extends uvm_driver #(uart_xtn);
	`uvm_component_utils(uart_driver);

	uart_agt_config m_cfg;
	bit [7:0] lcr;

	virtual uart_if vif;	

	extern function new(string name = "uart_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(uart_xtn xtn);
endclass

//Constructor New
function uart_driver::new(string name = "uart_driver", uvm_component parent);
	super.new(name,parent);
endfunction

//Build Phase
function void uart_driver::build_phase(uvm_phase phase);
	if(!uvm_config_db #(uart_agt_config)::get(this,"","uart_agt_config",m_cfg))
		`uvm_fatal("UART_DRIVER","m_cfg didn't get, Have yopu set")
	
	if(!uvm_config_db #(bit[7:0])::get(this,"","bit[7:0]",lcr))
		`uvm_fatal("UART_DRIVER","lcr didn't get, Have yopu set")		
endfunction

//Connect Phase
function void uart_driver::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction

//Run Phase
task uart_driver::run_phase(uvm_phase phase);
	vif.txd = 1'b1;

	forever
	begin
		seq_item_port.get_next_item(req);
		send_to_dut(req);
		seq_item_port.item_done();
	end
endtask

//Send to DUT
task uart_driver::send_to_dut(uart_xtn xtn);
	@(posedge vif.baud_o);
	vif.txd = 1'b0;
	
	repeat(16)
	@(posedge vif.baud_o);
	vif.txd = xtn.txd[0];

	repeat(16)
	@(posedge vif.baud_o);
	vif.txd = xtn.txd[1];

	repeat(16)
	@(posedge vif.baud_o);
	vif.txd = xtn.txd[2];

	repeat(16)
	@(posedge vif.baud_o);
	vif.txd = xtn.txd[3];

	repeat(16)
	@(posedge vif.baud_o);
	
	case(lcr[1:0])
		2'b00: begin
			vif.txd = xtn.txd[4];
			repeat(16)
			@(posedge vif.baud_o);
		       end

		2'b01: begin
			vif.txd = xtn.txd[4];
			repeat(16)
			@(posedge vif.baud_o);
			vif.txd = xtn.txd[5];
			repeat(16)
			@(posedge vif.baud_o);
		       end

		2'b10: begin
			vif.txd = xtn.txd[4];
			repeat(16)
			@(posedge vif.baud_o);
			vif.txd = xtn.txd[5];
			repeat(16)
			@(posedge vif.baud_o);
			vif.txd = xtn.txd[6];
			repeat(16)
			@(posedge vif.baud_o);
		       end

		2'b11: begin
			vif.txd = xtn.txd[4];
			repeat(16)
			@(posedge vif.baud_o);
			vif.txd = xtn.txd[5];
			repeat(16)
			@(posedge vif.baud_o);
			vif.txd = xtn.txd[6];
			repeat(16)
			@(posedge vif.baud_o);
			vif.txd = xtn.txd[7];
			repeat(16)
			@(posedge vif.baud_o);
		       end
	endcase

	if(lcr[3])
	begin
		vif.txd = ^(xtn.txd);
		repeat(16)
		@(posedge vif.baud_o);
	end

	vif.txd = 1'b1;
	repeat(16)
	@(posedge vif.baud_o);

	`uvm_info("UART_DRIVER","Printing from UART Driver",UVM_LOW)
	xtn.print();
endtask
