class uart_agent_top extends uvm_env;
	`uvm_component_utils(uart_agent_top)

	//handle of agent
	uart_agent uart_agnth[];
	uart_agt_config m_cfg;

	//methods
	extern function new(string name = "uart_agent_top", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
endclass

//Constructor new
function uart_agent_top::new(string name = "uart_agent_top", uvm_component parent);
	super.new(name,parent);
endfunction

//Build phase
function void uart_agent_top::build_phase(uvm_phase phase);
	if(!uvm_config_db #(uart_agt_config)::get(this,"","uart_agt_config",m_cfg))
			`uvm_fatal("APB_AGENT_TOP","Cannot get the m_cfg, Have you set")

	uart_agnth = new[m_cfg.no_of_agents];

	foreach(uart_agnth[i])
		uart_agnth[i] = uart_agent::type_id::create($sformatf("uart_agnth %0d",i),this);
endfunction


