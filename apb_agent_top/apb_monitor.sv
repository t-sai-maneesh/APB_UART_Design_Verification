class apb_monitor extends uvm_monitor;
	`uvm_component_utils(apb_monitor);

	virtual apb_if.APB_MON_MP vif;
	apb_agt_config m_cfg;

	apb_xtn xtn;

	uvm_analysis_port #(apb_xtn) monitor_port;	

	//Methods
	extern function new(string name = "apb_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
endclass

//Constructor New
function apb_monitor::new(string name = "apb_monitor", uvm_component parent);
	super.new(name,parent);
	monitor_port = new("monitor_port",this);
endfunction

//Build phase
function void apb_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(apb_agt_config)::get(this,"","apb_agt_config",m_cfg))
		`uvm_fatal("APB_MONITOR","m_cfg didn't get, Have you set")
	
	xtn = apb_xtn::type_id::create("xtn");
endfunction

//Connect_phase
function void apb_monitor::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction

//Run phase
task apb_monitor::run_phase(uvm_phase phase);
	forever
	begin
		collect_data();
	end
endtask

//Collect Data from DUT
task apb_monitor::collect_data();
	
	@(vif.apb_mon_cb);
	wait(vif.apb_mon_cb.penable === 1)
	begin
		wait(vif.apb_mon_cb.pready == 1)
		
		xtn.presetn = vif.apb_mon_cb.presetn;
		xtn.paddr   = vif.apb_mon_cb.paddr;
		xtn.pwrite  = vif.apb_mon_cb.pwrite;
		xtn.pslverr = vif.apb_mon_cb.pslverr;
		xtn.psel    = vif.apb_mon_cb.psel;
		xtn.penable = vif.apb_mon_cb.penable;
		xtn.irq     = vif.apb_mon_cb.irq;

		//for pwdata &prdata
		if(xtn.pwrite)	
			xtn.pwdata = vif.apb_mon_cb.pwdata;
		else
			begin
			wait(vif.apb_mon_cb.prdata!==0)
			xtn.prdata = vif.apb_mon_cb.prdata;
			$display("aaprrrrrrrrrrrrrrrrrraaaaaaaaaaaaaa %p",vif.apb_mon_cb.prdata);
			end

		//LCR
		if(xtn.paddr == 8'hc && xtn.pwrite == 1)
			xtn.lcr = xtn.pwdata;

		//FCR
		if(xtn.paddr == 8'h8 && xtn.pwrite == 1)
			xtn.fcr = xtn.pwdata;

		//IER
		if(xtn.paddr == 8'h4 && xtn.pwrite == 1)
			xtn.ier = xtn.pwdata;

		//IIR
		if(xtn.paddr == 8'h8 && xtn.pwrite == 0)
		begin
			wait(vif.apb_mon_cb.irq)
			xtn.iir = vif.apb_mon_cb.prdata;
		end

		//MCR
		if(xtn.paddr == 8'h10 && xtn.pwrite == 1)
			xtn.mcr = xtn.pwdata;

		//LSR
		if(xtn.paddr == 8'h14 && xtn.pwrite == 0)
			xtn.lsr = xtn.prdata;

		//DIV_LSB
		if(xtn.paddr == 8'h1c && xtn.pwrite == 1)
			xtn.divisor[7:0] = xtn.pwdata;

		//DIV_MSB
		if(xtn.paddr == 8'h20 && xtn.pwrite == 1)
			xtn.divisor[15:8] = xtn.pwdata;

		//THR
		if(xtn.paddr == 8'h0 && xtn.pwrite == 1)
			xtn.thr.push_back(xtn.pwdata);
	
		//RBR
		if(xtn.paddr == 8'h0 && xtn.pwrite == 0)
		begin
			xtn.rbr.push_back(xtn.prdata);
		$display("rrrrrrrrbbbbbbbbbbbrrrrrrrrrrrrrrrrrr %d,%p",xtn.prdata,xtn.rbr);
		end
	end
	
	`uvm_info("APB_MONITOR","Printing from APB Monitor",UVM_LOW)
	xtn.print();

	monitor_port.write(xtn);
endtask

