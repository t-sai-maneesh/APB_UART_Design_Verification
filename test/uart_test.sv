class uart_test extends uvm_test;
	`uvm_component_utils(uart_test)

	//handles of env,config_db
	uart_env envh;
	env_config m_env_cfg;
	apb_agt_config m_apb_cfg[];
	uart_agt_config m_uart_cfg[];

	//Declare the in variables
	int has_apb_agt = 1;
	int has_uart_agt = 1;
	int no_of_agents = 1;
	int lcr = 8'b00001011;

	//methods
	extern function new(string name = "uart_test" , uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
endclass

//Constructor New
function uart_test::new(string name = "uart_test" , uvm_component parent);
	super.new(name,parent);
endfunction

//Build phase
function void uart_test::build_phase(uvm_phase phase);
	//Create instance for env config cls
	m_env_cfg = env_config::type_id::create("m_env_cfg");

	//for apb_agt
	if(has_apb_agt)
	begin
		m_env_cfg.m_apb_cfg = new[no_of_agents];
		m_apb_cfg = new[no_of_agents];
		foreach(m_apb_cfg[i])
		begin
			m_apb_cfg[i] = apb_agt_config::type_id::create($sformatf("m_apb_cfg[%0d]",i));
			m_apb_cfg[i].is_active = UVM_ACTIVE;
			if(!uvm_config_db #(virtual apb_if)::get(this,"","apb_if",m_apb_cfg[i].vif))
				`uvm_fatal("UART_TEST","vif from top didn't get, Have you set")
			m_env_cfg.m_apb_cfg = m_apb_cfg;
			m_apb_cfg[i].no_of_agents = no_of_agents;			
			uvm_config_db #(apb_agt_config)::set(this,"*","apb_agt_config",m_apb_cfg[i]);
		end		
	end

	//for uart agt
	if(has_uart_agt)
	begin
		m_env_cfg.m_uart_cfg = new[no_of_agents];
		m_uart_cfg = new[no_of_agents];
		foreach(m_uart_cfg[i])
		begin
			m_uart_cfg[i] = uart_agt_config::type_id::create($sformatf("m_uart_cfg[%0d]",i));
			m_uart_cfg[i].is_active = UVM_ACTIVE;
			if(!uvm_config_db #(virtual uart_if)::get(this,"","uart_if",m_uart_cfg[i].vif))
				`uvm_fatal("UART_TEST","vif from top didn't get, Have you set")
			m_env_cfg.m_uart_cfg = m_uart_cfg;
			m_uart_cfg[i].no_of_agents = no_of_agents;
			uvm_config_db #(uart_agt_config)::set(this,"*","uart_agt_config",m_uart_cfg[i]);
		end
	end
	
	//assign local variables to the variables in config db
	m_env_cfg.has_apb_agt = has_apb_agt;
	m_env_cfg.has_uart_agt = has_uart_agt;

	//Set the lcr
	uvm_config_db #(bit[7:0])::set(this,"*","bit[7:0]",lcr);	

	//set the env config db
	uvm_config_db #(env_config)::set(this,"*","env_config",m_env_cfg);

	//create instance for env
	envh = uart_env::type_id::create("envh",this);
endfunction

//End of Elaboration Phase
function void uart_test::end_of_elaboration_phase(uvm_phase phase);
	uvm_top.print_topology();
endfunction

/*-----------------------------------------------------------------------------------
		Test class for Half Duplex
-----------------------------------------------------------------------------------*/
class apb_hd_seqs_test extends uart_test;
	`uvm_component_utils(apb_hd_seqs_test)

	//Declare a handle for seqs
	apb_hd_seqs hd_seqs;

	//Methods
	extern function new(string name = "apb_hd_seqs_test",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//Constructor New
function apb_hd_seqs_test::new(string name = "apb_hd_seqs_test",uvm_component parent);
	super.new(name,parent);
endfunction

//Build phase
function void apb_hd_seqs_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//Run phase
task apb_hd_seqs_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	hd_seqs = apb_hd_seqs::type_id::create("hd_seqs");

	hd_seqs.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	#1000000;
	phase.drop_objection(this);
endtask

/*-----------------------------------------------------------------------------------
		Test class for Half Duplex RXD
-----------------------------------------------------------------------------------*/

class apb_hd1_seqs_test extends uart_test;
	`uvm_component_utils(apb_hd1_seqs_test)

	//Declare a handle for seqs
	apb_hd1_seqs hd1_seqs;
	apb_read read;
	uart_hd_seqs uart1;

	//Methods
	extern function new(string name = "apb_hd1_seqs_test",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//Constructor New
function apb_hd1_seqs_test::new(string name = "apb_hd1_seqs_test",uvm_component parent);
	super.new(name,parent);
endfunction

//Build phase
function void apb_hd1_seqs_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//Run phase
task apb_hd1_seqs_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	hd1_seqs = apb_hd1_seqs::type_id::create("hd1_seqs");
	read = apb_read::type_id::create("read");
	uart1 = uart_hd_seqs::type_id::create("uart1");
	
	
	hd1_seqs.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	uart1.start(envh.uart_agnt_top.uart_agnth[0].uart_seqrh);

	read.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	#1000000;

	phase.drop_objection(this);
endtask

/*-----------------------------------------------------------------------------------
		Test class for Full Duplex
-----------------------------------------------------------------------------------*/
class apb_fd_seqs_test extends uart_test;
	`uvm_component_utils(apb_fd_seqs_test)

	//Declare a handle for seqs
	apb_fd_seqs fd_seqs;
	apb_read read;
	uart_hd_seqs uart1;

	//Methods
	extern function new(string name = "apb_fd_seqs_test",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//Constructor New
function apb_fd_seqs_test::new(string name = "apb_fd_seqs_test",uvm_component parent);
	super.new(name,parent);
endfunction

//Build phase
function void apb_fd_seqs_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//Run phase
task apb_fd_seqs_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	fd_seqs = apb_fd_seqs::type_id::create("fd_seqs");
	read = apb_read::type_id::create("read");
	uart1 = uart_hd_seqs::type_id::create("uart1");

	fd_seqs.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	uart1.start(envh.uart_agnt_top.uart_agnth[0].uart_seqrh);
	read.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	#2000000;
	phase.drop_objection(this);
endtask

/*-----------------------------------------------------------------------------------
		Test class for LoopBack
-----------------------------------------------------------------------------------*/
class apb_lb_seqs_test extends uart_test;
	`uvm_component_utils(apb_lb_seqs_test)

	//Declare a handle for seqs
	apb_lb_seqs lb_seqs;
	apb_read read;


	//Methods
	extern function new(string name = "apb_lb_seqs_test",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//Constructor New
function apb_lb_seqs_test::new(string name = "apb_lb_seqs_test",uvm_component parent);
	super.new(name,parent);
endfunction

//Build phase
function void apb_lb_seqs_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//Run phase
task apb_lb_seqs_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	lb_seqs = apb_lb_seqs::type_id::create("lb_seqs");
	read = apb_read::type_id::create("read");	

//	fork
	lb_seqs.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	#100000;
	read.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	#100000;
//	join

	phase.drop_objection(this);
endtask

/*-----------------------------------------------------------------------------------
		Test class for Parity Error
-----------------------------------------------------------------------------------*/
class apb_par_seqs_test extends uart_test;
	`uvm_component_utils(apb_par_seqs_test)

	//Declare a handle for seqs
	apb_par_seqs par_seqs;
	apb_read read;
	uart_hd_seqs uart1;

	//Methods
	extern function new(string name = "apb_par_seqs_test",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//Constructor New
function apb_par_seqs_test::new(string name = "apb_par_seqs_test",uvm_component parent);
	super.new(name,parent);
endfunction

//Build phase
function void apb_par_seqs_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//Run phase
task apb_par_seqs_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	par_seqs = apb_par_seqs::type_id::create("par_seqs");
	read = apb_read::type_id::create("read");
	uart1 = uart_hd_seqs::type_id::create("uart1");

	par_seqs.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	uart1.start(envh.uart_agnt_top.uart_agnth[0].uart_seqrh);
	read.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	#1000000;
	phase.drop_objection(this);
endtask

/*-----------------------------------------------------------------------------------
		Test class for Framing Error
-----------------------------------------------------------------------------------*/
class apb_frameerr_seqs_test extends uart_test;
	`uvm_component_utils(apb_frameerr_seqs_test)

	//Declare a handle for seqs
	apb_frameerr_seqs frameerr_seqs;
	apb_read read;
	uart_hd_seqs uart1;

	//Methods
	extern function new(string name = "apb_frameerr_seqs_test",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//Constructor New
function apb_frameerr_seqs_test::new(string name = "apb_frameerr_seqs_test",uvm_component parent);
	super.new(name,parent);
endfunction

//Build phase
function void apb_frameerr_seqs_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//Run phase
task apb_frameerr_seqs_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	frameerr_seqs = apb_frameerr_seqs::type_id::create("frameerr_seqs");
	read = apb_read::type_id::create("read");
	uart1 = uart_hd_seqs::type_id::create("uart1");

	frameerr_seqs.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	uart1.start(envh.uart_agnt_top.uart_agnth[0].uart_seqrh);
	read.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	#1000000;
	phase.drop_objection(this);
endtask

/*-----------------------------------------------------------------------------------
		Test class for Break Error
-----------------------------------------------------------------------------------*/
class apb_breakerr_seqs_test extends uart_test;
	`uvm_component_utils(apb_breakerr_seqs_test)

	//Declare a handle for seqs
	apb_breakerr_seqs breakerr_seqs;
	apb_read read;
	uart_hd_seqs uart1;

	//Methods
	extern function new(string name = "apb_breakerr_seqs_test",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//Constructor New
function apb_breakerr_seqs_test::new(string name = "apb_breakerr_seqs_test",uvm_component parent);
	super.new(name,parent);
endfunction

//Build phase
function void apb_breakerr_seqs_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//Run phase
task apb_breakerr_seqs_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	breakerr_seqs = apb_breakerr_seqs::type_id::create("breakerr_seqs");
	read = apb_read::type_id::create("read");
	uart1 = uart_hd_seqs::type_id::create("uart1");

	breakerr_seqs.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	#1000000;
	//uart1.start(envh.uart_agnt_top.uart_agnth[0].uart_seqrh);
	read.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	#1000000;
	phase.drop_objection(this);
endtask

/*-----------------------------------------------------------------------------------
		Test class for Overrun Error
-----------------------------------------------------------------------------------*/
class apb_orerr_seqs_test extends uart_test;
	`uvm_component_utils(apb_orerr_seqs_test)

	//Declare a handle for seqs
	apb_orerr_seqs orerr_seqs;
	apb_read read;
	uart_hd_seqs uart1;

	//Methods
	extern function new(string name = "apb_orerr_seqs_test",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//Constructor New
function apb_orerr_seqs_test::new(string name = "apb_orerr_seqs_test",uvm_component parent);
	super.new(name,parent);
endfunction

//Build phase
function void apb_orerr_seqs_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//Run phase
task apb_orerr_seqs_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	orerr_seqs = apb_orerr_seqs::type_id::create("orerr_seqs");
	read = apb_read::type_id::create("read");
	uart1 = uart_hd_seqs::type_id::create("uart1");

	orerr_seqs.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	repeat(20)
	begin
//	orerr_seqs.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	uart1.start(envh.uart_agnt_top.uart_agnth[0].uart_seqrh);
	#1000000;
	end
	repeat(20)
	begin
	read.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	#1000000;
	end
	phase.drop_objection(this);
endtask

/*-----------------------------------------------------------------------------------
		Test class for Timeout Error
-----------------------------------------------------------------------------------*/
class apb_timeoerr_seqs_test extends uart_test;
	`uvm_component_utils(apb_timeoerr_seqs_test)

	//Declare a handle for seqs
	apb_timeoerr_seqs timeoerr_seqs;
	apb_read read;

	//Methods
	extern function new(string name = "apb_timeoerr_seqs_test",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//Constructor New
function apb_timeoerr_seqs_test::new(string name = "apb_timeoerr_seqs_test",uvm_component parent);
	super.new(name,parent);
endfunction

//Build phase
function void apb_timeoerr_seqs_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//Run phase
task apb_timeoerr_seqs_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	timeoerr_seqs = apb_timeoerr_seqs::type_id::create("timeoerr_seqs");
	read = apb_read::type_id::create("read");

	timeoerr_seqs.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	#1000000;
	//uart1.start(envh.uart_agnt_top.uart_agnth[0].uart_seqrh);
	read.start(envh.apb_agnt_top.apb_agnth[0].apb_seqrh);
	#1000000;
	phase.drop_objection(this);
endtask
