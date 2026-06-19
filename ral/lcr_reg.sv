class lcr_reg extends uvm_reg;
	`uvm_object_utils(lcr_reg)

	uvm_reg_field reserved;
	rand uvm_reg_field break_intrpt;
	rand uvm_reg_field sticky_par;
	rand uvm_reg_field odd_even_bit;
	rand uvm_reg_field par_en;
	rand uvm_reg_field stop_bit;
	rand uvm_reg_field data_bits;

	//Constructor function
	function new(string name = "lcr_reg")
		super.new(name,7,uvm_no_coverage);
	endfunction

	//Build function
	virtual function void build();
		break_intrpt = uvm_reg_field::type_id::create("break_intrpt");
		sticky_par   = uvm_reg_field::type_id::create("sticky_par");
		odd_even_bit = uvm_reg_field::type_id::create("odd_even_bit");
		par_en	     = uvm_reg_field::type_id::create("par_en");
		stop_bit     = uvm_reg_field::type_id::create("stop_bit");
		data_bits    = uvm_reg_field::type_id::create("data_bits");

		break_intrpt.configure(this,1,6,"RW",0,1'b0,1,1,0);
		sticky_par.configure(this,1,5,"RW",0,1'b0,1,1,0);
		odd_even_bit.configure(this,1,4,"RW",0,1'b0,1,1,0);
		par_en.configure(this,1,3,"RW",0,1'b0,1,1,0);
		stop_bit.configure(this,1,2,"RW",0,1'b0,1,1,0);
		data_bits.configure(this,2,0,"RW",0,2'd0,1,1,0);
	endfunction
endclass
