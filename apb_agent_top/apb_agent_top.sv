class apb_agent_top extends uvm_env;
	`uvm_component_utils(apb_agent_top)

	//handle of agent
	apb_agent apb_agnth[];
	apb_agt_config m_cfg;

	//methods
	extern function new(string name = "apb_agent_top", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
endclass

//Constructor new
function apb_agent_top::new(string name = "apb_agent_top", uvm_component parent);
	super.new(name,parent);
endfunction

//Build phase
function void apb_agent_top::build_phase(uvm_phase phase);
	if(!uvm_config_db #(apb_agt_config)::get(this,"","apb_agt_config",m_cfg))
			`uvm_fatal("APB_AGENT_TOP","Cannot get the m_cfg, Have you set")

	apb_agnth = new[m_cfg.no_of_agents];

	foreach(apb_agnth[i])
		apb_agnth[i] = apb_agent::type_id::create($sformatf("apb_agnth %0d",i),this);
endfunction

