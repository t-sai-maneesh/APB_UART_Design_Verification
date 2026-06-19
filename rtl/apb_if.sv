interface apb_if(input bit pclk);
	logic [7:0] prdata;
	logic pready;
	logic pslverr;
	logic irq;

	logic presetn;
	logic [7:0] paddr;
	logic [7:0] pwdata;
	logic pwrite;
	logic penable;
	logic psel;

	clocking apb_drv_cb @(posedge pclk);
		default input #1 output #1;
		output presetn;
		output paddr;
		output pwdata;
		output pwrite;
		output penable;
		output psel;
		input pready;
		input prdata;
		input irq;
	endclocking

	clocking apb_mon_cb @(posedge pclk);
		default input #1 output #1;
		input presetn;
		input paddr;
		input pwdata;
		input pwrite;
		input penable;
		input psel;
		input prdata;
		input pready;	
		input pslverr;
		input irq;
	endclocking

	modport APB_DRV_MP(clocking apb_drv_cb);
	modport APB_MON_MP(clocking apb_mon_cb);
endinterface
