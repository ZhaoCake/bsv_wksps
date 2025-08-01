# Bluespec SystemVerilog Template Project

BSV模板项目，集成 Verilator 仿真支持

---

> 感谢wangxuan95博士的编译脚本封装，该封装是非常优秀的。[BSV_Tutorial_cn](https://github.com/WangXuan95/BSV_Tutorial_cn)

## 项目结构

```
bsv_wksps/
├── flake.nix           # Nix 开发环境配置
├── Makefile           # 构建系统
├── bsvbuild.sh        # BSV 编译脚本
├── bsv_src/           # BSV 源文件目录
│   ├── Counter.bsv    # 示例计数器模块
│   └── Tb.bsv         # 测试台
├── verilator_src/     # Verilator C++ 仿真文件
│   └── main.cpp       # 仿真主程序
├── waves/             # 波形文件输出目录（自动生成）
└── obj_dir/           # Verilator 构建目录（自动生成）
```

## 快速开始

1. **进入开发环境**
   ```bash
   nix develop
   ```

2. **编译 BSV 到 Verilog**
   ```bash
   make bsv-compile
   ```

3. **运行 Verilator 仿真**
   ```bash
   make verilator-sim
   ```

4. **查看波形**
   ```bash
   make wave
   ```

## 可用命令

- `make help` - 显示帮助信息
- `make bsv-compile` - 将 BSV 编译为 Verilog
- `make bsv-sim` - 运行 BSV 仿真（使用 bsvbuild.sh）
- `make verilator-build` - 构建 Verilator 仿真
- `make verilator-sim` - 运行 Verilator 仿真
- `make wave` - 打开波形查看器 (GTKWave)
- `make clean` - 清理生成的文件
- `make status` - 显示项目状态

## bsvbuild.sh 使用说明


**bsvbuild.sh** 的命令格式如下：

```bash
bsvbuild.sh -<param> [<top_module>] [<top_file_name>] [<log_file_name>] [<sim_time>]
```

其中：

-  `<top_module>` 是仿真顶层模块名，如果省略，默认为 `mkTb`
- `<top_file_name>` 是仿真顶层模块所在的文件名，如果省略，默认为 `Tb.bsv`
- `<log_file_name>` 是仿真打印（如果有仿真打印的话）的输出文件名，如果省略，则默认打印到 stdout（屏幕）
- `<sim_time>` 是 BSV 仿真的限制时间（单位：时钟周期），必须是一个正整数。如果省略，则为无穷（只在遇到 `$finish;` 时结束仿真）


​			**表**：**bsvbuild.sh** 的编译参数 `<param>` 的取值及其含义。

| \<param\> |   生成Verilog？    | 仿真方式 |     仿真打印？     | 生成仿真波形(.vcd)？ |
| :-------: | :----------------: | :------: | :----------------: | :------------------: |
|    -bs    |                    |   BSV    | :heavy_check_mark: |                      |
|    -bw    |                    |   BSV    |                    |  :heavy_check_mark:  |
|   -bsw    |                    |   BSV    | :heavy_check_mark: |  :heavy_check_mark:  |
|    -v     | :heavy_check_mark: |    -     |                    |                      |
|    -vs    | :heavy_check_mark: | Verilog  | :heavy_check_mark: |                      |
|    -vw    | :heavy_check_mark: | Verilog  |                    |  :heavy_check_mark:  |
|   -vsw    | :heavy_check_mark: | Verilog  | :heavy_check_mark: |  :heavy_check_mark:  |

---

项目使用 flake.nix 进行环境复现，结合 Makefile 提供完整的 BSV 开发和 Verilator 仿真流程。

## 开发工作流

1. **编写 BSV 代码**：在 `bsv_src/` 目录下编写 BSV 模块
2. **编写仿真代码**：在 `verilator_src/` 目录下编写 C++ 仿真驱动
3. **编译和仿真**：使用 Makefile 命令进行构建和仿真
4. **波形分析**：使用 GTKWave 查看仿真波形

## 依赖工具

- **bsc** - Bluespec SystemVerilog 编译器
- **iverilog** - Icarus Verilog （bsvbuild.sh 兼容性）
- **verilator** - 高性能 Verilog 仿真器
- **gtkwave** - 波形查看器
