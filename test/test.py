# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, ReadOnly, RisingEdge


async def multiply(dut, a, b):
    """Apply A and B, return the full product read back as low + high byte."""
    await FallingEdge(dut.clk)
    dut.ui_in.value = a
    dut.uio_in.value = b  # byte_sel = 0 -> low byte
    await RisingEdge(dut.clk)
    await ReadOnly()
    low = int(dut.uo_out.value)

    await FallingEdge(dut.clk)
    dut.uio_in.value = 0x80 | b  # byte_sel = 1 -> high byte
    await RisingEdge(dut.clk)
    await ReadOnly()
    high = int(dut.uo_out.value)
    return (high << 8) | low


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    assert int(dut.uo_out.value) == 0
    dut.rst_n.value = 1

    dut._log.info("Test multiplier")

    corner_cases = [(0, 0), (1, 1), (20, 30), (255, 1), (1, 127), (255, 127), (128, 64)]
    random.seed(1234)
    random_cases = [(random.randint(0, 255), random.randint(0, 127)) for _ in range(100)]

    for a, b in corner_cases + random_cases:
        result = await multiply(dut, a, b)
        assert result == a * b, f"{a} * {b}: expected {a * b}, got {result}"

    assert int(dut.uio_oe.value) == 0
