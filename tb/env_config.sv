class env_config extends uvm_object;
	`uvm_object_utils(env_config)

	//Members
	bit has_functional_coverage = 1;
	bit has_scoreboard = 1;

	bit has_apb_agt = 1;
	bit has_uart_agt = 1;

	apb_agt_config m_apb_cfg[];
	uart_agt_config m_uart_cfg[];

	//Methods
	extern function new(string name = "env_config");
endclass

//Constructor New
function env_config::new(string name = "env_config");
  super.new(name);
endfunction

