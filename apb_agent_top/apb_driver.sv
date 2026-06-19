class apb_driver extends uvm_driver #(apb_xtn);
	`uvm_component_utils(apb_driver);

	virtual apb_if.APB_DRV_MP vif;
	apb_agt_config m_cfg;

	extern function new(string name = "apb_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(apb_xtn xtn);
endclass

//Constructor New
function apb_driver::new(string name = "apb_driver", uvm_component parent);
	super.new(name,parent);
endfunction

//Build phase
function void apb_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(apb_agt_config)::get(this,"","apb_agt_config",m_cfg))
		`uvm_fatal("APB_DRIVER","m_cfg is not getting, have you set")
endfunction

//Connect_phase
function void apb_driver::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction

//Run phase
task apb_driver::run_phase(uvm_phase phase);
	@(vif.apb_drv_cb)
	vif.apb_drv_cb.presetn <= 1'b0;
	@(vif.apb_drv_cb)
	vif.apb_drv_cb.presetn <= 1'b1;
	forever
	begin
		seq_item_port.get_next_item(req);
		send_to_dut(req);	
		seq_item_port.item_done();
	end
endtask

//Send to DUT
task apb_driver::send_to_dut(apb_xtn xtn);
	//setup phase
//	@(vif.apb_drv_cb);
	@(vif.apb_drv_cb);

	vif.apb_drv_cb.paddr <= xtn.paddr;
	vif.apb_drv_cb.pwdata <= xtn.pwdata;
	vif.apb_drv_cb.pwrite <= xtn.pwrite;
	vif.apb_drv_cb.psel <= 1'b1;
	vif.apb_drv_cb.penable <= 1'b0;

	//access phase
	@(vif.apb_drv_cb);
	vif.apb_drv_cb.penable <= 1'b1;

	wait(vif.apb_drv_cb.pready)
	//while(vif.apb_drv_cb.pready !== 1)
    	//	@(vif.apb_drv_cb);
    
	if(xtn.paddr == 8'h08 && xtn.pwrite == 0)
	begin
		wait(vif.apb_drv_cb.irq===1)
		xtn.iir = vif.apb_drv_cb.prdata;
		seq_item_port.put_response(xtn);
	end
//	@(vif.apb_drv_cb);
	
	vif.apb_drv_cb.psel <= 1'b0;
	vif.apb_drv_cb.penable <= 1'b0;
	//vif.apb_drv_cb.pwrite <= 0;

	`uvm_info("APB_DRIVER","Printing from APB Driver",UVM_LOW)
	xtn.print();
endtask	
