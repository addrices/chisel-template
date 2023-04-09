#include "emu.h"
#include <memory>
#include <iostream>
#include <verilated.h>
#include <cstdlib>
#include <ctime>
#include <stdint.h>

extern "C" {
  void fp_add(int dataa, int datab, int *result){
    float result_f = (*(float*)&dataa + *(float*)&datab);
    // printf("a:%f b:%f fpadd fc:%x\n",*(float*)&dataa,*(float*)&datab,*(uint32_t*)&result_f);
    *result = *(int *)&result_f;
  }
}

vluint64_t main_time = 0; // Current simulation time
double sc_time_stamp()
{                   // Called by $time in Verilog
  return main_time; // converts to double, to match
                    // what SystemC does
}


int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
#ifdef __TRACE__
  Verilated::traceEverOn(true);
  Verilated::mkdir("logs");
#endif
  auto dut = std::make_shared<emu>();
  dut->reset = 0;
  srand(time(NULL));
  for (int i = 0; i < 10; i++) {
    uint32_t a = rand();
    uint32_t b = rand();
    float fa = (float)rand() / (float)rand();
    float fb = (float)rand() / (float)rand();
    dut->add_a = a;
    dut->add_b = b;
    dut->float_a = *(int*)&fa;
    dut->float_b = *(int*)&fb;

    dut->clk = 0;
    dut->eval();

    dut->clk = 1;
    dut->eval();
    
    float fc = fa+fb;
    // printf("a:%f b:%f right:%x fpadd fc:%x\n",*(float*)&fa,*(float*)&fb,*(uint32_t*)&fc,*(uint32_t*)&dut->float_c);
    assert(dut->add_c == a+b);
    assert(*(uint32_t*)&dut->float_c == *(uint32_t*)&fc);
  }
  printf("test pass\n");
  return 0;
}
