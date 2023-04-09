# chisel-template

这时一个简单的chisel的框架，可以添加verilog，sysverilog。并使用verilator进行测试。

# chisel part
在./src/scala下文件，在运行makefile时会运行```sbt "run MainDriver -X verilog -td output -o emu_top.v"```，这时会将chisel代码编译成verilog代码置emu_top.v中。

# verilator part
使用```make -nb```查看。
```
verilator --cc --exe --top-module top \
  -o emulator -Mdir output \
  --prefix emu output/emu_top.v src/sysverilog/floatadd.sv src/verilog/top.v emu/main.cpp 
cd output && make -s -f emu.mk
```
* --cc 表示生成一个C++的输出
* --exe 最后生成一个可执行文件
* --top-module top 指定生成的top模块
* -o 目标输出
* -Mdir 中间文件的输出路径
* --prefix 指定输出的top模块转化为C++类的名字

## +trace
在新版的verilator中，可以支持生成gtk波形图。需要生成gtk的波形图需要在.v文件中添加
```
  if ($test$plusargs("trace") != 0)  begin
      $display("[%0t] Tracing to logs/vlt_dump.vcd...\n", $time);
      $dumpfile("logs/vlt_dump.vcd");
      $dumpvars();
  end
```
并在C文件中添加全局变量
```
vluint64_t main_time = 0; // Current simulation time
double sc_time_stamp()
{                   // Called by $time in Verilog
  return main_time; // converts to double, to match
                    // what SystemC does
}
```
并在程序开始时初始化
```
Verilated::commandArgs(argc, argv);
#ifdef __TRACE__
  Verilated::traceEverOn(true);
  Verilated::mkdir("logs");
#endif
```
在编译verilator时添加```--trace -CFLAGS "-D __TRACE__" ```以表示启用--trace并将```-D __TRACE__```传入C的编译命令。

执行命令```./output/emulator +trace```来运行

然后执行```make show```来查看生成的波形。

# system verilog
使用DPI-C函数来调用C函数。

有时我们需要的verilog很难实现一个模块时，或者这个模块作为ip难以调用，我们可以借助system verilog来调用C函数模拟软件。这里我在floatadd.sv中的浮点数加法调用了fp_add函数。
```
import "DPI-C" function void fp_add(input int dataa,input int datab,output int result);
```
并在main.cpp函数中定义了C函数fp_add，每当一个时钟沿上沿到达时就调用一次这个函数来输出。
```
extern "C" {
  void fp_add(int dataa, int datab, int *result){
    float result_f = (*(float*)&dataa + *(float*)&datab);
    // printf("a:%f b:%f fpadd fc:%x\n",*(float*)&dataa,*(float*)&datab,*(uint32_t*)&result_f);
    *result = *(int *)&result_f;
  }
}
```
这样的机制可以帮助我们用软件实现一个硬件模块的黑盒。