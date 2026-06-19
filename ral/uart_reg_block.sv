class uart_reg_block extends uvm_reg_block;
	`uvm_object_utils(uart_reg_block)
		
	lcr lcr_reg;
	fcr fcr_reg;
	ier ier_reg;
	dlr dlr_reg;
	
	uvm_reg_map apb_map;
	
	function new(string name = "uart_reg_block");
		super.new(name,build_coverage(UVM_CVR_ADDR_MAP));
	endfunction

	virtual function void build();
		lcr_reg = lcr::type_id::create("lcr");
		lcr_reg.configure(this,null,"");
		lcr_reg.build();
		lcr_reg.add_hd1_path_slice("lcr",0,7);

		fcr_reg = fcr::type_id::create("fcr");
		fcr_reg.configure(this,null,"");
		fcr_reg.build();
		fcr_reg.add_hd1_path_slice("fcr",0,8);

		ier_reg = ier::type_id::create("ier");
		ier_reg.configure(this,null,"");
		ier_reg.build();
		ier_reg.add_hd1_path_slice("ier",0,4);

		dlr_reg = dlr::type_id::create("dlr");
		dlr_reg.configure(this,null,"");
		dlr_reg.build();
		dlr_reg.add_hd1_path_slice("dlr",0,16);

		//Create Map
		apb_map = create_map("apb_map",'h0,UVM_LITTLE_ENDIAN);

		//Add Registers to Maps
		apb_map.add_reg(lcr_reg,8'h0c,"RW");
		apb_map.add_reg(fcr_reg,8'h08,"W");
		apb_map.add_reg(ier_reg,8'h04,"RW");
		apb_map.add_reg(dlr_reg,16'h201c,"RW");

		add_hd1_path("tb.top.dut1","RTL");
		lock_model();
	endfunction
endclass
		
