class uart_agent extends uvm_agent;

	`uvm_component_utils(uart_agent)

	//handle for uart config db
	uart_agt_config m_cfg;

	//handles of seqr,drv,mon
	uart_seqr uart_seqrh;
	uart_driver uart_drvh;
	uart_monitor uart_monh;

	//methods
	extern function new(string name = "uart_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass

//Constructor new
function uart_agent::new(string name = "uart_agent",uvm_component parent);
	super.new(name, parent);
endfunction

//Build Phase
function void uart_agent::build_phase(uvm_phase phase);
	if(!uvm_config_db #(uart_agt_config)::get(this,"","uart_agt_config",m_cfg))
		`uvm_fatal("APB_AGENT","Cannot get the m_cfg, Have you set")

	uart_monh = uart_monitor::type_id::create("uart_monh",this);

	if(m_cfg.is_active == UVM_ACTIVE)
	begin
		uart_seqrh = uart_seqr::type_id::create("uart_seqrh",this);
		uart_drvh  = uart_driver::type_id::create("uart_drvh",this);
	end
endfunction

//Connect_phase
function void uart_agent::connect_phase(uvm_phase phase);
	
	if(m_cfg.is_active == UVM_ACTIVE)
		uart_drvh.seq_item_port.connect(uart_seqrh.seq_item_export);
endfunction
