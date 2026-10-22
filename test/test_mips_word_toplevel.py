#!/usr/bin/env python3

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge


@cocotb.test()
async def test_pc_incrementa(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert int(dut.PC_out.value) == 0, "PC deveria ser 0 durante o reset"
    dut.reset.value = 0

    # Programa da ROM: add (0), sub (1), zeros (nop) ate o beq em 63.
    # O PC vai de 4 em 4 ate 252 (beq $t0, $t3, -6). Como $t0 = $t3 = 0,
    # o desvio e tomado: 252 + 4 + (-6 * 4) = 232.
    pc = 0
    for ciclo in range(80):
        got = int(dut.PC_out.value)
        assert got == pc, f"ciclo {ciclo}: PC esperado {pc}, obtido {got}"
        await FallingEdge(dut.clk)
        pc = 232 if pc == 252 else pc + 4
