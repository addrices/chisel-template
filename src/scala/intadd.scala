import chisel3._
import chisel3.util._
import chisel3.stage.{ChiselStage, ChiselGeneratorAnnotation}
import chisel3.iotesters.{ChiselFlatSpec, Driver, PeekPokeTester}

class intadd extends Module {
  val io = IO(new Bundle {
    val a = Input(UInt(32.W))
    val b = Input(UInt(32.W))
    val c = Output(UInt(32.W))
    val over = Output(Bool())
  })
  
  val c_r = RegInit(0.U(33.W))
  c_r := io.a + io.b
  io.over := c_r(32).asBool()
  io.c := c_r(31,0)
}

object MainDriver extends ChiselFlatSpec {
  def main(args: Array[String]): Unit = {
    (new ChiselStage).execute(
      args,
      Seq(ChiselGeneratorAnnotation(() => new intadd)))
  }
}
// Array("-X", "verilog","--target-dir", "output/")