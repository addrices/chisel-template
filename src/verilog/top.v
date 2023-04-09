module top(
  input clk,
  input reset,
  input [31:0] add_a,
  input [31:0] add_b,
  output [31:0] add_c,
  output add_over,
  input [31:0] float_a,
  input [31:0] float_b,
  output [31:0] float_c
);
reg [8*8:1] aa;
initial begin
  if ($test$plusargs("trace") != 0)  begin
      $display("[%0t] Tracing to logs/vlt_dump.vcd...\n", $time);
      $dumpfile("logs/vlt_dump.vcd");
      $dumpvars();
  end
  if($value$plusargs("TEST=%s", aa))
    $display("value was %s", aa);
  else 
    $display("+TEST= not found");
  $display("[%0t] Model running...\n", $time);
end

intadd add_impl(
  .clock(clk),
  .reset(reset),
  .io_a(add_a),
  .io_b(add_b),
  .io_c(add_c),
  .io_over(add_over)
);

fp_add fpadd_impl(
  .clk(clk),
  .dataa(float_a),
  .datab(float_b),
  .result(float_c)
);
endmodule