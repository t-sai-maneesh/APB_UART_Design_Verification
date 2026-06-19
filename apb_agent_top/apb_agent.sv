class apb_agent extends uvm_agent;

	`uvm_component_utils(apb_agent)

	//handle for apb config db
	apb_agt_config m_cfg;

	//handles of seqr,drv,mon
	apb_seqr apb_seqrh;
	apb_driver apb_drvh;
	apb_monitor apb_monh;

	//methods
	extern function new(string name = "apb_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass

//Constructor new
function apb_agent::new(string name = "apb_agent",uvm_component parent);
	super.new(name, parent);
endfunction

//Build Phase
function void apb_agent::build_phase(uvm_phase phase);
	if(!uvm_config_db #(apb_agt_config)::get(this,"","apb_agt_config",m_cfg))
		`uvm_fatal("APB_AGENT","Cannot get the m_cfg, Have you set")

	apb_monh = apb_monitor::type_id::create("apb_monh",this);

	if(m_cfg.is_active == UVM_ACTIVE)
	begin
		apb_seqrh = apb_seqr::type_id::create("apb_seqrh",this);
		apb_drvh  = apb_driver::type_id::create("apb_drvh",this);
	end
endfunction

//Connect_phase
function void apb_agent::connect_phase(uvm_phase phase);
	if(m_cfg==null)
		`uvm_fatal("apb_agent","m_cfg is null in connect phase")

	`uvm_info("apb_agent",$sformatf("is_active=%0d",m_cfg.is_active),UVM_LOW)	

	if(m_cfg.is_active == UVM_ACTIVE)
	begin
		apb_drvh.seq_item_port.connect(apb_seqrh.seq_item_export);
		`uvm_info("APB_AGENT","Connected",UVM_LOW)
	end
endfunction
