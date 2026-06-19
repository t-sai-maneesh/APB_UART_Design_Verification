class uart_env extends uvm_env;
	`uvm_component_utils(uart_env)

	//handles of agnt_tops,sb
	apb_agent_top apb_agnt_top;
	uart_agent_top uart_agnt_top;
	uart_scoreboard sbh;
	
	//env config handle
	env_config m_env_cfg;

	//methods
	extern function new(string name = "uart_env", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass

//Constructor New
function uart_env::new(string name = "uart_env", uvm_component parent);
	super.new(name,parent);
endfunction

//Build Phase
function void uart_env::build_phase(uvm_phase phase);
	if(!uvm_config_db #(env_config)::get(this,"","env_config",m_env_cfg))
		`uvm_fatal("UART_ENV","Cannot get the m_env_cfg, Have you set")
	
	//Check if apb agent is there
	if(m_env_cfg.has_apb_agt)
		apb_agnt_top = apb_agent_top::type_id::create("apb_agnt_top",this);

	//check if uart agent is there
	if(m_env_cfg.has_uart_agt)
		uart_agnt_top = uart_agent_top::type_id::create("uart_agnt_top",this);

	//check if scoreboard is there
	if(m_env_cfg.has_scoreboard)
		sbh = uart_scoreboard::type_id::create("sbh",this);
endfunction

function void uart_env::connect_phase(uvm_phase phase);
	apb_agnt_top.apb_agnth[0].apb_monh.monitor_port.connect(sbh.fifo_h_w.analysis_export);
	uart_agnt_top.uart_agnth[0].uart_monh.monitor_port.connect(sbh.fifo_h_r.analysis_export);
endfunction
